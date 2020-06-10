class Trend {
  const SIZE = 60;
  const ZERO = 0;
  const DOWN = -1;
  const UP   = 1;

  hidden var buffer;
  hidden var index;
  hidden var size;

  function initialize(sizeValue) {
    size = sizeValue;
    buffer = createBuffer(size);
    index = 0;
  }

  function add(value) {
    value = value.toDouble();
    buffer[index] = value;
    index++;
    index %= size;

    return self;
  }

  function compute() {
    var currentIndex = index;
    var sum_xx = 0.0;
    var sum_xy = 0.0;
    var sum_x = 0.0;
    var sum_y = 0.0;
    var x, y;
    for (var i = 0; i < size; i++) {
      x = i;
      y = buffer[currentIndex];
      sum_xx += x * x;
      sum_xy += x * y;
      sum_x += x;
      sum_y += y;
      currentIndex++;
      currentIndex %= size;
    }
    return (size * sum_xy - sum_x * sum_y) / (size * sum_xx - sum_x * sum_x);
  }

  function direction() {
    var t = compute();
    if (t < 0) {
      return DOWN;
    } else if (t > 0) {
      return UP;
    } else {
      return ZERO;
    }
  }

  private

  function createBuffer(bufferSize) {
    var buffer = [];
    for (var i = 0; i < bufferSize; i++) {
      buffer.add(0.0d);
    }
    return buffer;
  }
}