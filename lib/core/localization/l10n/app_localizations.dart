import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/locale/locale_cubit.dart';
import '../app_language.dart';

/// Every user-facing string in the app, in English and Arabic.
///
/// Used as `context.l10n.save` via the extension at the bottom of this
/// file. Reading it through [LocaleCubit] means a language change
/// rebuilds every widget that touched a string - no restart needed.
///
/// ADDING A STRING
///   1. Add a getter below.
///   2. Add the same key to [_en] and [_ar].
///   3. Use `context.l10n.yourKey` in the widget.
///
/// ADDING A LANGUAGE
///   1. Add it to [AppLanguage].
///   2. Copy [_en] to a new map and translate every value.
///   3. Add a branch in [_table].
///
/// Keys are shared across screens on purpose: "Save" is one key, not
/// one per form. Where two screens genuinely need different wording,
/// they get different keys.
class AppLocalizations {
  AppLocalizations(this.language);

  final AppLanguage language;

  static AppLocalizations of(BuildContext context) {
    final language = context.read<LocaleCubit>().state;
    return AppLocalizations(language);
  }

  Map<String, String> get _table =>
      language == AppLanguage.arabic ? _ar : _en;

  /// Falls back to English, then to the key itself - a missing
  /// translation shows readable text instead of a blank widget.
  String _t(String key) => _table[key] ?? _en[key] ?? key;

