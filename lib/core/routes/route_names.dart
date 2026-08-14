/// Centralized route name constants for the Authentication module.
class RouteNames {
  RouteNames._();

  static const String login = '/login';
  static const String register = '/register';
  static const String verification = '/verification';
  static const String checkEmail = '/check-email';
  static const String forgotPassword = '/forgot-password';
  static const String newPassword = '/new-password';
  static const String plan = '/plan';
  static const String addPost = '/add-post';
  static const String addStory = '/add-story';
  static const String archivedMaterials = '/archived-materials';
  /// Placeholder destination for "Login as guest" / successful auth.
  /// Wire this up to your Home module's route once it exists.
  static const String home = '/home';
static const String notifications = '/notifications';
  // Basic section (post-login app shell)
  static const String mainShell = '/main'; // hosts the IndexedStack + BottomNavBar
  static const String chatDetail = '/chat-detail';
  static const String addProduct = '/add-product';
  static const String addService = '/add-service';
  static const String myCourses = '/my-courses';
  static const String cartOrders = '/cart-orders';
  static const String sellerOrders = '/seller-orders';
  static const String orderDetailBuyer = '/order-detail-buyer';
  static const String orderDetailSeller = '/order-detail-seller';

  // Menu section
  static const String materialInventory = '/material-inventory';
  static const String addMaterial = '/add-material';
  static const String jobRequests = '/job-requests';
  static const String salons = '/salons';
  static const String salonDetail = '/salon-detail';
  static const String offers = '/offers';
  static const String addDiscount = '/add-discount';
  static const String addOffer = '/add-offer';
  static const String addPackage = '/add-package';
  static const String trainingCourses = '/training-courses';
  static const String myManagedCourses = '/my-managed-courses';
  static const String availableCourses = '/available-courses';
  static const String enrollments = '/enrollments';
  static const String certificates = '/certificates';
  static const String reviews = '/reviews';
  static const String reports = '/reports';
  static const String settings = '/settings';

  // Screens added for endpoints that previously had no UI.
  /// Followers & blocked users (`/expert/followers`, `/blocked-users`).
  static const String community = '/community';

  /// Low-stock + tomorrow's material needs
  /// (`/expert/inventory/alerts`, `/inventory/smart-alert`).
  static const String inventoryAlerts = '/inventory-alerts';

  /// Stock ledger for one material
  /// (`/expert/inventory/{id}/movements`). Argument: item id [String].
  static const String stockMovements = '/stock-movements';

  /// Change password (`POST /expert/auth/change_password`).
  static const String changePassword = '/change-password';

  /// Create or edit a course (`POST /expert/courses`).
  /// Argument: course id [String] when editing, null when creating.
  static const String addCourse = '/add-course';

  /// Materials one service consumes
  /// (`/expert/services/{id}/materials`). Argument: service id [String].
  static const String serviceMaterials = '/service-materials';
}
