import 'dart:io';
import 'package:beautyhup/blocs/add_story/story_event.dart';
import 'package:beautyhup/blocs/add_story/story_state.dart';
import 'package:beautyhup/data/repositories/AddStoryRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

import '../../blocs/add_story/story_bloc.dart';
import '../../widgets/VideoThumbnailWidget.dart';

class CreateStoryPage extends StatelessWidget {
  CreateStoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AddStoryRepository(),
      child: BlocProvider(
        create: (context) => StoryBloc(context.read<AddStoryRepository>()),
        child: pagestory(),
      ),
    );
  }
}

class pagestory extends StatelessWidget {
  pagestory({super.key});

  final TextEditingController textController = TextEditingController();

  Future<void> pickImages(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedImage = await picker.pickMedia();

    if (pickedImage != null) {
      context.read<StoryBloc>().add(
            AddImagesEvent([pickedImage.path]) as StoryEvent,
          );
    }
  }

  void removeImage(int index, BuildContext context) {
    context.read<StoryBloc>().add(RemoveImageEvent(index));
  }

  bool isVideoPath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.contains('video'); // في حال كانت الاستجابة تحوي كلمة video
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoryBloc, StoryState>(
      listener: (context, state) {
        if (state.status == StoryStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Story created successfully!"),
            ),
          );
        } else if (state.status == StoryStatus.failure) {
          print(
              "Error creating story: ${state.errorMessage}"); // Debugging line
          print("Current state: ${state.status}"); // Debugging line
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to create story: ${state.errorMessage}"),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create Story"),
        ),
        body: BlocListener<StoryBloc, StoryState>(
            listener: (context, state) {
              if (state.status == StoryStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Story created successfully!"),
                  ),
                );
              } else if (state.status == StoryStatus.failure) {
                print(
                    "Error creating story: ${state.errorMessage}"); // Debugging line
                print("Current state: ${state.status}"); // Debugging line
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text("Failed to create story: ${state.errorMessage}"),
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

                  BlocBuilder<StoryBloc, StoryState>(builder: (context, state) {
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
                                    final mediaPath = state.images[index];

                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: isVideoPath(mediaPath)
                                              ? VideoThumbnailWidget(
                                                  videoPath:
                                                      mediaPath) // عرض صورة الفيديو
                                              : Image.file(
                                                  File(mediaPath),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                        ),

                                        // زر الإغلاق / الحذف (X)
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
                                        ),
                                      ],
                                    );
                                  })),
                    );
                  }),

                  const SizedBox(height: 20),

                  /// Post Button
                  BlocBuilder<StoryBloc, StoryState>(builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () { 
                            print(state.images);
                          context.read<StoryBloc>().add(
                              PostSubmitted(
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
                        child: state.status == StoryStatus.loading
                            ? const CircularProgressIndicator()
                            : const Text(
                                "add Story",
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
      ),
    );
  }
}
