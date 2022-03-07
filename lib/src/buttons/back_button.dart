import 'package:flutter/material.dart';
import 'icon_button.dart' as avocado;

class BackButton extends StatelessWidget {
  const BackButton({ 
    Key? key, 
    this.color, 
    this.onPressed 
  }) : super(key: key);

  final Color? color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return Center(
      child: avocado.IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () {
          if (onPressed != null) {
            onPressed!();
          } else {
            Navigator.maybePop(context);
          }
        },
        child: const BackButtonIcon(),
      ),
    );
  }
}