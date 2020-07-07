class DivisionValue {
  hidden var initialValue;
  hidden var value = null;

  function initialize(iv) {
    initialValue = iv;
  }

  function compute(dividend, divisor) {
    if (divisor == 0) {
      value = null;
    } else {
      value = dividend / divisor;
    }
    return value;
  }

  function toString() {
    if (value == null) {
      return initialValue;
    } else {
      return value.format("%.3f");
    }
  }
}