import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

/// Widget that adds desktop-specific interactions like hover effects,
/// right-click support, and keyboard focus
class DesktopInteractiveWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onRightClick;
  final VoidCallback? onMiddleClick;
  final String? tooltip;
  final MouseCursor cursor;
  final bool enableHoverEffect;
  final Color? hoverColor;
  final Duration animationDuration;

  const DesktopInteractiveWidget({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onRightClick,
    this.onMiddleClick,
    this.tooltip,
    this.cursor = SystemMouseCursors.click,
    this.enableHoverEffect = true,
    this.hoverColor,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<DesktopInteractiveWidget> createState() =>
      _DesktopInteractiveWidgetState();
}

class _DesktopInteractiveWidgetState extends State<DesktopInteractiveWidget> {
  bool _hovering = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveHoverColor = widget.hoverColor ?? theme.hoverColor;

    Widget result = MouseRegion(
      cursor: widget.onTap != null ? widget.cursor : SystemMouseCursors.basic,
      onEnter: (_) {
        if (widget.enableHoverEffect) {
          setState(() => _hovering = true);
        }
      },
      onExit: (_) {
        if (widget.enableHoverEffect) {
          setState(() => _hovering = false);
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onSecondaryTap: widget.onRightClick,
        onTertiaryTapDown: widget.onMiddleClick != null
            ? (_) => widget.onMiddleClick!()
            : null,
        child: Focus(
          onFocusChange: (focused) => setState(() => _focused = focused),
          child: AnimatedContainer(
            duration: widget.animationDuration,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _hovering && widget.enableHoverEffect
                  ? effectiveHoverColor
                  : Colors.transparent,
              border: _focused
                  ? Border.all(
                      color: theme.focusColor,
                      width: 2,
                    )
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      result = Tooltip(
        message: widget.tooltip!,
        child: result,
      );
    }

    return result;
  }
}

/// Widget that handles keyboard shortcuts
class KeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final Map<ShortcutActivator, VoidCallback> shortcuts;
  final bool autofocus;

  const KeyboardShortcuts({
    super.key,
    required this.child,
    required this.shortcuts,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: shortcuts
          .map((key, value) => MapEntry(key, VoidCallbackIntent(value))),
      child: Actions(
        actions: {
          VoidCallbackIntent: VoidCallbackAction(),
        },
        child: Focus(
          autofocus: autofocus,
          child: child,
        ),
      ),
    );
  }
}

/// Intent for void callbacks
class VoidCallbackIntent extends Intent {
  final VoidCallback callback;
  const VoidCallbackIntent(this.callback);
}

/// Action that executes void callbacks
class VoidCallbackAction extends Action<VoidCallbackIntent> {
  @override
  Object? invoke(VoidCallbackIntent intent) {
    intent.callback();
    return null;
  }
}

/// Common keyboard shortcuts for spiritual routines app
class SpiritualKeyboardShortcuts {
  // Navigation shortcuts
  static const home = SingleActivator(LogicalKeyboardKey.keyH, control: true);
  static const routines =
      SingleActivator(LogicalKeyboardKey.keyR, control: true);
  static const reader = SingleActivator(LogicalKeyboardKey.keyL, control: true);
  static const settings =
      SingleActivator(LogicalKeyboardKey.keyS, control: true);

  // Action shortcuts
  static const newRoutine =
      SingleActivator(LogicalKeyboardKey.keyN, control: true);
  static const search = SingleActivator(LogicalKeyboardKey.keyF, control: true);
  static const refresh = SingleActivator(LogicalKeyboardKey.f5);
  static const escape = SingleActivator(LogicalKeyboardKey.escape);

  // Counter shortcuts
  static const increment = SingleActivator(LogicalKeyboardKey.space);
  static const decrement = SingleActivator(LogicalKeyboardKey.backspace);
  static const decrementTen =
      SingleActivator(LogicalKeyboardKey.backspace, shift: true);
  static const reset =
      SingleActivator(LogicalKeyboardKey.keyR, control: true, shift: true);

  // Text navigation
  static const nextPage = SingleActivator(LogicalKeyboardKey.pageDown);
  static const previousPage = SingleActivator(LogicalKeyboardKey.pageUp);
  static const increaseFontSize =
      SingleActivator(LogicalKeyboardKey.equal, control: true);
  static const decreaseFontSize =
      SingleActivator(LogicalKeyboardKey.minus, control: true);

  // Media controls
  static const playPause =
      SingleActivator(LogicalKeyboardKey.space, control: true);
  static const volumeUp =
      SingleActivator(LogicalKeyboardKey.arrowUp, control: true);
  static const volumeDown =
      SingleActivator(LogicalKeyboardKey.arrowDown, control: true);
}

/// Mixin to add keyboard navigation to any widget
mixin KeyboardNavigationMixin<T extends StatefulWidget> on State<T> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Handle arrow key navigation
  KeyEventResult handleArrowKeys(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        onArrowUp();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        onArrowDown();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        onArrowLeft();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        onArrowRight();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
        onEnter();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  // Override these methods in your widget
  void onArrowUp() {}
  void onArrowDown() {}
  void onArrowLeft() {}
  void onArrowRight() {}
  void onEnter() {}
}

/// Desktop-optimized scrollbar wrapper
class DesktopScrollbar extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final bool isAlwaysShown;
  final double thickness;

  const DesktopScrollbar({
    super.key,
    required this.child,
    this.controller,
    this.isAlwaysShown = true,
    this.thickness = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: MaterialStateProperty.all(isAlwaysShown),
          thickness: MaterialStateProperty.all(thickness),
          radius: const Radius.circular(6),
          thumbColor: MaterialStateProperty.all(
            theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          trackColor: MaterialStateProperty.all(
            theme.colorScheme.onSurface.withOpacity(0.05),
          ),
          trackBorderColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ),
      child: Scrollbar(
        controller: controller,
        child: child,
      ),
    );
  }
}

/// Context menu for desktop right-click
class DesktopContextMenu extends StatelessWidget {
  final Widget child;
  final List<ContextMenuItem> items;

  const DesktopContextMenu({
    super.key,
    required this.child,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      child: child,
    );
  }

  void _showContextMenu(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: items
          .map((item) => PopupMenuItem(
                enabled: item.enabled,
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      Icon(item.icon, size: 20),
                      const SizedBox(width: 12),
                    ],
                    Text(item.label),
                    const Spacer(),
                    if (item.shortcut != null)
                      Text(
                        item.shortcut!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                      ),
                  ],
                ),
                onTap: item.onTap,
              ))
          .toList(),
    );
  }
}

