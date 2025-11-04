import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaizen_pro/src/components/auth/hook/login_hook.dart';
import 'package:kaizen_pro/src/components/auth/model/login_request.dart';
import 'package:kaizen_pro/src/routes/app_routes.dart';

/// LoginScreen - Diseño minimalista y profesional
///
/// Widget reutilizable que expone callbacks para conectar lógica externa
class LoginScreen extends StatefulWidget {
  final String? initialUsername;
  final String? initialPassword;
  final ValueChanged<String>? onUsernameChanged;
  final ValueChanged<String>? onPasswordChanged;
  final VoidCallback? onSubmit;
  final bool isLoading;
  final String? errorMessage;

  const LoginScreen({
    super.key,
    this.initialUsername,
    this.initialPassword,
    this.onUsernameChanged,
    this.onPasswordChanged,
    this.onSubmit,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.initialUsername ?? '',
    );
    _passwordController = TextEditingController(
      text: widget.initialPassword ?? '',
    );

    _usernameController.addListener(() {
      if (widget.onUsernameChanged != null) {
        widget.onUsernameChanged!(_usernameController.text);
      }
    });

    _passwordController.addListener(() {
      if (widget.onPasswordChanged != null) {
        widget.onPasswordChanged!(_passwordController.text);
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _usernameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa el usuario';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa la contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ajuste para evitar espacio transparente alrededor del logo:
                    // limitamos el alto y usamos FittedBox con BoxFit.cover dentro
                    // de un ClipRect para recortar margenes transparentes del PNG.
                    SizedBox(
                      height: 160,
                      child: ClipRect(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Image.asset(
                            'assets/logo/logo.png',
                            semanticLabel: 'Logo Mophra',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Iniciar sesión',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ingresa tus credenciales para continuar',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white60),
                    ),
                    const SizedBox(height: 48),

                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        labelStyle: const TextStyle(color: Colors.white60),
                        hintText: 'username',
                        hintStyle: const TextStyle(color: Colors.white30),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Colors.white60,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF3B82F6),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 2,
                          ),
                        ),
                        errorStyle: const TextStyle(color: Color(0xFFEF4444)),
                      ),
                      validator: _usernameValidator,
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(color: Colors.white60),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.white60,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white60,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF3B82F6),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 2,
                          ),
                        ),
                        errorStyle: const TextStyle(color: Color(0xFFEF4444)),
                      ),
                      validator: _passwordValidator,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Callback para recuperar contraseña
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Consumer(
                      builder: (context, ref, _) {
                        final loginState = ref.useLogin.getState();
                        final isLoading =
                            widget.isLoading || loginState.isLoading;
                        final String errorMessage =
                            (widget.errorMessage != null &&
                                widget.errorMessage!.isNotEmpty)
                            ? widget.errorMessage!
                            : (loginState.error ?? '');

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (errorMessage.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFEF4444,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Color(0xFFEF4444),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        errorMessage,
                                        style: const TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      final valid =
                                          _formKey.currentState?.validate() ??
                                          false;
                                      if (!valid) return;

                                      if (widget.onSubmit != null) {
                                        widget.onSubmit!();
                                      } else {
                                        final req = LoginRequest(
                                          username: _usernameController.text
                                              .trim(),
                                          password: _passwordController.text,
                                        );
                                        await ref.useLogin.login(req);
                                        if (!context.mounted) return; // evitar usar context tras await si el widget fue desmontado
                                        // Navegar al dashboard si el login fue exitoso
                                        final state = ref.useLogin.getState();
                                        final token = state.data?.token ?? '';
                                        if (token.isNotEmpty) {
                                          Navigator.of(context)
                                              .pushReplacementNamed(AppRoutes.dashboard);
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(
                                  0xFF3B82F6,
                                ).withOpacity(0.5),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Entrar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
