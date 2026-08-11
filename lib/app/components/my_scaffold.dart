import 'package:kena_emotional_journey/app/components/global_unfocus_keyboard.dart';
import 'package:kena_emotional_journey/app/components/ui_helper.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class MyScaffold extends StatefulWidget {
  const MyScaffold({
    super.key,
    this.body,
    this.appBar,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.bottomSheet,
    this.persistentFooterButtons,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.primary,
    this.isSafeArea,
    this.extendBody,
    this.extendBodyBehindAppBar,
    this.removeSafeAreaBottom,
  });

  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? bottomSheet;
  final Widget? persistentFooterButtons;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final bool? primary;
  final bool? isSafeArea;
  final bool? extendBody;
  final bool? extendBodyBehindAppBar;
  final bool? removeSafeAreaBottom;

  @override
  State<MyScaffold> createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  @override
  Widget build(BuildContext context) {
    UIHelper.setStatusBar(background: context.colors.background);
    return Container(
      decoration: BoxDecoration(
        // Uncomment and customize if you want a background image
        // image: DecorationImage(
        //   image: AssetImage(Assets.images.bg.path),
        //   fit: BoxFit.fill,
        //   colorFilter: ColorFilter.mode(
        //     context.colors.background.withOpacity(0.88),
        //     BlendMode.srcOver,
        //   ),
        // ),
      ),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body:
            ((widget.extendBody ?? false) ||
                (widget.extendBodyBehindAppBar ?? false))
            ? (widget.body ?? const SizedBox.shrink())
            : GlobalUnfocusKeyboard(
                child: (widget.isSafeArea == false)
                    ? widget.body ?? const SizedBox.shrink()
                    : SafeArea(
                        bottom: widget.removeSafeAreaBottom ?? false
                            ? false
                            : true,
                        child: widget.body ?? const SizedBox.shrink(),
                      ),
              ),
        appBar: widget.appBar,
        drawer: widget.drawer,
        bottomNavigationBar: widget.bottomNavigationBar,
        floatingActionButton: widget.floatingActionButton,
        bottomSheet: widget.bottomSheet,
        persistentFooterButtons: widget.persistentFooterButtons != null
            ? [widget.persistentFooterButtons!]
            : null,
        endDrawer: widget.endDrawer,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        primary: widget.primary ?? true,
        extendBody: widget.extendBody ?? false,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar ?? false,
      ),
    );
  }
}