/// Context menu item model
class ContextMenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? shortcut;
  final bool enabled;

  const ContextMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.shortcut,
    this.enabled = true,
  });
}

/// Desktop-optimized selection controls
class DesktopSelectionControls extends MaterialTextSelectionControls {
  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ValueListenable<ClipboardStatus>? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return _DesktopTextSelectionToolbar(
      globalEditableRegion: globalEditableRegion,
      textLineHeight: textLineHeight,
      selectionMidpoint: selectionMidpoint,
      endpoints: endpoints,
      delegate: delegate,
      clipboardStatus: clipboardStatus,
      handleCut: canCut(delegate) ? () => handleCut(delegate) : null,
      handleCopy: canCopy(delegate) ? () => handleCopy(delegate) : null,
      handlePaste: canPaste(delegate) ? () => handlePaste(delegate) : null,
      handleSelectAll:
          canSelectAll(delegate) ? () => handleSelectAll(delegate) : null,
    );
  }
}

class _DesktopTextSelectionToolbar extends StatelessWidget {
  final Rect globalEditableRegion;
  final double textLineHeight;
  final Offset selectionMidpoint;
  final List<TextSelectionPoint> endpoints;
  final TextSelectionDelegate delegate;
  final ValueListenable<ClipboardStatus>? clipboardStatus;
  final VoidCallback? handleCut;
  final VoidCallback? handleCopy;
  final VoidCallback? handlePaste;
  final VoidCallback? handleSelectAll;

  const _DesktopTextSelectionToolbar({
    required this.globalEditableRegion,
    required this.textLineHeight,
    required this.selectionMidpoint,
    required this.endpoints,
    required this.delegate,
    this.clipboardStatus,
    this.handleCut,
    this.handleCopy,
    this.handlePaste,
    this.handleSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (handleCut != null)
            _ToolbarButton(
              icon: Icons.cut,
              tooltip: 'Cut (Ctrl+X)',
              onPressed: handleCut!,
            ),
          if (handleCopy != null)
            _ToolbarButton(
              icon: Icons.copy,
              tooltip: 'Copy (Ctrl+C)',
              onPressed: handleCopy!,
            ),
          if (handlePaste != null)
            _ToolbarButton(
              icon: Icons.paste,
              tooltip: 'Paste (Ctrl+V)',
              onPressed: handlePaste!,
            ),
          if (handleSelectAll != null)
            _ToolbarButton(
              icon: Icons.select_all,
              tooltip: 'Select All (Ctrl+A)',
              onPressed: handleSelectAll!,
            ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }
}
