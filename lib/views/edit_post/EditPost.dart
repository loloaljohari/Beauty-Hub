import 'dart:io';
import 'package:beautyhup/blocs/profile/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../blocs/add_post/post_bloc.dart';
import '../../blocs/add_post/post_event.dart';
import '../../blocs/add_post/post_state.dart';
import '../../blocs/profile/profile_event.dart';
import '../../data/repositories/addPostRepository.dart';

class Editpost extends StatelessWidget {
  Editpost({
    super.key,
    required this.caption,
    this.id,
  });
  final String caption;
  final id;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AddPostRepository(),
      child: BlocProvider(
        create: (context) => PostBloc(context.read<AddPostRepository>()),
        child: pageEditpost(
          caption: caption,
          id: id,
        ),
      ),
    );
  }
}

class pageEditpost extends StatelessWidget {
  pageEditpost({
    super.key,
    required this.caption,
    this.id,
  });
  final String? caption;
  final id;

  Future<void> pickImages(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final List<XFile> pickedImages = await picker.pickMultiImage();

    if (pickedImages.isNotEmpty) {
      context.read<PostBloc>().add(
            AddImagesEvent(pickedImages.map((e) => e.path).toList()),
          );
    }
  }

  void removeImage(int index, BuildContext context) {
    context.read<PostBloc>().add(RemoveImageEvent(index));
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController =
        TextEditingController(text: caption);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Post"),
      ),
      body: BlocListener<PostBloc, PostState>(
          listener: (context, state) {
            if (state.status == PostStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Post created successfully!"),
                ),
              );

              Navigator.of(context).popUntil((route) => route.isFirst);
            } else if (state.status == PostStatus.failure) {
              print(
                  "Error creating post: ${state.errorMessage}"); // Debugging line
              print("Current state: ${state.status}"); // Debugging line
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Failed to create post: ${state.errorMessage}"),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              shrinkWrap: true,
              children: [
                TextField(
                  controller: textController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Write something...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<PostBloc, PostState>(builder: (context, state) {
                  return GestureDetector(
                    onTap: () => pickImages(context),
                    child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: state.images.isEmpty
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Add Images",
                                  )
                                ],
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(8),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: state.images.length,
                                itemBuilder: (context, index) {
                                  print(
                                      "Image path: ${state.images[index]}"); // Debugging line
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          File(state.images[index]),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            removeImage(index, context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              )),
                  );
                }),
                const SizedBox(height: 20),
                BlocBuilder<PostBloc, PostState>(builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<PostBloc>().add(
                              EditPostEvent(
                                id: id,
                                caption: textController.text,
                                images: state.images,
                              ),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state.status == PostStatus.loading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "Edit Post",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                })
              ],
            ),
          )),
    );
  }
}
