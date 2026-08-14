import 'package:beautyhup/core/utils/image_helpers.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/salon_model.dart';

/// Salon/center listing card matching "Salons & Centers": image
/// placeholder + name + subtitle + city + star rating.
class SalonCard extends StatelessWidget {
  const SalonCard({super.key, required this.salon, required this.onTap});

  final SalonModel salon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(AppDimens.productCardRadius.r(context)),
      child: Container(
        
        decoration: BoxDecoration(
          
          color: AppColors.white,
          boxShadow:   [ BoxShadow(
                color: const Color.fromARGB(78, 0, 0, 0), blurRadius: 4, offset: Offset(0, 2))
          ],
          borderRadius:
              BorderRadius.circular(AppDimens.productCardRadius.r(context)),
          // border: Border.all(color: AppColors.divider),
        ),
        // padding: EdgeInsets.all(AppDimens.spaceSm.r(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
              SizedBox(
              height: 200, 
               width: 170, 
              child: Stack(
                fit: StackFit.expand,
                children: [
                  
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          AppDimens.productCardRadius.r(context)),
                      topRight: Radius.circular(
                          AppDimens.productCardRadius.r(context)),
                    ),
                    // Was `Image.asset(product.imageUrl!)`: it force-
                    // unwrapped a nullable field (crash when a product
                    // has no image) AND loaded a server path as a local
                    // asset, which can never resolve.
                    child: _productImage(salon.imageUrl),
                  ),
                  // 2. التدرج الأبيض (Gradient) في الأسفل
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80, // يحدد مدى ارتفاع التدرج الأبيض فوق الصورة
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white
                                .withOpacity(0.0), // يبدأ شفافاً من الأعلى
                            Colors.white, // ينتهي بلون أبيض نقي في الأسفل
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
           
            // AspectRatio(
            //   aspectRatio: 1.4,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: AppColors.imagePlaceholder,
            //       borderRadius: BorderRadius.circular(10),
            //       image: salon.imageUrl==null?null:
            //       DecorationImage(image: NetworkImage(salon.imageUrl!),fit: BoxFit.cover)
                  
            //     ),
            //     alignment: Alignment.center,
            //     child:salon.imageUrl!=null?null : Icon(
            //       Icons.storefront_outlined,
            //       size: 30.r(context),
            //       color: AppColors.textHint,
            //     ),
            //   ),
            // ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column    (
          crossAxisAlignment: CrossAxisAlignment.start,
          
              children:[  SizedBox(height: AppDimens.spaceXs.h(context)),
              Text(
                salon.name,
                style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
              ),
              if (salon.subtitle.isNotEmpty)
                Text(
                  salon.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.sp(context),
                    color: AppColors.textSecondaryGrey,
                  ),
                ),
              SizedBox(height: 2.h(context)),
              Row(
                children: [
                  Icon(Icons.star, size: 14.r(context), color: Colors.amber),
                  SizedBox(width: 2.w(context)),
                  Text(
                    salon.rating.toStringAsFixed(0),
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12.sp(context)),
                  ),
                  const Spacer(),
                  Text(
                    salon.city,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11.sp(context),
                      color: AppColors.textSecondaryGrey,
                    ),
                  ),])
                ],
              ),
      ),
          ],
        ),
      ),
    );
  }
}


Widget _productImage(String? path) {
  final url = remoteImageUrl(path);

  if (url == null) {
    return Container(
      color: AppColors.imagePlaceholder,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.avatarPlaceholder,
      ),
    );
  }

  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      color: AppColors.imagePlaceholder,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.avatarPlaceholder,
      ),
    ),
  );
}
