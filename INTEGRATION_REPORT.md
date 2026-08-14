# Beauty Hub — تقرير ربط تطبيق Flutter بالـ Backend

المصدر المعتمد: `routes/api.php` + `Postman collection` + كود الـ Controllers/Services.
لم يُبنَ أي شيء على تخمين من أسماء ملفات Flutter.

---

## 0. تحذير مهم قبل أي شيء

**لم يُختبر هذا الكود.** بيئة العمل لم تحتوِ على Flutter/Dart SDK ولا على اتصال شبكة،
فلم يكن ممكنًا تشغيل `flutter pub get` أو `flutter analyze` أو `flutter run`،
ولا إرسال أي request فعلي إلى الـ Backend.

ما تم التحقق منه آليًا فقط:
- توازن الأقواس في **جميع** ملفات `.dart` (287 ملف) — سليم.
- أن كل `import` (نسبي و`package:beautyhup/`) يشير إلى ملف موجود — صفر أخطاء.
- أن كل `state.copyWith(...)` في كل BLoC يستخدم معاملات معرّفة فعلًا
  في ملف الـ state المقابل — صفر أخطاء.
- عدم وجود أي token أو host مكتوب يدويًا في `lib/`.

**توقّعي ظهور أخطاء compile عند أول build.** راجعي القسم 7.

---

## 1. ملخص الربط

التطبيق هو **تطبيق الخبير (Expert)**. الـ Backend يوفّر ~60 endpoint لهذا الدور
من أصل 313 request في Postman؛ الباقي يخص Customer / Salon / Center / Warehouse / Admin
ولا يمكن الوصول إليه بتوكن خبير.

### طبقة الأساس (ملفات جديدة)

| الملف | الدور |
|---|---|
| `core/config/app_config.dart` | مصدر وحيد للـ URLs + `mediaUrl()` لبناء روابط الصور |
| `core/network/api_endpoints.dart` | خريطة كاملة لكل endpoints الخبير، منقولة من `routes/api.php` |
| `core/network/api_response.dart` | فك غلاف الاستجابة بأمان + تحويل الأنواع |
| `core/storage/storage_service.dart` | طبقة SharedPreferences منظّمة |
| `core/utils/image_helpers.dart` | `remoteImageProvider()` — يُرجع `null` بدل رابط مكسور |
| `core/notification/device_token_sync.dart` | تسجيل FCM token لدى الـ Backend |
| `widgets/state_views.dart` | Loading / Empty / Error / Skeleton بنفس الـ Design System |

`core/network/api_client.dart` أُعيدت كتابته بالكامل مع **الحفاظ على نفس الواجهة الثابتة**
حتى لا يُكسر أي call site موجود.

---

## 2. الـ APIs التي تم ربطها

### Authentication — `POST /expert/auth/*`
`register` · `login` · `verify_otp` · `resend_otp` · `forget_password` ·
`reset_password` · `change_password` · `logout` · `delete_account` · `GET profile` ·
`POST update_profile`

الثلاثة التالية كانت `TODO` وهمية بالكامل قبل الآن:
`resend_otp` · `forget_password` · `reset_password`.

### Bookings — `GET /expert/bookings` · `GET bookings/{id}` · `DELETE bookings/{id}`
### Calendar — `GET /expert/calendar` · `PUT /expert/calendar`
### Reviews — `GET /expert/reviews` · `POST reviews/{id}/reply` · `POST reviews/{id}/visibility`
### Offers — `GET/POST /expert/offers` · `POST offers/{id}/end`
### Loyalty — `GET /expert/loyalty/birthdays` · `POST loyalty/{user}/birthday-gift`
### Employment — `GET /expert/employment-requests` · `POST .../accept` · `POST .../reject`
### Reports — `GET /expert/reports?from&to`
### Courses — `GET/POST /expert/courses` · `POST/DELETE courses/{id}` ·
`POST courses/{id}/archive` · `GET courses/{id}/enrollments` ·
`PUT .../progress` · `POST .../certificate` · `GET /expert/certificates`
### Profile certificates — `GET/POST /expert/certificates-profile` · `DELETE .../{id}`
### Posts — `GET /expert/getMyPosts` · `DELETE /expert/deletePost/{id}`
### Stories — `GET /expert/getMyStories` · `DELETE /expert/deleteStory/{id}`
### Services — `GET /expert/services` · `DELETE /expert/services/{id}`
### Services — `GET/POST /expert/services` · `POST services/{id}` · `DELETE services/{id}` ·
`POST services/{id}/instructions` · `POST services/{id}/questions` ·
`POST services/{id}/min-bookings` · `GET/POST services/{id}/materials`
### Community — `GET /expert/followers` · `DELETE followers/{id}` ·
`GET /expert/blocked-users` · `POST/DELETE blocked-users/{id}`
### Inventory — `GET/POST /expert/inventory` · `GET inventory/{id}` ·
`POST inventory/{id}/update` · `DELETE inventory/{id}` · `POST inventory/{id}/restore` ·
`GET inventory/alerts` · `GET inventory/smart-alert` · `GET/POST inventory/{id}/movements`
### Chat — `GET /expert/chats` · `GET chats/unread-count` · `POST chats/open` ·
`GET/POST chats/{id}/messages` · `POST chats/{id}/read` · `DELETE chats/{id}/messages/{msg}`
### FCM — `POST /expert/device-token` · `DELETE /expert/device-token`

