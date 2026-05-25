const int _minimumBitmaskSize = 1;
const int _maximumBitmaskSize = 63;

/// A Bitmask class, which contains a collection of single bits.
///
/// There are four ways to construct a Bitmap object:
/// ```dart
/// // Create a Bitmask of 6 bits all set to 0
/// final mask1 = Bitmask(6);
/// // Create a Bitmask of 10 bits, with bits 1, 3, and 5 set to 1.
/// final mask2 = Bitmask.fromInt(21, 10);
/// // Create a Bitmask of 4 bits, with bits 1 and 3 set.
/// final mask3 = Bitmask.fromList([1, 3], 4);
/// // Create a Bitmask that is a deep copy of another.
/// final mask4 = Bitmask.fromBitmask(mask2);
/// ```
/// There are two ways to set individual bits, and two ways to unset
/// individual bits:
/// ```dart
/// // To set a bit, use either:
/// mask2.set(4); // Set bit 4 to 1 (true);
/// mask2[4] = true;  // Set the same bit to 1 (true)
/// // To unset a bit, use either:
/// mask2.unset(3);  // Set bit 3 to 0 (false)
/// mask2[3] = false; // Set same bit to 0 (false)
/// ```
/// The normal bit-wise operations are supported:
/// ```dart
/// // Bit-wise AND.
/// var mask5 = mask1 & mask2;
/// // Bit-wise OR.
/// var mask6 = mask1 | mask2;
/// // Bit-wise XOR.
/// var mask7 = mask1 ^ mask2;
/// // Bit-wise NOT.
/// var mask8 = ~mask1;
/// ```
/// To convert to and from an integer:
/// ```dart
/// // Create an 8 bit Bitmask object with bits 1, 3, and 5 set.
/// var mask9 = Bitmask.fromInt(21, 8);
/// // Get integer value from Bitmask object
/// var bits = mask9.flags; // bits contains value 21.
/// ```
/// To reset all bits in a Bitmask object to 0 (false), call clear().
/// ```dart
/// mask9.clear();  // mask9 now contains all zeroes.
/// ```
/// There are two ways to determine if a bit is set:
/// ```dart
/// bool bit4 = mask7.isSet(4);
/// bool bit3 = mask7[3];
/// ```
/// Dart does not support generic enumerations, so Bitmask constructors
/// and methods use integer arguments. It is possible to use enumerations
/// with Bitmask by converting the enumeration values to integers as follows:
/// ```dart
/// enum Maskbits { zero, one, two, three, four }
///
/// var mask1 = Bitmask(Maskbits.values.length);
/// mask1[Maskbits.one.index] = true; // Set bit 1.
/// // Create Bitmask object to hold all Maskbits, with bits 1 and 2 set to 1
/// var mask2 = Bitmask.fromList([Maskbits.one.index, Maskbits.two.index],
///     Maskbits.values.length);
/// ```
class Bitmask {
  /// Construct a bitmask with no bits set.
  ///
  /// [_numberOfBits] is the number of bits in the BitMask. The minimum
  /// value for this argument is 1; a Bitmask of zero or a negative
  /// size does not make sense. The maximum
  /// value for this argument is 63 as that is the size of a bitmask that
  /// can fit in an integer. This value should be no larger than 52 if
  /// the BitMask is used on the Web because that is the largest size that
  /// can be reliably set in Javascript.
  ///
  /// Throws [ArgumentError] if the bit number is invalid (< 1 or greater
  /// than 63).
  Bitmask(int numberOfBits) {
    if (numberOfBits < _minimumBitmaskSize) {
      throw ArgumentError('Bitmask constructor: Attempting to create a '
          "Bitmask size less than one bit.");
    }
    if (numberOfBits > _maximumBitmaskSize) {
      throw ArgumentError('Bitmask constructor: Attempting to create a '
          'Bitmask size larger than 63 bits in size.');
    }
    _mask = List<bool>.filled(numberOfBits, false, growable: false);
  }

  /// Create a Bitmask from an integer value.
  ///
  /// [_bits] is the integer value to create the Bitmask for.
  ///
  /// [_numberOfBits] is the number of bits in the Bitmask. No check is made
  /// to ensure that the size of the Bitmask is large enough to hold all
  /// of the bits in [_bits]. The minimum
  /// value for this argument is 1; a Bitmask of zero or a negative
  /// size does not make sense. The maximum
  /// value for this argument is 63 as that is the size of a bitmask that
  /// can fit in an integer. This value should be no larger than 52 if
  /// the BitMask is used on the Web because that is the largest size that
  /// can be reliably set in Javascript.
  ///
  /// Throws [ArgumentError] is [_numberOfBits] is not between 1 and 63.
  factory Bitmask.fromInt(int bits, int numberOfBits) {
    if (numberOfBits < _minimumBitmaskSize ||
        numberOfBits > _maximumBitmaskSize) {
      throw ArgumentError('Bitmask.fromInt: Bitmask size must be between'
          ' 1 and 63.');
    }
    Bitmask mask = Bitmask(numberOfBits);
    for (int i = 0; i < numberOfBits; i++) {
      mask[i] = (bits & 1) == 1;
      bits >>= 1;
    }
    return mask;
  }

