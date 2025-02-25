## 0.0.1

- Initial release.

## 0.0.2

- Fix: Dart conventions and supported platforms.

## 0.0.3

- Fix: Static analyses.

## 0.0.4

- Fix/Optimize: Behavior when NeverScrollPhysics is applied and use of variables in the widget.

## 0.0.6

- New: Fixed loader movement when get to end position, customize RefreshLoader and added none value to RefreshDragEnum.

## 0.0.6

- Fix: Applied custom color RefreshLoader

## 0.0.7

- Fix: Prevent bottomLoader from appearing when RefreshDragEnum is set to top, and topLoader from appearing when set to bottom.

## 0.0.8

Fix: Corrected overscroll detection when RefreshDragEnum was set to either top or bottom. After multiple overscrolls in one direction, followed by a scroll in the opposite direction, _isEdge was incorrectly marked as true. This fix ensures accurate drag direction detection and proper refresh process activation.
