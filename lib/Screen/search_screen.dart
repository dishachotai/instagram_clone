import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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

        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: Column(
        children: [

          // =================================================
          // SEARCH BOX
          // =================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              5,
              12,
              12,
            ),

            child: TextField(
              controller: searchController,

              onChanged: (value) {
                setState(() {
                  searchText =
                      value.trim().toLowerCase();
                });
              },

              decoration: InputDecoration(
                hintText: 'Search users',

                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),

                suffixIcon:
                    searchText.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();

                              setState(() {
                                searchText = '';
                              });
                            },

                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                            ),
                          )
                        : null,

                filled: true,
                fillColor: Colors.grey.shade100,

                contentPadding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 10,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),

                  borderSide: BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),

                  borderSide: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          // =================================================
          // SEARCH RESULTS
          // =================================================

          Expanded(
            child: searchText.isEmpty

                // ---------------- EMPTY SEARCH ----------------
                ? const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.search,
                          size: 70,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 15),

                        Text(
                          'Search for people',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )

                // ---------------- FIRESTORE ----------------
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore
                        .instance
                        .collection('users')
                        .snapshots(),

                    builder:
                        (context, snapshot) {

                      // LOADING
                      if (snapshot.connectionState ==
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
                              20,
                            ),

                            child: Text(
                              'Error: ${snapshot.error}',
                              textAlign:
                                  TextAlign.center,
                            ),
                          ),
                        );
                      }

                      // NO DATA
                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No users found',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                            ),
                          ),
                        );
                      }

                      // =================================================
                      // FILTER USERS
                      // =================================================

                      final users =
                          snapshot.data!.docs.where(
                        (doc) {
                          final data =
                              doc.data()
                                  as Map<String, dynamic>;

                          final username =
                              (data['username'] ?? '')
                                  .toString()
                                  .toLowerCase();

                          final fullName =
                              (data['fullName'] ?? '')
                                  .toString()
                                  .toLowerCase();

                          return username.contains(
                                searchText,
                              ) ||
                              fullName.contains(
                                searchText,
                              );
                        },
                      ).toList();

                      // NO MATCH
                      if (users.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [
                              const Icon(
                                Icons.person_search,
                                size: 65,
                                color: Colors.grey,
                              ),

                              const SizedBox(height: 15),

                              const Text(
                                'No users found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'Try searching another name',
                                style: TextStyle(
                                  color:
                                      Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // =================================================
                      // USER LIST
                      // =================================================

                      return ListView.separated(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),

                        itemCount: users.length,

                        separatorBuilder:
                            (context, index) =>
                                const Divider(
                          height: 1,
                          indent: 75,
                        ),

                        itemBuilder:
                            (context, index) {

                          final data =
                              users[index].data()
                                  as Map<String, dynamic>;

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
                                  '';

                          return ListTile(
                            contentPadding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),

                            // ---------------- AVATAR ----------------

                            leading:
                                const CircleAvatar(
                              radius: 27,

                              backgroundColor:
                                  Color(0xffeeeeee),

                              child: Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 28,
                              ),
                            ),

                            // ---------------- USERNAME ----------------

                            title: Text(
                              username,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),

                            // ---------------- FULL NAME ----------------

                            subtitle: fullName.isNotEmpty
                                ? Text(
                                    fullName,
                                    style:
                                        TextStyle(
                                      color: Colors
                                          .grey
                                          .shade600,
                                    ),
                                  )
                                : Text(
                                    email,
                                    style:
                                        TextStyle(
                                      color: Colors
                                          .grey
                                          .shade600,
                                    ),
                                  ),

                            // ---------------- PROFILE ----------------

                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),

                            // ---------------- TAP ----------------

                            onTap: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ProfileScreen(
                                    username:
                                        username,

                                    fullName:
                                        fullName,

                                    email: email,

                                    userId:
                                        users[index]
                                            .id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}