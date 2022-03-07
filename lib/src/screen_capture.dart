
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class ScreenCapture extends StatefulWidget {
  const ScreenCapture({ 
    Key? key, required this.child 
  }) : super(key: key);

  final Widget child; 

  @override
  State<ScreenCapture> createState() => _ScreenCaptureState();
}

class _ScreenCaptureState extends State<ScreenCapture> {
  // Documentation on the global key states that 'a good practice is to 
  // let a State object own the GlobalKey, and instantiate it outside 
  // the build method, such as in [State.initState]'. 
  final GlobalKey globalKey = GlobalKey();

  Future<void> _capture(BuildContext context) async {
    final RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    assert(!boundary.debugNeedsPaint);
    final ui.Image image = await boundary.toImage(pixelRatio: MediaQuery.of(context).devicePixelRatio);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List bytes = byteData!.buffer.asUint8List();
    File('screenshots/${DateTime.now().microsecondsSinceEpoch}.png').writeAsBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_){
      _capture(context);
    });

    return RepaintBoundary(
      key: globalKey,
      child: widget.child,
    );
  }
}