using Toybox.WatchUi;

class VIDataFieldView extends WatchUi.DataField {
  hidden var viValue = new DivisionValue("_.___");
  hidden var viTrend;
  hidden var viLapValue = new DivisionValue("_.___");
  hidden var viLapTrend;

  const INITIAL_POWER_VALUE = "___W";
  hidden var avgPowerValue = INITIAL_POWER_VALUE;
  hidden var avgLapPowerValue = INITIAL_POWER_VALUE;
  hidden var avgNrmPowerValue = INITIAL_POWER_VALUE;
  hidden var avgNrmLapPowerValue = INITIAL_POWER_VALUE;

  hidden var avg;
  hidden var avgTrend;
  hidden var avgLap;
  hidden var avgLapTrend;

  hidden var nrm;
  hidden var avgNrm;
  hidden var avgNrmTrend;
  hidden var avgNrmLap;
  hidden var avgNrmLapTrend;

  hidden var showLap;

  hidden var excludeZero;

  function initialize() {
    DataField.initialize();
    showLap = true;
    configureExcludeZero();
    reset();
  }

  function onTimerReset() {
    reset();
  }

  function onTimerLap() {
    resetLap();
  }

  function compute(info) {
    if (info.timerState != Activity.TIMER_STATE_ON) {
      return;
    }

    var currentPower = 0;
    if (info has :currentPower && info.currentPower != null) {
      currentPower = info.currentPower;
    }

    if (excludeZero && currentPower == 0) {
      System.println("Excluding zero power value.");
      return;
    }
    System.println("Power value currently measured: " + currentPower + "W");

    // Average power
    var averagePower = avg.add(currentPower).compute();
    avgTrend.add(averagePower);
    avgPowerValue = averagePower.format("%u") + "W";

    // Average Lap Power
    var averageLapPower = avgLap.add(currentPower).compute();
    avgLapTrend.add(averageLapPower);
    avgLapPowerValue = averageLapPower.format("%u") + "W";

    // Current Normalized Power
    var normalizedPower = nrm.add(currentPower).compute();

    if (normalizedPower == null) {
      return;
    }

    // Average Normalized Power
    var avgNormalizedPower = avgNrm.add(normalizedPower).compute();
    avgNrmTrend.add(avgNormalizedPower);
    avgNrmPowerValue = avgNormalizedPower.format("%u") + "W";

    // Average Normalized Lap Power
    var avgNormalizedLapPower = avgNrmLap.add(normalizedPower).compute();
    avgNrmLapTrend.add(avgNormalizedLapPower);
    avgNrmLapPowerValue = avgNormalizedLapPower.format("%u") + "W";

    var vi = viValue.compute(avgNormalizedPower, averagePower);
    if (vi != null) {
      viTrend.add(vi);
    }

    var viLap = viLapValue.compute(avgNormalizedLapPower, averageLapPower);
    if (viLap != null) {
      viLapTrend.add(viLap);
    }
  }

  function onUpdate(dc) {
    setColors(dc);

    var ratio = dc.getWidth().toFloat() / dc.getHeight();
    if (ratio < 3) {
      drawNarrowDisplay(dc);
    } else {
      drawWideDisplay(dc);
    }
  }

  function resetLap() {
    avgLap = new Average();
    avgNrmLap = new Average();
    resetLapTrend();
  }

  function reset() {
    resetLap();
    nrm = new Normalized();
    avg = new Average();
    avgNrm = new Average();
    resetTrend();
  }

  function trendDuration() {
    var size = 60;
    if (Application has :Properties) {
      size = Application.Properties.getValue("trendDuration").toNumber();
    }
    return size;
  }

  function resetTrend() {
    var size = trendDuration();
    System.println("Configure trends for " + size + " seconds duration");
    avgTrend = new Trend(size);
    avgNrmTrend = new Trend(size);
    viTrend = new Trend(size);
  }

  function resetLapTrend() {
    var size = trendDuration();
    System.println("Configure lap trends for " + size + " seconds duration");
    avgLapTrend= new Trend(size);
    avgNrmLapTrend = new Trend(size);
    viLapTrend = new Trend(size);
  }

  function configureExcludeZero() {
    excludeZero = false;
    if (Application has :Properties) {
      excludeZero = Application.Properties.getValue("excludeZero");
    }
  }

  function reconfigure() {
    resetTrend();
    resetLapTrend();
    configureExcludeZero();
  }

  function toggleLapState() {
    showLap = !showLap;
  }

  private

  function sortFonts(dc, a) {
    var aSize = a.size();

    for (var i = 0; i < aSize; i++) {
      a[i] = [ a[i], dc.getFontHeight(a[i]) ];
    }

    for (var i = 0; i < aSize - 1; i++) {
      var m = i;

      for (var j = i + 1; j < aSize; j++) {
        if (a[j][1] > a[m][1]) {
          m = j;
        }
      }

      if (m != i) {
        var tmp = a[i];
        a[i] = a[m];
        a[m] = tmp;
      }
    }

    for (var i = 0; i < aSize; i++) {
      a[i] = a[i][0];
    }
  }

  function determineFont(dc, fonts, divisor) {
    sortFonts(dc, fonts);
    var requestedHeight = dc.getHeight().toFloat() / divisor;
    var font = fonts[fonts.size() - 1];
    for (var i = 0; i < fonts.size(); i++) {
      if (dc.getFontHeight(fonts[i]) <= requestedHeight) {
        font = fonts[i];
        break;
      }
    }
    return [ font, dc.getFontHeight(font) ];
  }