  String get save => _t('save');
  String get cancel => _t('cancel');
  String get delete => _t('delete');
  String get edit => _t('edit');
  String get close => _t('close');
  String get confirm => _t('confirm');
  String get back => _t('back');
  String get remove => _t('remove');
  String get restore => _t('restore');
  String get update => _t('update');
  String get accept => _t('accept');
  String get approve => _t('approve');
  String get block => _t('block');
  String get unblock => _t('unblock');
  String get other => _t('other');
  String get day => _t('day');
  String get hours => _t('hours');
  String get total => _t('total');
  String get items => _t('items');
  String get notes => _t('notes');
  String get notesOptional => _t('notesOptional');
  String get reason => _t('reason');
  String get status => _t('status');
  String get attachment => _t('attachment');
  String get copyLink => _t('copyLink');
  String get linkCopied => _t('linkCopied');
  String get appName => _t('appName');
  String get firstName => _t('firstName');
  String get lastName => _t('lastName');
  String get emailAddress => _t('emailAddress');
  String get phoneNumber => _t('phoneNumber');
  String get password => _t('password');
  String get confirmPassword => _t('confirmPassword');
  String get newPassword => _t('newPassword');
  String get newPasswordLower => _t('newPasswordLower');
  String get currentPassword => _t('currentPassword');
  String get confirmNewPassword => _t('confirmNewPassword');
  String get changePassword => _t('changePassword');
  String get passwordChangedSignInAgain => _t('passwordChangedSignInAgain');
  String get signedOutAfterChange => _t('signedOutAfterChange');
  String get continueWithGoogle => _t('continueWithGoogle');
  String get profile => _t('profile');
  String get account => _t('account');
  String get setting => _t('setting');
  String get bio => _t('bio');
  String get bioDescription => _t('bioDescription');
  String get specialization => _t('specialization');
  String get experience => _t('experience');
  String get yourAddress => _t('yourAddress');
  String get location => _t('location');
  String get audience => _t('audience');
  String get growth => _t('growth');
  String get business => _t('business');
  String get home => _t('home');
  String get store => _t('store');
  String get chats => _t('chats');
  String get reservations => _t('reservations');
  String get products => _t('products');
  String get services => _t('services');
  String get posts => _t('posts');
  String get reviews => _t('reviews');
  String get orders => _t('orders');
  String get bookings => _t('bookings');
  String get employees => _t('employees');
  String get followers => _t('followers');
  String get following => _t('following');
  String get blocked => _t('blocked');
  String get notifications => _t('notifications');
  String get reports => _t('reports');
  String get payment => _t('payment');
  String get salonsAndCenters => _t('salonsAndCenters');
  String get salonsAndCenter => _t('salonsAndCenter');
  String get addProduct => _t('addProduct');
  String get productName => _t('productName');
  String get manageProducts => _t('manageProducts');
  String get searchProducts => _t('searchProducts');
  String get price => _t('price');
  String get totalPrice => _t('totalPrice');
  String get wholesalePrice => _t('wholesalePrice');
  String get quantity => _t('quantity');
  String get category => _t('category');
  String get description => _t('description');
  String get sku => _t('sku');
  String get inStock => _t('inStock');
  String get lowStock => _t('lowStock');
  String get outOfStock => _t('outOfStock');
  String get stockQuantity => _t('stockQuantity');
  String get currentStock => _t('currentStock');
  String get minimumStockThreshold => _t('minimumStockThreshold');
  String get minLevel => _t('minLevel');
  String get reorderAt => _t('reorderAt');
  String get material => _t('material');
  String get materialName => _t('materialName');
  String get materialInventory => _t('materialInventory');
  String get addMaterial => _t('addMaterial');
  String get updateMaterial => _t('updateMaterial');
  String get archivedMaterials => _t('archivedMaterials');
  String get materialUsed => _t('materialUsed');
  String get materialsUsage => _t('materialsUsage');
  String get pickAMaterial => _t('pickAMaterial');
  String get movements => _t('movements');
  String get stockHistory => _t('stockHistory');
  String get stockAlerts => _t('stockAlerts');
  String get recordStockMovement => _t('recordStockMovement');
  String get stockUpdated => _t('stockUpdated');
  String get shortages => _t('shortages');
  String get quantityPerSession => _t('quantityPerSession');
  String get unitOptional => _t('unitOptional');
  String get unitHint => _t('unitHint');
  String get howMuchPerSession => _t('howMuchPerSession');
  String get myCartAndOrders => _t('myCartAndOrders');
  String get checkout => _t('checkout');
  String get cartEmpty => _t('cartEmpty');
  String get addedToCart => _t('addedToCart');
  String get storeOrders => _t('storeOrders');
  String get orderDetail => _t('orderDetail');
  String get orderStatus => _t('orderStatus');
  String get markAsShipped => _t('markAsShipped');
  String get cancelOrder => _t('cancelOrder');
  String get customerInformation => _t('customerInformation');
  String get sellerManagesStatus => _t('sellerManagesStatus');
  String get bookingDetails => _t('bookingDetails');
  String get bookingInformation => _t('bookingInformation');
  String get upcomingBookings => _t('upcomingBookings');
  String get completeBooking => _t('completeBooking');
  String get bookingStatusUpdated => _t('bookingStatusUpdated');
  String get bookingCancelError => _t('bookingCancelError');
  String get bookingDetailsError => _t('bookingDetailsError');
  String get noServicesForBooking => _t('noServicesForBooking');
  String get instructionsLabel => _t('instructionsLabel');
  String get addService => _t('addService');
  String get serviceName => _t('serviceName');
  String get selectAService => _t('selectAService');
  String get basicInformation => _t('basicInformation');
  String get durationMinutes => _t('durationMinutes');
  String get slotDurationMinutes => _t('slotDurationMinutes');
  String get minimumNumberOfPeople => _t('minimumNumberOfPeople');
  String get peopleNeeding => _t('peopleNeeding');
  String get availableCities => _t('availableCities');
  String get homeServiceSettings => _t('homeServiceSettings');
  String get preBookingInstructions => _t('preBookingInstructions');
  String get addAnInstruction => _t('addAnInstruction');
  String get instructionsHelp => _t('instructionsHelp');
  String get requiredQuestions => _t('requiredQuestions');
  String get questionsHelp => _t('questionsHelp');
  String get serviceNotCreated => _t('serviceNotCreated');
  String get noMaterialsLinked => _t('noMaterialsLinked');
  String get addTimeToWork => _t('addTimeToWork');
  String get startTime => _t('startTime');
  String get endTime => _t('endTime');
  String get startDate => _t('startDate');
  String get endDate => _t('endDate');
  String get workingHours => _t('workingHours');
  String get keepOneWorkingDay => _t('keepOneWorkingDay');
  String get offersAndDiscounts => _t('offersAndDiscounts');
  String get addDiscount => _t('addDiscount');
  String get addOffer => _t('addOffer');
  String get addPackage => _t('addPackage');
  String get packageName => _t('packageName');
  String get offerType => _t('offerType');
  String get discountPercentage => _t('discountPercentage');
  String get offerDescriptionHint => _t('offerDescriptionHint');
  String get addProductFromStore => _t('addProductFromStore');
  String get addProductOrService => _t('addProductOrService');
  String get sendGift => _t('sendGift');
  String get gifted => _t('gifted');
  String get trainingAndCourses => _t('trainingAndCourses');
  String get trainingCourses => _t('trainingCourses');
  String get myCourses => _t('myCourses');
  String get availableCourses => _t('availableCourses');
  String get myEnrollments => _t('myEnrollments');
  String get myCertificates => _t('myCertificates');
  String get courseTitle => _t('courseTitle');
  String get onlineCourse => _t('onlineCourse');
  String get maximumTrainees => _t('maximumTrainees');
  String get students => _t('students');
  String get coursesYouTeach => _t('coursesYouTeach');
  String get browseAndEnroll => _t('browseAndEnroll');
  String get trackYourProgress => _t('trackYourProgress');
  String get continueLearning => _t('continueLearning');
  String get completedCourses => _t('completedCourses');
  String get expiring => _t('expiring');
  String get jobRequests => _t('jobRequests');
  String get applicationForEmployment => _t('applicationForEmployment');
  String get requirements => _t('requirements');
  String get benefits => _t('benefits');
  String get salary => _t('salary');
  String get newLabel => _t('newLabel');
  String get accepted => _t('accepted');
  String get rejected => _t('rejected');
  String get postDeleted => _t('postDeleted');
  String get storyDeleted => _t('storyDeleted');
  String get captionTooLong => _t('captionTooLong');
  String get storyTextTooLong => _t('storyTextTooLong');
  String get postNeedsContent => _t('postNeedsContent');
  String get storyNeedsContent => _t('storyNeedsContent');
  String get upToTenFiles => _t('upToTenFiles');
  String get addCoverImage => _t('addCoverImage');
  String get averageRating => _t('averageRating');
  String get totalReviews => _t('totalReviews');
  String get revenue => _t('revenue');
  String get profit => _t('profit');
  String get revenueReport => _t('revenueReport');
  String get bookingReport => _t('bookingReport');
  String get searchChats => _t('searchChats');
  String get searchFollowers => _t('searchFollowers');
  String get sayHello => _t('sayHello');
  String get callInfo => _t('callInfo');
  String get positionInfo => _t('positionInfo');
  String get generalMedicalHistory => _t('generalMedicalHistory');
  String get allergies => _t('allergies');
  String get currentMedications => _t('currentMedications');
  String get skinHealthAssessment => _t('skinHealthAssessment');
  String get previousTreatments => _t('previousTreatments');
  String get lifestyleInformation => _t('lifestyleInformation');
  String get treatmentGoals => _t('treatmentGoals');
  String get noAlerts => _t('noAlerts');
  String get noNotifications => _t('noNotifications');
  String get noPostsYet => _t('noPostsYet');
  String get noReviewsYet => _t('noReviewsYet');
  String get noOffersYet => _t('noOffersYet');
  String get noDiscountsYet => _t('noDiscountsYet');
  String get noPackagesYet => _t('noPackagesYet');
  String get noOrdersYet => _t('noOrdersYet');
  String get noCustomerOrders => _t('noCustomerOrders');
  String get noCoursesYet => _t('noCoursesYet');
  String get noCoursesCreated => _t('noCoursesCreated');
  String get noEnrollments => _t('noEnrollments');
  String get noCertificates => _t('noCertificates');
  String get noJobRequests => _t('noJobRequests');
  String get noMessagesYet => _t('noMessagesYet');
  String get noMovementsYet => _t('noMovementsYet');
  String get noArchivedMaterials => _t('noArchivedMaterials');
  String get noBirthdaysToday => _t('noBirthdaysToday');
  String get nobodyIsBlocked => _t('nobodyIsBlocked');
  String get nothingHereYet => _t('nothingHereYet');
  String get everythingStocked => _t('everythingStocked');
  String get nothingToConsume => _t('nothingToConsume');
  String get noDocumentAttached => _t('noDocumentAttached');
  String get productOffersUnavailable => _t('productOffersUnavailable');
  String get noMaterialAtMinimum => _t('noMaterialAtMinimum');
  String get blockedListHint => _t('blockedListHint');
  String get tapPlusToPublishCourse => _t('tapPlusToPublishCourse');
  String get everyItemLinked => _t('everyItemLinked');
  String get noBookingsThatDay => _t('noBookingsThatDay');
  String get noProvidersMatch => _t('noProvidersMatch');
  String get bundleHint => _t('bundleHint');
  String get certificatesHint => _t('certificatesHint');
  String get discountHint => _t('discountHint');
  String get offersAttachToService => _t('offersAttachToService');
  String get reviewsWillAppear => _t('reviewsWillAppear');
  String get publishCourseHint => _t('publishCourseHint');
  String get recordPurchaseHint => _t('recordPurchaseHint');
  String get shareYourWork => _t('shareYourWork');
  String get salonInviteHint => _t('salonInviteHint');
  String get birthdayGiftHint => _t('birthdayGiftHint');
  String get storeOrderHint => _t('storeOrderHint');
  String get removeFollowerHint => _t('removeFollowerHint');
  String get removeProductHint => _t('removeProductHint');
  String get removeFollower => _t('removeFollower');
  String get removeFollowerQuestion => _t('removeFollowerQuestion');
  String get removeThisProduct => _t('removeThisProduct');
  String get settingsTitle => _t('settingsTitle');
  String get settingsPersonalInfo => _t('settingsPersonalInfo');
  String get settingsName => _t('settingsName');
  String get settingsEmail => _t('settingsEmail');
  String get settingsPhone => _t('settingsPhone');
  String get settingsBirthdate => _t('settingsBirthdate');
  String get settingsBio => _t('settingsBio');
  String get settingsLocation => _t('settingsLocation');
  String get settingsTimeOfWork => _t('settingsTimeOfWork');
  String get settingsAddTime => _t('settingsAddTime');
  String get settingsSecurity => _t('settingsSecurity');
  String get settingsChangePassword => _t('settingsChangePassword');
  String get settingsLanguage => _t('settingsLanguage');
  String get settingsLogout => _t('settingsLogout');
  String get settingsDeleteAccount => _t('settingsDeleteAccount');
  String get cannotReachServer => _t('cannotReachServer');
  String get serverTimeout => _t('serverTimeout');

