// ignore: file_names
import 'package:beautyhup/core/constants/app_colors.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/product_detail/product_detail_cubit.dart';
import '../../core/utils/image_helpers.dart';
import '../../widgets/state_views.dart';

/// One warehouse product, with a quantity stepper and add-to-cart.
///
/// Everything here used to be hardcoded: two Unsplash photos, the name
/// "Serum", a price of 15 and a "Book Now" button wired to nothing.
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductDetailCubit()..load(productId),
      child: const _ProductDetailsView(),
    );
  }
}

class _ProductDetailsView extends StatefulWidget {
  const _ProductDetailsView();

  @override
  State<_ProductDetailsView> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<_ProductDetailsView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<ProductDetailCubit, ProductDetailState>(
      listenWhen: (previous, current) =>
          previous.cartStatus != current.cartStatus,
      listener: (context, state) {
        if (state.cartStatus == AddToCartStatus.added) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.addedToCart)),
          );
        } else if (state.cartStatus == AddToCartStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        if (state.status == ProductDetailStatus.loading ||
            state.status == ProductDetailStatus.initial) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: LoadingState(),
          );
        }

        if (state.status == ProductDetailStatus.failure ||
            state.detail == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const BackButton(color: AppColors.textPrimary),
            ),
            body: ErrorState(message: state.errorMessage),
          );
        }

        final product = state.detail!.product;
        final images = state.images;
        final quantity = state.quantity;
        final cubit = context.read<ProductDetailCubit>();

        return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.45,
            child: Stack(
              children: [
                images.isEmpty
                    ? Container(color: AppColors.imagePlaceholder)
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (int index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            images[index],
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
                        },
                      ),
                Positioned(
                  top: 50,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.4,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (index) => buildDot(index: index),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.avatarPlaceholder,
                              backgroundImage:
                                  remoteImageProvider(product.imageUrl),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                product.salonName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: AppColors.decorativeYellow, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            state.detail!.sellerRating.toStringAsFixed(1),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isEmpty
                        ? 'No description provided.'
                        : product.description,
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.stock ?? 0} in stock',
                    style: TextStyle(
                      color: (product.stock ?? 0) > 0
                          ? AppColors.statusSuccess
                          : AppColors.statusDanger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B29),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove,
                                  color: Colors.white, size: 18),
                              onPressed: () => cubit.changeQuantity(-1),
                            ),
                            Text(
                              "$quantity",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add,
                                  color: Colors.white, size: 18),
                              onPressed: () => cubit.changeQuantity(1),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${state.unitPrice.toStringAsFixed(0)}\$',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          // "Book Now" made no sense on a warehouse
                          // product - this is a purchase, not a booking.
                          onPressed: (product.stock ?? 0) <= 0 ||
                                  state.cartStatus == AddToCartStatus.adding
                              ? null
                              : cubit.addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.decorativeYellow,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text(
                            (product.stock ?? 0) <= 0
                                ? 'Out of stock'
                                : 'Add to cart',
                            style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A1B29),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Total Price: ${state.totalPrice.toStringAsFixed(0)}\$',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
          ),
        );
      },
    );
  }

  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 20 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.decorativeYellow
            : const Color.fromARGB(255, 153, 153, 153).withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