  /// Create Bitmask with bits specified in a list set.
  ///
  /// [_bits] is the list of bits to set.
  ///
  /// [_numberOfBits] is the number of bits in this Bitmask.
  ///
  /// Throws [ArgumentError] if [_numberOfBits] is not between 1 and 63.
  ///
  /// Throws [ArgumentError] if any entry in [_bits] is outside the range
  /// of 0 and [_numberOfBits] - 1.
  factory Bitmask.fromList(List<int> bits, int numberOfBits) {
    if (numberOfBits < _minimumBitmaskSize ||
        numberOfBits > _maximumBitmaskSize) {
      throw ArgumentError('Bitmask.fromList: Bitmask size must be between'
          ' 1 and 63.');
    }
    var mask = Bitmask(numberOfBits);
    for (var bit in bits) {
      if (bit < 0 || bit >= numberOfBits) {
        throw ArgumentError('Bitmask.fromList: Attempting to set a bit '
            'that is less than 0 or greater than the size of the Bitmask.');
      }
      mask[bit] = true;
    }
    return mask;
  }

  /// Create a Bitmask object that is a copy of another Bitmask object.
  ///
  /// This constructor is required because with
  /// ```dart
  /// var mask2 = mask1;
  /// ```
  /// both [mask1] and [mask2] point to the same object, not different objects
  /// with the same content. Also, dart does
  /// not allow overriding _operator =_, so we can't override it to
  /// produce the result that we want.
  factory Bitmask.fromBitmask(Bitmask other) {
    return Bitmask.fromInt(other.flags, other.length);
  }

  /// Set all bits to false.
  void clear() {
    _mask = List<bool>.filled(_mask.length, false, growable: false);
  }

  /// Get the bitmask as an integer.
  int get flags {
    var result = 0;
    for (var bit = 0; bit < _mask.length; bit++) {
      if (_mask[bit]) {
        result += 1 << bit;
      }
    }
    return result;
  }

  /// Set the bit specified by [bit] to 1 (true).
  ///
  /// Throws [ArgumentError] if the bit number is invalid (< 0 or greater
  /// than the number of bits in the mask).
  void set(int bit) {
    if (bit < 0 || bit >= _mask.length) {
      throw ArgumentError('Bitmask.set: Request to set bit \'$bit\' which '
          'is invalid.');
    }
    _mask[bit] = true;
  }

  /// Set the bit specified by [bit] to 0 (false).
  ///
  /// Throws [ArgumentError] if the bit number is invalid (< 0 or greater
  /// than the number of bits in the mask).
  void unset(int bit) {
    if (bit < 0 || bit >= _mask.length) {
      throw ArgumentError('Bitmask.unset: Request to unset bit \'$bit\' which '
          'is invalid.');
    }
    _mask[bit] = false;
  }

  /// Check if a bit is set.
  ///
  /// Returns true if the bit is set, and false if the bit is not set.
  ///
  /// Throws [ArgumentError] if the bit number is invalid (< 0 or greater
  /// than the number of bits in the mask).
  bool isSet(int bit) {
    if (bit < 0 || bit >= _mask.length) {
      throw ArgumentError('Bitmask.isSet: Request to check bit \'$bit\' '
          'is invalid.');
    }
    return _mask[bit];
  }

  /// Get the setting of a bit.
  ///
  /// Returns true if the bit is set, and false if the bit is not set.
  ///
  /// Throws [ArgumentError] if the bit number is invalid (< 0 or greater
  /// than the number of bits in the mask).
  bool operator [](int bit) => isSet(bit);

  /// Set a bit to 1 (true) or 0 (false).
  ///
  /// Throws [ArgumentError] if the bit number is invalid (< 0 or greater
  /// than the number of bits in the mask).
  operator []=(int bit, bool value) {
    if (bit < 0 || bit >= _mask.length) {
      throw ArgumentError('Bitmask.operator []=: Request to set bit '
          '\'$bit\' is invalid.');
    }
    _mask[bit] = value;
  }

  /// Create a Bitmask of the bitwise complement of this object.
  Bitmask operator ~() {
    var newMask = Bitmask.fromBitmask(this);
    for (var bit = 0; bit < _mask.length; bit++) {
      newMask[bit] = !_mask[bit];
    }
    return newMask;
  }

