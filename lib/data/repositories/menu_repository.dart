import 'package:flutter/material.dart';
import '../../core/storage/storage_service.dart';
import '../models/menu_models.dart';
import '../../core/routes/route_names.dart';

/// Static data source defining the side drawer's sections and items,
/// matching the Figma "menu" frame (Business / Growth / Account).
class MenuRepository {
  const MenuRepository();

  Future<List<MenuSectionModel>> getSections() async{
   String? lang =await StorageService. getLocale();
    return [
        MenuSectionModel(
          title:lang=="ar"? 'العمل':  'Business',
          items: [
            MenuItemModel(
              id: 'material',
              label:lang=="ar"? 'مخزون المواد': 'Material',
              icon: Icons.inventory_2_outlined,
              routeName: RouteNames.materialInventory,
            ),
             MenuItemModel(
              id: 'job_requests',
              label:lang=="ar"? 'وظائف العمل': 'Job Requests',
              icon: Icons.work_outline,
              routeName: RouteNames.jobRequests,
            ),
             MenuItemModel(
              id: 'salons',
              label:lang=="ar"? 'الصالونات والمراكز': 'Salons & Center',
              icon: Icons.storefront_outlined,
              routeName: RouteNames.salons,
            ),
             MenuItemModel(
              id: 'stock_alerts',
              label:lang=="ar"? 'تنبيهات المخزون':  'Stock Alerts',
              icon: Icons.notification_important_outlined,
              routeName: RouteNames.inventoryAlerts,
            ),
          ],
        ),
         MenuSectionModel(
          title:lang=="ar"? 'النمو':  'Growth',
          items: [
            MenuItemModel(
              id: 'offers',
              label:lang=="ar"? 'العروض والننزيلات':  'Offers & Discounts',
              icon: Icons.local_offer_outlined,
              routeName: RouteNames.offers,
            ),
            MenuItemModel(
              id: 'reviews',
              label:lang=="ar"? 'التقيمات':  'Reviews',
              icon: Icons.reviews_outlined,
              routeName: RouteNames.reviews,
            ),
            MenuItemModel(
              id: 'training',
              label:lang=="ar"? 'الدورات التدريبية':  'Training Courses',
              icon: Icons.school_outlined,
              routeName: RouteNames.trainingCourses,
            ),
            MenuItemModel(
              id: 'community',
              label:lang=="ar"? 'المتابعين':  'Followers',
              icon: Icons.people_outline,
              routeName: RouteNames.community,
            ),
          ],
        ),
         MenuSectionModel(
          title:lang=="ar"? 'الحساب':  'Account',
          items: [
            MenuItemModel(
              id: 'reports',
              label:lang=="ar"? 'التقارير':  'Reports',
              icon: Icons.bar_chart_outlined,
              routeName: RouteNames.reports,
            ),
            MenuItemModel(
              id: 'settings',
              label:lang=="ar"? 'الأعدادات':  'Setting',
              icon: Icons.settings_outlined,
              routeName: RouteNames.settings,
            ),
          ],
        ),
      ];
}}
