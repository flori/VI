using DrawHelper;

class NarrowDisplay {
  hidden var dc;
  hidden var data;

  function initialize(myDC, myData) {
    dc = myDC;
    data = myData;
  }

  private function drawNarrowDisplay() {
    var font = DrawHelper.determineFont(
      dc,
      [ Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY ],
      2
    );
    dc.drawText(
      dc.getWidth() / 2,
      2,
      font[0],
      data.name,
      Graphics.TEXT_JUSTIFY_CENTER
    );
    font = DrawHelper.determineFont(
      dc,
      [ Graphics.FONT_NUMBER_THAI_HOT, Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_NUMBER_MILD, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY ],
      2
    );
    var t = data.value.toString();
    dc.drawText(
      dc.getWidth() / 2,
      dc.getHeight() - font[1] - 1,
      font[0],
      t,
      Graphics.TEXT_JUSTIFY_CENTER
    );
    var tw = dc.getTextWidthInPixels(t, font[0]);
    DrawHelper.drawTrend(
      dc,
      data.trend.direction(),
      dc.getWidth() / 2 - tw / 2 - dc.getWidth() / 12 - dc.getTextWidthInPixels(".", font[0]) / 2,
      dc.getHeight() - font[1] - 1,
      dc.getWidth() / 12,
      font[1]
    );
  }

  function draw() {
    drawNarrowDisplay();
  }
}
