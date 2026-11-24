import 'package:flutter/material.dart';

class ChecklistFooter extends StatelessWidget {
  final bool isSaving;
  final bool canSave;
  final VoidCallback onSave;

  const ChecklistFooter({
    super.key,
    required this.isSaving,
    required this.canSave,
    required this.onSave,
  });

  static const _green = Color(0xFF1E7A3C);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          16,
          14,
          16,
          12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(
              color: Color(0xFFE0E0DA),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.045),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: (!isSaving && canSave) ? onSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE0E0DA),
              disabledForegroundColor: const Color(0xFF9A9A94),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 23,
                    height: 23,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.send_rounded,
                        size: 19,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Enviar Checklist',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