  /// Create a Bitmask that is the bitwise AND of one Bitmask with another.
  ///
  /// Throws [ArgumentError] if the Bitmasks are not the same size.
  Bitmask operator &(Bitmask other) {
    if (length != other.length) {
      throw ArgumentError('Bitmask.operator &: Attempting to do a bitwise'
          ' AND of two Bitmasks that are not the same size.');
    }
    Bitmask newMask = Bitmask.fromBitmask(this);
    for (int bit = 0; bit < _mask.length; bit++) {
      newMask[bit] &= other[bit];
    }
    return newMask;
  }

  /// Create a Bitmask that is the bitwise OR of one Bitmask with another.
  ///
  /// Throws [ArgumentError] if the Bitmasks are not the same size.
  Bitmask operator |(Bitmask other) {
    if (length != other.length) {
      throw ArgumentError('Bitmask.operator |: Attempting to do a bitwise'
          ' OR of two Bitmasks that are not the same size.');
    }
    Bitmask newMask = Bitmask.fromBitmask(this);
    for (var bit = 0; bit < _mask.length; bit++) {
      newMask[bit] |= other[bit];
    }
    return newMask;
  }

  /// Create a Bitmask that is the bitwise XOR of one Bitmask with another.
  ///
  /// Throws [ArgumentError] if the Bitmasks are not the same size.
  Bitmask operator ^(Bitmask other) {
    if (length != other.length) {
      throw ArgumentError('Bitmask.operator ^: Attempting to do a bitwise'
          ' XOR of two Bitmasks that are not the same size.');
    }
    Bitmask newMask = Bitmask.fromBitmask(this);
    for (var bit = 0; bit < length; bit++) {
      newMask[bit] ^= other[bit];
    }
    return newMask;
  }

  /// Shift the bits in this Bitmask left by [shift] positions.
  ///
  /// Bits shifted beyond the mask size (bit >= length) are discarded.
  /// New bits at the right are set to 0.
  ///
  /// Throws [ArgumentError] if [shift] is negative.
  Bitmask operator <<(int shift) {
    if (shift < 0) {
      throw ArgumentError('Bitmask.operator <<: Shift amount must be '
          'non-negative.');
    }
    var newMask = Bitmask(length);
    for (var bit = 0; bit < length - shift; bit++) {
      newMask[bit + shift] = _mask[bit];
    }
    return newMask;
  }

  /// Shift the bits in this Bitmask right by [shift] positions.
  ///
  /// Bits shifted beyond the mask size (bit < 0) are discarded.
  /// New bits at the left are set to 0.
  ///
  /// Throws [ArgumentError] if [shift] is negative.
  Bitmask operator >>(int shift) {
    if (shift < 0) {
      throw ArgumentError('Bitmask.operator >>: Shift amount must be '
          'non-negative.');
    }
    var newMask = Bitmask(length);
    for (var bit = 0; bit < length - shift; bit++) {
      newMask[bit] = _mask[bit + shift];
    }
    return newMask;
  }

  /// Returns a list of the indices of all set bits.
  ///
  /// ```dart
  /// var mask = Bitmask.fromInt(13, 6); // bits 0, 2, 3 are set
  /// print(mask.toList()); // [0, 2, 3]
  /// ```
  List<int> toList() {
    var result = <int>[];
    for (var bit = 0; bit < _mask.length; bit++) {
      if (_mask[bit]) {
        result.add(bit);
      }
    }
    return result;
  }

  /// Returns the number of bits that are set (have value 1).
  ///
  /// ```dart
  /// var mask = Bitmask.fromInt(13, 6); // bits 0, 2, 3 are set
  /// print(mask.countSetBits()); // 3
  /// ```
  int countSetBits() {
    var count = 0;
    for (var bit = 0; bit < _mask.length; bit++) {
      if (_mask[bit]) {
        count++;
      }
    }
    return count;
  }

  /// Returns a human-readable string representation of the bitmask.
  ///
  /// The output shows the bits from most significant to least significant
  /// (left to right), matching the standard binary representation.
  ///
  /// ```dart
  /// var mask = Bitmask.fromInt(21, 6);
  /// print(mask.toString()); // 010101
  /// ```
  @override
  String toString() {
    var sb = StringBuffer();
    for (var bit = _mask.length - 1; bit >= 0; bit--) {
      sb.write(_mask[bit] ? '1' : '0');
    }
    return sb.toString();
  }

  /// Hash code of this object.
  @override
  int get hashCode => flags.hashCode;

  /// Equality operator.
  ///
  /// For two Bitmasks to be equal, they must be the same size and have
  /// all of the same bits set and unset.
  @override
  bool operator ==(Object other) {
    return other is Bitmask && length == other.length && flags == other.flags;
  }

  /// The number of bits in the mask.
  int get length => _mask.length;

  late List<bool> _mask;
}
