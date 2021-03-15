using Toybox.WatchUi;
using DrawHelper;

class VIDataFieldView extends WatchUi.DataField {
  hidden var viValue = new DivisionValue("_.___");
  hidden var viTrend;
  hidden var viLapValue = new DivisionValue("_.___");
  hidden var viLapTrend;

  hidden var avgPowerValue = new NullableValue("%u", "W", "___");
  hidden var avgLapPowerValue = new NullableValue("%u", "W", "___");
  hidden var avgNrmPowerValue = new NullableValue("%u", "W", "___");
  hidden var avgNrmLapPowerValue = new NullableValue("%u", "W", "___");

  hidden var ifValue = new DivisionValue("_.___");
  hidden var ifTrend;
  hidden var ifLapValue = new DivisionValue("_.___");
  hidden var ifLapTrend;
  hidden var ftpValue = new NullableValue("%u", "W", "___");
  hidden var ftp = 255.0;
  hidden var ftpTrend = new NoTrend();

  hidden var avg;
  hidden var avgTrend;
  hidden var avgLap;
  hidden var avgLapTrend;

  hidden var nrm;
  hidden var nrmLap;
  hidden var avgNrm;
  hidden var avgNrmTrend;
  hidden var avgNrmLap;
  hidden var avgNrmLapTrend;

  hidden var displayState;

  hidden var excludeZero;

  hidden var resetNrmOnLap;

  enum {
    STD,
    LAP,
    IF_STD,
    IF_LAP,
  }

  function initialize() {
    DataField.initialize();
    displayState = LAP;
    configureExcludeZero();
    configureFTP();
    configureResetNrmOnLap();
    reset();
  }

  function onTimerReset() {
    reset();
  }

  function onTimerLap() {
    resetLap();
  }

  function compute(info) {
    ftpValue.set(ftp);

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
    avgPowerValue.set(averagePower);

    // Average Lap Power
    var averageLapPower = avgLap.add(currentPower).compute();
    avgLapTrend.add(averageLapPower);
    avgLapPowerValue.set(averageLapPower);

    var normalizedPower = nrm.add(currentPower).compute();
    if (normalizedPower != null) {

      // Average Normalized Power
      var avgNormalizedPower = avgNrm.add(normalizedPower).compute();
      avgNrmTrend.add(avgNormalizedPower);
      avgNrmPowerValue.set(avgNormalizedPower);

      var vi = viValue.compute(avgNormalizedPower, averagePower);
      if (vi != null) {
        viTrend.add(vi);
      }

      var intensity = ifValue.compute(avgNormalizedPower, ftp);
      if (intensity != null) {
        ifTrend.add(intensity);
      }
    }

    var normalizedLapPower = nrmLap.add(currentPower).compute();
    if (normalizedLapPower != null) {
      // Average Normalized Lap Power
      var avgNormalizedLapPower = avgNrmLap.add(normalizedLapPower).compute();
      avgNrmLapTrend.add(avgNormalizedLapPower);
      avgNrmLapPowerValue.set(avgNormalizedLapPower);

      var viLap = viLapValue.compute(avgNormalizedLapPower, averageLapPower);
      if (viLap != null) {
        viLapTrend.add(viLap);
      }

      var intensityLap = ifLapValue.compute(avgNormalizedLapPower, ftp);
      if (intensityLap != null) {
        ifLapTrend.add(intensityLap);
      }
    }
  }

  function onUpdate(dc) {
    setColors(dc);

    var ratio = dc.getWidth().toFloat() / dc.getHeight();
    if (ratio < 3) {
      switch (displayState) {
        case STD:
          new NarrowDisplay(dc, new ValueData("VI", viValue, viTrend)).draw();
          break;
        case LAP:
          new NarrowDisplay(dc, new ValueData("VI Lap", viLapValue, viLapTrend)).draw();
          break;
        case IF_STD:
          new NarrowDisplay(dc, new ValueData("IF", ifValue, ifTrend)).draw();
          break;
        case IF_LAP:
          new NarrowDisplay(dc, new ValueData("IF Lap", ifLapValue, ifLapTrend)).draw();
          break;
      }
    } else {
      switch (displayState) {
        case STD:
          new WideDisplay(dc,
            new ValueData("VI", viValue, viTrend),
            new ValueData("NP", avgNrmPowerValue, avgNrmTrend),
            new ValueData("AP", avgPowerValue, avgTrend)
          ).draw();
          break;
        case LAP:
          new WideDisplay(dc,
            new ValueData("VI Lap", viLapValue, viLapTrend),
            new ValueData("NP", avgNrmLapPowerValue, avgNrmLapTrend),
            new ValueData("AP", avgLapPowerValue, avgLapTrend)
          ).draw();
          break;
        case IF_STD:
          new WideDisplay(dc,
            new ValueData("IF", ifValue, ifTrend),
            new ValueData("NP", avgNrmPowerValue, avgNrmTrend),
            new ValueData("TP", ftpValue, ftpTrend)
          ).draw();
          break;
        case IF_LAP:
          new WideDisplay(dc,
            new ValueData("IF Lap", ifLapValue, ifLapTrend),
            new ValueData("NP", avgNrmLapPowerValue, avgNrmLapTrend),
            new ValueData("TP", ftpValue, ftpTrend)
          ).draw();
          break;
      }
    }
  }

  function resetLap() {
    if (resetNrmOnLap) {
      nrmLap = new Normalized();
    } else {
      nrmLap = nrm;
    }
    avgLap = new Average();
    avgNrmLap = new Average();
    avgLapPowerValue.set(null);
    avgNrmLapPowerValue.set(null);
    ifLapValue.set(null);
    viLapValue.set(null);

    resetLapTrend();
  }

  function reset() {
    nrm = new Normalized();
    avg = new Average();
    avgNrm = new Average();
    avgPowerValue.set(null);
    avgNrmPowerValue.set(null);
    viValue.set(null);
    ifValue.set(null);

    resetLap();
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
    ifTrend = new Trend(size);
  }

  function resetLapTrend() {
    var size = trendDuration();
    System.println("Configure lap trends for " + size + " seconds duration");
    avgLapTrend= new Trend(size);
    avgNrmLapTrend = new Trend(size);
    viLapTrend = new Trend(size);
    ifLapTrend = new Trend(size);
  }

  function configureExcludeZero() {
    excludeZero = false;
    if (Application has :Properties) {
      excludeZero = Application.Properties.getValue("excludeZero");
    }
  }

  function configureFTP() {
    ftp = 0.0;
    if (Application has :Properties) {
      ftp = Application.Properties.getValue("ftp").toDouble();
    }
  }

  function configureResetNrmOnLap() {
    resetNrmOnLap = false;
    if (Application has :Properties) {
      resetNrmOnLap = Application.Properties.getValue("resetNrmOnLap");
    }
  }

  function reconfigure() {
    configureExcludeZero();
    configureFTP();
    configureResetNrmOnLap();
    resetTrend();
    resetLapTrend();
  }

  function toggleDisplayState() {
    displayState = (displayState + 1) % 4;
    System.println("Switch to display state " + displayState);
  }

  private

  function setColors(dc) {
    var backgroundColor = getBackgroundColor();
    var dataColor = Graphics.COLOR_WHITE;
    if (backgroundColor == Graphics.COLOR_WHITE) {
      dataColor = Graphics.COLOR_BLACK;
    }

    dc.setColor(dataColor, backgroundColor);
    dc.clear();
  }
}