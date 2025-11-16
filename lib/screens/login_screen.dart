import 'dart:ui';
import 'package:empower_ananya/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  late AnimationController _animationController;

  String _email = '';
  String _password = '';
  String _error = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      final user = await _auth.signInWithEmailAndPassword(_email, _password);
      if (!mounted) return;
      if (user == null) {
        setState(() {
          _error = 'Could not sign in. Please check credentials.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color(0xFF0052D4),
                      Color(0xFF4364F7),
                      Color(0xFF65C7F7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform: GradientRotation(
                        _animationController.value * 2 * 3.1415),
                  ),
                ),
              );
            },
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(51)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/empowerananya.jpg',
                                height: 100),
                            const SizedBox(height: 16),
                            Text(
                              'Admin Portal',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration(
                                  labelText: 'Email',
                                  icon: Icons.email_outlined),
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) =>
                                  val!.isEmpty ? 'Enter an email' : null,
                              onChanged: (val) =>
                                  setState(() => _email = val.trim()),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration(
                                  labelText: 'Password',
                                  icon: Icons.lock_outline),
                              obscureText: true,
                              validator: (val) => val!.length < 6
                                  ? 'Password must be 6+ chars'
                                  : null,
                              onChanged: (val) =>
                                  setState(() => _password = val),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.white))
                                  : ElevatedButton(
                                      onPressed: _signIn,
                                      child: const Text('Login'),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            if (_error.isNotEmpty)
                              Text(
                                _error,
                                style: const TextStyle(
                                    color: Colors.yellowAccent, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      {required String labelText, required IconData icon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white.withAlpha(179)),
      prefixIcon: Icon(icon, color: Colors.white.withAlpha(179)),
      filled: true,
      fillColor: Colors.white.withAlpha(26),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(51))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2)),
    );
  }
}
