import 'package:flutter/material.dart';
import '../utils/performance_utils.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.tablet) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveBreakpoints.getResponsivePadding(context);
    
    return Container(
      padding: padding ?? EdgeInsets.all(responsivePadding),
      margin: margin,
      child: child,
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double baseFontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.baseFontSize = 16.0,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveFontSize = ResponsiveBreakpoints.getResponsiveFontSize(
      context, 
      baseFontSize,
    );

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: responsiveFontSize,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveBreakpoints.getResponsivePadding(context);
    
    return Card(
      elevation: elevation ?? 4,
      margin: margin ?? EdgeInsets.all(responsivePadding / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(responsivePadding),
        child: child,
      ),
    );
  }
}