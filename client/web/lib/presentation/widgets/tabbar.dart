import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TabData {
  final int index;
  final Tab title;
  final Widget content;

  TabData({required this.index, required this.title, required this.content});
}

/// Defines where the Tab indicator animation moves to when new Tab is added.
///
///
enum MoveToTab {
  /// The [idol] indicator will remain on current Tab when new Tab is added.
  idol,

  /// The [next] indicator will move to next Tab when new Tab is added.
  next,

  /// The [previous] indicator will move to previous Tab  when new Tab is added.
  previous,

  /// The [first] indicator will move to first Tab when new Tab is added.
  first,

  /// The [last] indicator will move to the Last Tab when new Tab is added.
  last,
}

/// Dynamic Tabs.
class DynamicTabBarWidget extends TabBar {
  /// List of Tabs.
  ///
  /// TabData contains [index] of the tab and the title which is extension of [TabBar] header.
  /// and the [content] is the extension of [TabBarView] so all the page content is displayed in this section
  ///
  ///
  final List<TabData> dynamicTabs;
  final Function(TabController) onTabControllerUpdated;
  final Function(int?)? onTabChanged;

  /// Defines where the Tab indicator animation moves to when new Tab is added.
  ///
  /// TabData contains two states at the moment [IDOL] and [LAST]
  ///
  final MoveToTab? onAddTabMoveTo;

  /// Tab indicator animation moves to given Index when new Tab is added.
  ///
  /// If [onAddTabMoveTo] has some value, then this property is ignored.
  ///
  /// After using this if needed make it [null] to avoid conflicts with [onAddTabMoveTo]
  ///
  /// example: tabs.length - 1
  final int? onAddTabMoveToIndex;

  /// The back icon of the TabBar when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default back icon is used.
  ///
  /// If [isScrollable] is false, this property is ignored.
  final Widget? backIcon;

  /// The forward icon of the TabBar when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default forward icon is used.
  ///
  /// If [isScrollable] is false, this property is ignored.
  final Widget? nextIcon;

  /// The showBackIcon property of DynamicTabBarWidget is used when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default value is [true].
  ///
  /// If [isScrollable] is false, this property is ignored.
  final bool? showBackIcon;

  /// The showNextIcon property of DynamicTabBarWidget is used when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default value is [true].
  ///
  /// If [isScrollable] is false, this property is ignored.
  final bool? showNextIcon;

  /// The leading property is used to add custom leading widget in TabBar.
  ///
  /// By default [leading] widget is null.
  ///
  final Widget? leading;

  /// The leading property is used to add custom trailing widget in TabBar.
  ///
  /// By default [trailing] widget is null.
  ///
  final Widget? trailing;

  /// The physics property is used to set the physics of TabBarView.
  final ScrollPhysics? physicsTabBarView;

  /// The dragStartBehavior property is used to set the dragStartBehavior of TabBarView.
  ///
  /// By default [dragStartBehavior] is DragStartBehavior.start.
  final DragStartBehavior dragStartBehaviorTabBarView;

  /// The clipBehavior property is used to set the clipBehavior of TabBarView.
  ///
  /// By default [clipBehavior] is Clip.hardEdge.
  final double viewportFractionTabBarView;

  /// The clipBehavior property is used to set the clipBehavior of TabBarView.
  ///
  /// By default [clipBehavior] is Clip.hardEdge.
  final Clip clipBehaviorTabBarView;

  DynamicTabBarWidget({
    super.key,
    required this.dynamicTabs,
    required this.onTabControllerUpdated,
    this.onTabChanged,
    this.onAddTabMoveTo,
    this.onAddTabMoveToIndex,
    super.isScrollable,
    this.backIcon,
    this.nextIcon,
    this.showBackIcon = true,
    this.showNextIcon = true,
    this.leading,
    this.trailing,
    // Default Tab properties :---------------------------------------
    super.padding,
    super.indicatorColor,
    super.automaticIndicatorColorAdjustment = true,
    super.indicatorWeight = 2.0,
    super.indicatorPadding = EdgeInsets.zero,
    super.indicator,
    super.indicatorSize,
    super.dividerColor,
    super.dividerHeight,
    super.labelColor,
    super.labelStyle,
    super.labelPadding,
    super.unselectedLabelColor,
    super.unselectedLabelStyle,
    super.dragStartBehavior = DragStartBehavior.start,
    super.overlayColor,
    super.mouseCursor,
    super.enableFeedback,
    super.onTap,
    super.physics,
    super.splashFactory,
    super.splashBorderRadius,
    super.tabAlignment,
    this.physicsTabBarView,
    this.dragStartBehaviorTabBarView = DragStartBehavior.start,
    this.viewportFractionTabBarView = 1.0,
    this.clipBehaviorTabBarView = Clip.hardEdge,
  }) : super(tabs: []);

  @override
  State<DynamicTabBarWidget> createState() => _DynamicTabBarWidgetState();
}

