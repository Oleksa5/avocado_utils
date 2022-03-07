import 'package:flutter/material.dart';

/// An item to use with [SimpleDialog].
class SimpleDialogItem extends StatelessWidget {
  const SimpleDialogItem({ 
    Key? key, 
    this.padding,
    required this.child
  }) : super(key: key);

  final EdgeInsets? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: child,
    );
  }
}

/// When pressed, pops the top-most route off the route navigator.
class SimpleDialogButton extends StatelessWidget {
  const SimpleDialogButton({ 
    Key? key,
    required this.text,
    this.onPressed
  }) : super(key: key);

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogItem(
      child: ElevatedButton(
        onPressed: () {
          onPressed?.call();
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.green,
          visualDensity: const VisualDensity() 
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        )
      ),
    );
  }
}