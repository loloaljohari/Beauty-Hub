import 'package:beautyhup/views/add_post/addPost.dart';
import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../views/add_discount/add_discount_page.dart';
import '../../views/add_material/add_material_page.dart';
import '../../views/add_offer/add_offer_page.dart';
import '../../views/add_package/add_package_page.dart';
import '../../views/add_product/add_product_page.dart';
import '../../views/add_service/add_service_page.dart';
import '../../views/archived_materials/archived_materials_page.dart';
import '../../views/available_courses/available_courses_page.dart';
import '../../views/cart_orders/cart_orders_page.dart';
import '../../views/certificates/certificates_page.dart';
import '../../views/add_course/add_course_page.dart';
import '../../views/change_password/change_password_page.dart';
import '../../views/community/community_page.dart';
import '../../views/inventory_alerts/inventory_alerts_page.dart';
import '../../views/service_materials/service_materials_page.dart';
import '../../views/stock_movements/stock_movements_page.dart';
import '../../views/chat_detail/chat_detail_page.dart';
import '../../views/chats/createstorypage.dart';
import '../../views/check_email/check_email_page.dart';
import '../../views/enrollments/enrollments_page.dart';
import '../../views/forgot_password/forgot_password_page.dart';
import '../../views/job_requests/job_requests_page.dart';
import '../../views/login/login_page.dart';
import '../../views/main_shell_page.dart';
import '../../views/material_inventory/material_inventory_page.dart';
import '../../views/my_courses/my_courses_page.dart';
import '../../views/my_managed_courses/my_managed_courses_page.dart';
import '../../views/my_store/seller_orders_page.dart';
import '../../views/new_password/new_password_page.dart';
import '../../views/notifications/notifications_page.dart';
import '../../views/offers/offers_page.dart';
import '../../views/order_detail/order_detail_page.dart';
import '../../views/plan/plan_page.dart';
import '../../views/register/register_page.dart';
import '../../views/reports/reports_page.dart';
import '../../views/reviews/reviews_page.dart';
import '../../views/salon_detail/salon_detail_page.dart';
import '../../views/salons/salons_page.dart';
import '../../views/settings/settings_page.dart';
import '../../views/training_courses/training_courses_page.dart';
import '../../views/verification/verification_page.dart';
import 'route_names.dart';

