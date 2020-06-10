class Average {
  hidden var total;
  hidden var count;

  function initialize() {
    total = 0.0d;
    count = 0;
  }

  function add(value) {
    count++;
    total += value.toDouble();
    return self;
  }

  function compute() {
    if (count > 0) {
      return total / count;
    } else {
      return null;
    }
  }
}