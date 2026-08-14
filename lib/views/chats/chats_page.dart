import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../widgets/state_views.dart';
import '../../core/utils/image_helpers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_view/story_view.dart';
import '../../blocs/chats/chats_bloc.dart';
import '../../blocs/chats/chats_event.dart';
import '../../blocs/chats/chats_state.dart';
import '../../blocs/nav/nav_bloc.dart';
import '../../blocs/nav/nav_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/main_shell_scope.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/app_header.dart';
import '../../widgets/chat_list_item.dart';

/// Chats & Stories screen - matches Figma frame "Chats & Stories".
class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  // 1. تعريف الكنترولر هنا بدلاً من تعريفه داخل دالة build
  late final StoryController _storyController;

  @override
  void initState() {
    super.initState();
    _storyController = StoryController();
  }

  @override
  void dispose() {
    // التخلص من الكنترولر عند تدمير الودجيت
    _storyController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ChatsBloc()..add(ChatsLoaded(_storyController)),
        ),
        BlocProvider(
          create: (_) => ProfileBloc()..add(ProfileLoaded()),
        ),
      ],
      // 2. تغليف الـ View بـ BlocListener لتتبع تغيرات التنقل NavBloc
      child: BlocListener<NavBloc, NavState>(
        listenWhen: (previous, current) =>
            previous.currentIndex != current.currentIndex && current.currentIndex == 3,
        listener: (context, state) {
          // استدعاء تحديث البيانات فور كبس التاب رقم 3
          context.read<ChatsBloc>().add(ChatsLoaded(_storyController));
        },
        child: _ChatsView(storyController: _storyController),
      ),
    );
  }
}

class _ChatsView extends StatelessWidget {
  final StoryController storyController;
  const _ChatsView({required this.storyController});

