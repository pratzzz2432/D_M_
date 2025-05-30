import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:d_m/app/common/widgets/translatable_text.dart';
import 'package:d_m/services/translation_service.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // Function to handle likes
  void _likePost(String postId, int currentLikes) {
    FirebaseFirestore.instance.collection('Posts').doc(postId).update({
      'likes': currentLikes + 1, // Increment likes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Community Posts")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching posts."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No posts available."));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final String postId = post.id;
              final String postAuthor = post['author'] ?? 'Unknown';
              final String postContent =
                  post['content'] ?? 'No content available.';
              final String? imageUrl = post['imageUrl']; // Get image URL
              final int likes = post['likes'] ?? 0; // Default likes = 0

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author Row
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/images/default_user.png',
                            ),
                          ),
                          const SizedBox(width: 10),
                          TranslatableText(
                            postAuthor,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Post Content
                      TranslatableText(postContent, style: const TextStyle(fontSize: 15)),

                      const SizedBox(height: 10),

                      // Image (if available)
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder:
                                (context, error, stackTrace) => const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      // Like Button & Like Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Like Button
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up_alt_outlined),
                                color: Colors.blue,
                                onPressed: () => _likePost(postId, likes),
                              ),
                              TranslatableText(
                                "$likes Likes",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          // Comment Button (Optional for Future)
                          IconButton(
                            icon: const Icon(Icons.comment_outlined),
                            onPressed: () {
                              // Future comment functionality
                            },
                          ),
                        ],
                      ),
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
