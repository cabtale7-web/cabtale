import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class PagerContent extends StatefulWidget {
  const PagerContent({
    super.key,
    required this.image,
    required this.text,
    required this.index,
  });

  final String image;
  final String text;
  final int index;

  @override
  State<PagerContent> createState() => _PagerContentState();
}

class _PagerContentState extends State<PagerContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _textScaleAnim;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2), // smaller offset so it's quicker
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _textScaleAnim = Tween<double>(begin: 0.97, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedText(BuildContext context) {
    return ScaleTransition(
      scale: _textScaleAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeExtraLarge),
              child: Text(
                widget.text,
                style: textMedium.copyWith(
                  color: Colors.white,
                  fontSize: 30, // slightly smaller for balance
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  height: 1.3,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(1.5, 1.5),
                    ),
                  ],
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index != 3) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          // Animated Background
          Positioned(
            bottom: 50,
            right: 0,
            left: -130,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SizedBox(
                  width: 600,
                  height: 600,
                  child: Image.asset(
                    Images.splashBackgroundOne,
                    fit: BoxFit.fitHeight,
                    color: Colors.black.withOpacity(0.25),
                    alignment: widget.index == 0
                        ? Alignment.centerLeft
                        : widget.index == 1
                        ? Alignment.centerRight
                        : Alignment.center,
                  ),
                ),
              ),
            ),
          ),

          // Foreground Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              _buildAnimatedText(context),
              const Spacer(),
              FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                    widget.index != 0 ? Dimensions.paddingSizeLarge : 0,
                  ),
                  child: Image.asset(
                    widget.image,
                    height: MediaQuery.of(context).size.height * 0.45,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ],
          ),
        ],
      );
    } else {
      // Last Page (index == 3)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _fadeAnim,
            child: Image.asset(
              widget.image,
              height: MediaQuery.of(context).size.height * 0.6,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          _buildAnimatedText(context),
        ],
      );
    }
  }
}
