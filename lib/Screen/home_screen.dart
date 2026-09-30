import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'search_screen.dart';
import 'add_post_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  int currentIndex = 0;

  // ============================================================
  // LIKE / UNLIKE POST
  // ============================================================

  Future<void> toggleLike(
    String postId,
  ) async {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    try {
      final postRef =
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postId);

      final postSnapshot =
          await postRef.get();

      if (!postSnapshot.exists) {
        return;
      }

      final data =
          postSnapshot.data()
              as Map<String, dynamic>;

      final List<dynamic> likes =
          data['likes'] is List
              ? data['likes']
                  as List<dynamic>
              : [];

      // UNLIKE

      if (likes.contains(
        currentUser.uid,
      )) {
        await postRef.update({
          'likes':
              FieldValue.arrayRemove([
            currentUser.uid,
          ]),
        });
      }

      // LIKE

      else {
        await postRef.update({
          'likes':
              FieldValue.arrayUnion([
            currentUser.uid,
          ]),
        });
      }
    } catch (e) {
      debugPrint(
        'Like error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to like post: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // HOME PAGE
  // ============================================================

  Widget buildHomePage() {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor:
          Colors.white,

      appBar: AppBar(
        backgroundColor:
            Colors.white,

        foregroundColor:
            Colors.black,

        elevation: 0,

        title: const Text(
          'Instagram',

          style: TextStyle(
            fontSize: 26,
            fontWeight:
                FontWeight.bold,
            fontStyle:
                FontStyle.italic,
          ),
        ),

        actions: [

          // Notifications

          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Notifications coming soon',
                  ),
                ),
              );
            },

            icon: const Icon(
              Icons.favorite_border,
              size: 28,
            ),
          ),

          // Messages

          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Messages coming soon',
                  ),
                ),
              );
            },

            icon: const Icon(
              Icons.chat_bubble_outline,
              size: 26,
            ),
          ),
        ],
      ),

      // ========================================================
      // POSTS
      // ========================================================

      body:
          StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('posts')
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
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  25,
                ),

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [

                    const Icon(
                      Icons.error_outline,
                      size: 65,
                      color: Colors.grey,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      'Unable to load posts',

                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      '${snapshot.error}',

                      textAlign:
                          TextAlign.center,

                      style:
                          TextStyle(
                        color: Colors
                            .grey
                            .shade600,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },

                      child:
                          const Text(
                        'Retry',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final posts =
              snapshot.data?.docs ??
                  [];

          // NO POSTS

          if (posts.isEmpty) {
            return _buildNoPosts();
          }

          // POSTS

          return ListView.builder(
            padding:
                const EdgeInsets.only(
              bottom: 20,
            ),

            itemCount:
                posts.length,

            itemBuilder:
                (context, index) {

              final post =
                  posts[index].data()
                      as Map<String,
                          dynamic>;

              final postId =
                  posts[index].id;

              final username =
                  post['username']
                          ?.toString() ??
                      'user';

              final fullName =
                  post['fullName']
                          ?.toString() ??
                      '';

              final caption =
                  post['caption']
                          ?.toString() ??
                      '';

              final userId =
                  post['userId']
                          ?.toString() ??
                      '';

              final List<dynamic>
                  likes =
                  post['likes'] is List
                      ? post['likes']
                          as List<dynamic>
                      : [];

              final imageBase64 =
                  post['imageBase64']
                          ?.toString() ??
                      '';

              return buildPostCard(
                postId: postId,

                username:
                    username,

                fullName:
                    fullName,

                caption:
                    caption,

                likes:
                    likes,

                imageBase64:
                    imageBase64,

                userId:
                    userId,

                currentUserId:
                    currentUser?.uid,
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // NO POSTS
  // ============================================================

  Widget _buildNoPosts() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Container(
              width: 100,
              height: 100,

              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,

                color: Colors
                    .grey
                    .shade100,
              ),

              child: const Icon(
                Icons
                    .photo_library_outlined,
                size: 50,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'No posts yet',

              style:
                  TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Posts will appear here',

              style:
                  TextStyle(
                color: Colors
                    .grey
                    .shade600,
                fontSize: 15,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  currentIndex = 2;
                });
              },

              icon: const Icon(
                Icons
                    .add_a_photo_outlined,
              ),

              label:
                  const Text(
                'Create Post',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // POST IMAGE
  // ============================================================

  Widget buildPostImage(
    String imageBase64,
  ) {
    if (imageBase64.isEmpty) {
      return Container(
        width:
            double.infinity,

        height: 350,

        color:
            Colors.grey.shade200,

        child: const Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              Icons.image_outlined,
              size: 70,
              color: Colors.grey,
            ),

            SizedBox(
              height: 8,
            ),

            Text(
              'Post Image',

              style:
                  TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    try {
      final Uint8List bytes =
          base64Decode(
        imageBase64,
      );

      return SizedBox(
        width:
            double.infinity,

        height: 350,

        child: Image.memory(
          bytes,

          width:
              double.infinity,

          height: 350,

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

              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 70,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      );
    } catch (e) {
      return Container(
        width:
            double.infinity,

        height: 350,

        color:
            Colors.grey.shade200,

        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 70,
            color: Colors.grey,
          ),
        ),
      );
    }
  }

  // ============================================================
  // POST CARD
  // ============================================================

  Widget buildPostCard({
    required String postId,
    required String username,
    required String fullName,
    required String caption,
    required List<dynamic> likes,
    required String imageBase64,
    required String userId,
    required String? currentUserId,
  }) {

    final bool isLiked =
        currentUserId != null &&
        likes.contains(
          currentUserId,
        );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        // ======================================================
        // USER HEADER
        // ======================================================

        Padding(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 12,
            vertical: 10,
          ),

          child: Row(
            children: [

              const CircleAvatar(
                radius: 21,

                backgroundColor:
                    Color(0xffeeeeee),

                child: Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Text(
                      username.isEmpty
                          ? 'user'
                          : '@$username',

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    if (fullName
                        .isNotEmpty)
                      Text(
                        fullName,

                        style:
                            TextStyle(
                          fontSize: 12,
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                  ScaffoldMessenger
                      .of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'More options coming soon',
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.more_vert,
                ),
              ),
            ],
          ),
        ),

        // ======================================================
        // REAL POST IMAGE
        // ======================================================

        buildPostImage(
          imageBase64,
        ),

        // ======================================================
        // ACTION BUTTONS
        // ======================================================

        Padding(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 8,
            vertical: 4,
          ),

          child: Row(
            children: [

              // LIKE

              IconButton(
                onPressed: () async {
                  await toggleLike(
                    postId,
                  );
                },

                icon: Icon(
                  isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,

                  size: 28,

                  color: isLiked
                      ? Colors.red
                      : Colors.black,
                ),
              ),

              // COMMENT

              IconButton(
                onPressed: () {
                  ScaffoldMessenger
                      .of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Comments coming soon 💬',
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons
                      .chat_bubble_outline,
                  size: 26,
                ),
              ),

              // SHARE

              IconButton(
                onPressed: () {
                  ScaffoldMessenger
                      .of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Share feature coming soon',
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.send_outlined,
                  size: 26,
                ),
              ),

              const Spacer(),

              // SAVE

              IconButton(
                onPressed: () {
                  ScaffoldMessenger
                      .of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Save feature coming soon',
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.bookmark_border,
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        // ======================================================
        // LIKE COUNT
        // ======================================================

        Padding(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 14,
          ),

          child: Text(
            '${likes.length} likes',

            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        // ======================================================
        // CAPTION
        // ======================================================

        if (caption.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 14,
            ),

            child: RichText(
              text: TextSpan(
                style:
                    const TextStyle(
                  color: Colors.black,
                ),

                children: [

                  TextSpan(
                    text:
                        '$username ',

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  TextSpan(
                    text:
                        caption,
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(
          height: 18,
        ),

        const Divider(
          height: 1,
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH PAGE
  // ============================================================

  Widget buildSearchPage() {
    return const SearchScreen();
  }

  // ============================================================
  // REELS PAGE
  // ============================================================

  Widget buildReelsPage() {
    return Scaffold(
      backgroundColor:
          Colors.black,

      appBar: AppBar(
        backgroundColor:
            Colors.black,

        foregroundColor:
            Colors.white,

        elevation: 0,

        title: const Text(
          'Reels',

          style:
              TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              Icons
                  .video_library_outlined,
              color: Colors.white,
              size: 70,
            ),

            SizedBox(
              height: 15,
            ),

            Text(
              'Reels Coming Soon',

              style:
                  TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 8,
            ),

            Text(
              'Short videos will appear here',

              style:
                  TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE PAGE
  // ============================================================

  Widget buildProfilePage() {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please login first',

            style:
                TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    return StreamBuilder<
        DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .snapshots(),

      builder:
          (context, snapshot) {

        if (snapshot
                .connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error: ${snapshot.error}',

                textAlign:
                    TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData ||
            !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Profile not found',

                style:
                    TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          );
        }

        final data =
            snapshot.data!.data()
                as Map<String,
                    dynamic>;

        final username =
            data['username']
                    ?.toString() ??
                '';

        final fullName =
            data['fullName']
                    ?.toString() ??
                '';

        final email =
            data['email']
                    ?.toString() ??
                currentUser.email ??
                '';

        return ProfileScreen(
          userId:
              currentUser.uid,

          username:
              username,

          fullName:
              fullName,

          email:
              email,
        );
      },
    );
  }

  // ============================================================
  // ADD POST PAGE
  // ============================================================

  Widget buildAddPostPage() {
    return AddPostScreen(
      onPostCreated: () {
        setState(() {
          currentIndex = 0;
        });
      },
    );
  }

  // ============================================================
  // CURRENT PAGE
  // ============================================================

  Widget getCurrentPage() {
    switch (currentIndex) {

      case 0:
        return buildHomePage();

      case 1:
        return buildSearchPage();

      case 2:
        return buildAddPostPage();

      case 3:
        return buildReelsPage();

      case 4:
        return buildProfilePage();

      default:
        return buildHomePage();
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
      body:
          getCurrentPage(),

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex:
            currentIndex,

        type:
            BottomNavigationBarType
                .fixed,

        selectedItemColor:
            Colors.black,

        unselectedItemColor:
            Colors.grey,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),

            activeIcon: Icon(
              Icons.home,
            ),

            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.search_outlined,
            ),

            activeIcon: Icon(
              Icons.search,
            ),

            label: 'Search',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_box_outlined,
            ),

            activeIcon: Icon(
              Icons.add_box,
            ),

            label: 'Add',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons
                  .video_library_outlined,
            ),

            activeIcon: Icon(
              Icons.video_library,
            ),

            label: 'Reels',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),

            activeIcon: Icon(
              Icons.person,
            ),

            label: 'Profile',
          ),
        ],
      ),
    );
  }
}