class _DynamicTabBarWidgetState extends State<DynamicTabBarWidget> with TickerProviderStateMixin {
  TabController? _tabController;

  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = getTabController(initialIndex: activeTab);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _tabController = getTabController(initialIndex: widget.dynamicTabs.length - 1);
    if (_tabController != null) {
      widget.onTabControllerUpdated.call(_tabController!);
    }
  }

  @override
  void didUpdateWidget(covariant DynamicTabBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.dynamicTabs.isEmpty) {
      return;
    }

    if (_tabController?.length != widget.dynamicTabs.length) {
      var activeTabIndex = getActiveTab();
      if (activeTabIndex >= widget.dynamicTabs.length) {
        activeTabIndex = widget.dynamicTabs.length - 1;
      }
      _tabController = getTabController(initialIndex: activeTabIndex);

      var tabIndex = widget.onAddTabMoveToIndex ?? getOnAddMoveToTab(widget.onAddTabMoveTo);

      if (tabIndex != null) {
        Future.delayed(Duration.zero, () {
          _tabController?.animateTo(
            tabIndex,
          );
          setState(() {
            activeTab = tabIndex;
          });
        });
      }
    } else {}

    if (_tabController != null) {
      widget.onTabControllerUpdated.call(_tabController!);
    }
  }

  TabController getTabController({int initialIndex = 0}) {
    if (initialIndex >= widget.dynamicTabs.length) {
      initialIndex = widget.dynamicTabs.length - 1;
    }
    return TabController(
      initialIndex: initialIndex,
      length: widget.dynamicTabs.length,
      vsync: this,
    )..addListener(() {
        setState(() {
          activeTab = _tabController?.index ?? 0;
          if (_tabController?.indexIsChanging == true) {
            widget.onTabChanged!(_tabController?.index);
          }
        });
      });
  }

  int getActiveTab() {
    // when there are No tabs
    if (activeTab == 0 && widget.dynamicTabs.isEmpty) {
      return 0;
    }
    if (activeTab == widget.dynamicTabs.length) {
      return widget.dynamicTabs.length - 1;
    }
    if (activeTab < widget.dynamicTabs.length) {
      return activeTab;
    }
    return widget.dynamicTabs.length;
  }

  int? getOnAddMoveToTab(MoveToTab? moveToTab) {
    switch (moveToTab) {
      case MoveToTab.next:
        return activeTab + 1;

      case MoveToTab.previous:
        return activeTab > 0 ? activeTab - 1 : activeTab;

      case MoveToTab.first:
        return 0;

      case MoveToTab.last:
        return widget.dynamicTabs.length - 1;

      case MoveToTab.idol:
        return null;

      case null:
        return widget.dynamicTabs.length - 1;
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: DefaultTabController(
        length: widget.dynamicTabs.length,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                if (widget.leading != null) widget.leading!,
                if (widget.isScrollable == true && widget.showBackIcon == true)
                  IconButton(
                    icon: widget.backIcon ??
                        const Icon(
                          Icons.arrow_back_ios,
                        ),
                    onPressed: _moveToPreviousTab,
                  ),
                Expanded(
                  child: widget.dynamicTabs.isEmpty
                      ? const SizedBox()
                      : TabBar(
                          isScrollable: widget.isScrollable,
                          controller: _tabController,
                          tabs: widget.dynamicTabs.map((tab) => tab.title).toList(),
                          padding: widget.padding,
                          indicatorColor: widget.indicatorColor,
                          automaticIndicatorColorAdjustment: widget.automaticIndicatorColorAdjustment,
                          indicatorWeight: widget.indicatorWeight,
                          indicatorPadding: widget.indicatorPadding,
                          indicator: widget.indicator,
                          indicatorSize: widget.indicatorSize,
                          dividerColor: widget.dividerColor,
                          dividerHeight: widget.dividerHeight,
                          labelColor: widget.labelColor,
                          labelStyle: widget.labelStyle,
                          labelPadding: widget.labelPadding,
                          unselectedLabelColor: widget.unselectedLabelColor,
                          unselectedLabelStyle: widget.unselectedLabelStyle,
                          dragStartBehavior: widget.dragStartBehavior,
                          overlayColor: widget.overlayColor,
                          mouseCursor: widget.mouseCursor,
                          enableFeedback: widget.enableFeedback,
                          onTap: widget.onTap,
                          physics: widget.physics,
                          splashFactory: widget.splashFactory,
                          splashBorderRadius: widget.splashBorderRadius,
                          tabAlignment: widget.tabAlignment,
                        ),
                ),
                if (widget.isScrollable == true && widget.showNextIcon == true)
                  IconButton(
                    icon: widget.nextIcon ??
                        const Icon(
                          Icons.arrow_forward_ios,
                        ),
                    onPressed: _moveToNextTab,
                  ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: widget.physicsTabBarView,
                dragStartBehavior: widget.dragStartBehaviorTabBarView,
                viewportFraction: widget.viewportFractionTabBarView,
                clipBehavior: widget.clipBehaviorTabBarView,
                children: widget.dynamicTabs.map((tab) => tab.content).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _moveToNextTab() {
    if (_tabController != null && _tabController!.index + 1 < _tabController!.length) {
      _tabController!.animateTo(_tabController!.index + 1);
    } else {}
  }

  _moveToPreviousTab() {
    if (_tabController != null && _tabController!.index > 0) {
      _tabController!.animateTo(_tabController!.index - 1);
    } else {}
  }
}
