import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;          // حجم الشعار (عرض وارتفاع)
  final bool showShadow;      // هل يظهر ظل؟
  final EdgeInsets margin;    // مسافة خارجية
  final VoidCallback? onTap;  // وظيفة عند الضغط (اختياري)

  const AppLogo({
    super.key,
    this.size = 80,
    this.showShadow = true,
    this.margin = EdgeInsets.zero,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: showShadow
                  ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
                  : null,
            ),
            child: ClipOval(
              child: Image.asset(
                'images/bb.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.recycling_outlined,
                  size: size * 0.6,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}