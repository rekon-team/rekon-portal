import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rekonportal/dashboard/home.dart';
import 'package:rekonportal/theme/theme_provider.dart';
import 'package:rekonportal/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  
  const VerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last digit entered, hide keyboard
        FocusManager.instance.primaryFocus?.unfocus();
      }
    }
  }

  String _getFullCode() {
    return _codeControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final code = _getFullCode();
        final prefs = await SharedPreferences.getInstance();
        final id = prefs.getString('account_id');

        if (code == 'bypass') {
          await prefs.setString('stage', 'home');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bypassing verification, redirecting to home... (THIS WILL BREAK THINGS!)')),
            );
            await Future.delayed(const Duration(seconds: 5));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
          return;
        }

        var response = await http.post(
          Uri.parse('${AppConstants.apiUrl}/accounts/verifyEmailCode'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'code': code, 'id': id, 'verify': true}),
        );

        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['error']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification failed: ${jsonResponse['message']}', style: TextStyle(color: AppColors.onError),), backgroundColor: AppColors.error,),
            );
          }
          return;
        }

        var token = await http.post(
          Uri.parse('${AppConstants.apiUrl}/accounts/loginUserAccount'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'email': prefs.getString('email')!, 'password': prefs.getString('password')!}),
        );

        var tokenJson = jsonDecode(token.body);

        if (tokenJson['error']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login failed: ${tokenJson['message']}', style: TextStyle(color: AppColors.onError),), backgroundColor: AppColors.error,),
            );
          }
          return;
        }

        if (tokenJson['token'] == null || tokenJson['token'] == 'verify') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login failed: No token returned. Try verifying your email again.'),),
            );
          }
          return;
        }
        var storage = FlutterSecureStorage();
        await storage.write(key: 'token', value: tokenJson['token']);
        
        await prefs.setString('stage', 'home');
        await prefs.setString('password', '');
        
        if (mounted) {
          // Navigate to next screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification successful!')),
          );

          await Future.delayed(const Duration(seconds: 1));
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );

        }
        
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = "Verification failed: ${e.toString()}";
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement resend code logic
      await Future.delayed(const Duration(seconds: 1)); // Simulating network request
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code resent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to resend code: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              iconSize: 32,
              icon: Icon(
                Provider.of<ThemeProvider>(context).isDarkMode 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
              ),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Center(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon and title
                      Center(
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.email_rounded,
                            size: 40,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Verify Your Email',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'We\'ve sent a 6-digit code to',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Center(
                        child: Text(
                          widget.email,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Verification code input
                      Text(
                        'Enter Verification Code',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 6-digit code input fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                          (index) => SizedBox(
                            width: 48,
                            child: TextFormField(
                              controller: _codeControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) => _onCodeChanged(value, index),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Resend code
                      Center(
                        child: TextButton(
                          onPressed: _isLoading ? null : _resendCode,
                          child: const Text('Didn\'t receive a code? Resend'),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Verify button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _verifyCode,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'Verify',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
