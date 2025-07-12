import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  
  late AnimationController _titleAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _fadeController;
  
  late Animation<double> _titleSlideAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<double> _contentSlideAnimation;
  late Animation<double> _contentOpacityAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonOpacityAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> splashData = [
    {
      "image": "assets/parking_spot.png",
      "text": "🅿️ Discover Available Parking\nSpots Near You"
    },
    {
      "image": "assets/secure_booking.png",
      "text": "📱 Reserve Your Spot\nInstantly with One Tap"
    },
    {
      "image": "assets/navigation_map.png",
      "text": "🗺️ Smart Directions\nto Your Reserved Spot"
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Initialize animations
    _titleSlideAnimation = Tween<double>(
      begin: -50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _titleOpacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeOut,
    ));
    
    _contentSlideAnimation = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _contentOpacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOut,
    ));
    
    _buttonScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _buttonOpacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _titleAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _contentAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _buttonAnimationController.forward();
    
    _fadeController.forward();
  }

  void _resetAnimations() {
    _contentAnimationController.reset();
    _buttonAnimationController.reset();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      _contentAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _buttonAnimationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _contentAnimationController.dispose();
    _buttonAnimationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00BCD4), // Cyan
              Color(0xFF2196F3), // Blue
              Color(0xFF9C27B0), // Purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Animated App Title
              AnimatedBuilder(
                animation: _titleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _titleSlideAnimation.value),
                    child: Opacity(
                      opacity: _titleOpacityAnimation.value,
                      child: const Text(
                        'ParkEase',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Content area with white background
              Expanded(
                child: AnimatedBuilder(
                  animation: _fadeController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            // PageView for content
                            Expanded(
                              child: PageView.builder(
                                controller: _controller,
                                itemCount: splashData.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                  _resetAnimations();
                                },
                                itemBuilder: (context, index) => AnimatedSplashContent(
                                  image: splashData[index]["image"]!,
                                  text: splashData[index]["text"]!,
                                  contentAnimation: _contentAnimationController,
                                  slideAnimation: _contentSlideAnimation,
                                  opacityAnimation: _contentOpacityAnimation,
                                ),
                              ),
                            ),
                            // Bottom section with indicators and button
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                children: [
                                  // Animated Dot indicators
                                  AnimatedBuilder(
                                    animation: _buttonAnimationController,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _buttonOpacityAnimation.value,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(
                                            splashData.length,
                                            (index) => buildDot(index),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 30),
                                  // Animated Button
                                  AnimatedBuilder(
                                    animation: _buttonAnimationController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _buttonScaleAnimation.value,
                                        child: Opacity(
                                          opacity: _buttonOpacityAnimation.value,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (_currentIndex == splashData.length - 1) {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                                          LoginScreen(),
                                                      transitionsBuilder:
                                                          (context, animation, secondaryAnimation, child) {
                                                        return FadeTransition(
                                                          opacity: animation,
                                                          child: child,
                                                        );
                                                      },
                                                      transitionDuration: const Duration(milliseconds: 500),
                                                    ),
                                                  );
                                                } else {
                                                  _controller.nextPage(
                                                    duration: const Duration(milliseconds: 400),
                                                    curve: Curves.easeInOutCubic,
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF4A90E2),
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                minimumSize: const Size(double.infinity, 55),
                                                elevation: 3,
                                              ),
                                              child: AnimatedSwitcher(
                                                duration: const Duration(milliseconds: 300),
                                                child: Text(
                                                  _currentIndex == splashData.length - 1
                                                      ? "Get Started"
                                                      : "Next",
                                                  key: ValueKey(_currentIndex == splashData.length - 1),
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AnimatedContainer buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentIndex == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentIndex == index 
            ? const Color(0xFF4A90E2) 
            : Colors.grey[400],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class AnimatedSplashContent extends StatelessWidget {
  final String image, text;
  final AnimationController contentAnimation;
  final Animation<double> slideAnimation;
  final Animation<double> opacityAnimation;

  const AnimatedSplashContent({
    super.key,
    required this.image,
    required this.text,
    required this.contentAnimation,
    required this.slideAnimation,
    required this.opacityAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Animated Image
          Expanded(
            flex: 4,
            child: AnimatedBuilder(
              animation: contentAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, slideAnimation.value),
                  child: Opacity(
                    opacity: opacityAnimation.value,
                    child: Hero(
                      tag: image,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              spreadRadius: 3,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: AnimatedScale(
                          scale: opacityAnimation.value,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutBack,
                          child: Image.asset(
                            image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          // Animated Text content
          Expanded(
            flex: 1,
            child: AnimatedBuilder(
              animation: contentAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, slideAnimation.value * 0.5),
                  child: Opacity(
                    opacity: opacityAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 600),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: const Color(0xFF2C3E50),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}