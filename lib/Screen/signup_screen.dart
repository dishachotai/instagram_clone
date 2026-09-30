import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    fullNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signupUser() async {
    final email = emailController.text.trim();
    final fullName = fullNameController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty ||
        fullName.isEmpty ||
        username.isEmpty ||
        password.isEmpty) {
      showMessage('Please fill all fields');
      return;
    }

    if (password.length < 6) {
      showMessage(
        'Password must be at least 6 characters',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(
        username,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'email': email,
        'fullName': fullName,
        'username': username,
        'bio': '',
        'followers': [],
        'following': [],
        'postsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showMessage(
        'Account created successfully 🎉',
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed';

      if (e.code == 'email-already-in-use') {
        message =
            'This email is already registered';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      }

      showMessage(message);
    } catch (e) {
      showMessage(
        'Something went wrong',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget inputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool password = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: password && obscurePassword,

      decoration: InputDecoration(
        hintText: hint,

        prefixIcon: Icon(
          icon,
          color: Colors.grey.shade600,
        ),

        suffixIcon: password
            ? IconButton(
                onPressed: () {
                  setState(() {
                    obscurePassword =
                        !obscurePassword;
                  });
                },
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade600,
                ),
              )
            : null,

        filled: true,
        fillColor: Colors.grey.shade100,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
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

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20,
          ),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),

            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 30,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(28),

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.08),
                    blurRadius: 25,
                    offset:
                        const Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                children: [

                  // LOGO
                  Container(
                    width: 72,
                    height: 72,

                    decoration:
                        const BoxDecoration(
                      shape: BoxShape.circle,

                      gradient:
                          LinearGradient(
                        colors: [
                          Color(0xffffc107),
                          Color(0xffff5722),
                          Color(0xffe91e63),
                          Color(0xff9c27b0),
                        ],
                        begin:
                            Alignment.bottomLeft,
                        end:
                            Alignment.topRight,
                      ),
                    ),

                    child: Container(
                      margin:
                          const EdgeInsets.all(3),

                      decoration:
                          const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),

                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 34,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Instagram',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight:
                          FontWeight.bold,
                      fontStyle:
                          FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Create your account',
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // EMAIL
                  inputBox(
                    controller:
                        emailController,
                    hint:
                        'Email address',
                    icon:
                        Icons.email_outlined,
                  ),

                  const SizedBox(height: 12),

                  // FULL NAME
                  inputBox(
                    controller:
                        fullNameController,
                    hint:
                        'Full name',
                    icon:
                        Icons.person_outline,
                  ),

                  const SizedBox(height: 12),

                  // USERNAME
                  inputBox(
                    controller:
                        usernameController,
                    hint:
                        'Username',
                    icon:
                        Icons.alternate_email,
                  ),

                  const SizedBox(height: 12),

                  // PASSWORD
                  inputBox(
                    controller:
                        passwordController,
                    hint:
                        'Password',
                    icon:
                        Icons.lock_outline,
                    password: true,
                  ),

                  const SizedBox(height: 22),

                  // SIGNUP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 54,

                    child: DecoratedBox(
                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xff405de6),
                            Color(0xff5851db),
                            Color(0xff833ab4),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),

                      child: ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : signupUser,

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.transparent,
                          shadowColor:
                              Colors.transparent,
                          disabledBackgroundColor:
                              Colors.transparent,
                          foregroundColor:
                              Colors.white,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),

                        child: isLoading
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style:
                                    TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TERMS
                  Text(
                    'By creating an account, you agree to our '
                    'Terms, Privacy Policy and Cookies Policy.',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // LOGIN CARD
                  Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),

                    decoration: BoxDecoration(
                      color:
                          Colors.grey.shade50,

                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color:
                                Colors.grey.shade700,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.pop(
                              context,
                            );
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '© Instagram Clone',
                    style: TextStyle(
                      color:
                          Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}