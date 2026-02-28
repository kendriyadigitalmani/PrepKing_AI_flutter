import 'package:flutter/material.dart';

void main() {
  runApp(const PrepKingAIApp());
}

class PrepKingAIApp extends StatelessWidget {
  const PrepKingAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrepKing AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0F0F23),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      body: Stack(
        children: [
          _AnimatedGradientBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(isMobile),
                  _buildFeaturesSection(isMobile),
                  _buildCTASection(isMobile),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          height: isMobile ? 600 : 700,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('🤖 PrepKing AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 16 : 18)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Master Your Exams with\nAI-Powered Learning',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 20),
              Text(
                'Personalized study plans, instant doubt solving,\nand smart analytics to ace your exams.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: isMobile ? 16 : 20, height: 1.5),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPrimaryButton('Get Started Free', Icons.rocket_launch, isMobile),
                  const SizedBox(width: 15),
                  _buildSecondaryButton('Watch Demo', Icons.play_circle, isMobile),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTrustBadge('10K+', 'Students'),
                  const SizedBox(width: 20),
                  _buildTrustBadge('95%', 'Success Rate'),
                  const SizedBox(width: 20),
                  _buildTrustBadge('24/7', 'AI Support'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, IconData icon, bool isMobile) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 30, vertical: isMobile ? 12 : 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white, size: isMobile ? 18 : 20),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: isMobile ? 14 : 16)),
          ]),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, IconData icon, bool isMobile) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 30, vertical: isMobile ? 12 : 16),
          decoration: BoxDecoration(border: Border.all(color: Colors.white30), borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white, size: isMobile ? 18 : 20),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: isMobile ? 14 : 16)),
          ]),
        ),
      ),
    );
  }

  Widget _buildTrustBadge(String value, String label) {
    return Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: Colors.white60, fontSize: 12)),
    ]);
  }

  Widget _buildFeaturesSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: 60),
      color: const Color(0xFF1A1A2E),
      child: Column(children: [
        Text('Why Choose PrepKing AI?', style: TextStyle(color: Colors.white, fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 40),
        Wrap(spacing: 20, runSpacing: 20, alignment: WrapAlignment.center, children: [
          _buildFeatureCard(icon: Icons.psychology, title: 'AI Tutor', description: '24/7 instant doubt solving', color: const Color(0xFF6366F1), isMobile: isMobile),
          _buildFeatureCard(icon: Icons.analytics, title: 'Smart Analytics', description: 'Track progress & optimize', color: const Color(0xFF8B5CF6), isMobile: isMobile),
          _buildFeatureCard(icon: Icons.auto_graph, title: 'Personalized Plans', description: 'Custom study schedules', color: const Color(0xFFA78BFA), isMobile: isMobile),
        ]),
      ]),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String description, required Color color, required bool isMobile}) {
    return Container(
      width: isMobile ? double.infinity : 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withOpacity(0.1), color.withOpacity(0.05)]),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(description, style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
      ]),
    );
  }

  Widget _buildCTASection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: 60),
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E)])),
      child: Column(children: [
        Text('Ready to Ace Your Exams?', style: TextStyle(color: Colors.white, fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('Join thousands of students who transformed their learning with AI', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: isMobile ? 14 : 16)),
        const SizedBox(height: 30),
        _buildPrimaryButton('Start Learning Now', Icons.school, isMobile),
      ]),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      color: const Color(0xFF0A0A1A),
      child: Column(children: [
        Text('© 2026 PrepKing AI. All rights reserved.', style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildFooterLink('Privacy'),
          const SizedBox(width: 20),
          _buildFooterLink('Terms'),
          const SizedBox(width: 20),
          _buildFooterLink('Contact'),
        ]),
      ]),
    );
  }

  Widget _buildFooterLink(String text) {
    return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () {}, child: Text(text, style: TextStyle(color: Colors.white70, fontSize: 12))));
  }
}

class _AnimatedGradientBackground extends StatefulWidget {
  @override
  State<_AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<_AnimatedGradientBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color1, _color2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 8), vsync: this)..repeat(reverse: true);
    _color1 = ColorTween(begin: const Color(0xFF6366F1), end: const Color(0xFF8B5CF6)).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _color2 = ColorTween(begin: const Color(0xFF0F0F23), end: const Color(0xFF1A1A2E)).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _controller, builder: (context, child) {
      return Container(decoration: BoxDecoration(gradient: RadialGradient(center: Alignment.topRight, radius: 1.5, colors: [_color1.value?.withOpacity(0.15) ?? Colors.transparent, _color2.value ?? Colors.transparent, const Color(0xFF0F0F23)])));
    });
  }
}