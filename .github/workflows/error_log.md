Run flutter build apk --release
  flutter build apk --release
  shell: /usr/bin/bash -e {0}
  env:
    FLUTTER_ROOT: /opt/hostedtoolcache/flutter/stable-3.24.0-x64
    PUB_CACHE: /home/runner/.pub-cache

Running Gradle task 'assembleRelease'...                        
Checking the license for package Android SDK Build-Tools 33.0.1 in /usr/local/lib/android/sdk/licenses
License for package Android SDK Build-Tools 33.0.1 accepted.
Preparing "Install Android SDK Build-Tools 33.0.1 v.33.0.1".
"Install Android SDK Build-Tools 33.0.1 v.33.0.1" ready.
Installing Android SDK Build-Tools 33.0.1 in /usr/local/lib/android/sdk/build-tools/33.0.1
"Install Android SDK Build-Tools 33.0.1 v.33.0.1" complete.
"Install Android SDK Build-Tools 33.0.1 v.33.0.1" finished.
Checking the license for package Android SDK Platform 33 in /usr/local/lib/android/sdk/licenses
License for package Android SDK Platform 33 accepted.
Preparing "Install Android SDK Platform 33 (revision 3)".
"Install Android SDK Platform 33 (revision 3)" ready.
Installing Android SDK Platform 33 in /usr/local/lib/android/sdk/platforms/android-33
"Install Android SDK Platform 33 (revision 3)" complete.
"Install Android SDK Platform 33 (revision 3)" finished.
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
lib/ui/stats_page.dart:110:20: Error: Can't find ')' to match '('.
    return Scaffold(
                   ^
lib/ui/game/game_page.dart:20:9: Error: Type 'GameMode' not found.
  final GameMode mode;
        ^^^^^^^^
lib/ui/game/controllers/game_controller.dart:39:21: Error: Type 'GameMode' not found.
  void initGameMode(GameMode mode) {
                    ^^^^^^^^
lib/ui/game/widgets/game_grid.dart:246:52: Error: Type 'BlockPreviewData' not found.
  grid_widget.BlockPreviewData? _toGridPreviewData(BlockPreviewData? data) {
                                                   ^^^^^^^^^^^^^^^^
lib/ui/game/widgets/game_grid.dart:255:7: Error: Type 'ClearAnimationState' not found.
      ClearAnimationState? state) {
      ^^^^^^^^^^^^^^^^^^^
lib/ui/game/widgets/game_grid.dart:265:7: Error: Type 'PlaceAnimationState' not found.
      PlaceAnimationState? state) {
      ^^^^^^^^^^^^^^^^^^^
lib/ui/game/game_page.dart:24:17: Error: Undefined name 'GameMode'.
    this.mode = GameMode.classic,
                ^^^^^^^^
lib/ui/game/game_page.dart:20:9: Error: 'GameMode' isn't a type.
  final GameMode mode;
        ^^^^^^^^
lib/ui/game/game_page.dart:41:7: Error: The argument type 'WidgetRef' can't be assigned to the parameter type 'Ref<Object?>'.
 - 'WidgetRef' is from 'package:flutter_riverpod/src/consumer.dart' ('../../../.pub-cache/hosted/pub.dev/flutter_riverpod-2.6.1/lib/src/consumer.dart').
 - 'Ref' is from 'package:riverpod/src/framework.dart' ('../../../.pub-cache/hosted/pub.dev/riverpod-2.6.1/lib/src/framework.dart').
 - 'Object' is from 'dart:core'.
      ref,
      ^
lib/ui/game/game_page.dart:68:15: Error: The argument type 'Widget' can't be assigned to the parameter type 'PreferredSizeWidget?'.
 - 'Widget' is from 'package:flutter/src/widgets/framework.dart' ('/opt/hostedtoolcache/flutter/stable-3.24.0-x64/packages/flutter/lib/src/widgets/framework.dart').
 - 'PreferredSizeWidget' is from 'package:flutter/src/widgets/preferred_size.dart' ('/opt/hostedtoolcache/flutter/stable-3.24.0-x64/packages/flutter/lib/src/widgets/preferred_size.dart').
      appBar: _buildAppBar(),
              ^
lib/ui/tutorial_page.dart:33:26: Error: The getter 'combo2' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'combo2'.
        iconColor: theme.combo2,
                         ^^^^^^
lib/ui/tutorial_page.dart:39:26: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
        iconColor: theme.accent,
                         ^^^^^^
lib/ui/tutorial_page.dart:45:26: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
        iconColor: theme.accent,
                         ^^^^^^
lib/ui/tutorial_page.dart:51:26: Error: The getter 'warning' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'warning'.
        iconColor: theme.warning,
                         ^^^^^^^
lib/ui/tutorial_page.dart:85:30: Error: The getter 'background' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'background'.
      backgroundColor: theme.background,
                             ^^^^^^^^^^
lib/ui/tutorial_page.dart:99:40: Error: The getter 'secondaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'secondaryText'.
                          color: theme.secondaryText,
                                       ^^^^^^^^^^^^^
lib/ui/tutorial_page.dart:118:64: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                      return _buildTutorialStep(_steps[index], theme);
                                                               ^
lib/ui/tutorial_page.dart:139:43: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
                                  ? theme.accent 
                                          ^^^^^^
lib/ui/tutorial_page.dart:140:43: Error: The getter 'secondaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'secondaryText'.
                                  : theme.secondaryText.withOpacity(0.5),
                                          ^^^^^^^^^^^^^
lib/ui/tutorial_page.dart:158:54: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
                              backgroundColor: theme.accent,
                                                     ^^^^^^
lib/ui/tutorial_page.dart:159:54: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
                              foregroundColor: theme.primaryText,
                                                     ^^^^^^^^^^^
lib/ui/tutorial_page.dart:187:54: Error: The getter 'cardBackground' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'cardBackground'.
                              backgroundColor: theme.cardBackground,
                                                     ^^^^^^^^^^^^^^
lib/ui/tutorial_page.dart:188:54: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
                              foregroundColor: theme.primaryText,
                                                     ^^^^^^^^^^^
lib/ui/tutorial_page.dart:193:46: Error: The getter 'secondaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'secondaryText'.
                                color: theme.secondaryText.withOpacity(0.3),
                                             ^^^^^^^^^^^^^
lib/ui/help_page.dart:17:30: Error: The getter 'background' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'background'.
      backgroundColor: theme.background,
                             ^^^^^^^^^^
lib/ui/help_page.dart:19:36: Error: The getter 'cardBackground' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'cardBackground'.
            backgroundColor: theme.cardBackground,
                                   ^^^^^^^^^^^^^^
lib/ui/help_page.dart:22:45: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
              style: TextStyle(color: theme.primaryText),
                                            ^^^^^^^^^^^
lib/ui/help_page.dart:24:51: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
            iconTheme: IconThemeData(color: theme.primaryText),
                                                  ^^^^^^^^^^^
lib/ui/help_page.dart:35:36: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
                  iconColor: theme.accent,
                                   ^^^^^^
lib/ui/help_page.dart:38:26: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                  theme: theme,
                         ^
lib/ui/help_page.dart:47:36: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
                  iconColor: theme.accent,
                                   ^^^^^^
lib/ui/help_page.dart:50:26: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                  theme: theme,
                         ^
lib/ui/help_page.dart:59:36: Error: The getter 'warning' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'warning'.
                  iconColor: theme.warning,
                                   ^^^^^^^
lib/ui/help_page.dart:62:26: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                  theme: theme,
                         ^
lib/ui/help_page.dart:71:36: Error: The getter 'combo2' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'combo2'.
                  iconColor: theme.combo2,
                                   ^^^^^^
lib/ui/help_page.dart:74:26: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                  theme: theme,
                         ^
lib/ui/help_page.dart:83:36: Error: The getter 'error' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'error'.
                  iconColor: theme.error,
                                   ^^^^^
lib/ui/help_page.dart:86:26: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                  theme: theme,
                         ^
lib/ui/help_page.dart:95:34: Error: The getter 'cardBackground' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'cardBackground'.
                    color: theme.cardBackground,
                                 ^^^^^^^^^^^^^^
lib/ui/help_page.dart:98:36: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
                      color: theme.accent.withOpacity(0.3),
                                   ^^^^^^
lib/ui/help_page.dart:107:38: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
                        color: theme.accent,
                                     ^^^^^^
lib/ui/help_page.dart:118:46: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
                                color: theme.accent,
                                             ^^^^^^
lib/ui/help_page.dart:127:46: Error: The getter 'secondaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'secondaryText'.
                                color: theme.secondaryText,
                                             ^^^^^^^^^^^^^
lib/ui/help_page.dart:151:46: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
                      backgroundColor: theme.accent,
                                             ^^^^^^
lib/ui/help_page.dart:152:46: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
                      foregroundColor: theme.primaryText,
                                             ^^^^^^^^^^^
lib/ui/game/controllers/game_controller.dart:39:21: Error: 'GameMode' isn't a type.
  void initGameMode(GameMode mode) {
                    ^^^^^^^^
lib/ui/game/controllers/game_controller.dart:43:17: Error: The getter 'GameMode' isn't defined for the class 'GameController'.
 - 'GameController' is from 'package:block_blast/ui/game/controllers/game_controller.dart' ('lib/ui/game/controllers/game_controller.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'GameMode'.
    if (mode == GameMode.timed) {
                ^^^^^^^^
lib/ui/game/controllers/game_controller.dart:116:29: Error: The method 'GameOverDialog' isn't defined for the class 'GameController'.
 - 'GameController' is from 'package:block_blast/ui/game/controllers/game_controller.dart' ('lib/ui/game/controllers/game_controller.dart').
Try correcting the name to the name of an existing method, or defining a method named 'GameOverDialog'.
      builder: (context) => GameOverDialog(
                            ^^^^^^^^^^^^^^
lib/ui/game/widgets/game_grid.dart:246:52: Error: 'BlockPreviewData' isn't a type.
  grid_widget.BlockPreviewData? _toGridPreviewData(BlockPreviewData? data) {
                                                   ^^^^^^^^^^^^^^^^
lib/ui/game/widgets/game_grid.dart:255:7: Error: 'ClearAnimationState' isn't a type.
      ClearAnimationState? state) {
      ^^^^^^^^^^^^^^^^^^^
lib/ui/game/widgets/game_grid.dart:265:7: Error: 'PlaceAnimationState' isn't a type.
      PlaceAnimationState? state) {
      ^^^^^^^^^^^^^^^^^^^
lib/ui/game/widgets/pause_overlay.dart:23:24: Error: The getter 'background' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'background'.
          color: theme.background.withOpacity(0.7),
                       ^^^^^^^^^^
lib/ui/game/widgets/pause_overlay.dart:30:32: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
                  color: theme.primaryText,
                               ^^^^^^^^^^^
lib/ui/game/widgets/pause_overlay.dart:37:34: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
                    color: theme.primaryText,
                                 ^^^^^^^^^^^
lib/ui/game/widgets/pause_overlay.dart:48:44: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
                    backgroundColor: theme.accent,
                                           ^^^^^^
lib/ui/game/widgets/pause_overlay.dart:49:44: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
                    foregroundColor: theme.primaryText,
                                           ^^^^^^^^^^^
lib/ui/game/widgets/game_body_widget.dart:36:25: Error: The getter 'GameMode' isn't defined for the class 'GameBodyWidget'.
 - 'GameBodyWidget' is from 'package:block_blast/ui/game/widgets/game_body_widget.dart' ('lib/ui/game/widgets/game_body_widget.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'GameMode'.
        if (gameMode == GameMode.timed)
                        ^^^^^^^^
lib/ui/stats_page.dart:49:32: Error: The getter 'dialogBackground' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'dialogBackground'.
        backgroundColor: theme.dialogBackground,
                               ^^^^^^^^^^^^^^^^
lib/ui/stats_page.dart:52:41: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
          style: TextStyle(color: theme.primaryText),
                                        ^^^^^^^^^^^
lib/ui/stats_page.dart:56:41: Error: The getter 'secondaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'secondaryText'.
          style: TextStyle(color: theme.secondaryText),
                                        ^^^^^^^^^^^^^
lib/ui/stats_page.dart:63:45: Error: The getter 'secondaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'secondaryText'.
              style: TextStyle(color: theme.secondaryText),
                                            ^^^^^^^^^^^^^
lib/ui/stats_page.dart:70:45: Error: The getter 'error' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'error'.
              style: TextStyle(color: theme.error),
                                            ^^^^^
lib/ui/stats_page.dart:85:36: Error: The getter 'cardBackground' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'cardBackground'.
            backgroundColor: theme.cardBackground,
                                   ^^^^^^^^^^^^^^
lib/ui/stats_page.dart:111:34: Error: The getter 'background' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'background'.
          backgroundColor: theme.background,
                                 ^^^^^^^^^^
lib/ui/stats_page.dart:113:36: Error: The getter 'cardBackground' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'cardBackground'.
            backgroundColor: theme.cardBackground,
                                   ^^^^^^^^^^^^^^
lib/ui/stats_page.dart:116:45: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
              style: TextStyle(color: theme.primaryText),
                                            ^^^^^^^^^^^
lib/ui/stats_page.dart:118:51: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
            iconTheme: IconThemeData(color: theme.primaryText),
                                                  ^^^^^^^^^^^
lib/ui/stats_page.dart:121:56: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
                icon: Icon(Icons.refresh, color: theme.primaryText),
                                                       ^^^^^^^^^^^
lib/ui/stats_page.dart:130:34: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
                    color: theme.accent,
                                 ^^^^^^
lib/ui/stats_page.dart:139:40: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
                      iconColor: theme.accent,
                                       ^^^^^^
lib/ui/stats_page.dart:143:30: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                      theme: theme,
                             ^
lib/ui/stats_page.dart:151:40: Error: The getter 'combo2' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'combo2'.
                      iconColor: theme.combo2,
                                       ^^^^^^
lib/ui/stats_page.dart:155:30: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                      theme: theme,
                             ^
lib/ui/stats_page.dart:163:40: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
                      iconColor: theme.accent,
                                       ^^^^^^
lib/ui/stats_page.dart:167:30: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                      theme: theme,
                             ^
lib/ui/stats_page.dart:175:40: Error: The getter 'combo5' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'combo5'.
                      iconColor: theme.combo5,
                                       ^^^^^^
lib/ui/stats_page.dart:179:30: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                      theme: theme,
                             ^
lib/ui/stats_page.dart:187:40: Error: The getter 'warning' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'warning'.
                      iconColor: theme.warning,
                                       ^^^^^^^
lib/ui/stats_page.dart:191:30: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                      theme: theme,
                             ^
lib/ui/stats_page.dart:199:40: Error: The getter 'error' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'error'.
                      iconColor: theme.error,
                                       ^^^^^
lib/ui/stats_page.dart:203:30: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                      theme: theme,
                             ^
lib/ui/stats_page.dart:213:60: Error: The getter 'combo3' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'combo3'.
                          Icon(Icons.history, color: theme.combo3, size: 20),
                                                           ^^^^^^
lib/ui/stats_page.dart:218:44: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
                              color: theme.primaryText,
                                           ^^^^^^^^^^^
lib/ui/stats_page.dart:234:40: Error: The getter 'cardBackground' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'cardBackground'.
                          color: theme.cardBackground,
                                       ^^^^^^^^^^^^^^
lib/ui/stats_page.dart:240:59: Error: The getter 'secondaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'secondaryText'.
                            style: TextStyle(color: theme.secondaryText, fontSize: 14),
                                                          ^^^^^^^^^^^^^
lib/ui/stats_page.dart:245:49: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                      ..._buildScoreHistoryList(theme, l10n),
                                                ^
lib/ui/stats_page.dart:250:69: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                    if (_scoreHistory.length >= 3) _buildTrendChart(theme, l10n),
                                                                    ^
lib/ui/stats_page.dart:260:48: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
                        backgroundColor: theme.accent,
                                               ^^^^^^
lib/ui/stats_page.dart:261:48: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
                        foregroundColor: theme.primaryText,
                                               ^^^^^^^^^^^
lib/ui/game_over_dialog.dart:138:7: Error: The getter 'GameTheme' isn't defined for the class '_GameOverDialogContentState'.
 - '_GameOverDialogContentState' is from 'package:block_blast/ui/game_over_dialog.dart' ('lib/ui/game_over_dialog.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'GameTheme'.
      GameTheme.combo2, // 黄色
      ^^^^^^^^^
lib/ui/game_over_dialog.dart:139:7: Error: The getter 'GameTheme' isn't defined for the class '_GameOverDialogContentState'.
 - '_GameOverDialogContentState' is from 'package:block_blast/ui/game_over_dialog.dart' ('lib/ui/game_over_dialog.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'GameTheme'.
      GameTheme.combo3, // 橙色
      ^^^^^^^^^
lib/ui/game_over_dialog.dart:140:7: Error: The getter 'GameTheme' isn't defined for the class '_GameOverDialogContentState'.
 - '_GameOverDialogContentState' is from 'package:block_blast/ui/game_over_dialog.dart' ('lib/ui/game_over_dialog.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'GameTheme'.
      GameTheme.combo4, // 红色
      ^^^^^^^^^
lib/ui/game_over_dialog.dart:141:7: Error: The getter 'GameTheme' isn't defined for the class '_GameOverDialogContentState'.
 - '_GameOverDialogContentState' is from 'package:block_blast/ui/game_over_dialog.dart' ('lib/ui/game_over_dialog.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'GameTheme'.
      GameTheme.combo5, // 紫色
      ^^^^^^^^^
lib/ui/game_over_dialog.dart:142:7: Error: The getter 'GameTheme' isn't defined for the class '_GameOverDialogContentState'.
 - '_GameOverDialogContentState' is from 'package:block_blast/ui/game_over_dialog.dart' ('lib/ui/game_over_dialog.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'GameTheme'.
      GameTheme.accent, // 主题强调色
      ^^^^^^^^^
lib/ui/game_over_dialog.dart:143:7: Error: The getter 'GameTheme' isn't defined for the class '_GameOverDialogContentState'.
 - '_GameOverDialogContentState' is from 'package:block_blast/ui/game_over_dialog.dart' ('lib/ui/game_over_dialog.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'GameTheme'.
      GameTheme.warning, // 警告色
      ^^^^^^^^^
lib/ui/game_over_dialog.dart:171:64: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                      painter: _ConfettiPainter(_confettiList, theme),
                                                               ^
lib/ui/game_over_dialog.dart:196:36: Error: The getter 'dialogBackground' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'dialogBackground'.
                      color: theme.dialogBackground,
                                   ^^^^^^^^^^^^^^^^
lib/ui/game_over_dialog.dart:210:38: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                        _buildHeader(theme, l10n),
                                     ^
lib/ui/game_over_dialog.dart:212:44: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                        _buildScoreSection(theme, l10n),
                                           ^
lib/ui/game_over_dialog.dart:215:44: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                        _buildStatsSection(theme, l10n),
                                           ^
lib/ui/game_over_dialog.dart:218:48: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                        _buildHighScoreSection(theme, l10n),
                                               ^
lib/ui/game_over_dialog.dart:221:39: Error: The argument type 'ThemeManager' can't be assigned to the parameter type 'AppTheme'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
 - 'AppTheme' is from 'package:block_blast/game/themes/app_theme.dart' ('lib/game/themes/app_theme.dart').
                        _buildButtons(theme, l10n),
                                      ^
lib/ui/game/animations/score_animation_widget.dart:110:30: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
                color: theme.primaryText,
                             ^^^^^^^^^^^
lib/ui/game/animations/score_animation_widget.dart:118:30: Error: The getter 'secondaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'secondaryText'.
                color: theme.secondaryText,
                             ^^^^^^^^^^^^^
lib/ui/game/animations/score_animation_widget.dart:149:26: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
            color: theme.accent.withOpacity(0.2),
                         ^^^^^^
lib/ui/game/animations/score_animation_widget.dart:151:45: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
            border: Border.all(color: theme.accent, width: 1),
                                            ^^^^^^
lib/ui/game/animations/score_animation_widget.dart:156:28: Error: The getter 'accent' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'accent'.
              color: theme.accent,
                           ^^^^^^
lib/ui/game/widgets/block_pool.dart:60:19: Error: The getter 'ref' isn't defined for the class 'BlockPool'.
 - 'BlockPool' is from 'package:block_blast/ui/game/widgets/block_pool.dart' ('lib/ui/game/widgets/block_pool.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'ref'.
    final theme = ref.watch(themeManagerProvider).currentTheme;
                  ^^^
lib/ui/game/widgets/block_pool.dart:164:19: Error: The getter 'ref' isn't defined for the class 'BlockPool'.
 - 'BlockPool' is from 'package:block_blast/ui/game/widgets/block_pool.dart' ('lib/ui/game/widgets/block_pool.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'ref'.
    final theme = ref.watch(themeManagerProvider).currentTheme;
                  ^^^
lib/ui/game/animations/combo_animation_widget.dart:147:30: Error: The getter 'primaryText' isn't defined for the class 'ThemeManager'.
 - 'ThemeManager' is from 'package:block_blast/game/themes/theme_manager.dart' ('lib/game/themes/theme_manager.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'primaryText'.
                color: theme.primaryText,
                             ^^^^^^^^^^^
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildRelease'.
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.24.0-x64/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 4m 35s
Running Gradle task 'assembleRelease'...                          277.1s
Gradle task assembleRelease failed with exit code 1
Error: Process completed with exit code 1.