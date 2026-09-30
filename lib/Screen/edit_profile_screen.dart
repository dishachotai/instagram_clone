import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final String currentFullName;
  final String currentUsername;
  final String currentBio;

  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.currentFullName,
    required this.currentUsername,
    required this.currentBio,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  late TextEditingController fullNameController;
  late TextEditingController usernameController;
  late TextEditingController bioController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    fullNameController =
        TextEditingController(
      text: widget.currentFullName,
    );

    usernameController =
        TextEditingController(
      text: widget.currentUsername,
    );

    bioController =
        TextEditingController(
      text: widget.currentBio,
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    final fullName =
        fullNameController.text.trim();

    final username =
        usernameController.text.trim();

    final bio =
        bioController.text.trim();

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your full name',
          ),
        ),
      );
      return;
    }

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your username',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // update firestore user document with new data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set(
        {
          'fullName': fullName,
          'username': username,
          'bio': bio,
        },

        SetOptions(
          merge: true,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully ✅',
          ),
        ),
      );
      
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        title: const Text(
          'Edit Profile',

          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          TextButton(
            onPressed:
                isSaving ? null : saveProfile,

            child: const Text(
              'Save',

              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor:
                  Color(0xffeadcff),

              child: Icon(
                Icons.person,
                size: 55,
                color: Color(0xff5736a3),
              ),
            ),

            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Photo upload coming next 📷',
                    ),
                  ),
                );
              },
              child: const Text(
                'Change Profile Photo',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),
            TextField(
              controller: fullNameController,
              textInputAction:
                  TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 15),
            TextField(
              controller: usernameController,
              textInputAction:
                  TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixText: '@ ',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: bioController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Bio',
                hintText:
                    'Write something about yourself...',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                ),
              ),
            ),
          const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    isSaving
                        ? null
                        : saveProfile,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue,
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:FontWeight.bold,
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