/// Central [onGenerateRoute] handler for the whole app
/// (Authentication module + post-login "Basic" module + "Menu"
/// module).
///
/// Wire this into your [MaterialApp] via:
/// ```dart
/// MaterialApp(
///   initialRoute: RouteNames.login,
///   onGenerateRoute: AppRouter.onGenerateRoute,
/// )
/// ```
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // --- Authentication module ---
      case RouteNames.login:
        return _build(const LoginPage(), settings);
      case RouteNames.register:
        return _build(const RegisterPage(), settings);
      case RouteNames.verification:
        String email = settings.arguments as String? ?? '';
        return _build(VerificationPage(email: email), settings);
      case RouteNames.checkEmail:
        return _build(const CheckEmailPage(), settings);
      case RouteNames.forgotPassword:
        return _build(const ForgotPasswordPage(), settings);
      case RouteNames.newPassword:
        final resetArgs = settings.arguments as ResetPasswordArgs?;
        return _build(NewPasswordPage(args: resetArgs), settings);
      case RouteNames.plan:
        return _build(const PlanPage(), settings);
      case RouteNames.addStory:
        return _build(CreateStoryPage(), settings);
      case RouteNames.archivedMaterials:
        return _build(const ArchivedMaterialsPage(), settings);
      // --- Basic module (post-login app shell) ---
      case RouteNames.home:
      case RouteNames.mainShell:
        return _build(const MainShellPage(), settings);

      case RouteNames.chatDetail:
        final chatId = settings.arguments as String? ?? '';
        return _build(ChatDetailPage(chatId: chatId), settings);

      case RouteNames.addProduct:
        // An id in the arguments switches the form into edit mode.
        final productId = settings.arguments as String?;
        return _build(AddProductPage(productId: productId), settings);
      case RouteNames.notifications:
        return _build(const NotificationsPage(), settings);
      case RouteNames.addService:
        return _build(const AddServicePage(), settings);

      case RouteNames.myCourses:
        return _build(const MyCoursesPage(), settings);

      case RouteNames.cartOrders:
        return _build(const CartOrdersPage(), settings);

      case RouteNames.sellerOrders:
        return _build(const SellerOrdersPage(), settings);

      case RouteNames.addPost:
        return _build(CreatePostPage(), settings);

      case RouteNames.orderDetailBuyer:
        final orderId = settings.arguments as String? ?? '';
        return _build(
          OrderDetailPage(orderId: orderId, role: OrderRole.buyerWarehouse),
          settings,
        );

      case RouteNames.orderDetailSeller:
        final orderId = settings.arguments as String? ?? '';
        return _build(
          OrderDetailPage(orderId: orderId, role: OrderRole.sellerStore),
          settings,
        );

      // --- Menu module (side drawer destinations) ---
      case RouteNames.materialInventory:
        return _build(const MaterialInventoryPage(), settings);

      case RouteNames.changePassword:
        return _build(const ChangePasswordPage(), settings);

      case RouteNames.addCourse:
        final courseId = settings.arguments as String?;
        return _build(AddCoursePage(courseId: courseId), settings);

      case RouteNames.community:
        return _build(const CommunityPage(), settings);

      case RouteNames.inventoryAlerts:
        return _build(const InventoryAlertsPage(), settings);

      case RouteNames.stockMovements:
        final itemId = settings.arguments as String? ?? '';
        return _build(StockMovementsPage(itemId: itemId), settings);

      case RouteNames.serviceMaterials:
        final serviceId = settings.arguments as String? ?? '';
        return _build(ServiceMaterialsPage(serviceId: serviceId), settings);

      case RouteNames.addMaterial:
        return _build(const AddMaterialPage(), settings);

      case RouteNames.jobRequests:
        return _build(const JobRequestsPage(), settings);

      case RouteNames.salons:
        return _build(const SalonsPage(), settings);

      case RouteNames.salonDetail:
        // Accepts either a bare id (defaults to salon) or SalonDetailArgs
        // carrying the provider type. Casting straight to String? would
        // throw on the second form.
        final salonArgs = settings.arguments;
        return _build(
          salonArgs is SalonDetailArgs
              ? SalonDetailPage(salonId: salonArgs.id, type: salonArgs.type)
              : SalonDetailPage(salonId: salonArgs as String? ?? ''),
          settings,
        );

      case RouteNames.offers:
        return _build(const OffersPage(), settings);

      case RouteNames.addDiscount:
        return _build(const AddDiscountPage(), settings);

      case RouteNames.addOffer:
        return _build(const AddOfferPage(), settings);

      case RouteNames.addPackage:
        // An id in the arguments switches the form into edit mode.
        final packageId = settings.arguments as String?;
        return _build(AddPackagePage(packageId: packageId), settings);

      case RouteNames.trainingCourses:
        return _build(const TrainingCoursesPage(), settings);

      case RouteNames.myManagedCourses:
        return _build(const MyManagedCoursesPage(), settings);

      case RouteNames.availableCourses:
        return _build(const AvailableCoursesPage(), settings);

      case RouteNames.enrollments:
        final enrollmentsCourseId = settings.arguments as String?;
        return _build(
          EnrollmentsPage(courseId: enrollmentsCourseId),
          settings,
        );

      case RouteNames.certificates:
        return _build(const CertificatesPage(), settings);

      case RouteNames.reviews:
        return _build(const ReviewsPage(), settings);

      case RouteNames.reports:
        return _build(const ReportsPage(), settings);

      case RouteNames.settings:
        return _build(const SettingsPage(), settings);

      default:
        return _build(const LoginPage(), settings);
    }
  }

  static Route<dynamic> _build(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