---

## 3. أخطاء فعلية كانت ستظهر عند التشغيل — وتم إصلاحها

1. **توكن مكتوب يدويًا في الكود**
   `reservations_bloc.dart` كان يبني `http.Request` بتوكن `Bearer 16|sP8Yv...`
   يخص جلسة مطوّر واحد. كان سيُرجع 401 لكل مستخدم آخر. حُذف بالكامل.

2. **رسائل الخطأ كلها "Unknown error"**
   `_extractMessage` لم يكن يقرأ `error_message`، وهو المفتاح الوحيد الذي يستخدمه
   `ApiResponseTrait::sendError`.

3. **`postMultipart` يبتلع الاستثناءات ويُرجع `null`**
   أي فشل في رفع صورة كان يمرّ بصمت ثم ينفجر لاحقًا كـ null-dereference.

4. **الجدول الأسبوعي كان يُمسح عند إضافة يوم**
   `PUT /calendar` يحذف الجدول كاملًا ثم يُدرج ما يصله. `addSchedule` كان يرسل
   يومًا واحدًا فقط. الآن: قراءة الأسبوع → دمج → إرسال الكل.

5. **ترقيم الأيام 1–7 بدل 0–6**
   الـ Backend يتحقق `between:0,6`. كل يوم كان يُخزَّن مُزاحًا، و"السبت" كان يفشل بـ 422.

6. **`updateProfile` يقرأ `response["data"]` غير الموجود**
   الـ Backend يحذف مفتاح `data` عندما يكون فارغًا → crash مؤكد.
   الآن يُعاد جلب البروفايل بدل تحليل رد فارغ.

7. **تدفّق استعادة كلمة المرور مكسور منطقيًا**
   `verify_otp` كان يُستدعى أولًا، وهو **يمسح `otp_code` من قاعدة البيانات**،
   فيفشل `reset_password` بعده حتمًا. الكود الآن يُمرَّر للشاشة التالية بدل استهلاكه.

8. **5 خانات OTP والكود 6 أرقام** → آخر رقم لا يُلتقط أبدًا.

9. **`profile.avatarUrl!` قبل فحص الـ null**
   في `settings_page.dart` كان الـ `!` يُنفَّذ قبل شرط `== null` بسطرين
   → أي خبير بلا صورة كان يُعطّل الشاشة.

10. **`double.parse(ser['price'])`**
    MySQL يُرجع أعمدة DECIMAL كنصوص أحيانًا وكأرقام أحيانًا → crash متقطّع.

11. **روابط الصور بلا `/storage/`** في 10 ملفات.

12. **FCM token يُطبع في الـ console ولا يُرسل لأي مكان** → لا يمكن لأي إشعار push
    أن يصل الجهاز.

13. **`following_count: 500`** و`experienceYears: 5` مثبّتة يدويًا.

14. **`GET /expert/inventory/trashed` — مسار غير موجود**
    شاشة "المواد المؤرشفة" كانت تستدعيه. Laravel كان سيطابقه مع
    `GET /expert/inventory/{item}` بقيمة `item = "trashed"` ويُرجع 404
    "المادة غير موجودة". الآلية الحقيقية هي `?with_archived=1` على مسار القائمة.

15. **أربع طلبات متطابقة في كل تحميل للمخزون**
    `getMaterials` + ثلاث دوال عدّادات، كلها تستدعي `GET /inventory`.
    صارت طلبًا واحدًا تُشتق منه العدّادات الثلاثة.

