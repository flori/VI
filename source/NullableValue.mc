class NullableValue {
  hidden var valueFormat;
  hidden var initialValue;
  hidden var valueUnit;
  hidden var value = null;

  function initialize(format, unit, iv) {
    valueFormat = format;
    initialValue = iv;
    valueUnit = unit;
  }

  function set(v) {
    value = v;
    return self;
  }

  function toString() {
    if (value == null) {
      return initialValue + valueUnit;
    } else {
      return value.format(valueFormat) + valueUnit;
    }
  }
}