  function setColors(dc) {
    var backgroundColor = getBackgroundColor();
    var dataColor = Graphics.COLOR_WHITE;
    if (backgroundColor == Graphics.COLOR_WHITE) {
      dataColor = Graphics.COLOR_BLACK;
    }

    dc.setColor(dataColor, backgroundColor);
    dc.clear();
  }

  function drawTrend(dc, direction, x, y, w, h) {
    var pw = dc.getHeight() / 40;
    if (pw > 8) {
      pw = 4;
    }
    y += h * 30 / 100;
    h = h * 625 / 1000;
    h -= 6 * pw;
    dc.fillPolygon(
      [ [ x, y + h / 2 - pw ], [ x + w, y + h / 2 - pw ], [ x + w, y + h / 2 + pw], [ x, y + h / 2 + pw ] ]
    );
    if (direction == Trend.UP) {
      dc.fillPolygon(
        [ [ x, y + h / 2 - pw * 3 ], [ x + w / 2, y - pw * 3 ], [ x + w, y + h / 2 - pw * 3 ] ]
      );
    }
    if (direction == Trend.DOWN) {
      dc.fillPolygon(
        [ [ x, y + h / 2 + pw * 3 ], [ x + w / 2, y + h + pw * 3 ], [ x + w, y + h / 2 + pw * 3 ] ]
      );
    }
  }

  function drawNarrowDisplay(dc) {
    var font = determineFont(
      dc,
      [ Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY ],
      2
    );
    dc.drawText(
      dc.getWidth() / 2,
      2,
      font[0],
      showLap ? "VI Lap" : "VI",
      Graphics.TEXT_JUSTIFY_CENTER
    );
    font = determineFont(
      dc,
      [ Graphics.FONT_NUMBER_THAI_HOT, Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_NUMBER_MILD, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY ],
      2
    );
    var t = showLap ? viLapValue.format() : viValue.format();
    dc.drawText(
      dc.getWidth() / 2,
      dc.getHeight() - font[1] - 1,
      font[0],
      t,
      Graphics.TEXT_JUSTIFY_CENTER
    );
    var tw = dc.getTextWidthInPixels(t, font[0]);
    drawTrend(
      dc,
      showLap ? viLapTrend.direction() : viTrend.direction(),
      dc.getWidth() / 2 - tw / 2 - dc.getWidth() / 12 - dc.getTextWidthInPixels(".", font[0]) / 2,
      dc.getHeight() - font[1] - 1,
      dc.getWidth() / 12,
      font[1]
    );
  }

  function drawWideDisplay(dc) {
    var font = determineFont(
      dc,
      [ Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY ],
      2
    );
    dc.drawText(
      dc.getWidth() / 4,
      1,
      font[0],
      showLap ? "VI Lap" : "VI",
      Graphics.TEXT_JUSTIFY_CENTER
    );
    font = determineFont(
      dc,
      [ Graphics.FONT_NUMBER_THAI_HOT, Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_NUMBER_MILD, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY ],
      2
    );
    var t = showLap ? viLapValue.format() : viValue.format();
    dc.drawText(
      dc.getWidth() / 4 + dc.getTextWidthInPixels(".", font[0]),
      dc.getHeight() - font[1] - 1,
      font[0],
      t,
      Graphics.TEXT_JUSTIFY_CENTER
    );
    var tw = dc.getTextWidthInPixels(t, font[0]);
    drawTrend(
      dc,
      showLap ? viLapTrend.direction() : viTrend.direction(),
      dc.getWidth() / 4 - tw / 2 - dc.getWidth() / 24,
      dc.getHeight() - font[1] - 1,
      dc.getWidth() / 24,
      font[1]
    );

    font = determineFont(
      dc,
      [ Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY ],
      2
    );
    dc.drawText(
      dc.getWidth() / 2 + 1,
      dc.getHeight() / 4 - font[1] / 2,
      font[0],
      "NP",
      Graphics.TEXT_JUSTIFY_LEFT
    );
    var twNP = dc.getTextWidthInPixels("NP", font[0]);
    dc.drawText(
      dc.getWidth() / 2 + 1,
      dc.getHeight() * 3 / 4 - font[1] / 2,
      font[0],
      "AP",
      Graphics.TEXT_JUSTIFY_LEFT
    );
    var twAP = dc.getTextWidthInPixels("AP", font[0]);
    font = determineFont(
      dc,
      [ Graphics.FONT_NUMBER_THAI_HOT, Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_NUMBER_MILD, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY ],
      2
    );
    drawTrend(
      dc,
      showLap ? avgNrmLapTrend.direction() : avgNrmTrend.direction(),
      dc.getWidth() / 2 + 1 + twNP + dc.getTextWidthInPixels(".", font[0]),
      dc.getHeight() - 2 * font[1] - 1,
      dc.getWidth() / 24,
      font[1]
    );
    dc.drawText(
      dc.getWidth() - 4,
      dc.getHeight() - 2 * font[1] - 1,
      font[0],
      showLap ? avgNrmLapPowerValue : avgNrmPowerValue,
      Graphics.TEXT_JUSTIFY_RIGHT
    );
    drawTrend(
      dc,
      showLap ? avgLapTrend.direction() : avgTrend.direction(),
      dc.getWidth() / 2 + 1 + twAP + dc.getTextWidthInPixels(".", font[0]),
      dc.getHeight() - font[1] - 1,
      dc.getWidth() / 24,
      font[1]
    );
    dc.drawText(
      dc.getWidth() - 4,
      dc.getHeight() - font[1] - 1,
      font[0],
      showLap ? avgLapPowerValue : avgPowerValue,
      Graphics.TEXT_JUSTIFY_RIGHT
    );
  }
}