16. **`saveInstructions` كان يرسل `jsonEncode([...])`**
    بينما العمود `instructions` حقل TEXT واحد. كان تطبيق العميل سيعرض
    مصفوفة JSON خامًا للمستخدم. صارت الأسطر تُدمج بفواصل أسطر.

17. **`saveBasicInfo` كان يُرجع `0` عند الفشل بدل رمي استثناء**
    فيُكمل الـ wizard ويرسل التعليمات والأسئلة إلى `services/0/...`
    → 404 بلا سبب ظاهر للمستخدم.

18. **`saveQuestions` بقائمة فارغة** → الـ Backend يتحقق `array|min:1`
    فيُرجع 422 يبدو كعطل في الخادم، بينما إنهاء الـ wizard بلا أسئلة أمر مشروع.
    صار الاستدعاء يُتخطّى.

19. **`updateService` كان يرسل `instructions[0]` فقط** فتضيع باقي الأسطر.

20. **`import 'dart:ffi'` غير مستخدم** في `add_service_bloc` — يكسر بناء الويب.

20-أ. **تعارض بين Postman والـ Backend في مواد الخدمة**
    Postman يوثّق الحقل باسم `quantity_per_booking`، بينما
    `SyncServiceMaterialsRequest` يتحقق من `materials.*.quantity_per_session`
    وهو أيضًا اسم العمود في الـ migration. **اتّباع Postman هنا كان سيُرجع 422
    في كل مرة.** اعتمدتُ الـ Backend كما نصّ شرطك رقم 18.

20-ب. **رفع ستوري بعدة ملفات تحت مفتاح `media`**
    التحقق يتوقّع ملفًا واحدًا (`file`)، ورفع عدة ملفات بنفس المفتاح
    يجعل Laravel يراها مصفوفة فيرفضها. صار يُرسل ملف واحد فقط.
    كما أن **الستوري النصية (تعليق بلا صورة) كانت غير ممكنة من التطبيق**
    رغم أن الـ Backend يقبلها (`required_without`).

20-ج. **`e.toString()` يظهر للمستخدم** في بلوكات المنشور والستوري والخدمة —
    أي رسالة مثل `ApiException(422): ...` كانت تُعرض كما هي.

21. **`MaterialItemModel.fromJson` كان يبني رابط الصورة عبر
    `baseUrl.replaceAll('/api/expert', '')`** — ينكسر مع أي host أو prefix آخر.
    كما كان يقرأ `price` من عمود `wholesale_price` فيعرض السعرين متطابقين،
    ويُسنِد `stock_quantity` (وهو `float` في الـ Backend) إلى حقل `int`.

---

## 4. الواجهات التي عُدِّلت

**لم يتغيّر التصميم.** تم التحقق آليًا: `app_theme.dart` و`core/constants/`
(الألوان، الخطوط، المقاسات) و`assets/` **متطابقة حرفيًا** مع الأصل.

| الشاشة | ما أُضيف |
|---|---|
| Reviews | Skeleton / Empty / Error + pull-to-refresh |
| Job Requests | Skeleton / Empty / Error + refresh + snackbar للأخطاء |
| Home | Skeleton / Empty / Error + refresh |
| Reports | Loading / Error |
| Chats | Skeleton / Error |
| Chat Detail | Loading / Empty / Error + auto-scroll + عرض المرفقات |
| Settings | Error state + إصلاح crash الصورة |
| Offers | Skeleton / Error + تبويب المكافآت صار أعياد ميلاد حقيقية مع زر إهداء |
| Material Inventory | Skeleton / Error |

**ملاحظة متعمّدة:** `initializeNotification.dart` يطبع الـ FCM token في الـ console.
تركتُه كما هو التزامًا بشرط "لا تغيّر Firebase أو إعداداته"، لكن يُفضّل إزالة هذا
السطر قبل الإصدار.
| Profile / PostFeed | معالجة فشل تحميل الصور (`errorBuilder` + `loadingBuilder`) |
| Check Email / New Password | تمرير الـ OTP بدل استهلاكه |

### الواجهات الجديدة التي أُنشئت

أُنشئت أربع شاشات، كلها لـ endpoints موجودة فعلًا في الـ Backend ولم يكن لها
أي واجهة تصل إليها. **جميعها مبنية من مكوّنات المشروع الحالية**
(`SegmentedTabBar`, `StatBadgeRow`, `BottomSheetWrapper`, `PrimaryButton`,
`EmptyState`) ومن نفس الألوان والخطوط والمقاسات — بلا أي token أو نمط جديد.

