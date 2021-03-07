using DrawHelper;

class WideDisplay {
  hidden var dc;
  hidden var data;
  hidden var upperData;
  hidden var lowerData;

  function initialize(myDC, myData, myUpperData, myLowerData) {
    dc = myDC;
    data = myData;
    upperData = myUpperData;
    lowerData = myLowerData;
  }

  private function drawWideDisplay() {
    var font = DrawHelper.determineFont(
      dc,
      [ Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY ],
      2
    );
    dc.drawText(
      dc.getWidth() / 4,
      1,
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
      dc.getWidth() / 4 + dc.getTextWidthInPixels(".", font[0]),
      dc.getHeight() - font[1] - 1,
      font[0],
      t,
      Graphics.TEXT_JUSTIFY_CENTER
    );
    var tw = dc.getTextWidthInPixels(t, font[0]);
    DrawHelper.drawTrend(
      dc,
      data.trend.direction(),
      dc.getWidth() / 4 - tw / 2 - dc.getWidth() / 24,
      dc.getHeight() - font[1] - 1,
      dc.getWidth() / 24,
      font[1]
    );

    font = DrawHelper.determineFont(
      dc,
      [ Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY ],
      2
    );
    dc.drawText(
      dc.getWidth() / 2 + 1,
      dc.getHeight() / 4 - font[1] / 2,
      font[0],
      upperData.name,
      Graphics.TEXT_JUSTIFY_LEFT
    );
    var twNP = dc.getTextWidthInPixels(upperData.name, font[0]);
    dc.drawText(
      dc.getWidth() / 2 + 1,
      dc.getHeight() * 3 / 4 - font[1] / 2,
      font[0],
      lowerData.name,
      Graphics.TEXT_JUSTIFY_LEFT
    );
    var twAP = dc.getTextWidthInPixels(lowerData.name, font[0]);
    font = DrawHelper.determineFont(
      dc,
      [ Graphics.FONT_NUMBER_THAI_HOT, Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_NUMBER_MILD, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY ],
      2
    );
    DrawHelper.drawTrend(
      dc,
      upperData.trend.direction(),
      dc.getWidth() / 2 + 1 + twNP + dc.getTextWidthInPixels(".", font[0]),
      dc.getHeight() - 2 * font[1] - 1,
      dc.getWidth() / 24,
      font[1]
    );
    dc.drawText(
      dc.getWidth() - 4,
      dc.getHeight() - 2 * font[1] - 1,
      font[0],
      upperData.value.toString(),
      Graphics.TEXT_JUSTIFY_RIGHT
    );
    DrawHelper.drawTrend(
      dc,
      lowerData.trend.direction(),
      dc.getWidth() / 2 + 1 + twAP + dc.getTextWidthInPixels(".", font[0]),
      dc.getHeight() - font[1] - 1,
      dc.getWidth() / 24,
      font[1]
    );
    dc.drawText(
      dc.getWidth() - 4,
      dc.getHeight() - font[1] - 1,
      font[0],
      lowerData.value.toString(),
      Graphics.TEXT_JUSTIFY_RIGHT
    );
  }

  function draw() {
    drawWideDisplay();
  }
}
