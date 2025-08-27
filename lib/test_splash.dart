import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RISAQ Splash Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: const AnimatedSplashScreen(),
    );
  }
}

/// 🌙✨ Écran de démarrage spectaculaire avec animations premium
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  // Controllers principaux
  late AnimationController _masterController;
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _shineController;
  late AnimationController _textController;
  
  // Animations complexes
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoBlur;
  late Animation<Offset> _logoSlide;
  
  // Animations de particules
  late Animation<double> _particleSpread;
  late Animation<double> _particleOpacity;
  
  // Animations d'ondes
  late Animation<double> _waveScale;
  late Animation<double> _waveOpacity;
  
  // Animation de brillance
  late Animation<double> _shinePosition;
  late Animation<double> _shineOpacity;
  
  // Animation du texte
  late Animation<double> _textScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  
  // Particules
  final List<Particle> _particles = [];
  
  @override
  void initState() {
    super.initState();
    
    // Vibration subtile au démarrage
    HapticFeedback.lightImpact();
    
    _initializeAnimations();
    _generateParticles();
    _startAnimationSequence();
  }
  
  void _initializeAnimations() {
    // Controller principal avec durée totale
    _masterController = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    );
    
    // Controller du logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Controller des particules
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Controller des ondes
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    // Controller de brillance
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Controller du texte
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Animations du logo avec courbes sophistiquées
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
    ]).animate(_logoController);
    
    _logoRotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -0.5, end: 0.1)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.1, end: 0.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_logoController);
    
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    _logoBlur = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 10.0, end: 0.0),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_logoController);
    
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutQuart,
    ));
    
    // Animations des particules
    _particleSpread = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOutExpo,
    ));
    
    _particleOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.8),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 0.8),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 0.0),
        weight: 30,
      ),
    ]).animate(_particleController);
    
    // Animations des ondes
    _waveScale = Tween<double>(
      begin: 0.5,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeOut,
    ));
    
    _waveOpacity = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeOut,
    ));
    
    // Animation de brillance
    _shinePosition = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shineController,
      curve: Curves.easeInOut,
    ));
    
    _shineOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.5),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 0.5),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 0.0),
        weight: 20,
      ),
    ]).animate(_shineController);
    
    // Animations du texte
    _textScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));
    
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));
    
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutQuart,
    ));
  }
  
  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(
        position: Offset(
          random.nextDouble() * 2 - 1,
          random.nextDouble() * 2 - 1,
        ),
        size: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 0.5 + 0.5,
        angle: random.nextDouble() * math.pi * 2,
        opacity: random.nextDouble() * 0.6 + 0.2,
      ));
    }
  }
  
  Future<void> _startAnimationSequence() async {
    // Séquence d'animations orchestrée
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Démarrer le logo avec effet d'entrée spectaculaire
    _logoController.forward();
    
    // Déclencher les ondes après 300ms
    await Future.delayed(const Duration(milliseconds: 300));
    _waveController.repeat();
    
    // Particules après 500ms
    await Future.delayed(const Duration(milliseconds: 500));
    _particleController.forward();
    
    // Brillance après 800ms
    await Future.delayed(const Duration(milliseconds: 800));
    _shineController.forward();
    
    // Texte après 1200ms
    await Future.delayed(const Duration(milliseconds: 1200));
    _textController.forward();
    
    // Vibration de confirmation
    await Future.delayed(const Duration(milliseconds: 500));
    HapticFeedback.mediumImpact();
  }
  
  @override
  void dispose() {
    _masterController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _shineController.dispose();
    _textController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          // Fond avec gradient sophistiqué
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  const Color(0xFF1E3A5F).withOpacity(0.3),
                  const Color(0xFF0A0E21),
                  Colors.black,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          
          // Effet de particules flottantes
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: ParticlePainter(
                  particles: _particles,
                  progress: _particleSpread.value,
                  opacity: _particleOpacity.value,
                ),
              );
            },
          ),
          
          // Logo principal avec effets
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _logoController,
                _waveController,
                _shineController,
              ]),
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ondes d'énergie
                    ..._buildEnergyWaves(),
                    
                    // Logo avec transformations 3D
                    SlideTransition(
                      position: _logoSlide,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_logoRotation.value)
                          ..scale(_logoScale.value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Halo lumineux
                              Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.cyan.withOpacity(0.3 * _logoOpacity.value),
                                      Colors.blue.withOpacity(0.1 * _logoOpacity.value),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyan.withOpacity(0.5 * _logoOpacity.value),
                                      blurRadius: 50,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Logo avec effet de flou et brillance
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: _logoBlur.value,
                                    sigmaY: _logoBlur.value,
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        begin: Alignment(-1 + _shinePosition.value, -1),
                                        end: Alignment(-0.5 + _shinePosition.value, 0.5),
                                        colors: [
                                          Colors.white.withOpacity(0.0),
                                          Colors.white.withOpacity(_shineOpacity.value),
                                          Colors.white.withOpacity(0.0),
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                      ).createShader(bounds);
                                    },
                                    blendMode: BlendMode.plus,
                                    child: Opacity(
                                      opacity: _logoOpacity.value,
                                      child: Container(
                                        width: 200,
                                        height: 200,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(0.1),
                                              Colors.white.withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Image.asset(
                                          'assets/images/app_logo.png',
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            // Fallback si l'image n'est pas trouvée
                                            return Icon(
                                              Icons.star,
                                              size: 100,
                                              color: Colors.white.withOpacity(0.8),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Texte animé
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return SlideTransition(
                  position: _textSlide,
                  child: Transform.scale(
                    scale: _textScale.value,
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [
                                  Colors.cyan,
                                  Colors.blue,
                                  Colors.cyan,
                                ],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'RISAQ',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Routines Spirituelles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildEnergyWaves() {
    return List.generate(3, (index) {
      return Transform.scale(
        scale: _waveScale.value + (index * 0.3),
        child: Opacity(
          opacity: _waveOpacity.value * (1 - index * 0.3),
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.cyan.withOpacity(0.3),
                width: 2 - (index * 0.5),
              ),
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  Colors.cyan.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// Modèle de particule
class Particle {
  final Offset position;
  final double size;
  final double speed;
  final double angle;
  final double opacity;
  
  Particle({
    required this.position,
    required this.size,
    required this.speed,
    required this.angle,
    required this.opacity,
  });
}

// Painter pour les particules
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final double opacity;
  
  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.opacity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    
    for (final particle in particles) {
      final distance = progress * 300 * particle.speed;
      final x = center.dx + math.cos(particle.angle) * distance;
      final y = center.dy + math.sin(particle.angle) * distance;
      
      // Gradient radial pour chaque particule
      paint.shader = RadialGradient(
        colors: [
          Colors.cyan.withOpacity(particle.opacity * opacity),
          Colors.blue.withOpacity(particle.opacity * opacity * 0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(x, y),
        radius: particle.size * 2,
      ));
      
      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1 + progress * 0.5),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}