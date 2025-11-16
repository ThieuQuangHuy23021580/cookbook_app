import 'package:flutter/material.dart';
import '../core/index.dart';
class GmailSignInButton extends StatefulWidget {

  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final String text;
  final bool isLoading;
  const GmailSignInButton({
    super.key,
    this.onSuccess,
    this.onError,
    this.text = 'Đăng ký với Gmail',
    this.isLoading = false,
  });
  @override
  State<GmailSignInButton> createState() => _GmailSignInButtonState();
}

class _GmailSignInButtonState extends State<GmailSignInButton> {
  bool _isPressed = false;
  bool _isProcessing = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!_isProcessing && !widget.isLoading) {
          setState(() {
            _isPressed = true;
          });
        }
      },
      onTapUp: (_) {
        if (!_isProcessing && !widget.isLoading) {
          setState(() {
            _isPressed = false;
          });
        }
      },
      onTapCancel: () {
        if (!_isProcessing && !widget.isLoading) {
          setState(() {
            _isPressed = false;
          });
        }
      },
      onTap: _isProcessing || widget.isLoading ? null : _handleGmailSignIn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isPressed
              ? const Color(0xFF4285F4).withOpacity(0.9)
              : const Color(0xFF4285F4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isPressed
                ? const Color(0xFF1A73E8)
                : const Color(0xFF4285F4),
            width: 1,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: const Color(0xFF4285F4).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing || widget.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.g_mobiledata,
                  color: Color(0xFF4285F4),
                  size: 16,
                ),
              ),
            const SizedBox(width: 12),
            Text(
              _isProcessing || widget.isLoading ? 'Đang xử lý...' : widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGmailSignIn() async {
    setState(() {
      _isProcessing = true;
    });
    try {
      final result = await AuthService.signInWithGoogle();
      if (result.success) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.data?['message'] ?? SuccessMessages.loginSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (widget.onError != null) {
          widget.onError!();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? ErrorMessages.unknownError),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      if (widget.onError != null) {
        widget.onError!();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AuthService.handleNetworkError(error)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
