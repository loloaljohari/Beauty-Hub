import 'package:beautyhup/blocs/reservations/reservations_bloc.dart';
import '../core/localization/l10n/app_localizations.dart';
import '../core/utils/image_helpers.dart';
import 'package:beautyhup/blocs/reservations/reservations_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/booking_model.dart';

/// Reservation/booking card matching the Figma "Booking" tab card:
/// avatar + customer name + date/time + address + Cancel button.
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.onCancel,
  });

  final BookingModel booking;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    print(booking.image);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimens.spaceMd.r(context)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(AppDimens.postCardRadius.r(context)),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: (AppDimens.avatarSizeMedium / 2).r(context),
            backgroundColor: booking.image == '' || booking.image == null
                ? AppColors.primaryAccent
                : null,
            backgroundImage: booking.image != ''
                ? remoteImageProvider(booking.image)
                : null,
            child: Text(
              // في حال عدم وجود اسم أو صوره، نأخذ أول حرف أو حرف 'U'
              ( !booking.image.contains('http') )
                  ? booking.customerName[0].toUpperCase()
                  : '',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white),
            ),
          ),
          SizedBox(width: AppDimens.spaceSm.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.customerName,
                  style: AppTextStyles.label.copyWith(fontSize: 15.sp(context)),
                ),
                SizedBox(height: AppDimens.spaceXxs.h(context)),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14.r(context),
                        color: AppColors.textSecondaryGrey),
                    SizedBox(width: 4.w(context)),
                    Text(
                      '${booking.date}  ${booking.time}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.sp(context),
                        color: AppColors.textSecondaryGrey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimens.spaceXxs.h(context)),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14.r(context),
                        color: AppColors.textSecondaryGrey),
                    SizedBox(width: 4.w(context)),
                    Expanded(
                      child: Text(
                        booking.address,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12.sp(context),
                          color: AppColors.textSecondaryGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          BlocBuilder<ReservationsBloc, ReservationsState>(
              builder: (context, state) {
            return TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: state.actionStatus == ReservationActionStatus.loading
                  ? const CircularProgressIndicator()
                  : Text(
                      context.l10n.cancel,
                      style: TextStyle(fontSize: 13.sp(context)),
                    ),
            );
          }),
        ],
      ),
    );
  }
}
