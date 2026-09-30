import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends StatefulWidget {
  final VoidCallback onPostCreated;

  const AddPostScreen({
    super.key,
    required this.onPostCreated,
  });

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController captionController =
      TextEditingController();

  final ImagePicker imagePicker = ImagePicker();

  Uint8List? selectedImage;

  bool isLoading = false;

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) {
        return;
      }

      final Uint8List bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = bytes;
      });
    } catch (e) {
      showMessage('Image select nahi ho payi: $e');
    }
  }

  // ============================================================
  // COMPRESS IMAGE
  // ============================================================

  Future<String?> compressAndConvertImage(
    Uint8List bytes,
  ) async {
    try {
      final img.Image? originalImage =
          img.decodeImage(bytes);

      if (originalImage == null) {
        return null;
      }

      // Image ko maximum 800px width tak resize karenge.
      final img.Image resizedImage =
          originalImage.width > 800
              ? img.copyResize(
                  originalImage,
                  width: 800,
                )
              : originalImage;

      // JPEG compression
      final List<int> compressedBytes =
          img.encodeJpg(
        resizedImage,
        quality: 65,
      );

      // Firestore document size safe rakhne ke liye
      // image bahut badi nahi honi chahiye.
      if (compressedBytes.length > 700000) {
        showMessage(
          'Image thodi badi hai. Please smaller image select karein.',
        );

        return null;
      }

      return base64Encode(compressedBytes);
    } catch (e) {
      debugPrint(
        'Image compression error: $e',
      );

      return null;
    }
  }

  // ============================================================
  // CREATE POST
  // ============================================================

  Future<void> createPost() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please login first');
      return;
    }

    final caption =
        captionController.text.trim();

    if (caption.isEmpty) {
      showMessage(
        'Please enter a caption',
      );
      return;
    }

    if (selectedImage == null) {
      showMessage(
        'Please select an image',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ========================================================
      // COMPRESS IMAGE
      // ========================================================

      final String? imageBase64 =
          await compressAndConvertImage(
        selectedImage!,
      );

      if (imageBase64 == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        return;
      }

      // ========================================================
      // GET USER DATA
      // ========================================================

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final userData =
          userDoc.data() ?? {};

      final username =
          userData['username']
                  ?.toString() ??
              user.displayName ??
              'user';

      final fullName =
          userData['fullName']
                  ?.toString() ??
              '';

      // ========================================================
      // CREATE POST
      // ========================================================

      final postRef =
          FirebaseFirestore.instance
              .collection('posts')
              .doc();

      await postRef.set({
        'postId': postRef.id,

        'userId': user.uid,

        'username': username,

        'fullName': fullName,

        'caption': caption,

        // Likes
        'likes': [],

        // Comments
        'comments': [],

        // Image stored as compressed Base64
        'imageBase64': imageBase64,

        // Old field kept for compatibility
        'imageUrl': '',

        // Created time
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      // ========================================================
      // UPDATE POST COUNT
      // ========================================================

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'postsCount':
              FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      showMessage(
        'Post shared successfully 🎉',
      );

      captionController.clear();

      setState(() {
        selectedImage = null;
      });

      await Future.delayed(
        const Duration(
          milliseconds: 700,
        ),
      );

      if (!mounted) return;

      // Go back to Home tab
      widget.onPostCreated();
    } on FirebaseException catch (e) {
      debugPrint(
        'Firebase Error: ${e.code}',
      );

      debugPrint(
        'Firebase Message: ${e.message}',
      );

      if (mounted) {
        showMessage(
          'Firebase Error: ${e.message ?? e.code}',
        );
      }
    } catch (e) {
      debugPrint(
        'Create Post Error: $e',
      );

      if (mounted) {
        showMessage(
          'Something went wrong: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        title: const Text(
          'Create Post',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          TextButton(
            onPressed:
                isLoading
                    ? null
                    : createPost,

            child: Text(
              'Share',
              style: TextStyle(
                color: isLoading
                    ? Colors.grey
                    : Colors.blue,

                fontWeight:
                    FontWeight.bold,

                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // USER
            // ==================================================

            Row(
              children: [
                const CircleAvatar(
                  radius: 28,

                  backgroundColor:
                      Color(0xffeeeeee),

                  child: Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Text(
                    user?.displayName ??
                        user?.email ??
                        'User',

                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // IMAGE
            // ==================================================

            GestureDetector(
              onTap: pickImage,

              child: Container(
                width:
                    double.infinity,

                height: 300,

                decoration:
                    BoxDecoration(
                  color: Colors
                      .grey
                      .shade100,

                  borderRadius:
                      BorderRadius
                          .circular(
                    15,
                  ),

                  border:
                      Border.all(
                    color: Colors
                        .grey
                        .shade300,
                  ),
                ),

                child:
                    selectedImage !=
                            null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),

                            child:
                                Image.memory(
                              selectedImage!,
                              width:
                                  double.infinity,
                              height:
                                  double.infinity,
                              fit:
                                  BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [
                              Icon(
                                Icons
                                    .add_photo_alternate_outlined,
                                size: 70,
                                color: Colors
                                    .grey
                                    .shade500,
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              Text(
                                'Tap to select image',
                                style:
                                    TextStyle(
                                  color: Colors
                                      .grey
                                      .shade600,
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight
                                          .w500,
                                ),
                              ),

                              const SizedBox(
                                height: 5,
                              ),

                              Text(
                                'Choose image from gallery',
                                style:
                                    TextStyle(
                                  color: Colors
                                      .grey
                                      .shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // ==================================================
            // CHANGE IMAGE
            // ==================================================

            if (selectedImage != null)
              SizedBox(
                width:
                    double.infinity,

                child:
                    OutlinedButton
                        .icon(
                  onPressed:
                      pickImage,

                  icon: const Icon(
                    Icons
                        .photo_library_outlined,
                  ),

                  label: const Text(
                    'Change Image',
                  ),
                ),
              ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // CAPTION
            // ==================================================

            const Text(
              'Caption',

              style:
                  TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            TextField(
              controller:
                  captionController,

              maxLines: 5,

              decoration:
                  InputDecoration(
                hintText:
                    'Write a caption...',

                filled: true,

                fillColor: Colors
                    .grey
                    .shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),

                  borderSide:
                      BorderSide.none,
                ),

                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),

                  borderSide:
                      const BorderSide(
                    color: Colors.blue,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // SHARE BUTTON
            // ==================================================

            SizedBox(
              width:
                  double.infinity,

              height: 52,

              child:
                  ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : createPost,

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      Colors.blue,

                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),
                ),

                child:
                    isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,

                            child:
                                CircularProgressIndicator(
                              color:
                                  Colors.white,
                              strokeWidth:
                                  2,
                            ),
                          )
                        : const Text(
                            'Share Post',

                            style:
                                TextStyle(
                              fontSize:
                                  16,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}