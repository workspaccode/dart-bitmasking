# bitmasking

A Dart package providing a `Bitmask` class for efficient bit-level operations.

[![pub package](https://img.shields.io/pub/v/bitmasking.svg)](https://pub.dev/packages/bitmasking)
[![License](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE)

## Features

- Create bitmasks with 1 to 63 bits
- Set, unset, and check individual bits
- Bitwise AND, OR, XOR, NOT operators
- Left and right shift operators
- Convert to/from integers and lists
- Count set bits, list set bit indices
- Human-readable `toString()` output

## Usage

```dart
import 'package:bitmasking/bitmasking.dart';

void main() {
  // Create a 6-bit mask with bits 0, 2, 3 set (value 13)
  var mask = Bitmask.fromInt(13, 6);

  // Set and unset bits
  mask.set(5);
  mask.unset(3);
  mask[1] = true;

  // Read bits
  print(mask[2]); // true
  print(mask.isSet(4)); // false

  // Bitwise operations
  var other = Bitmask.fromInt(21, 6);
  var and = mask & other;
  var or = mask | other;
  var xor = mask ^ other;
  var not = ~mask;

  // Shift operations
  var shifted = mask << 2;
  var rightShifted = mask >> 1;

  // Utility
  print(mask.flags); // integer value
  print(mask.toList()); // [0, 1, 2, 5]
  print(mask.countSetBits()); // 4
  print(mask.toString()); // "100111"
}
```

## Constructors

| Constructor | Description |
|---|---|
| `Bitmask(n)` | Create a mask with `n` bits, all 0 |
| `Bitmask.fromInt(v, n)` | Create from integer value `v` with `n` bits |
| `Bitmask.fromList(bits, n)` | Create with specific bits set |
| `Bitmask.fromBitmask(other)` | Deep copy of another Bitmask |

## Additional information

See the [API documentation](https://pub.dev/documentation/bitmasking/latest/) for full details.