  static const Map<String, String> _en = {
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'close': 'Close',
    'confirm': 'Confirm',
    'back': 'Back',
    'remove': 'Remove',
    'restore': 'Restore',
    'update': 'update',
    'accept': 'Accept',
    'approve': 'Approve',
    'block': 'Block',
    'unblock': 'Unblock',
    'other': 'Other',
    'day': 'Day',
    'hours': 'Hours',
    'total': 'Total',
    'items': 'Items',
    'notes': 'Notes',
    'notesOptional': 'Notes (optional)',
    'reason': 'Reason',
    'status': 'Status',
    'attachment': 'Attachment',
    'copyLink': 'Copy link',
    'linkCopied': 'Link copied.',
    'appName': 'Beauty Hub',
    'firstName': 'First Name',
    'lastName': 'Last Name',
    'emailAddress': 'Email Address',
    'phoneNumber': 'Phone Number',
    'password': 'Password',
    'confirmPassword': 'Confirm Password',
    'newPassword': 'New Password',
    'newPasswordLower': 'New password',
    'currentPassword': 'Current password',
    'confirmNewPassword': 'Confirm new password',
    'changePassword': 'Change Password',
    'passwordChangedSignInAgain': 'Password changed. Please sign in again.',
    'signedOutAfterChange': 'You will be signed out of all devices after changing ',
    'continueWithGoogle': 'continue with Google',
    'profile': 'Profile',
    'account': 'Account',
    'setting': 'Setting',
    'bio': 'Bio',
    'bioDescription': 'Bio / Description',
    'specialization': 'Specialization',
    'experience': 'Experience',
    'yourAddress': 'Your Address',
    'location': 'Location',
    'audience': 'Audience',
    'growth': 'Growth',
    'business': 'Business',
    'home': 'Home',
    'store': 'Store',
    'chats': 'Chats',
    'reservations': 'Reservations',
    'products': 'Products',
    'services': 'Services',
    'posts': 'Posts',
    'reviews': 'Reviews',
    'orders': 'Orders',
    'bookings': 'Bookings',
    'employees': 'Employees',
    'followers': 'Followers',
    'following': 'Following',
    'blocked': 'Blocked',
    'notifications': 'NOTIFICATIONS',
    'reports': 'Reports',
    'payment': 'Payment',
    'salonsAndCenters': 'Salons & Centers',
    'salonsAndCenter': 'Salons & Center',
    'addProduct': 'Add product',
    'productName': 'Product name',
    'manageProducts': 'Manage products',
    'searchProducts': 'Search products',
    'price': 'Price',
    'totalPrice': 'Total price',
    'wholesalePrice': 'Wholesale Price',
    'quantity': 'Quantity',
    'category': 'Category',
    'description': 'Description',
    'sku': 'SKU',
    'inStock': 'In stock',
    'lowStock': 'Low stock',
    'outOfStock': 'Out of stock',
    'stockQuantity': 'Stock Quantity',
    'currentStock': 'Current stock',
    'minimumStockThreshold': 'Minimum Stock Threshold',
    'minLevel': 'Min level',
    'reorderAt': 'Reorder at',
    'material': 'Material',
    'materialName': 'Material name',
    'materialInventory': 'Material Inventory',
    'addMaterial': 'Add Material',
    'updateMaterial': 'Update Material',
    'archivedMaterials': 'Archived Materials',
    'materialUsed': 'Material used',
    'materialsUsage': 'Materials Usage',
    'pickAMaterial': 'Pick a material',
    'movements': 'Movements',
    'stockHistory': 'Stock History',
    'stockAlerts': 'Stock Alerts',
    'recordStockMovement': 'Record stock movement',
    'stockUpdated': 'Stock updated.',
    'shortages': 'Shortages',
    'quantityPerSession': 'Quantity per session',
    'unitOptional': 'Unit (optional)',
    'unitHint': 'ml, g, piece',
    'howMuchPerSession': 'How much of this does one session use?',
    'myCartAndOrders': 'My Cart & Orders',
    'checkout': 'Checkout',
    'cartEmpty': 'Your cart is empty',
    'addedToCart': 'Added to your cart.',
    'storeOrders': 'Store Orders',
    'orderDetail': 'Order Detail',
    'orderStatus': 'Order Status',
    'markAsShipped': 'Mark as shipped',
    'cancelOrder': 'Cancel order',
    'customerInformation': 'Customer Information',
    'sellerManagesStatus': 'Status updates are managed by the seller and ',
    'bookingDetails': 'Booking Details',
    'bookingInformation': 'Booking Information',
    'upcomingBookings': 'Upcoming Bookings',
    'completeBooking': 'Complete Booking',
    'bookingStatusUpdated': 'تم تحديث حالة الحجز.',
    'bookingCancelError': 'Something went wrong while cancelling.',
    'bookingDetailsError': 'Something went wrong while loading details.',
    'noServicesForBooking': 'No services added to this appointment',
    'instructionsLabel': 'Instructions',
    'addService': 'Add service',
    'serviceName': 'Service name',
    'selectAService': 'Select a service',
    'basicInformation': 'Basic Information',
    'durationMinutes': 'Duration (minutes)',
    'slotDurationMinutes': 'slot duration (minutes)',
    'minimumNumberOfPeople': 'Minimum number of people',
    'peopleNeeding': 'People needing',
    'availableCities': 'Available cities',
    'homeServiceSettings': 'Home Service Settings',
    'preBookingInstructions': 'Pre-booking Instructions',
    'addAnInstruction': 'Add an instruction',
    'instructionsHelp': 'Add instructions the customer must follow before their appointment.',
    'requiredQuestions': 'Required Questions',
    'questionsHelp': 'These questions will be asked to the customer before booking.',
    'serviceNotCreated': 'The service was not created. Please try again.',
    'noMaterialsLinked': 'No materials linked',
    'addTimeToWork': 'Add time to work',
    'startTime': 'Start time',
    'endTime': 'End time',
    'startDate': 'Start date',
    'endDate': 'End date',
    'workingHours': 'Working hours',
    'keepOneWorkingDay': 'Your schedule must keep at least one working day.',
    'offersAndDiscounts': 'Offers & Discounts',
    'addDiscount': 'Add discount',
    'addOffer': 'Add offer',
    'addPackage': 'Add Package',
    'packageName': 'Package name',
    'offerType': 'Offer type',
    'discountPercentage': 'Discount percentage (%)',
    'offerDescriptionHint': 'Description (e.g. buy two get one free)',
    'addProductFromStore': 'Add product from your store',
    'addProductOrService': 'Add product from your store or your Service',
    'sendGift': 'Send gift',
    'gifted': 'Gifted',
    'trainingAndCourses': 'Training & Courses',
    'trainingCourses': 'Training Courses',
    'myCourses': 'My Courses',
    'availableCourses': 'Available Courses',
    'myEnrollments': 'My Enrollments',
    'myCertificates': 'My Certificates',
    'courseTitle': 'Course title',
    'onlineCourse': 'Online course',
    'maximumTrainees': 'Maximum trainees (optional)',
    'students': 'Students',
    'coursesYouTeach': 'Courses you teach',
    'browseAndEnroll': 'Browse & enroll',
    'trackYourProgress': 'Track your progress',
    'continueLearning': 'Continue Learning',
    'completedCourses': 'Completed courses',
    'expiring': 'Expiring',
    'jobRequests': 'Job Requests',
    'applicationForEmployment': 'Application for Employment',
    'requirements': 'Requirements',
    'benefits': 'Benefits',
    'salary': 'Salary',
    'newLabel': 'New',
    'accepted': 'Accepted',
    'rejected': 'Rejected',
    'postDeleted': 'Post deleted successfully',
    'storyDeleted': 'Story deleted successfully',
    'captionTooLong': 'The caption is too long (2200 characters maximum).',
    'storyTextTooLong': 'Story text is too long (500 characters maximum).',
    'postNeedsContent': 'Add a caption or at least one photo.',
    'storyNeedsContent': 'Add a photo, a video, or some text to post a story.',
    'upToTenFiles': 'A post can include up to 10 photos or videos.',
    'addCoverImage': 'Add a cover image',
    'averageRating': 'Average rating',
    'totalReviews': 'Total reviews',
    'revenue': 'Revenue',
    'profit': 'Profit',
    'revenueReport': 'Revenue Report',
    'bookingReport': 'Booking Report',
    'searchChats': 'Search chats',
    'searchFollowers': 'Search followers',
    'sayHello': 'Say hello to start the conversation.',
    'callInfo': 'Call info',
    'positionInfo': 'Position info',
    'generalMedicalHistory': 'General Medical History',
    'allergies': 'Allergies',
    'currentMedications': 'Current Medications',
    'skinHealthAssessment': 'Skin Health Assessment',
    'previousTreatments': 'Previous Aesthetic Treatments',
    'lifestyleInformation': 'Lifestyle Information',
    'treatmentGoals': 'Treatment Goals',
    'noAlerts': 'No Alerts',
    'noNotifications': 'No Notifications',
    'noPostsYet': 'No posts yet',
    'noReviewsYet': 'No reviews yet',
    'noOffersYet': 'No offers yet',
    'noDiscountsYet': 'No discounts yet',
    'noPackagesYet': 'No packages yet',
    'noOrdersYet': 'No orders yet',
    'noCustomerOrders': 'No customer orders yet',
    'noCoursesYet': 'No courses yet',
    'noCoursesCreated': 'No courses created yet',
    'noEnrollments': 'No enrollments here',
    'noCertificates': 'No certificates here',
    'noJobRequests': 'No job requests',
    'noMessagesYet': 'No messages yet',
    'noMovementsYet': 'No movements yet',
    'noArchivedMaterials': 'No archived materials',
    'noBirthdaysToday': 'No birthdays today',
    'nobodyIsBlocked': 'Nobody is blocked',
    'nothingHereYet': 'Nothing here yet',
    'everythingStocked': 'Everything is stocked',
    'nothingToConsume': 'Nothing scheduled to consume',
    'noDocumentAttached': 'No document attached to this one.',
    'productOffersUnavailable': 'Product offers are not available',
    'noMaterialAtMinimum': 'No material has dropped to its minimum level.',
    'blockedListHint': 'Anyone you block will be listed here so you can undo it.',
    'tapPlusToPublishCourse': 'Tap + to publish your first course.',
    'everyItemLinked': 'Every item in your inventory is already linked to ',
    'noBookingsThatDay': 'Either there are no bookings for that day, or your services ',
    'noProvidersMatch': 'No approved providers match this filter. Try ',
    'bundleHint': 'Bundle a few of your services and products together and sell ',
    'certificatesHint': 'Certificates you add to your profile, and ones you ',
    'discountHint': 'Create a discount on one of your services and it will appear ',
    'offersAttachToService': 'Offers on this account attach to a service, not a ',
    'reviewsWillAppear': 'Once customers rate your services, their reviews will ',
    'publishCourseHint': 'Publish a course and trainees will be able to enroll ',
    'recordPurchaseHint': 'Record a purchase or a consumption and it will ',
    'shareYourWork': 'Share your work and it will show up here for your ',
    'salonInviteHint': 'When a salon or beauty center invites you to join their ',
    'birthdayGiftHint': 'When one of your followers has a birthday, you can send them ',
    'storeOrderHint': 'When someone buys from your store, their order shows up ',
    'removeFollowerHint': 'They will stop following you and any conversation ',
    'removeProductHint': 'It will no longer appear in your store. Past orders keep it.',
    'removeFollower': 'Remove follower',
    'removeFollowerQuestion': 'Remove follower?',
    'removeThisProduct': 'Remove this product?',
    'settingsTitle': 'Settings',
    'settingsPersonalInfo': 'Personal Information',
    'settingsName': 'Name',
    'settingsEmail': 'Email',
    'settingsPhone': 'Phone',
    'settingsBirthdate': 'Birthdate',
    'settingsBio': 'Bio',
    'settingsLocation': 'Location',
    'settingsTimeOfWork': 'Time of work',
    'settingsAddTime': 'Add time',
    'settingsSecurity': 'Security',
    'settingsChangePassword': 'Change password',
    'settingsLanguage': 'Language',
    'settingsLogout': 'Log out',
    'settingsDeleteAccount': 'Delete account',
    'cannotReachServer': 'Cannot reach the server. Check your connection.',
    'serverTimeout': 'The server took too long to respond. Please try again.',
  };

