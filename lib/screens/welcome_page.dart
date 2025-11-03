import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class WelcomePage extends StatefulWidget {

  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  bool _isLoginPressed = false;
  bool _isRegisterPressed = false;
  late AnimationController _animationController;
  late AnimationController _logoAnimationController;
  late Animation<double> _animation;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<Offset> _logoPosition;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.elasticOut),
    );
    _logoPosition = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeOut),
    );
    _logoAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _logoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFFEF3A16), const Color(0xFFFF5A00), _animation.value)!,
                      Color.lerp(const Color(0xFFFF5A00), const Color(0xFFEF3A16), _animation.value)!,
                      Color.lerp(const Color(0xFFEF3A16), const Color(0xFF8B0000), _animation.value * 0.5)!,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),
          ...List.generate(18, (index) {
            return Positioned(
              left: (index * 48.0) % MediaQuery.of(context).size.width,
              top: (index * 72.0) % MediaQuery.of(context).size.height,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -40 * _animation.value),
                    child: Opacity(
                      opacity: (1 - _animation.value) * 0.6,
                      child: Container(
                        width: 3 + (index % 3) * 2,
                        height: 3 + (index % 3) * 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          Positioned.fill(
            child: IgnorePointer(
              child: ClipPath(
                clipper: _DiagonalClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _logoPosition,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.8),
                              blurRadius: 10,
                              offset: const Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              colors: [Colors.transparent, Colors.transparent],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstOut,
                          child: const Icon(
                            Icons.restaurant,
                            size: 68,
                            color: Color(0xFFEF3A16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FadeTransition(
                  opacity: _logoOpacity,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _logoAnimationController,
                      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                    )),
                    child: const Text(
                      'CookBook',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _logoOpacity,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _logoAnimationController,
                      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                    )),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        'Gắn kết yêu thương từ gian bếp nhỏ.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTapDown: (_) {
                      setState(() { _isLoginPressed = true; });
                    },
                    onTapUp: (_) {
                      setState(() { _isLoginPressed = false; });
                    },
                    onTapCancel: () {
                      setState(() { _isLoginPressed = false; });
                    },
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _isLoginPressed ? const Color(0xFFFF5A00) : const Color(0xFFEF3A16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          width: 1,
                          color: Colors.white,
                        ),
                        boxShadow: _isLoginPressed
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF5A00).withOpacity(0.28),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: const Center(
                        child: Text(
                          'Đăng Nhập',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTapDown: (_) {
                      setState(() { _isRegisterPressed = true; });
                    },
                    onTapUp: (_) {
                      setState(() { _isRegisterPressed = false; });
                    },
                    onTapCancel: () {
                      setState(() { _isRegisterPressed = false; });
                    },
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _isRegisterPressed ? const Color(0xFFFF5A00).withOpacity(0.10) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isRegisterPressed ? const Color(0xFFFF5A00) : const Color(0xFFEF3A16),
                          width: 2,
                        ),
                        boxShadow: _isRegisterPressed
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF5A00).withOpacity(0.22),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                      ),
                      child: Center(
                        child: Text(
                          'Đăng Ký',
                          style: TextStyle(
                            color: _isRegisterPressed ? const Color(0xFFFF5A00) : const Color(0xFFEF3A16),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.35);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.30,
      size.width * 0.5,
      size.height * 0.36,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.42,
      size.width,
      size.height * 0.36,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