| الشاشة | الـ endpoints | لماذا |
|---|---|---|
| **Audience** (`/community`) | `GET /followers` · `DELETE followers/{id}` · `GET /blocked-users` · `POST/DELETE blocked-users/{id}` | البروفايل كان يعرض رقم المتابعين فقط بلا أي وصول للأشخاص. تبويبان + بحث على الخادم + حظر/رفع حظر مع تأكيد. |
| **Stock Alerts** (`/inventory-alerts`) | `GET /inventory/alerts` · `GET /inventory/smart-alert` | التنبيه الذكي كان غير قابل للوصول إطلاقًا: يقارن حجوزات الغد بالمخزون ويحسب النقص لكل مادة. |
| **Stock History** (`/stock-movements`) | `GET/POST /inventory/{id}/movements` | الـ Backend يتتبّع المخزون عبر **حركات**، لا بتعديل مباشر. زر +/- في البطاقة لم يكن يغادر الجهاز أبدًا. |
| **Service Materials** (`/service-materials`) | `GET/POST /services/{id}/materials` | هذه هي القطعة الناقصة التي **تجعل التنبيه الذكي يعمل أصلًا** — بدون هذه الروابط يُرجع `smart-alert` قائمة فارغة مهما كان عدد الحجوزات. |

**نقاط الدخول** (بلا تغيير في أي تفاعل قائم):
- القائمة الجانبية: "Stock Alerts" تحت Business، و"Followers" تحت Growth.
- شاشة المخزون: أيقونة جرس في الـ AppBar → التنبيهات؛ **ضغطة مطوّلة** على البطاقة → سجل الحركات (الضغطة العادية ما زالت تفتح التعديل).
- بطاقة المادة في التنبيهات → سجل حركاتها مباشرة.
- قائمة الخدمات في البروفايل: أيقونة ثالثة → مواد الخدمة.

**ملاحظة على شاشة العروض:** تبويبا "Products Offers" و"Packages" لا يوجد لهما
Backend (انظر القسم 6-أ). استبدلتُهما برسالة تشرح السبب، لكنني **أبقيتُ الكلاسين
`_ProductOffersTab` و`_PackagesTab` كاملين في الملف** حتى يمكن إعادة تفعيلهما
بسطر واحد إذا أُضيفت الـ endpoints لاحقًا. سيُصنّفهما الـ analyzer كـ unused —
هذا متوقّع ومقصود.

---

## 5. Packages

**لم تُضف أي package.** `pubspec.yaml` متطابق حرفيًا مع الأصل
(`shared_preferences` و`http` و`image_picker` كانت موجودة أصلًا).

**لم تُغيَّر إعدادات البيئة.** تم التحقق: `android/`, `ios/`, `firebase.json`,
`firebase_options.dart` جميعها متطابقة مع الأصل.

---

## 6. ما لم يُربط — والسبب الدقيق

### أ) لا يوجد له API لدور الخبير إطلاقًا

| الشاشة | السبب |
|---|---|
| `my_store`, `add_product` | المنتجات موجودة تحت `warehouse` و`customer` فقط. لا يملك الخبير متجرًا في نموذج البيانات. |
| `cart_orders`, `order_detail` | السلة والطلبات = `POST /customer/cart/*`, `GET /customer/orders`. خلف حارس الـ customer. |
| `salons`, `salon_detail` | تصفّح مقدّمي الخدمة = `GET /customer/providers/*`. لا يوجد مقابل للخبير. |
| `notifications` | لا يوجد `GET /expert/notifications`. الـ Backend يكتب في جدول `notifications` لكنه لا يعرضه إلا للـ customer. |
| `plan` (الاشتراكات) | `GET /admin/subscription-plans` فقط. |
| `available_courses`, `enrollments` (كمتدرّب) | الخبير **يُنشئ** الدورات ولا يلتحق بها. `POST /customer/courses/{id}/enroll` خلف حارس الـ customer. |
| تبويبا "Products Offers" و"Packages" | `offers.service_id` مفتاح أجنبي إلى `services`. لا يوجد مفهوم عرض على منتج، ولا جدول packages إطلاقًا. |

**قراري في هذه الحالات:** تركتُ الشاشات تُحمّل فارغة مع تعليق يشرح السبب،
بدل عرض بيانات مُختلَقة تبدو حقيقية للمستخدم.

