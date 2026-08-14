import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/utils/image_helpers.dart';
import 'package:flutter/services.dart'; // من أجل النسخ للحافظة
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/reservations/reservations_bloc.dart';
import '../../blocs/reservations/reservations_event.dart';
import '../../blocs/reservations/reservations_state.dart';
import '../../core/constants/app_colors.dart';

// تأكد من استدعاء ملفات الـ Bloc والموديل الخاصة بك هنا
// import 'reservations_bloc.dart';

class BookingDetailsPage extends StatefulWidget {
  final int bookingId;

  const BookingDetailsPage({Key? key, required this.bookingId})
      : super(key: key);

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  @override
  void initState() {
    super.initState();
    // استدعاء الحدث لجلب البيانات
    context.read<ReservationsBloc>().add(GetBookingDetails(widget.bookingId));
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('تم نسخ $label بنجاح!'),
          duration: const Duration(seconds: 2)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
String _calculateDuration(String? start, String? end) {
  if (start == null ||
      end == null ||
      start.isEmpty ||
      end.isEmpty) {
    return 'غير محدد';
  }

  try {
    final startParts = start.split(':');
    final endParts = end.split(':');

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

    final endMinutes =
        int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    final difference = endMinutes - startMinutes;

    if (difference <= 0) return 'غير محدد';

    final hours = difference ~/ 60;
    final minutes = difference % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours ساعة و $minutes دقيقة';
    } else if (hours > 0) {
      return 'ساعة $hours ';
    } else {
      return '$minutes دقيقة';
    }
  } catch (e) {
    return 'غير محدد';
  }
}
  Widget _buildInfoRow(String label, String value,
      {bool isCopyable = false, String? copyLabel}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Row(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              if (isCopyable) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _copyToClipboard(value, copyLabel ?? ''),
                  child: const Icon(Icons.copy,
                      size: 16, color: AppColors.primaryAccent),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReservationsBloc, ReservationsState>(
      bloc: context.read<ReservationsBloc>(),
      listener: (context, state) {
        if (state.actionStatus == ReservationActionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
                content: Text(state.errorMessage!),
                duration: Duration(seconds: 2)),
          );
          Navigator.pop(context, true); // العودة إلى الصفحة السابقة
        } else if (state.actionStatus == ReservationActionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(context.l10n.bookingCancelError),
                duration: Duration(seconds: 2)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF7F8FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.bookingDetails,
                  style: TextStyle(color: Colors.black, fontSize: 18)),
              Text('Booking #${widget.bookingId}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        body: BlocBuilder<ReservationsBloc, ReservationsState>(
          builder: (context, state) {
            // عدّل الحالة حسب مسميات الـ State لديك
            if (state.status == ReservationsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.selectedBooking == null) {
              return Center(child: Text(context.l10n.bookingDetailsError));
            }

            final booking = state.selectedBooking!;
            final user = booking.user;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // --- قسم البروفايل ---
                  Center(
                    child: Column(
                      children: [
                        // صورة المستخدم أو أيقونة افتراضية عند الـ null
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primaryAccent,
                          child: (user!.profilePhoto != null &&
                                  user.profilePhoto!.isNotEmpty)
                              ? ClipOval(
                                  child: Image.network(
                                    // Relative storage path; without
                                    // the host prefix this always 404s.
                                    remoteImageUrl(user.profilePhoto)!,
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: AppColors.primaryAccent),
                                  ),
                                )
                              : Text(
                                  // في حال عدم وجود اسم أو صوره، نأخذ أول حرف أو حرف 'U'
                                  (user.fullName.isNotEmpty)
                                      ? user.fullName[0].toUpperCase()
                                      : 'L',
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white),
                                ),
                        ),
                        const SizedBox(height: 12),

                        // اسم المستخدم أو قيمة افتراضية
                        Text(
                          user.fullName.isNotEmpty
                              ? user.fullName
                              : 'مستخدم بدون اسم',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        // حالة الحجز
                        Chip(
                          label: Text(
                            (booking.status ?? 'pending').toUpperCase(),
                            style: TextStyle(
                              color:
                                  _getStatusColor(booking.status ?? 'pending'),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor:
                              _getStatusColor(booking.status ?? 'pending')
                                  .withOpacity(0.1),
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- معلومات الحجز ---
                  _buildSectionCard(
                    title: context.l10n.customerInformation,
                    icon: Icons.person,
                    children: [
                      _buildInfoRow(
                          'Name',
                          user.fullName.isNotEmpty
                              ? user.fullName
                              : 'غير محدد'),
                      _buildInfoRow(
                        'Phone',
                        user.phone.isNotEmpty ? user.phone : 'غير متوفر',
                        isCopyable: user.phone.isNotEmpty,
                        copyLabel: 'رقم الهاتف',
                      ),
                      _buildInfoRow(
                        'Email',
                        user.email.isNotEmpty ? user.email : 'غير متوفر',
                        isCopyable: user.email.isNotEmpty,
                        copyLabel: 'البريد الإلكتروني',
                      ),
                      _buildInfoRow('Gender', user.gender ?? 'غير محدد'),
                      _buildInfoRow(
                        'Birth Date',
                        user.birthDate != null && user.birthDate.isNotEmpty
                            ? DateFormat('d MMM yyyy')
                                .format(DateTime.parse(user.birthDate))
                            : 'غير محدد',
                      ),
                      _buildInfoRow(
                        'City',
                        user.city != null && user.city.isNotEmpty
                            ? user.city
                            : 'غير محدد',
                      ),
                    ],
                  ),
                  // --- معلومات الموعد ---
                  _buildSectionCard(
                    title: context.l10n.bookingInformation,
                    icon: Icons.calendar_month,
                    children: [
                      _buildInfoRow(
                        'Date',
                        booking.bookingDate != null &&
                                booking.bookingDate!.isNotEmpty
                            ? DateFormat('d MMM yyyy')
                                .format(DateTime.parse(booking.bookingDate!))
                            : 'غير محدد',
                      ),
                      _buildInfoRow(
                        'Start Time',
                        booking.startTime != null &&
                                booking.startTime!.isNotEmpty
                            ? booking.startTime!.substring(0, 5)
                            : 'غير محدد',
                      ),
                      _buildInfoRow(
                        'End Time',
                        booking.endTime != null && booking.endTime!.isNotEmpty
                            ? booking.endTime!.substring(0, 5)
                            : 'غير محدد',
                      ),
                      _buildInfoRow(
                        'Duration',
                        _calculateDuration(
                          booking.startTime,
                          booking.endTime,
                        ),
                      ),
                    ],
                  ),
                  // --- تفاصيل الدفع ---
                  _buildSectionCard(
                    title: context.l10n.payment,
                    icon: Icons.attach_money,
                    children: [
                      _buildInfoRow('Total', '\$${booking.totalPrice}'),
                      _buildInfoRow('Deposit', '\$${booking.depositAmount}'),
                      _buildInfoRow(
                          'Remaining', '\$${booking.remainingAmount}'),
                    ],
                  ),

                  // --- الخدمات المضافة ---
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: ExpansionTile(
                      title: Text(context.l10n.services,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      leading: const Icon(Icons.design_services,
                          color: AppColors.primaryAccent),
                      children: (booking.bookingServices == null ||
                              booking.bookingServices!.isEmpty)
                          ? [
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  context.l10n.noServicesForBooking,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic),
                                ),
                              )
                            ]
                          // Was `Text(service.toString())`, which dumped
                          // the whole raw map onto the screen. Each row
                          // is a `booking_services` record with the full
                          // `service` object nested inside it.
                          : booking.bookingServices!
                              .map((service) =>
                                  _buildServiceTile(service))
                              .toList(),
                    ),
                  ),
                  // --- الملاحظات ---
                  if (booking.notes != null && booking.notes!.isNotEmpty)
                    _buildSectionCard(
                      title: context.l10n.notes,
                      icon: Icons.notes,
                      children: [
                        Text(
                          (booking.notes != null &&
                                  booking.notes!.trim().isNotEmpty)
                              ? booking.notes!
                              : 'لا توجد ملاحظات مدونة لهذا الموعد',
                          style: TextStyle(
                            color: (booking.notes != null &&
                                    booking.notes!.trim().isNotEmpty)
                                ? Colors.black
                                : Colors.grey,
                            fontStyle: (booking.notes == null ||
                                    booking.notes!.trim().isEmpty)
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 100), // مساحة للأزرار السفلية
                ],
              ),
            );
          },
        ),

        // --- الأزرار السفلية (Approve / Cancel) ---
        bottomNavigationBar:
            BlocConsumer<ReservationsBloc, ReservationsState>(
          listenWhen: (previous, current) =>
              previous.actionStatus != current.actionStatus,
          listener: (context, state) {
            if (state.actionStatus == ReservationActionStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            } else if (state.actionStatus ==
                ReservationActionStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.bookingStatusUpdated)),
              );
            }
          },
          builder: (context, state) {
            if (state.selectedBooking == null) return const SizedBox.shrink();
            final status = state.selectedBooking!.status!.toLowerCase();

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4))
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (status == 'pending') ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<ReservationsBloc>().add(
                                ReservationCancelled(
                                    state.selectedBooking!.id.toString(),
                                    '\' \''));
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(context.l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          // POST /expert/bookings/{id}/confirm - this
                          // was an empty comment, so the button did
                          // nothing and no notification was ever sent.
                          onPressed: state.actionStatus ==
                                  ReservationActionStatus.loading
                              ? null
                              : () => context.read<ReservationsBloc>().add(
                                    ReservationConfirmed(
                                      state.selectedBooking!.id.toString(),
                                    ),
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(context.l10n.approve),
                        ),
                      ),
                    ],
                    if (status == 'confirmed') ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: state.actionStatus ==
                                  ReservationActionStatus.loading
                              ? null
                              : () => context.read<ReservationsBloc>().add(
                                    ReservationCompleted(
                                      state.selectedBooking!.id.toString(),
                                    ),
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(context.l10n.completeBooking),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// One row of `booking_services`.
///
/// The API nests the whole service record under a `service` key, next
/// to the booking-specific fields (`price_snapshot`, `duration_minutes`,
/// `employee_id`). The snapshot price is what the customer actually
/// agreed to, so it wins over the service's current price - editing a
/// service later must not rewrite an existing booking's total.
Widget _buildServiceTile(dynamic raw) {
  final row = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  final service = row['service'] is Map
      ? Map<String, dynamic>.from(row['service'] as Map)
      : <String, dynamic>{};

  final name = (service['name'] ?? 'خدمة').toString();
  final description = (service['description'] ?? '').toString();

  final price = double.tryParse('${row['price_snapshot'] ?? service['price'] ?? 0}') ?? 0;
  final minutes = int.tryParse('${row['duration_minutes'] ?? service['duration_minutes'] ?? 0}') ?? 0;

  final instructions = (service['instructions'] ?? '').toString();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        if (minutes > 0) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 14, color: AppColors.textSecondaryGrey),
              const SizedBox(width: 4),
              Text(
                '$minutes دقيقة',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryGrey,
                ),
              ),
            ],
          ),
        ],
        if (description.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryGrey,
              height: 1.4,
            ),
          ),
        ],
        if (instructions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
             const   Text(
                'Instruction',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Instructions are stored as one TEXT column with
                // newlines, not as a list.
                Text(
                  instructions,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryGrey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
        const Divider(height: 24),
      ],
    ),
  );
}