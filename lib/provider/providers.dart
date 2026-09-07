import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:kena_emotional_journey/provider/auth/locale_provider.dart';
import 'package:kena_emotional_journey/provider/connectivity_provider.dart';
import 'package:kena_emotional_journey/provider/user_home_provider.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/provider/weekly_sharing_provider.dart';

// final List<VendorModel> initialVendors = [
//   VendorModel(
//     name: 'Harry Brook',
//     address: '15 Maiden Ln Suite 908, New York, NY 10038',
//     location: LatLng(31.50293, 74.34801),
//     // menu: '50 products',
//     // hours: '10 Hours',
//     phone: '09876542',
//     email: 'harry@brook.com',
//     vendorType: 'Food vendor',
//     menu: [
//       MenuItemModel(
//         itemName: 'First Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//       MenuItemModel(
//         itemName: 'Second Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//       MenuItemModel(
//         itemName: 'Third Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//     ],
//     hoursADay: '10 Hours',
//     profileImage:
//         'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=800&q=80',
//   ),
//   VendorModel(
//     name: 'Emma Stone',
//     email: 'emma@stone.com',
//     phone: '09876542',
//     address: '22 Broadway, New York, NY 10007',
//     location: LatLng(31.46719, 74.26598),
//     vendorType: 'Grocery vendor',
//     menu: [
//       MenuItemModel(
//         itemName: 'First Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//       MenuItemModel(
//         itemName: 'Second Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//     ],
//     hoursADay: '10 Hours',
//     profileImage:
//         'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?q=80&w=1074&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//   ),
//   VendorModel(
//     name: 'Tom Hanks',
//     address: '34 Wall Street, New York, NY 10005',
//     location: LatLng(31.47124, 74.35593),
//     vendorType: 'Electronics vendor',
//     phone: '09876542',
//     email: 'tom@hank.com',
//     menu: [
//       MenuItemModel(
//         itemName: 'First Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//       MenuItemModel(
//         itemName: 'Second Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//       MenuItemModel(
//         itemName: 'Third Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//       MenuItemModel(
//         itemName: 'Fourth Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//       MenuItemModel(
//         itemName: 'Fifth Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//     ],
//     hoursADay: '10 Hours',
//     profileImage:
//         'https://images.unsplash.com/photo-1519520104014-df63821cb6f9?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//   ),
//   VendorModel(
//     name: 'Sophia Lee',
//     address: '10 Park Ave, New York, NY 10016',
//     location: LatLng(31.450, 74.310),
//     vendorType: 'Clothing vendor',
//     phone: '09876542',
//     email: 'sophia@lee.com',
//     menu: [
//       MenuItemModel(
//         itemName: 'First Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//       MenuItemModel(
//         itemName: 'Second Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//       MenuItemModel(
//         itemName: 'Third Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//       MenuItemModel(
//         itemName: 'Fourth Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//       MenuItemModel(
//         itemName: 'Fifth Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//       MenuItemModel(
//         itemName: 'Sixth Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//       MenuItemModel(
//         itemName: 'Seventh Item',
//         servings: [
//           ServingModel(servingQuantity: 'Single Serving', servingPrice: '\$73'),
//         ],
//       ),
//     ],
//     hoursADay: '10 Hours',
//     profileImage:
//         'https://images.unsplash.com/photo-1762844877991-54c007866283?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//   ),
// ];

final providers = <SingleChildWidget>[
  // ChangeNotifierProvider(create: (_) => NavigationProvider()),
  // ChangeNotifierProvider(create: (_) => DoctorProvider(), lazy: false),
  ChangeNotifierProvider(create: (_) => LocaleNotifier()),
  ChangeNotifierProvider(create: (_) => UserHomeProvider()),
  ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
  ChangeNotifierProvider(create: (_) => NavigationActionsController()),
  ChangeNotifierProvider(create: (_) => WeeklySharingController()),
  // ChangeNotifierProvider(
  //   create: (_) => UserHomeProvider(vendors: initialVendors),
  // ),
  // ChangeNotifierProvider(create: (_) => FilterProvider()),
  // Add more providers here
];
