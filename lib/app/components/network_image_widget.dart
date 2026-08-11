// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:kena/app/components/loading_widget.dart';
// import 'package:flutter/material.dart';

// //custom network image widget, we will used this widget show images, also handled exceptions
// // this widget is generic, we can change it and this change will appear across the app
// class NetworkImageWidget extends StatelessWidget {
//   const NetworkImageWidget({
//     required this.imageUrl,
//     super.key,
//     this.width = 40,
//     this.height = 40,
//     this.borderRadius = 18,
//     this.iconSize = 20,
//     this.boxFit = BoxFit.cover,
//   });
//   final String imageUrl;
//   final double width;
//   final double height;
//   final double borderRadius;
//   final double iconSize;
//   final BoxFit boxFit;

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(borderRadius),
//       child: imageUrl == ''
//           ? Container(
//               width: width,
//               height: height,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade900,
//                 borderRadius: BorderRadius.circular(borderRadius),
//               ),
//               child: Icon(Icons.person_outline, size: iconSize),
//             )
//           : CachedNetworkImage(
//               imageUrl: imageUrl,
//               width: width,
//               height: height,
//               imageBuilder: (context, imageProvider) => Container(
//                 width: width,
//                 height: height,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(borderRadius),
//                   image: DecorationImage(image: imageProvider, fit: boxFit),
//                 ),
//               ),
//               placeholder: (context, url) => Container(
//                 width: width,
//                 height: height,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade900,
//                   borderRadius: BorderRadius.circular(borderRadius),
//                 ),
//                 child: const Padding(
//                   padding: EdgeInsets.all(12),
//                   child: LoadingWidget(),
//                 ),
//               ),
//               errorWidget: (context, url, error) => Container(
//                 width: width,
//                 height: height,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade900,
//                   borderRadius: BorderRadius.circular(13),
//                 ),
//                 child: Icon(Icons.error_outline, size: iconSize),
//               ),
//             ),
//     );
//   }
// }
