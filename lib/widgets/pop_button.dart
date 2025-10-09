import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// REUSABLE BUTTON WITH POP EFFECT
class PopButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color bgColor;
  final Color textColor;
  final bool outlined;
  final Widget? icon;

  const PopButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.bgColor,
    required this.textColor,
    this.outlined = false,
    this.icon,
  });

  @override
  State<PopButton> createState() => _PopButtonState();
}

class _PopButtonState extends State<PopButton>
    with SingleTickerProviderStateMixin {
  double scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => scale = 1.0);
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() => scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: scale,
        child: widget.outlined
            ? OutlinedButton.icon(
                onPressed: widget.onPressed,
                icon: widget.icon ?? const SizedBox(),
                label: Text(
                  widget.text,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: widget.textColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: widget.bgColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              )
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.bgColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: Text(
                    widget.text,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: widget.textColor,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
