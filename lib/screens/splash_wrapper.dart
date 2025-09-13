// =======================
// splash_wrapper.dart (Scanner)
// =======================

import 'dart:io';
import 'package:flutter/material.dart';
import 'id_scanner_screen.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  _SplashWrapperState createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> with TickerProviderStateMixin {
  bool showLanding = true;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  WebSocket? _socket;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _connectToReceiver();
  }

  void _initAnimations() {
    _fadeController = AnimationController(duration: Duration(milliseconds: 1500), vsync: this);
    _scaleController = AnimationController(duration: Duration(milliseconds: 1200), vsync: this);
    _slideController = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    Future.delayed(Duration(milliseconds: 300), () => _scaleController.forward());
    Future.delayed(Duration(milliseconds: 600), () => _slideController.forward());
  }

  void _connectToReceiver() async {
    try {
      _socket = await WebSocket.connect('ws://192.168.144.8:3000');
      print("✅ Scanner connecté au récepteur");

      _socket!.listen((message) {
        print("📩 Message reçu dans SplashWrapper : \$message");
        if (message == "start_checkin") {
          _handleTap();
        }
      });
    } catch (e) {
      print("❌ Erreur WebSocket scanner : \$e");
    }
  }

  void _handleTap() {
    setState(() {
      showLanding = false;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Scaffold(
        body: showLanding
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Icon(Icons.hotel, size: 120, color: Colors.white),
              ),
              const SizedBox(height: 40),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        "Bienvenue chez Ibis Styles",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Appuyez ou attendez pour commencer",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
            : IdScannerScreen(),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }
}