### ب) مربوط جزئيًا

- **Home feed**: يعرض منشورات الخبير نفسه (`getMyPosts`). لا يوجد feed لمنشورات
  الآخرين لهذا الدور. `isLiked` / `isFollowing` تبقى محلية لأن الإعجاب والمتابعة
  أفعال customer.
- **Home notifications**: مبنية على `employment-requests?status=pending`
  — أقرب بديل حقيقي وقابل للتنفيذ.
- **Stories strip**: يعرض الخبير نفسه فقط، للسبب أعلاه.

### ج) لم يبقَ شيء

كل endpoint متاح لدور الخبير أصبح مربوطًا بطبقة بيانات **وله واجهة تصل إليه**.

### الجولة الأخيرة — سدّ خمس ثغرات

1. **Add Discount كان يعرض "نجاح" بلا حفظ.** النموذج كان يستدعي
   `Future.delayed` ثم يُظهر النجاح، بينما `createDiscount()` جاهزة وغير
   مستخدَمة. رُبط الآن بـ `POST /expert/offers`، مع استبدال حقول التاريخ
   النصية بـ **date pickers** تُخرج `YYYY-MM-DD` (التحقق `date` كان سيرفض
   `18/6/2026` المكتوبة يدويًا)، والتحقق من `end > start` و`1..99` محليًا
   قبل الإرسال. زرّا "+" في تبويبي Products/Packages أُخفيا لأنهما يؤدّيان
   إلى نماذج لا Backend لها.

2. **My Courses** كان يقرأ من `CoursesRepository` الساكن بينما
   `TrainingRepository` مربوط بـ `GET /expert/courses` — نفس البيانات من
   مصدرين. صار `CoursesRepository` يفوّض إليه. والحذف صار **يصل الخادم فعلًا**
   بدل إزالة الصف من الذاكرة فقط (فيعود عند الفتح التالي).

3. **نموذج إنشاء/تعديل دورة** — شاشة جديدة `/add-course` تغطي
   `POST /expert/courses` و`POST /expert/courses/{id}`، بكل حقول
   `StoreCourseRequest` (غلاف، وصف، ساعات، حد أقصى للمتدربين، تواريخ،
   أونلاين/حضوري). مربوطة من زرّي "+" في الشاشتين، ومن `onEdit` على البطاقة.
   كما رُبط `onViewStudents` بشاشة الالتحاقات مع تمرير `courseId`.

4. **شاشة تغيير كلمة السر** — `/change-password`. تُنبّه المستخدم أن الخادم
   **يُبطل كل التوكنات** عند النجاح، ولذلك تعيده إلى تسجيل الدخول بدل الرجوع.

5. **اللغة تُحفظ الآن** عبر `StorageService.saveLocale` وتُقرأ **بشكل متزامن**
   عند الإقلاع (`StorageService.init()` يسبق `runApp`)، فلا وميض للغة الخاطئة
   في أول إطار. لا تُمسح عند تسجيل الخروج — اللغة تفضيل جهاز لا بيانات جلسة.

---

## 7. قائمة فحص قبل أول build

1. `flutter pub get` ثم `flutter analyze` — وأرسلي لي الأخطاء.
2. **عنوان الـ Backend**: المحاكي لا يرى `127.0.0.1` (يشير إلى المحاكي نفسه):
   ```
   flutter run --dart-define=BASE_URL=http://10.0.2.2:8000
   ```
   أو عدّلي `defaultValue` في `core/config/app_config.dart`.
3. **الصور**: تأكدي من `php artisan storage:link` على الـ Backend،
   وإلا فكل روابط `/storage/` سترجع 404.
4. **أولوية الاشتباه**: الشاشات التي غيّرتُ حالات الـ BLoC فيها من متزامنة إلى
   `async` — الدورات، الشهادات، العروض، الحجوزات. هذه أكثر ما قد يُظهر
   أخطاء نوع أو `await` ناقص.
5. `analysis_options.yaml` لم يُمسّ، لذا قد تظهر تحذيرات lint على كود قديم
   لم أعدّله — تجاهليها في هذه المرحلة.

---

## 8. اقتراح للمرحلة التالية

بالترتيب حسب الأثر:

1. تشغيل `flutter analyze` وإصلاح ما يظهر (أساسي قبل أي شيء).
2. اختبار Login → Bookings → Reviews مقابل Backend حقيقي.
3. ربط Material Inventory و Add/Edit Service.
4. اتخاذ قرار بشأن شاشات القسم 6-أ: إما إخفاؤها من القائمة الجانبية،
   أو إضافة endpoints لها في الـ Backend.


