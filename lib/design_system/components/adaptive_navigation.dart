import 'package:flutter/material.dart';
import 'package:spiritual_routines/core/widgets/responsive_breakpoints.dart';

/// Adaptive navigation scaffold that switches between NavigationBar (mobile),
/// NavigationRail (tablet/desktop) based on screen size
class AdaptiveNavigationScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;

  const AdaptiveNavigationScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.floatingActionButton,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, screenType) {
        // Desktop: NavigationRail on the left
        if (screenType == ScreenType.desktop) {
          return Scaffold(
            appBar: appBar,
            body: Row(
              children: [
                NavigationRail(
                  extended: constraints.maxWidth > Breakpoints.xl,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: constraints.maxWidth > Breakpoints.xl
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  destinations: destinations
                      .map(
                        (d) => NavigationRailDestination(
                          icon: d.icon,
                          selectedIcon: d.selectedIcon ?? d.icon,
                          label: Text(d.label),
                        ),
                      )
                      .toList(),
                  trailing: floatingActionButton != null
                      ? Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: floatingActionButton,
                            ),
                          ),
                        )
                      : null,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        // Tablet: NavigationRail compact
        if (screenType == ScreenType.tablet) {
          return Scaffold(
            appBar: appBar,
            body: Row(
              children: [
                NavigationRail(
                  extended: false,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: NavigationRailLabelType.selected,
                  destinations: destinations
                      .map(
                        (d) => NavigationRailDestination(
                          icon: d.icon,
                          selectedIcon: d.selectedIcon ?? d.icon,
                          label: Text(d.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
            floatingActionButton: floatingActionButton,
          );
        }

        // Mobile: BottomNavigationBar
        return Scaffold(
          appBar: appBar,
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations,
          ),
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}

/// Master-detail layout for tablet and desktop screens
class AdaptiveMasterDetailLayout extends StatelessWidget {
  final Widget master;
  final Widget? detail;
  final double masterWidth;
  final bool showDivider;

  const AdaptiveMasterDetailLayout({
    super.key,
    required this.master,
    this.detail,
    this.masterWidth = 320.0,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, screenType) {
        // Mobile: Show only master or detail based on navigation
        if (screenType == ScreenType.mobile) {
          return detail ?? master;
        }

        // Tablet/Desktop: Show both master and detail side by side
        return Row(
          children: [
            SizedBox(
              width: masterWidth,
              child: master,
            ),
            if (showDivider) const VerticalDivider(width: 1),
            Expanded(
              child: detail ?? const _EmptyDetailView(),
            ),
          ],
        );
      },
    );
  }
}

/// Empty state for detail view when nothing is selected
class _EmptyDetailView extends StatelessWidget {
  const _EmptyDetailView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Sélectionnez un élément',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Adaptive dialog that adjusts size based on screen
class AdaptiveDialog extends StatelessWidget {
  final Widget? title;
  final Widget content;
  final List<Widget>? actions;
  final double? maxWidth;

  const AdaptiveDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;

    // Adaptive max width based on screen type
    final adaptiveMaxWidth = maxWidth ??
        (screenType == ScreenType.mobile
            ? double.infinity
            : screenType == ScreenType.tablet
                ? 600.0
                : 800.0);

    if (screenType == ScreenType.mobile) {
      // Full screen dialog on mobile
      return Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: title,
            actions: actions,
          ),
          body: content,
        ),
      );
    }

    // Regular dialog with constrained width on tablet/desktop
    return AlertDialog(
      title: title,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: adaptiveMaxWidth,
        ),
        child: content,
      ),
      actions: actions,
    );
  }
}

/// Adaptive app bar that changes height and padding based on screen
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double? elevation;

  const AdaptiveAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.elevation,
  });

  @override
  Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;

    return AppBar(
      title: title,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle || screenType == ScreenType.mobile,
      elevation: elevation,
      toolbarHeight: screenType == ScreenType.desktop ? 64.0 : kToolbarHeight,
    );
  }
}
