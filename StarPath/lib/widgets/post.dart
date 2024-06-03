import 'package:flutter/material.dart';
import 'package:starpath/model/PostData.dart';
import 'package:starpath/widgets/up-down_votes.dart';
import 'package:starpath/windows/comment_page.dart';
import 'package:starpath/misc/constants.dart';

class Post extends StatefulWidget {
  PostData postData;
  Post({super.key, required this.postData});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  int numComments = 0;

  @override
  Widget build(BuildContext context) {
    String user = widget.postData.id_user,
        description = widget.postData.description;

    bool hasValidImage = widget.postData.content.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: POST_BACKGROUND,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: hasValidImage
                        ? Image.network(widget.postData.content)
                        : Image.asset("assets/images/placeholder-image.jpg"),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user),
                              Text(description),
                            ],
                          ),
                        ),
                      ),
                      Votes(
                        likes: widget.postData.like,
                        dislikes: widget.postData.dislike,
                        id_post: widget.postData.id_post,
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            String postId = widget.postData.id_post;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CommentPage(postId: postId),
                              ),
                            );
                          },
                          child: const Icon(Icons.comment),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
