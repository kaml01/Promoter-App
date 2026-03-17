import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as Permissionhandler;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promoterapp/util/ApiHelper.dart';
import '../config/Common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  StreamSubscription? connection;
  bool isoffline = false;
  TextEditingController usercontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  bool _obscureText = true, gpsstatus = false;
  Location location = Location();

  // Brand Colors
  static const Color primaryGreen = Color(0xFF063A06);
  static const Color lightGreen = Color(0xFF0A5C0A);

  void checkurlstatus(context) async {
    try {
      proxylogin(context, usercontroller.text).then((value) => {
        updateurl(value, context)
      });
    } catch (e, s) {
      print(s);
    }
  }

  void updateurl(status, context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (status == true) {
      prefs.setString(IP_URL, "http://dsr.jivocanola.com/AndroidServer/");
      // prefs.setString(IP_URL, "http://103.89.45.75:90/AndroidServer/");
      login(context, usercontroller.text, passcontroller.text);
    } else {
      prefs.setString(IP_URL, "http://dsr.jivocanola.com/AndroidServer/");
      // prefs.setString(IP_URL, "http://103.89.45.75:90/AndroidServer/");
      login(context, usercontroller.text, passcontroller.text);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showDisclosureDialog();
    });
  }

  Future<void> _showDisclosureDialog() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: primaryGreen),
            const SizedBox(width: 10),
            const Text('Disclosure'),
          ],
        ),
        content: const Text(
          "This app collects location data to enable location feature even when the app is closed or not in use.",
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: primaryGreen,
            ),
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> askpermission() async {
    try {
      var camerastatus = await Permissionhandler.Permission.camera.status;
      var locationstatus = await Permissionhandler.Permission.locationWhenInUse.status;

      if (camerastatus.isGranted == false || locationstatus.isGranted == false) {
        await [
          Permissionhandler.Permission.location,
          Permissionhandler.Permission.camera
        ].request();
      }

      bool ison = await location.serviceEnabled();
      if (!ison) {
        bool isturnedon = await location.requestService();
        gpsstatus = isturnedon;
      } else {
        gpsstatus = true;
      }
    } catch (e) {
      print("Permission error: $e");
    }
  }

  @override
  void dispose() {
    connection?.cancel();
    usercontroller.dispose();
    passcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: ProgressHUD(
          child: Builder(
            builder: (ctx) => Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8F5E9), // Light green tint
                    Color(0xFFF5F5F5), // Light gray
                    Color(0xFFE0F2E0), // Pale green
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Section
                        _buildLogoSection(),
                        const SizedBox(height: 40),
                        // Login Card
                        _buildLoginCard(ctx),
                        const SizedBox(height: 24),
                        // Footer
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo Container with shadow
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/Images/logo.png',
              height: 50,
            ),
          ),
        ),

        // const SizedBox(height: 20),
        // Text(
        //   'JIVO',
        //   style: TextStyle(
        //     fontSize: 28,
        //     fontWeight: FontWeight.bold,
        //     color: primaryGreen,
        //     letterSpacing: 4,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext ctx) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: primaryGreen.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Username Field
          _buildTextField(
            controller: usercontroller,
            hintText: 'Username',
            prefixIcon: Icons.person_outline,
            obscureText: false,
          ),
          const SizedBox(height: 20),

          // Password Field
          _buildTextField(
            controller: passcontroller,
            hintText: 'Password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureText,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscureText = !_obscureText),
              child: Icon(
                _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey[500],
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Forgot Password
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: TextButton(
          //     onPressed: () {
          //       // Handle forgot password
          //     },
          //     style: TextButton.styleFrom(
          //       foregroundColor: primaryGreen,
          //       padding: EdgeInsets.zero,
          //       minimumSize: const Size(0, 0),
          //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //     ),
          //     child: const Text(
          //       'Forgot Password?',
          //       style: TextStyle(fontSize: 13),
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 28),

          // Login Button
          _buildLoginButton(ctx),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: primaryGreen.withOpacity(0.7),
            size: 22,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext ctx) {
    return GestureDetector(
      onTap: () => checkurlstatus(ctx),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [primaryGreen, lightGreen],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LOGIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      '© 2025 Jivo Wellness',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[500],
      ),
    );
  }
}