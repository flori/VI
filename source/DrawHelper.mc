module DrawHelper {
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

  function drawTrend(dc, direction, x, y, w, h) {
    if (direction == Trend.NOPE) {
      return;
    }
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
}