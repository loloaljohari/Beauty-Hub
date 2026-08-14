import 'package:beautyhup/core/localization/l10n/app_localizations.dart';
import '../core/utils/image_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_state.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/utils/responsive.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<IconData> _icons = [
    Icons.home_outlined,
    Icons.storefront_outlined,
    Icons.calendar_today_outlined,
    Icons.chat_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
     
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenPaddingH.w(context),
      ),
      height: 70.h(context),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(55, 0, 0, 0),
            blurRadius: 5,
            offset: Offset(0, -4),
          ),
        ],
        color: AppColors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(AppDimens.cardRadiusLarge), topRight: Radius.circular(AppDimens.cardRadiusLarge)),
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / 5;
          final isRTL = Directionality.of(context) == TextDirection.rtl;
            return Stack(
              children: [
                // 1. الخلفية المتحركة (Sliding Pill)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                     left: isRTL ? null : (currentIndex * tabWidth),
                  right: isRTL ? (currentIndex * tabWidth) : null,
                  top: 0,
                  bottom: 0,
                  
                  // استخدام AnimatedOpacity لإخفاء الخلفية عند اختيار البروفايل
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: currentIndex == 4 ? 0.0 : 1.0, 
                    child: SizedBox(
                      width: tabWidth,
                      child: Center(
                        child: Container(
                          height: 47.h(context),
                          width: 77,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                AppDimens.cardRadiusLarge.r(context)),
                            color: AppColors.iconActive,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. طبقة الأيقونات والصورة الشخصية
                Row(
                  children: [
                    for (var i = 0; i < _icons.length; i++)
                      SizedBox(
                        width: tabWidth,
                        child: _NavIcon(
                          icon: _icons[i],
                          isActive: currentIndex == i,
                          onTap: () => onTap(i),
                        ),
                      ),
                    SizedBox(
                      width: tabWidth,
                      child: _ProfileAvatarTab(
                        isActive: currentIndex == 4,
                        onTap: () => onTap(4),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: SizedBox(
          height: 47.h(context),
          width: 77,
          child: Center(
            child: Icon(
              icon,
              size: 30.r(context),
              color: isActive ? AppColors.white : AppColors.iconActive,
            ),
          ),
        ),
      ),
    );
  }
}

// عاد هذا الجزء تماماً كما كان في كودك الأصلي
class _ProfileAvatarTab extends StatelessWidget {
  const _ProfileAvatarTab({required this.isActive, required this.onTap});
final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = 35.r(context);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Center( // Center تمت إضافته فقط لضمان توسيط الصورة داخل المساحة الجديدة
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            print('Profile avatar URL: ${state.user?.avatarUrl}');
            return state.user?.avatarUrl==null||state.user?.avatarUrl=="null" ?Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.avatarPlaceholder,
                border: isActive
                    ? Border.all(color: AppColors.iconActive, width: 2)
                    : null,
              ),
            )
         :Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: remoteImageProvider(state.user!.avatarUrl)!,
                  fit: BoxFit.cover,
                ),
                border: isActive
                    ? Border.all(color: AppColors.iconActive, width: 3,strokeAlign: BorderSide.strokeAlignOutside)
                    : null,
              ),
            );
          }
        ),
      ),
    );
  }
}