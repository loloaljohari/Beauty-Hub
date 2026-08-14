import 'package:beautyhup/core/utils/main_shell_scope.dart';
import 'package:beautyhup/views/my_store/seller_orders_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/nav/nav_bloc.dart';
import '../../blocs/nav/nav_state.dart';
import '../../blocs/reservations/reservations_bloc.dart';
import '../../blocs/reservations/reservations_event.dart';
import '../../blocs/reservations/reservations_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/app_header.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/segmented_tab_bar.dart';
import 'booking_details_page.dart';

/// Reservations screen - matches Figma frame "Reservations"
/// (977:3334). The "Products" tab placeholder is reserved for a
/// future products-booking view; only "Booking" has Figma content
/// today.
class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReservationsBloc()..add(const ReservationsLoaded()),
      child: BlocListener<NavBloc, NavState>(
        listenWhen: (previous, current) =>
            previous.currentIndex != current.currentIndex &&
            current.currentIndex == 2,
        listener: (context, state) {
          context.read<ReservationsBloc>().add(const ReservationsLoaded());
        },
        child: const _ReservationsView(),
      ),
    );
  }
}

class _ReservationsView extends StatelessWidget {
  const _ReservationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: AppHeader(
            hasUnreadNotification: true,
            rev: true,
            onMenuTap: () {
              print("STEP 1");

              final scope = MainShellScope.of(context);

              print("STEP 2");

              scope.openMenu();

              print("STEP 3");
            },
          )),
      body: BlocBuilder<ReservationsBloc, ReservationsState>(
        builder: (context, state) {
          if (state.status != ReservationsStatus.loaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPaddingH.w(context),
                ),
                child: SegmentedTabBar(
                  labels: const ['Booking', 'Products'],
                  selectedIndex: state.tabIndex,
                  onChanged: (index) => context
                      .read<ReservationsBloc>()
                      .add(ReservationsTabChanged(index)),
                ),
              ),
              SizedBox(height: AppDimens.spaceSm.h(context)),
              Expanded(
                child: state.tabIndex == 0
                    ? (state.bookings.isEmpty)
                        ? const Center(
                            child: SizedBox(
                              child: Text('there aren\'t bookings'),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimens.screenPaddingH.w(context),
                              vertical: AppDimens.spaceXs.h(context),
                            ),
                            itemCount: state.bookings.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: AppDimens.spaceSm.h(context)),
                            itemBuilder: (context, index) {
                              final booking = state.bookings[index];
                              return state.bookings[index].status == 'cancelled'
                                  ? const Center(
                                      child: SizedBox(),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        print('Booking ID: ${booking.id}');
                                     await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider(
                                              create: (_) => ReservationsBloc(),
                                              child: BookingDetailsPage(
                                                bookingId: int.parse(booking.id),
                                              ),
                                            ),
                                          ),
                                        );
                                        if (context.mounted) {
                                          context
                                              .read<ReservationsBloc>()
                                              .add(const ReservationsLoaded());
                                        }

                                      },
                                      child: BookingCard(
                                        booking: booking,
                                        onCancel: () => context
                                            .read<ReservationsBloc>()
                                            .add(ReservationCancelled(
                                                booking.id, '\' \'')),
                                      ),
                                    );
                            },
                          )
                    : const SellerOrdersPage(),
              ),
            ],
          );
        },
      ),
    );
  }
}
