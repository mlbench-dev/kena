import 'package:flutter/material.dart';

/// =========================================================
/// CLIPPERS (USED FOR IMAGES)
/// =========================================================

// -------------------
// TOP LEFT CLIPPER
// -------------------
class TopLeftRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => TrianglePaths.topLeft(size);

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}

// -------------------
// BOTTOM CLIPPER
// -------------------
class BottomRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => TrianglePaths.bottom(size);

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}

// -------------------
// RIGHT SIDE CLIPPER
// -------------------
class RightSideRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => TrianglePaths.right(size);

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}

/// =========================================================
/// PATH BUILDER (REUSABLE FOR BOTH CLIPPER & PAINTER)
/// =========================================================

class TrianglePaths {
  static double r = 10.0;

  static Path topLeft(Size size) {
    final path = Path();

    path.moveTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.lineTo(size.width * 0.98 - r, 0);
    path.quadraticBezierTo(size.width * 0.98, 0, size.width * 0.96, r);

    path.lineTo(size.width * 0.495 + r, size.height * 0.495 - r);
    path.quadraticBezierTo(
      size.width * 0.495,
      size.height * 0.495,
      size.width * 0.495 - r,
      size.height * 0.495,
    );

    path.lineTo(r, size.height * 0.94 - r);
    path.quadraticBezierTo(0, size.height * 0.94, 0, size.height * 0.94 - r);

    path.close();
    return path;
  }

  static Path bottom(Size size) {
    final path = Path();

    path.moveTo(0, size.height * 0.98 - r);
    path.quadraticBezierTo(0, size.height * 0.98, r, size.height * 0.98);

    path.lineTo(size.width * 0.96 - r, size.height * 0.98);
    path.quadraticBezierTo(
      size.width * 0.96,
      size.height * 0.98,
      size.width * 0.94,
      size.height * 0.98 - r,
    );

    path.lineTo(size.width * 0.495 + r, size.height * 0.505 + r);
    path.quadraticBezierTo(
      size.width * 0.495,
      size.height * 0.505,
      size.width * 0.495 - r,
      size.height * 0.505 + r,
    );

    path.close();
    return path;
  }

  static Path right(Size size) {
    final path = Path();

    path.moveTo(size.width * 0.98 - r, size.height * 0.08);
    path.quadraticBezierTo(
      size.width * 0.98,
      size.height * 0.08,
      size.width * 0.98,
      size.height * 0.08 + r,
    );

    path.lineTo(size.width * 0.98, size.height * 0.92 - r);
    path.quadraticBezierTo(
      size.width * 0.98,
      size.height * 0.92,
      size.width * 0.98 - r,
      size.height * 0.92,
    );

    path.lineTo(size.width * 0.51 + r, size.height * 0.5 + r / 2);
    path.quadraticBezierTo(
      size.width * 0.51,
      size.height * 0.5,
      size.width * 0.51 + r,
      size.height * 0.5 - r / 2,
    );

    path.close();
    return path;
  }
}

/// =========================================================
/// SOLID BORDER PAINTER (FOR EMPTY STATE)
/// =========================================================

class TriangleBorderPainter extends CustomPainter {
  final Path Function(Size size) buildPath;

  TriangleBorderPainter({required this.buildPath});

  @override
  void paint(Canvas canvas, Size size) {
    final path = buildPath(size);

    // Transparent fill
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.fill,
    );

    // ✅ SOLID BORDER (NO DASH)
    canvas.drawPath(
      path,
      Paint()
        ..color = Color(0xff21573b)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
