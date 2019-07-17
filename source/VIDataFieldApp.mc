using Toybox.Application;
using Toybox.Test;

class VIDataFieldApp extends Application.AppBase {
  var field;

  function initialize() {
    AppBase.initialize();
  }

  function onStart(state) {
  }

  function onStop(state) {
  }

  function getInitialView() {
    field = new VIDataFieldView();
    return [ field, new VIDataFieldDelegate() ];
  }

  function toggleLapState() {
    return field.toggleLapState();
  }
}