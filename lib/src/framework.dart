import 'package:flutter/widgets.dart';

abstract class MultipassBuildWidget extends StatefulWidget {
  const MultipassBuildWidget({ Key? key }) : super(key: key);

  @override
  MultipassBuildElement createElement() => MultipassBuildElement(this);

  @override
  MultipassBuildState createState();
}

class MultipassBuildElement extends StatefulElement {
  MultipassBuildElement(MultipassBuildWidget widget) : super(widget);

  late bool Function() afterPass;

  @override
  void performRebuild() {
    do {
      super.performRebuild();
    } while (afterPass.call());
  }
}

abstract class MultipassBuildState<T extends StatefulWidget> extends State<T> {
  MultipassBuildElement get _element => context as MultipassBuildElement;

  @override
  void initState() {
    super.initState();
    _element.afterPass = afterPass;
  }

  bool afterPass();
}