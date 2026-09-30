import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  bool isLoading = false;
  bool emailSent = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // =========================================================
  // SEND RESET EMAIL
  // =========================================================

  Future<void> sendResetEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage(
        'Please enter your email address',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      setState(() {
        emailSent = true;
      });

      showMessage(
        'Password reset link sent to your email 📧',
      );
    } on FirebaseAuthException catch (e) {
      String message =
          'Something went wrong';

      if (e.code == 'user-not-found') {
        message =
            'No account found with this email';
      } else if (e.code == 'invalid-email') {
        message =
            'Please enter a valid email';
      }

      showMessage(message);
    } catch (e) {
      showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =========================================================
  // SNACKBAR
  // =========================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
          ),

          child: Column(
            children: [

              const SizedBox(height: 35),

              // =================================================
              // LOCK ICON
              // =================================================

              Container(
                width: 85,
                height: 85,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),

                child: const Icon(
                  Icons.lock_outline,
                  size: 42,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // TITLE
              // =================================================

              const Text(
                'Trouble logging in?',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // =================================================
              // DESCRIPTION
              // =================================================

              Text(
                'Enter your email address and '
                'we\'ll send you a link to reset '
                'your password.',

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 35),

              // =================================================
              // EMAIL FIELD
              // =================================================

              TextField(
                controller: emailController,

                keyboardType:
                    TextInputType.emailAddress,

                decoration: InputDecoration(
                  hintText:
                      'Email address',

                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey.shade600,
                  ),

                  filled: true,

                  fillColor:
                      Colors.grey.shade100,

                  contentPadding:
                      const EdgeInsets.symmetric(
                    vertical: 17,
                    horizontal: 15,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),

                    borderSide:
                        BorderSide.none,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),

                    borderSide:
                        BorderSide.none,
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),

                    borderSide:
                        const BorderSide(
                      color: Colors.blue,
                      width: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // SEND BUTTON
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : sendResetEmail,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue,

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,

                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Send Reset Link',

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // EMAIL SENT MESSAGE
              // =================================================

              if (emailSent)
                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(15),

                  decoration: BoxDecoration(
                    color:
                        Colors.green.shade50,

                    borderRadius:
                        BorderRadius.circular(12),

                    border: Border.all(
                      color:
                          Colors.green.shade200,
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Icon(
                        Icons.check_circle,
                        color:
                            Colors.green.shade600,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Check your email inbox. '
                          'We sent you a password '
                          'reset link.',

                          style: TextStyle(
                            color:
                                Colors.green.shade800,

                            fontSize: 13,

                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 35),

              // =================================================
              // OR
              // =================================================

              Row(
                children: [

                  Expanded(
                    child: Divider(
                      color:
                          Colors.grey.shade300,
                    ),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),

                    child: Text(
                      'OR',

                      style: TextStyle(
                        color:
                            Colors.grey.shade600,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Divider(
                      color:
                          Colors.grey.shade300,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =================================================
              // CREATE NEW ACCOUNT
              // =================================================

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text(
                  'Back to Login',

                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // =================================================
              // FOOTER
              // =================================================

              Text(
                'Remember your password?',

                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 5),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text(
                  'Log in',

                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}