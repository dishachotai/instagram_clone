import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String fullName;
  final String email;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  bool isFollowing = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    checkFollowing();
  }

  // ============================================================
  // CHECK FOLLOWING
  // ============================================================

  Future<void> checkFollowing() async {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      return;
    }

    if (currentUser.uid == widget.userId) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get();

      final data = doc.data();

      final List<dynamic> followers =
          data?['followers'] ?? [];

      if (mounted) {
        setState(() {
          isFollowing =
              followers.contains(
            currentUser.uid,
          );

          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(
        'Check following error: $e',
      );

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // FOLLOW / UNFOLLOW
  // ============================================================

  Future<void> toggleFollow() async {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    if (currentUser.uid == widget.userId) {
      return;
    }

    try {
      final userRef =
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId);

      if (isFollowing) {
        await userRef.set(
          {
            'followers':
                FieldValue.arrayRemove([
              currentUser.uid,
            ]),
          },
          SetOptions(
            merge: true,
          ),
        );

        if (mounted) {
          setState(() {
            isFollowing = false;
          });
        }
      } else {
        await userRef.set(
          {
            'followers':
                FieldValue.arrayUnion([
              currentUser.uid,
            ]),
          },
          SetOptions(
            merge: true,
          ),
        );

        if (mounted) {
          setState(() {
            isFollowing = true;
          });
        }
      }
    } catch (e) {
      debugPrint(
        'Follow error: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) {
      return;
    }

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  void openEditProfile(
    String fullName,
    String username,
    String bio,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProfileScreen(
          userId: widget.userId,
          currentFullName:
              fullName,
          currentUsername:
              username,
          currentBio: bio,
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget buildProfileHeader({
    required String username,
    required String fullName,
    required String bio,
    required int posts,
    required int followers,
    required int following,
    required bool isOwnProfile,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          // ==================================================
          // TOP ROW
          // ==================================================

          Row(
            children: [

              const CircleAvatar(
                radius: 45,

                backgroundColor:
                    Color(0xffeeeeee),

                child: Icon(
                  Icons.person,
                  size: 52,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                width: 25,
              ),

              Expanded(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceEvenly,

                  children: [

                    buildCount(
                      posts.toString(),
                      'Posts',
                    ),

                    buildCount(
                      followers.toString(),
                      'Followers',
                    ),

                    buildCount(
                      following.toString(),
                      'Following',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          // ==================================================
          // FULL NAME
          // ==================================================

          Text(
            fullName,

            style:
                const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          // ==================================================
          // BIO
          // ==================================================

          if (bio.isNotEmpty)
            Text(
              bio,

              style:
                  const TextStyle(
                fontSize: 14,
                height: 1.3,
              ),
            ),

          const SizedBox(
            height: 15,
          ),

          // ==================================================
          // BUTTON
          // ==================================================

          if (isOwnProfile)

            Row(
              children: [

                Expanded(
                  child:
                      OutlinedButton(
                    onPressed: () {
                      openEditProfile(
                        fullName,
                        username,
                        bio,
                      );
                    },

                    style:
                        OutlinedButton
                            .styleFrom(
                      foregroundColor:
                          Colors.black,

                      side:
                          const BorderSide(
                        color: Colors.grey,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          8,
                        ),
                      ),
                    ),

                    child:
                        const Text(
                      'Edit Profile',

                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                SizedBox(
                  width: 48,
                  height: 40,

                  child:
                      OutlinedButton(
                    onPressed: logout,

                    style:
                        OutlinedButton
                            .styleFrom(
                      padding:
                          EdgeInsets.zero,

                      foregroundColor:
                          Colors.red,

                      side:
                          const BorderSide(
                        color: Colors.grey,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          8,
                        ),
                      ),
                    ),

                    child:
                        const Icon(
                      Icons.logout,
                      size: 20,
                    ),
                  ),
                ),
              ],
            )

          else

            SizedBox(
              width:
                  double.infinity,

              height: 40,

              child: isLoading

                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )

                  : ElevatedButton(
                      onPressed:
                          toggleFollow,

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            isFollowing
                                ? Colors
                                    .grey
                                    .shade200
                                : Colors
                                    .blue,

                        foregroundColor:
                            isFollowing
                                ? Colors.black
                                : Colors.white,

                        elevation: 0,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            8,
                          ),
                        ),
                      ),

                      child: Text(
                        isFollowing
                            ? 'Following'
                            : 'Follow',

                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // COUNT
  // ============================================================

  Widget buildCount(
    String number,
    String title,
  ) {
    return Column(
      mainAxisSize:
          MainAxisSize.min,

      children: [

        Text(
          number,

          style:
              const TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          title,

          style:
              const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SINGLE POST IMAGE
  // ============================================================

  Widget buildGridImage(
    String imageBase64,
  ) {
    if (imageBase64.isEmpty) {
      return Container(
        color:
            Colors.grey.shade200,

        child: const Center(
          child: Icon(
            Icons.image_outlined,
            color: Colors.grey,
            size: 35,
          ),
        ),
      );
    }

    try {
      final Uint8List bytes =
          base64Decode(
        imageBase64,
      );

      return Image.memory(
        bytes,

        width:
            double.infinity,

        height:
            double.infinity,

        fit:
            BoxFit.cover,

        errorBuilder:
            (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            color:
                Colors.grey.shade200,

            child:
                const Center(
              child: Icon(
                Icons
                    .broken_image_outlined,
                color: Colors.grey,
                size: 35,
              ),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        color:
            Colors.grey.shade200,

        child: const Center(
          child: Icon(
            Icons
                .broken_image_outlined,
            color: Colors.grey,
            size: 35,
          ),
        ),
      );
    }
  }

  // ============================================================
  // ACTUAL POSTS GRID
  // ============================================================

  Widget buildPostsGrid() {
    return StreamBuilder<
        QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('posts')
              .where(
                'userId',
                isEqualTo:
                    widget.userId,
              )
              .snapshots(),

      builder:
          (context, snapshot) {

        // LOADING

        if (snapshot
                .connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding:
                EdgeInsets.all(40),

            child: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        // ERROR

        if (snapshot.hasError) {
          return Padding(
            padding:
                const EdgeInsets.all(
              30,
            ),

            child: Center(
              child: Text(
                'Unable to load posts\n${snapshot.error}',

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        final posts =
            snapshot.data?.docs ??
                [];

        // NO POSTS

        if (posts.isEmpty) {
          return const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 40,
            ),

            child: Column(
              children: [

                Icon(
                  Icons
                      .camera_alt_outlined,
                  size: 45,
                  color: Colors.grey,
                ),

                SizedBox(
                  height: 10,
                ),

                Text(
                  'No Posts Yet',

                  style:
                      TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height: 5,
                ),

                Text(
                  'When you share photos, they will appear here.',

                  textAlign:
                      TextAlign.center,

                  style:
                      TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        // ACTUAL POSTS

        return GridView.builder(
          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

          padding:
              const EdgeInsets.only(
            top: 5,
          ),

          itemCount:
              posts.length,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,

            crossAxisSpacing: 2,

            mainAxisSpacing: 2,

            childAspectRatio: 1,
          ),

          itemBuilder:
              (context, index) {

            final post =
                posts[index].data()
                    as Map<String,
                        dynamic>;

            final String
                imageBase64 =
                post['imageBase64']
                        ?.toString() ??
                    '';

            return GestureDetector(
              onTap: () {
                showPostDialog(
                  imageBase64,
                  post['caption']
                          ?.toString() ??
                      '',
                );
              },

              child: buildGridImage(
                imageBase64,
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // OPEN POST
  // ============================================================

  void showPostDialog(
    String imageBase64,
    String caption,
  ) {
    if (imageBase64.isEmpty) {
      return;
    }

    try {
      final Uint8List bytes =
          base64Decode(
        imageBase64,
      );

      showDialog(
        context: context,

        builder:
            (context) {
          return Dialog(
            backgroundColor:
                Colors.black,

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [

                Image.memory(
                  bytes,

                  fit:
                      BoxFit.contain,

                  width:
                      double.infinity,

                  height: 400,
                ),

                if (caption.isNotEmpty)
                  Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(
                      12,
                    ),

                    color:
                        Colors.white,

                    child: Text(
                      caption,

                      style:
                          const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      debugPrint(
        'Open image error: $e',
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          Colors.white,

      appBar: AppBar(
        backgroundColor:
            Colors.white,

        foregroundColor:
            Colors.black,

        elevation: 0,

        title:
            StreamBuilder<
                DocumentSnapshot>(
          stream:
              FirebaseFirestore
                  .instance
                  .collection(
                    'users',
                  )
                  .doc(
                    widget.userId,
                  )
                  .snapshots(),

          builder:
              (context, snapshot) {

            if (!snapshot.hasData ||
                !snapshot
                    .data!.exists) {
              return Text(
                widget.username,
              );
            }

            final data =
                snapshot.data!
                        .data()
                    as Map<String,
                        dynamic>?;

            return Text(
              data?['username'] ??
                  widget.username,

              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            );
          },
        ),

        actions: [

          IconButton(
            onPressed: () {
              ScaffoldMessenger
                  .of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Menu coming next',
                  ),
                ),
              );
            },

            icon: const Icon(
              Icons.menu,
            ),
          ),
        ],
      ),

      body:
          StreamBuilder<
              DocumentSnapshot>(
        stream:
            FirebaseFirestore
                .instance
                .collection('users')
                .doc(widget.userId)
                .snapshots(),

        builder:
            (context, snapshot) {

          // LOADING

          if (snapshot
                  .connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // ERROR

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          // PROFILE NOT FOUND

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Profile not found',
              ),
            );
          }

          final data =
              snapshot.data!
                      .data()
                  as Map<String,
                      dynamic>?;

          final String username =
              data?['username']
                      ?.toString() ??
                  widget.username;

          final String fullName =
              data?['fullName']
                      ?.toString() ??
                  widget.fullName;

          final String bio =
              data?['bio']
                      ?.toString() ??
                  '';

          final List<dynamic> followers =
          data != null && data['followers'] is List
        ? List<dynamic>.from(data['followers'])
        : [];

      final List<dynamic> following =
      data != null && data['following'] is List
        ? List<dynamic>.from(data['following'])
        : [];

          final currentUser =
              FirebaseAuth
                  .instance
                  .currentUser;

          final bool
              isOwnProfile =
              currentUser != null &&
                  currentUser.uid ==
                      widget.userId;

          // ====================================================
          // IMPORTANT:
          // Posts count ab users.postsCount se nahi,
          // actual posts collection se aayega.
          // ====================================================

          return StreamBuilder<
              QuerySnapshot>(
            stream:
                FirebaseFirestore
                    .instance
                    .collection(
                      'posts',
                    )
                    .where(
                      'userId',
                      isEqualTo:
                          widget.userId,
                    )
                    .snapshots(),

            builder:
                (
              context,
              postSnapshot,
            ) {

              final int
                  actualPostCount =
                  postSnapshot
                          .hasData
                      ? postSnapshot
                          .data!
                          .docs
                          .length
                      : 0;

              return RefreshIndicator(
                onRefresh:
                    () async {
                  await Future
                      .delayed(
                    const Duration(
                      milliseconds:
                          500,
                    ),
                  );

                  if (mounted) {
                    setState(() {});
                  }
                },

                child:
                    SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),

                  child: Column(
                    children: [

                      // PROFILE HEADER

                      buildProfileHeader(
                        username:
                            username,

                        fullName:
                            fullName,

                        bio:
                            bio,

                        posts:
                            actualPostCount,

                        followers:
                            followers
                                .length,

                        following:
                            following
                                .length,

                        isOwnProfile:
                            isOwnProfile,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Divider(
                        height: 1,
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      const Icon(
                        Icons.grid_on,
                        size: 28,
                        color:
                            Colors.black,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // ACTUAL POSTS

                      buildPostsGrid(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}