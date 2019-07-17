using Toybox.Math;

class Normalized {
  const SIZE = 30;

  var total;
  var count;
  var rollingWindow;
  var sum;
  var index;

  function initialize() {
    total = 0.0d;
    count = 0;
    rollingWindow = createRollingWindow(SIZE);
    sum   = 0.0d;
    index = 0;
  }

  function add(value) {
    value = value.toDouble();
    count++;

    sum += value;
    sum -= rollingWindow[index];
    rollingWindow[index] = value;

    total += Math.pow(sum / SIZE, 4);

    index++;
    if (index >= SIZE) {
      index = 0;
    }

    return self;
  }

  function compute() {
    if (count > 0) {
      return Math.pow(total / count, 0.25);
    } else {
      return null;
    }
  }

  private

  function createRollingWindow(rollingWindowSize) {
    var rollingWindow = [];
    for (var i = 0; i < rollingWindowSize; i++) {
      rollingWindow.add(0.0d);
    }
    return rollingWindow;
  }
}