  static const Map<String, String> _ar = {
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'delete': 'حذف',
    'edit': 'تعديل',
    'close': 'إغلاق',
    'confirm': 'تأكيد',
    'back': 'رجوع',
    'remove': 'إزالة',
    'restore': 'استعادة',
    'update': 'تحديث',
    'accept': 'قبول',
    'approve': 'موافقة',
    'block': 'حظر',
    'unblock': 'إلغاء الحظر',
    'other': 'أخرى',
    'day': 'اليوم',
    'hours': 'ساعات',
    'total': 'الإجمالي',
    'items': 'العناصر',
    'notes': 'ملاحظات',
    'notesOptional': 'ملاحظات (اختياري)',
    'reason': 'السبب',
    'status': 'الحالة',
    'attachment': 'مرفق',
    'copyLink': 'نسخ الرابط',
    'linkCopied': 'تم نسخ الرابط.',
    'appName': 'بيوتي هَب',
    'firstName': 'الاسم الأول',
    'lastName': 'اسم العائلة',
    'emailAddress': 'البريد الإلكتروني',
    'phoneNumber': 'رقم الهاتف',
    'password': 'كلمة السر',
    'confirmPassword': 'تأكيد كلمة السر',
    'newPassword': 'كلمة سر جديدة',
    'newPasswordLower': 'كلمة السر الجديدة',
    'currentPassword': 'كلمة السر الحالية',
    'confirmNewPassword': 'تأكيد كلمة السر الجديدة',
    'changePassword': 'تغيير كلمة السر',
    'passwordChangedSignInAgain': 'تم تغيير كلمة السر. يرجى تسجيل الدخول من جديد.',
    'signedOutAfterChange': 'سيتم تسجيل خروجك من كل الأجهزة بعد تغيير ',
    'continueWithGoogle': 'المتابعة عبر Google',
    'profile': 'الملف الشخصي',
    'account': 'الحساب',
    'setting': 'الإعدادات',
    'bio': 'نبذة',
    'bioDescription': 'نبذة / وصف',
    'specialization': 'التخصص',
    'experience': 'الخبرة',
    'yourAddress': 'عنوانك',
    'location': 'الموقع',
    'audience': 'الفئة المستهدفة',
    'growth': 'النمو',
    'business': 'الأعمال',
    'home': 'الرئيسية',
    'store': 'المتجر',
    'chats': 'المحادثات',
    'reservations': 'الحجوزات',
    'products': 'المنتجات',
    'services': 'الخدمات',
    'posts': 'المنشورات',
    'reviews': 'التقييمات',
    'orders': 'الطلبات',
    'bookings': 'الحجوزات',
    'employees': 'الموظفون',
    'followers': 'المتابعون',
    'following': 'متابَع',
    'blocked': 'المحظورون',
    'notifications': 'الإشعارات',
    'reports': 'التقارير',
    'payment': 'الدفع',
    'salonsAndCenters': 'الصالونات والمراكز',
    'salonsAndCenter': 'الصالونات والمراكز',
    'addProduct': 'إضافة منتج',
    'productName': 'اسم المنتج',
    'manageProducts': 'إدارة المنتجات',
    'searchProducts': 'ابحثي عن منتج',
    'price': 'السعر',
    'totalPrice': 'السعر الإجمالي',
    'wholesalePrice': 'سعر الجملة',
    'quantity': 'الكمية',
    'category': 'الفئة',
    'description': 'الوصف',
    'sku': 'رمز المنتج',
    'inStock': 'متوفر',
    'lowStock': 'مخزون منخفض',
    'outOfStock': 'نفد المخزون',
    'stockQuantity': 'الكمية في المخزون',
    'currentStock': 'المخزون الحالي',
    'minimumStockThreshold': 'الحد الأدنى للمخزون',
    'minLevel': 'الحد الأدنى',
    'reorderAt': 'إعادة الطلب عند',
    'material': 'مادة',
    'materialName': 'اسم المادة',
    'materialInventory': 'مخزون المواد',
    'addMaterial': 'إضافة مادة',
    'updateMaterial': 'تعديل المادة',
    'archivedMaterials': 'المواد المؤرشفة',
    'materialUsed': 'المادة المستخدَمة',
    'materialsUsage': 'استهلاك المواد',
    'pickAMaterial': 'اختاري مادة',
    'movements': 'الحركات',
    'stockHistory': 'سجل المخزون',
    'stockAlerts': 'تنبيهات المخزون',
    'recordStockMovement': 'تسجيل حركة مخزون',
    'stockUpdated': 'تم تحديث المخزون.',
    'shortages': 'النواقص',
    'quantityPerSession': 'الكمية لكل جلسة',
    'unitOptional': 'الوحدة (اختياري)',
    'unitHint': 'مل، غرام، قطعة',
    'howMuchPerSession': 'كم تستهلك الجلسة الواحدة من هذه المادة؟',
    'myCartAndOrders': 'سلتي وطلباتي',
    'checkout': 'إتمام الشراء',
    'cartEmpty': 'سلتك فارغة',
    'addedToCart': 'تمت الإضافة إلى السلة.',
    'storeOrders': 'طلبات المتجر',
    'orderDetail': 'تفاصيل الطلب',
    'orderStatus': 'حالة الطلب',
    'markAsShipped': 'تعليم كمشحون',
    'cancelOrder': 'إلغاء الطلب',
    'customerInformation': 'معلومات العميل',
    'sellerManagesStatus': 'تحديثات الحالة يديرها البائع و',
    'bookingDetails': 'تفاصيل الحجز',
    'bookingInformation': 'معلومات الحجز',
    'upcomingBookings': 'الحجوزات القادمة',
    'completeBooking': 'إكمال الحجز',
    'bookingStatusUpdated': 'تم تحديث حالة الحجز.',
    'bookingCancelError': 'حدث خطأ أثناء إلغاء الحجز.',
    'bookingDetailsError': 'حدث خطأ أثناء جلب التفاصيل',
    'noServicesForBooking': 'لا توجد خدمات مضافة لهذا الموعد',
    'instructionsLabel': 'تعليمات',
    'addService': 'إضافة خدمة',
    'serviceName': 'اسم الخدمة',
    'selectAService': 'اختاري خدمة',
    'basicInformation': 'المعلومات الأساسية',
    'durationMinutes': 'المدة (بالدقائق)',
    'slotDurationMinutes': 'مدة الموعد (بالدقائق)',
    'minimumNumberOfPeople': 'الحد الأدنى لعدد الأشخاص',
    'peopleNeeding': 'عدد الأشخاص',
    'availableCities': 'المدن المتاحة',
    'homeServiceSettings': 'إعدادات الخدمة المنزلية',
    'preBookingInstructions': 'تعليمات ما قبل الحجز',
    'addAnInstruction': 'أضيفي تعليمة',
    'instructionsHelp': 'أضيفي التعليمات التي يجب على العميلة اتباعها قبل الموعد.',
    'requiredQuestions': 'الأسئلة المطلوبة',
    'questionsHelp': 'ستُطرح هذه الأسئلة على العميلة قبل الحجز.',
    'serviceNotCreated': 'لم يتم إنشاء الخدمة. يرجى المحاولة من جديد.',
    'noMaterialsLinked': 'لا مواد مرتبطة',
    'addTimeToWork': 'إضافة وقت عمل',
    'startTime': 'وقت البدء',
    'endTime': 'وقت الانتهاء',
    'startDate': 'تاريخ البدء',
    'endDate': 'تاريخ الانتهاء',
    'workingHours': 'ساعات العمل',
    'keepOneWorkingDay': 'يجب أن يبقى يوم عمل واحد على الأقل في جدولك.',
    'offersAndDiscounts': 'العروض والخصومات',
    'addDiscount': 'إضافة خصم',
    'addOffer': 'إضافة عرض',
    'addPackage': 'إضافة باقة',
    'packageName': 'اسم الباقة',
    'offerType': 'نوع العرض',
    'discountPercentage': 'نسبة الخصم (%)',
    'offerDescriptionHint': 'الوصف (مثال: اشتري قطعتين واحصلي على الثالثة مجانًا)',
    'addProductFromStore': 'أضيفي منتجًا من متجرك',
    'addProductOrService': 'أضيفي منتجًا من متجرك أو خدمة من خدماتك',
    'sendGift': 'إرسال هدية',
    'gifted': 'تم الإهداء',
    'trainingAndCourses': 'التدريب والدورات',
    'trainingCourses': 'الدورات التدريبية',
    'myCourses': 'دوراتي',
    'availableCourses': 'الدورات المتاحة',
    'myEnrollments': 'تسجيلاتي',
    'myCertificates': 'شهاداتي',
    'courseTitle': 'عنوان الدورة',
    'onlineCourse': 'دورة أونلاين',
    'maximumTrainees': 'الحد الأقصى للمتدربات (اختياري)',
    'students': 'المتدربات',
    'coursesYouTeach': 'الدورات التي تدرّسينها',
    'browseAndEnroll': 'تصفّحي وسجّلي',
    'trackYourProgress': 'تابعي تقدمك',
    'continueLearning': 'متابعة التعلّم',
    'completedCourses': 'الدورات المكتملة',
    'expiring': 'تنتهي قريبًا',
    'jobRequests': 'طلبات العمل',
    'applicationForEmployment': 'طلب توظيف',
    'requirements': 'المتطلبات',
    'benefits': 'المزايا',
    'salary': 'الراتب',
    'newLabel': 'جديد',
    'accepted': 'مقبول',
    'rejected': 'مرفوض',
    'postDeleted': 'تم حذف المنشور بنجاح',
    'storyDeleted': 'تم حذف القصة بنجاح',
    'captionTooLong': 'النص طويل جدًا (٢٢٠٠ حرف كحد أقصى).',
    'storyTextTooLong': 'نص القصة طويل جدًا (٥٠٠ حرف كحد أقصى).',
    'postNeedsContent': 'أضيفي نصًا أو صورة واحدة على الأقل.',
    'storyNeedsContent': 'أضيفي صورة أو فيديو أو نصًا لنشر القصة.',
    'upToTenFiles': 'يمكن أن يتضمن المنشور حتى ١٠ صور أو مقاطع.',
    'addCoverImage': 'أضيفي صورة غلاف',
    'averageRating': 'متوسط التقييم',
    'totalReviews': 'عدد التقييمات',
    'revenue': 'الإيرادات',
    'profit': 'الربح',
    'revenueReport': 'تقرير الإيرادات',
    'bookingReport': 'تقرير الحجوزات',
    'searchChats': 'ابحثي في المحادثات',
    'searchFollowers': 'ابحثي في المتابعين',
    'sayHello': 'ابدئي المحادثة بتحية.',
    'callInfo': 'معلومات الاتصال',
    'positionInfo': 'معلومات الموقع',
    'generalMedicalHistory': 'التاريخ الطبي العام',
    'allergies': 'الحساسية',
    'currentMedications': 'الأدوية الحالية',
    'skinHealthAssessment': 'تقييم صحة البشرة',
    'previousTreatments': 'العلاجات التجميلية السابقة',
    'lifestyleInformation': 'معلومات نمط الحياة',
    'treatmentGoals': 'أهداف العلاج',
    'noAlerts': 'لا تنبيهات',
    'noNotifications': 'لا إشعارات',
    'noPostsYet': 'لا منشورات بعد',
    'noReviewsYet': 'لا تقييمات بعد',
    'noOffersYet': 'لا عروض بعد',
    'noDiscountsYet': 'لا خصومات بعد',
    'noPackagesYet': 'لا باقات بعد',
    'noOrdersYet': 'لا طلبات بعد',
    'noCustomerOrders': 'لا طلبات من العملاء بعد',
    'noCoursesYet': 'لا دورات بعد',
    'noCoursesCreated': 'لم تنشئي أي دورة بعد',
    'noEnrollments': 'لا تسجيلات هنا',
    'noCertificates': 'لا شهادات هنا',
    'noJobRequests': 'لا طلبات عمل',
    'noMessagesYet': 'لا رسائل بعد',
    'noMovementsYet': 'لا حركات بعد',
    'noArchivedMaterials': 'لا مواد مؤرشفة',
    'noBirthdaysToday': 'لا أعياد ميلاد اليوم',
    'nobodyIsBlocked': 'لا أحد محظور',
    'nothingHereYet': 'لا شيء هنا بعد',
    'everythingStocked': 'المخزون مكتمل',
    'nothingToConsume': 'لا استهلاك مجدول',
    'noDocumentAttached': 'لا يوجد مستند مرفق بهذه.',
    'productOffersUnavailable': 'عروض المنتجات غير متاحة',
    'noMaterialAtMinimum': 'لم تصل أي مادة إلى حدها الأدنى.',
    'blockedListHint': 'سيظهر هنا كل من تحظرينه لتتمكني من التراجع.',
    'tapPlusToPublishCourse': 'اضغطي + لنشر أول دورة لك.',
    'everyItemLinked': 'كل مادة في مخزونك مرتبطة بالفعل بـ ',
    'noBookingsThatDay': 'إما لا توجد حجوزات في ذلك اليوم، أو أن خدماتك ',
    'noProvidersMatch': 'لا يوجد مزوّدون معتمدون بهذا الفلتر. جرّبي ',
    'bundleHint': 'اجمعي بعض خدماتك ومنتجاتك معًا وبيعيها ',
    'certificatesHint': 'الشهادات التي تضيفينها لملفك، وتلك التي ',
    'discountHint': 'أنشئي خصمًا على إحدى خدماتك وسيظهر ',
    'offersAttachToService': 'العروض في هذا الحساب ترتبط بخدمة لا بـ ',
    'reviewsWillAppear': 'عندما تقيّم العميلات خدماتك، ستظهر تقييماتهن ',
    'publishCourseHint': 'انشري دورة وسيتمكن المتدربون من التسجيل ',
    'recordPurchaseHint': 'سجّلي عملية شراء أو استهلاك وستظهر ',
    'shareYourWork': 'شاركي أعمالك وستظهر هنا لمتابعيك ',
    'salonInviteHint': 'عندما يدعوك صالون أو مركز تجميل للانضمام إلى ',
    'birthdayGiftHint': 'عندما يكون عيد ميلاد أحد متابعيك، يمكنك إرسال ',
    'storeOrderHint': 'عندما يشتري أحدهم من متجرك، يظهر طلبه ',
    'removeFollowerHint': 'سيتوقف عن متابعتك وأي محادثة ',
    'removeProductHint': 'لن يظهر في متجرك بعد الآن. الطلبات السابقة تحتفظ به.',
    'removeFollower': 'إزالة متابع',
    'removeFollowerQuestion': 'إزالة هذا المتابع؟',
    'removeThisProduct': 'إزالة هذا المنتج؟',
    'settingsTitle': 'الإعدادات',
    'settingsPersonalInfo': 'المعلومات الشخصية',
    'settingsName': 'الاسم',
    'settingsEmail': 'البريد الإلكتروني',
    'settingsPhone': 'الهاتف',
    'settingsBirthdate': 'تاريخ الميلاد',
    'settingsBio': 'نبذة',
    'settingsLocation': 'الموقع',
    'settingsTimeOfWork': 'أوقات العمل',
    'settingsAddTime': 'إضافة وقت',
    'settingsSecurity': 'الأمان',
    'settingsChangePassword': 'تغيير كلمة السر',
    'settingsLanguage': 'اللغة',
    'settingsLogout': 'تسجيل الخروج',
    'settingsDeleteAccount': 'حذف الحساب',
    'cannotReachServer': 'تعذّر الوصول إلى الخادم. تحققي من اتصالك.',
    'serverTimeout': 'استغرق الخادم وقتًا طويلًا للرد. يرجى المحاولة من جديد.',
  };
}

/// `context.l10n.save`
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
