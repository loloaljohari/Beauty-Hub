/// Every expert-side path the app can call, relative to
/// `AppConfig.apiBase` (`.../api/expert`).
///
/// Transcribed one-for-one from `routes/api.php` and cross-checked
/// against the Postman collection - the two are the contract, not the
/// Flutter file names. Anything not listed here does not exist on the
/// backend for this role.
///
/// The comment on each group records the HTTP verb the backend
/// actually accepts, because several of them are deliberately unusual
/// (updates over POST so multipart survives, `POST .../update` for
/// inventory, and so on).
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ─────────────────────────────────────────────────────────
  // POST unless noted. All of these are outside the auth middleware
  // except logout/profile/update/change-password/delete.
  static const String register = 'auth/register';
  static const String verifyOtp = 'auth/verify_otp';
  static const String resendOtp = 'auth/resend_otp';
  static const String forgetPassword = 'auth/forget_password';
  static const String resetPassword = 'auth/reset_password';
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String profile = 'auth/profile'; // GET
  static const String updateProfile = 'auth/update_profile'; // POST multipart
  static const String changePassword = 'auth/change_password';
  static const String deleteAccount = 'auth/delete_account'; // DELETE

  // ── Posts ────────────────────────────────────────────────────────
  // Note the non-REST naming - this is what the backend registers.
  static const String myPosts = 'getMyPosts'; // GET (paginated)
  static const String createPost = 'createPost'; // POST multipart, media[]
  static String postDetails(Object id) => 'getPostDetails/$id'; // GET
  static String updatePost(Object id) => 'updatePost/$id'; // POST multipart
  static String deletePost(Object id) => 'deletePost/$id'; // DELETE

  // ── Stories ──────────────────────────────────────────────────────
  static const String myStories = 'getMyStories'; // GET
  static const String createStory = 'createStory'; // POST multipart, media
  static String deleteStory(Object id) => 'deleteStory/$id'; // DELETE

  // ── Services ─────────────────────────────────────────────────────
  static const String services = 'services'; // GET / POST

  /// Reference list from `service_categories`. Needs the matching route
  /// on the backend; the app degrades to a local fallback without it.
  static const String serviceCategories = 'service-categories'; // GET
  static String service(Object id) => 'services/$id'; // POST (update), DELETE
  static String serviceInstructions(Object id) => 'services/$id/instructions';
  static String serviceQuestions(Object id) => 'services/$id/questions';
  static String serviceMinBookings(Object id) => 'services/$id/min-bookings';
  static String serviceMaterials(Object id) => 'services/$id/materials';

  // ── Bookings ─────────────────────────────────────────────────────
  static const String bookings = 'bookings'; // GET (paginated)
  static String booking(Object id) => 'bookings/$id'; // GET, DELETE (cancel)

  /// Expert-side status transitions. Salons and centers already had
  /// these; the expert routes were missing entirely.
  static String confirmBooking(Object id) => 'bookings/$id/confirm'; // POST
  static String completeBooking(Object id) => 'bookings/$id/complete'; // POST

  // ── Calendar ─────────────────────────────────────────────────────
  // PUT replaces the WHOLE weekly schedule - it is not an append.
  static const String calendar = 'calendar'; // GET / PUT

  // ── Inventory ────────────────────────────────────────────────────
  static const String inventory = 'inventory'; // GET / POST
  static const String inventoryAlerts = 'inventory/alerts'; // GET
  static const String inventorySmartAlert = 'inventory/smart-alert'; // GET
  static String inventoryItem(Object id) => 'inventory/$id'; // GET, DELETE
  static String inventoryUpdate(Object id) => 'inventory/$id/update'; // POST
  static String inventoryRestore(Object id) => 'inventory/$id/restore'; // POST
  static String inventoryMovements(Object id) =>
      'inventory/$id/movements'; // GET / POST

  // ── Courses the expert runs ──────────────────────────────────────
  static const String courses = 'courses'; // GET / POST
  static String course(Object id) => 'courses/$id'; // GET, POST/PUT, DELETE
  static String archiveCourse(Object id) => 'courses/$id/archive'; // POST
  static String courseEnrollments(Object id) => 'courses/$id/enrollments'; // GET
  static String enrollmentProgress(Object courseId, Object enrollmentId) =>
      'courses/$courseId/enrollments/$enrollmentId/progress'; // PUT
  static String issueCertificate(Object courseId, Object enrollmentId) =>
      'courses/$courseId/enrollments/$enrollmentId/certificate'; // POST

  /// Certificates the expert has GRANTED to trainees.
  static const String grantedCertificates = 'certificates'; // GET

  // ── Reviews ──────────────────────────────────────────────────────
  static const String reviews = 'reviews'; // GET (?rating, ?unanswered)
  static String replyToReview(Object id) => 'reviews/$id/reply'; // POST
  static String reviewVisibility(Object id) => 'reviews/$id/visibility'; // POST

  // ── Followers & blocking ─────────────────────────────────────────
  static const String followers = 'followers'; // GET (?q)
  static String removeFollower(Object userId) => 'followers/$userId'; // DELETE
  static const String blockedUsers = 'blocked-users'; // GET
  static String blockUser(Object userId) =>
      'blocked-users/$userId'; // POST / DELETE

  // ── Offers ───────────────────────────────────────────────────────
  static const String offers = 'offers'; // GET (?active) / POST
  static String endOffer(Object id) => 'offers/$id/end'; // POST

  // ── Professional certificates on the expert's own profile ────────
  static const String profileCertificates = 'certificates-profile'; // GET/POST
  static String profileCertificate(Object id) =>
      'certificates-profile/$id'; // DELETE

  // ── Loyalty ──────────────────────────────────────────────────────
  static const String birthdayFollowers = 'loyalty/birthdays'; // GET
  static String birthdayGift(Object userId) =>
      'loyalty/$userId/birthday-gift'; // POST

  // ── Employment (job) requests received from salons/centers ───────
  static const String employmentRequests = 'employment-requests'; // GET(?status)
  static String acceptEmployment(Object id) =>
      'employment-requests/$id/accept'; // POST
  static String rejectEmployment(Object id) =>
      'employment-requests/$id/reject'; // POST

  // ── Reports ──────────────────────────────────────────────────────
  static const String reports = 'reports'; // GET (?from, ?to)

  // ── Chat ─────────────────────────────────────────────────────────
  static const String chats = 'chats'; // GET
  static const String chatsUnreadCount = 'chats/unread-count'; // GET
  static const String openChat = 'chats/open'; // POST
  static String chatMessages(Object chatId) =>
      'chats/$chatId/messages'; // GET / POST
  static String markChatRead(Object chatId) => 'chats/$chatId/read'; // POST
  static String deleteChatMessage(Object chatId, Object messageId) =>
      'chats/$chatId/messages/$messageId'; // DELETE

  // ── Shop: the expert as a BUYER from warehouses ──────────────────
  static const String shopProducts = 'shop/products'; // GET (?q,?category_id)
  static String shopProduct(Object id) => 'shop/products/$id'; // GET

  static const String shopCart = 'shop/cart'; // GET
  static const String shopCartItems = 'shop/cart/items'; // POST
  static String shopCartItem(Object id) =>
      'shop/cart/items/$id'; // PUT / DELETE
  static const String shopCheckout = 'shop/cart/checkout'; // POST

  static const String shopOrders = 'shop/orders'; // GET (?status)
  static String shopOrder(Object id) => 'shop/orders/$id'; // GET
  static String cancelShopOrder(Object id) => 'shop/orders/$id/cancel'; // POST

  // ── Store: the expert as a SELLER ────────────────────────────────
  static const String storeProducts = 'store/products'; // GET / POST
  static String storeProduct(Object id) =>
      'store/products/$id'; // POST (update), DELETE

  static const String storeOrders = 'store/orders'; // GET (?status)
  static String storeOrder(Object id) => 'store/orders/$id'; // GET
  static String storeOrderStatus(Object id) =>
      'store/orders/$id/status'; // PUT

  // ── Packages: bundles of services and/or products ───────────────
  static const String packages = 'packages'; // GET (?active) / POST
  static String package(Object id) =>
      'packages/$id'; // GET, POST (update), DELETE
  static String togglePackage(Object id) => 'packages/$id/toggle'; // POST

  /// Services and for-sale products the expert may bundle.
  static const String packageAvailableItems =
      'packages/available-items'; // GET

  // ── Discovery: other providers, their feed and stories ───────────
  static const String discoverProviders =
      'discover/providers'; // GET (?type,?q,?city)
  static String discoverProvider(String type, Object id) =>
      'discover/providers/$type/$id'; // GET
  static String followProvider(String type, Object id) =>
      'discover/providers/$type/$id/follow'; // POST (toggle)
  static const String discoverFollowing = 'discover/following'; // GET
  static const String discoverFeed = 'discover/feed'; // GET (?limit)
  static const String discoverStories = 'discover/stories'; // GET
  static const String discoverCourses = 'discover/courses'; // GET (?q)
  static String enrollCourse(Object id) =>
      'discover/courses/$id/enroll'; // POST / DELETE
  static String viewDiscoverStory(Object id) =>
      'discover/stories/$id/view'; // POST

  // ── Notifications: role-agnostic, NOT under /expert ─────────────
  //
  // These sit at the API root because one controller serves every
  // account type; the recipient comes from the token, not the path.
  // `AppConfig.apiBase` already includes the /expert prefix, so these
  // are addressed with the `absolute` flag on ApiClient.
  // The leading slash escapes the /expert prefix (see ApiClient._uri).
  static const String notifications = '/notifications'; // GET (?unread,?type)
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String readNotification(Object id) => '/notifications/$id/read';
  static String deleteNotification(Object id) => '/notifications/$id';

  // ── FCM device tokens ────────────────────────────────────────────
  static const String deviceToken = 'device-token'; // GET / POST / DELETE
  static const String deviceTokenTest = 'device-token/test'; // POST
}