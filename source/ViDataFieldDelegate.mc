using Toybox.WatchUi;

class VIDataFieldDelegate extends WatchUi.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onTap(event) {
    Application.getApp().toggleDisplayState();
    return true;
  }

  function onMenu(event) {
    return true;
  }
}