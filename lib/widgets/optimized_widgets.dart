import 'package:flutter/material.dart';
import '../utils/performance_utils.dart';

// Optimized ListView with lazy loading
class OptimizedListView extends StatefulWidget {
  final List<dynamic> items;
  final Widget Function(BuildContext, int) itemBuilder;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final Widget? loadingWidget;

  const OptimizedListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.loadingWidget,
  }) : super(key: key);

  @override
  _OptimizedListViewState createState() => _OptimizedListViewState();
}

class _OptimizedListViewState extends State<OptimizedListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (widget.hasMore && widget.onLoadMore != null) {
        widget.onLoadMore!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return widget.loadingWidget ?? 
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
        }
        return widget.itemBuilder(context, index);
      },
    );
  }
}

// Optimized animated container
class OptimizedAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onTap;

  const OptimizedAnimatedContainer({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        child: child,
      ),
    );
  }
}

// Cached network image with optimization
class CachedOptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const CachedOptimizedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PerformanceUtils.optimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

// Optimized form field with debouncing
class OptimizedTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Duration debounceDuration;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final int? maxLines;

  const OptimizedTextField({
    Key? key,
    this.labelText,
    this.hintText,
    this.controller,
    this.onChanged,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  _OptimizedTextFieldState createState() => _OptimizedTextFieldState();
}

class _OptimizedTextFieldState extends State<OptimizedTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      validator: widget.validator,
      maxLines: widget.maxLines,
      onChanged: (value) {
        if (widget.onChanged != null) {
          PerformanceUtils.debounce(
            'textfield_${widget.labelText ?? 'default'}',
            widget.debounceDuration,
            () => widget.onChanged!(value),
          );
        }
      },
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}