---

# ملحق: جولة الميزات السبع (Shop / Discovery)

هذه الجولة تعتمد **كليًا** على إضافات الـ Backend في
`backend_expert_additions.zip`. بدون تشغيل الـ migration وإضافة الـ routes،
كل الـ endpoints الجديدة ترجع 404.

## طبقتان جديدتان

| الملف | يغطي |
|---|---|
| `data/repositories/shop_repository.dart` | كتالوج المستودع · السلة · الدفع · طلبات الشراء · متجر الخبير (CRUD) · الطلبات الواردة |
| `data/repositories/discovery_repository.dart` | تصفّح المزوّدين · المتابعة · feed المنشورات · ستوريات المتابَعين |

## الوحدات المربوطة

| الطلب | ما تم |
|---|---|
| ١. تبويب Products في الحجوزات | `store_orders_cubit` جديد؛ الصفحة على `GET /store/orders` مع pull-to-refresh |
| ٢. ستوريات الآخرين | شريط الستوري صار يضم المتابَعين؛ `getProviderStory()` يبني الريل ويسجّل المشاهدة |
| ٣. منتجات المستودع + التفاصيل + السلة | `product_detail_cubit` جديد؛ شاشة التفاصيل كانت مكتوبة يدويًا بالكامل |
| ٤. My Store + السلة + الطلبات | CRUD كامل + قائمة تعديل/حذف على البطاقة + السلة والطلبات على الخادم |
| ٥. صور البوستات والبروفايل | `discover/feed` مع fallback إلى `getMyPosts` عند 404 |
| ٦. الصالونات والمراكز + المتابعة | قائمة + تفاصيل + متابعة، مع `SalonDetailArgs` لتمرير النوع |
| ٧. أزرار العروض/الباقات | **لم يُنفَّذ** — لا يدعمه مخطط قاعدة البيانات (انظر أدناه) |

## أخطاء صامتة أُصلحت في هذه الجولة

1. **`MyStoreAddToCart` كان `TODO` فارغًا** — زر السلة لم يكن يفعل شيئًا إطلاقًا.
2. **`OrderDetailBloc` كان يعرض أول طلب في القائمة** عند عدم إيجاد المطلوب،
   أي طلب شخص آخر. صار يعرض رسالة خطأ.
3. **إلغاء الطلب** كان يحذف الصف من الذاكرة فقط فيعود عند الفتح التالي.
4. **`salon_detail`** كان سيعرض تقييمات الخبير نفسه على صفحة صالون آخر.
5. **`ProductDetailPage`** كان يعرض صورتين من Unsplash واسم "Serum" وسعر 15
   وزر "Book Now" غير موصول — على منتج شراء لا حجز.
6. **`product_card` كان `Image.asset(product.imageUrl!)`** — انهيار مؤكد لأي
   منتج بلا صورة، وتحميل مسار خادم كأصل محلي.
7. **`SKU` مطلوب في الـ Backend والنموذج لا يجمعه** — أُضيف توليد تلقائي
   (`ROSSER-4821`) بدل فشل تحقق مؤكد.

## قرارات تصميم تستحق الانتباه

**السلة تُدار من الخادم بالكامل.** كل تعديل يُرجع السلة كاملة، فالمجموع لا
يُحسب محليًا ولا يمكن أن يختلف عمّا سيُحاسب عليه الدفع.

**`OrderModel.serverTotal` حقل جديد.** الطلب قد يشمل بائعَين، وendpoints
المتجر تُرجع مجموعًا محصورًا ببنود المُنادي — وهو ليس مجموع البنود المحمّلة.

**`SalonDetailArgs`.** الصالونات والمراكز جدولان منفصلان وقد يتشاركان نفس
الـ id، فالنوع يسافر مع المعرّف.

## البند السابع — لماذا لم يُنفَّذ

`offers.service_id` مفتاح أجنبي إلى `services`؛ لا يوجد `product_id` ولا
جدول `packages`. تفعيلهما يحتاج **قرار تصميم منتج** لا إصلاح خطأ:

- **عرض على منتج:** عمود `product_id` nullable في `offers` + تعديل التحقق.
- **باقات:** جدولان جديدان `packages` و`package_items`.

تبويب Rewards يعمل فعلًا عبر `GET /expert/loyalty/birthdays`.