  @override
  Widget build(BuildContext context) {
    // context.read<ChatsBloc>().add(ChatsLoaded(storyController));
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: AppHeader(
            chat: true,
            onMenuTap: () {
              print("STEP 1");

              final scope = MainShellScope.of(context);

              print("STEP 2");

              scope.openMenu();

              print("STEP 3");
            },
          )),
      body: BlocBuilder<ChatsBloc, ChatsState>(
        builder: (context, state) {
          if (state.status == ChatsStatus.loading ||
              state.status == ChatsStatus.initial) {
            return const SkeletonList(itemCount: 6, itemHeight: 72);
          }

          if (state.status == ChatsStatus.failure) {
            return ErrorState(
              message: state.errorMessage.isEmpty ? null : state.errorMessage,
              onRetry: () => context
                  .read<ChatsBloc>()
                  .add(ChatsLoaded(StoryController())),
            );
          }

          final chats = state.filteredChats;

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPaddingH.w(context),
              vertical: AppDimens.spaceSm.h(context),
            ),
            children: [
              _SearchField(
                onChanged: (value) =>
                    context.read<ChatsBloc>().add(ChatsSearchChanged(value)),
              ),
              SizedBox(height: AppDimens.spaceMd.h(context)),
              SizedBox(
                height: 90.h(context),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.stories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return MyStoryAvatar(
                        storyController: storyController,
                      );
                    }

                    return index==1?null:
                     StoryAvatar(story: state.stories[index - 1]);
                  },
                ),
              ),
              SizedBox(height: AppDimens.spaceMd.h(context)),
              for (final chat in chats)
                ChatListItem(
                  chat: chat,
                  onTap: () => Navigator.of(context).pushNamed(
                    RouteNames.chatDetail,
                    arguments: chat.id,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: context.l10n.searchChats,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: EdgeInsets.symmetric(
          vertical: AppDimens.spaceSm.h(context),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// My Story Avatar shown as the first item in stories list.
class MyStoryAvatar extends StatelessWidget {
  final StoryController storyController;

  const MyStoryAvatar({super.key, required this.storyController});

  @override
  Widget build(BuildContext context) {
    final size = AppDimens.avatarSizeLarge.r(context) * 0.7;

    return InkWell(
      onTap: () async {
        // 1. قراءة الـ ChatsBloc من الكونتكست الحالي قبل الانتقال
        final chatsBloc = context.read<ChatsBloc>();
        final profileBloc = context.read<ProfileBloc>();
        if (chatsBloc.state.mystory[1].isEmpty) {
          await Navigator.of(context).pushNamed(RouteNames.addStory);
          if (context.mounted) {
            context.read<ChatsBloc>().add(ChatsLoaded(storyController));
          }
        } else {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: chatsBloc),
                  BlocProvider.value(value: profileBloc),
                ],
                child: myStoryDisplayPage(
                  storyController: storyController,
                ),
              ),
            ),
          );

          if (result == true && context.mounted) {
            context.read<ChatsBloc>().add(
                  ChatsLoaded(storyController),
                );
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.only(right: AppDimens.spaceSm.w(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if (state.status == ProfileStatus.loading ||
                        state.user == null) {
                      return const CircularProgressIndicator();
                    }
                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryAccent,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        backgroundColor: AppColors.avatarPlaceholder,
                        backgroundImage:
                            remoteImageProvider(state.user!.avatarUrl),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h(context)),
            SizedBox(
              width: size,
              child: Text(
                "My Story",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.bodySmall.copyWith(fontSize: 11.sp(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class myStoryDisplayPage extends StatefulWidget {
  final StoryController storyController;

  const myStoryDisplayPage({Key? key, required this.storyController})
      : super(key: key);

  @override
  State<myStoryDisplayPage> createState() => _StoryDisplayPageState();
}

class _StoryDisplayPageState extends State<myStoryDisplayPage> {
  // 1. متغير لتتبع رقم الستوري المعروضة حالياً
  int _currentIndex = 0;

  String getHoursAgo(String? createdAtString) {
    if (createdAtString == null || createdAtString.isEmpty) {
      return 'الآن';
    }

    try {
      final DateTime createdAt = DateTime.parse(createdAtString).toLocal();
      final DateTime now = DateTime.now();
      final int hours = now.difference(createdAt).inHours;

      if (hours <= 0) {
        return 'منذ أقل من ساعة';
      } else if (hours == 1) {
        return 'منذ ساعة';
      } else if (hours == 2) {
        return 'منذ ساعتين';
      } else if (hours >= 3 && hours <= 10) {
        return '$hours منذ ساعات ';
      } else {
        return '$hours منذ ساعة';
      }
    } catch (e) {
      return 'الآن';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatsBloc, ChatsState>(
      listener: (context, state) {
        if (state.actionStatus == ChatsActionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.storyDeleted),
            ),
          );
          // Navigator.pop(context, true);
         
         
          // print(Navigator.of(context).canPop());
        } else if (state.actionStatus == ChatsActionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Failed to delete Story',
              ),
            ),
          );
        }
      },
      child: BlocBuilder<ChatsBloc, ChatsState>(
        builder: (context, state1) {
          if (state1.status != ChatsStatus.loaded || state1.mystory == null) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state1.mystory.isEmpty || (state1.mystory[1] as List).isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pop(context, true);
              }
            });

            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          // جلب التاريخ الخاص بالستوري المعروضة حالياً وفقاً للـ _currentIndex
          final storiesDataList = state1.mystory[0] as List;
          String? currentCreatedAt;
          String? idStory;
          if (_currentIndex < storiesDataList.length) {
            currentCreatedAt =
                storiesDataList[_currentIndex]['created_at']?.toString();
            idStory = storiesDataList[_currentIndex]['id']?.toString();
          }

          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  // 2. تحديث index عند كل تغيير للستوري
                  StoryView(
                    repeat: true,
                    storyItems: state1.mystory[1],
                    controller: widget.storyController,
                    onStoryShow: (storyItem, index) {
                      if (_currentIndex != index) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _currentIndex = index;
                            });
                          }
                        });
                      }
                    },
                  ),

                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      final user = state.user;
                      final avatarPath = user?.avatarUrl ?? '';

                      return Positioned(
                        top: 20,
                        left: 16,
                        right: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: avatarPath.isNotEmpty
                                  ? remoteImageProvider(avatarPath)
                                  : null,
                              child: avatarPath.isEmpty
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4,
                                          color: Colors.black54,
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // عرض الوقت الديناميكي للستوري المحددة
                                  Text(
                                    getHoursAgo(currentCreatedAt),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 4,
                                          color: Colors.black54,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () async{
                                await  context.read<ChatsBloc>()..add(DeleteStory(
                                      idStory!, widget.storyController));
                              // context.read<ChatsBloc>().add(ChatsLoaded(StoryController));
                                Navigator.pop(context, true);
                                }),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
