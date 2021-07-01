/*
  Created by Aitor Font on 02/04/20.

  This file is a modification of the ExpasionTile class from flutter:
  https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/expansion_tile.dart

  - The expand duration can be changed
  - It adds a Container widget to wrap the ListTile so the header background color can be changed
  - The header content padding can be changed.
  - It adds a header background color accent that, if set, will animate the background color when
  the expasion has changed.
  - It removes the first Container wrap so it remove the border that was always appearing.
  - The user can modify the border color and height -> it appears when the tile is expanded.
*/

import 'package:flutter/material.dart';

const Duration _expandDuration = Duration(milliseconds: 200);

class CustomExpansionTile extends StatefulWidget {

  const CustomExpansionTile({
    required Key key,
    this.expandDuration,
    this.headerBackgroundColor,
    this.headerBackgroundColorAccent,
    this.headerContentPadding,
    this.leading,
    required this.title,
    this.backgroundColor,
    this.borderColor,
    this.borderHeight,
    this.iconColor,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.initiallyExpanded = false,
  })  : assert(initiallyExpanded != null),
        super(key: key);

  final Duration? expandDuration;
  final Color? headerBackgroundColor;
  final Color? headerBackgroundColorAccent;
  final EdgeInsets? headerContentPadding;
  final Widget? leading;
  final Widget title;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderHeight;
  final Color? iconColor;
  final ValueChanged<bool>? onExpansionChanged;
  final List<Widget> children;
  final Widget? trailing;
  final bool? initiallyExpanded;

  @override
  CustomExpansionTileState createState() => CustomExpansionTileState();

}

class CustomExpansionTileState extends State<CustomExpansionTile> with SingleTickerProviderStateMixin {

  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);

  final ColorTween _headerBackgroundColorTween = ColorTween();

  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;
  late Animation<Color?> _headerBackgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.expandDuration ?? _expandDuration, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    _headerBackgroundColor = _controller.drive(_headerBackgroundColorTween.chain(_easeInTween));

    _isExpanded = PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    if (widget.onExpansionChanged != null)
      widget.onExpansionChanged!(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget> [
        Container(
          color: _headerBackgroundColor.value,
          child: ListTile(
            contentPadding: widget.headerContentPadding ?? EdgeInsets.all(0),
            leading: widget.leading,
            title: widget.title,
            onTap: _handleTap,
            trailing: widget.trailing ??
              RotationTransition(
                turns: _iconTurns,
                child: Icon(
                  Icons.expand_more,
                  color: widget.iconColor ?? Colors.grey,
                ),
              ),
          ),
        ),
        ClipRect(
          child: Align(
            heightFactor: _heightFactor.value,
            child: child
          ),
        ),
        Container(
          color: widget.borderColor ?? Colors.transparent,
          height: _isExpanded ? (widget.borderHeight ?? 0.75) : 0
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    _headerBackgroundColorTween
      ..begin = widget.headerBackgroundColor ?? Colors.black
      ..end = widget.headerBackgroundColorAccent ?? (widget.headerBackgroundColor ?? Colors.black);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }

}