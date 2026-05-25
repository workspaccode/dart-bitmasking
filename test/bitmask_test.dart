import 'package:test/test.dart';
import 'package:bitmasking/bitmasking.dart';

enum _Maskbits { zero, one, two, three, four }

void main() {
  group('Bitmask constructor', () {
    test('creates bitmask with specified size', () {
      final mask = Bitmask(6);
      expect(mask.length, 6);
      expect(mask.flags, 0);
    });

    test('throws on size < 1', () {
      expect(() => Bitmask(0), throwsArgumentError);
      expect(() => Bitmask(-1), throwsArgumentError);
    });

    test('throws on size > 63', () {
      expect(() => Bitmask(64), throwsArgumentError);
    });
  });

  group('Bitmask.fromInt', () {
    test('creates bitmask from integer value', () {
      final mask = Bitmask.fromInt(21, 6);
      expect(mask.flags, 21);
      expect(mask[0], true);
      expect(mask[1], false);
      expect(mask[2], true);
      expect(mask[3], false);
      expect(mask[4], true);
      expect(mask[5], false);
    });

    test('creates zero bitmask from zero', () {
      final mask = Bitmask.fromInt(0, 10);
      expect(mask.flags, 0);
      for (var i = 0; i < 10; i++) {
        expect(mask[i], false);
      }
    });
  });

  group('Bitmask.fromList', () {
    test('creates bitmask with specified bits set', () {
      final mask = Bitmask.fromList([1, 3, 5], 8);
      expect(mask[1], true);
      expect(mask[3], true);
      expect(mask[5], true);
      expect(mask[0], false);
      expect(mask[2], false);
      expect(mask[4], false);
    });

    test('throws for bit out of range', () {
      expect(() => Bitmask.fromList([-1], 6), throwsArgumentError);
      expect(() => Bitmask.fromList([6], 6), throwsArgumentError);
    });

    test('works with enum indices', () {
      final mask = Bitmask.fromList(
        [_Maskbits.one.index, _Maskbits.two.index],
        _Maskbits.values.length,
      );
      expect(mask[1], true);
      expect(mask[2], true);
      expect(mask[0], false);
    });
  });

  group('Bitmask.fromBitmask', () {
    test('creates an independent copy', () {
      final original = Bitmask.fromInt(21, 6);
      final copy = Bitmask.fromBitmask(original);
      expect(copy.flags, original.flags);
      copy[0] = false;
      expect(original[0], true);
      expect(identical(copy, original), false);
    });
  });

  group('set / unset / index operator', () {
    test('set bit to true', () {
      final mask = Bitmask(8);
      mask.set(3);
      expect(mask[3], true);
    });

    test('unset bit to false', () {
      final mask = Bitmask.fromInt(21, 8);
      mask.unset(0);
      expect(mask[0], false);
      expect(mask.flags, 20);
    });

    test('index operator set', () {
      final mask = Bitmask(8);
      mask[5] = true;
      expect(mask[5], true);
    });

    test('index operator get', () {
      final mask = Bitmask.fromInt(21, 8);
      expect(mask[0], true);
      expect(mask[2], true);
    });

    test('set throws for invalid bit', () {
      final mask = Bitmask(8);
      expect(() => mask.set(-1), throwsArgumentError);
      expect(() => mask.set(8), throwsArgumentError);
    });

    test('unset throws for invalid bit', () {
      final mask = Bitmask(8);
      expect(() => mask.unset(-1), throwsArgumentError);
      expect(() => mask.unset(8), throwsArgumentError);
    });
  });

  group('isSet', () {
    test('returns correct boolean', () {
      final mask = Bitmask.fromInt(21, 8);
      expect(mask.isSet(0), true);
      expect(mask.isSet(1), false);
      expect(mask.isSet(2), true);
    });

    test('throws for invalid bit', () {
      final mask = Bitmask(8);
      expect(() => mask.isSet(-1), throwsArgumentError);
      expect(() => mask.isSet(8), throwsArgumentError);
    });
  });

  group('clear', () {
    test('resets all bits to false', () {
      final mask = Bitmask.fromInt(21, 6);
      mask.clear();
      expect(mask.flags, 0);
      for (var i = 0; i < 6; i++) {
        expect(mask[i], false);
      }
    });
  });

  group('flags', () {
    test('returns correct integer value', () {
      final mask = Bitmask(6);
      mask[0] = true;
      mask[2] = true;
      mask[3] = true;
      expect(mask.flags, 13);
    });
  });

  group('bitwise operators', () {
    test('AND', () {
      final a = Bitmask.fromInt(21, 6);
      final b = Bitmask.fromInt(13, 6);
      final result = a & b;
      expect(result.flags, 21 & 13);
    });

    test('OR', () {
      final a = Bitmask.fromInt(21, 6);
      final b = Bitmask.fromInt(13, 6);
      final result = a | b;
      expect(result.flags, 21 | 13);
    });

    test('XOR', () {
      final a = Bitmask.fromInt(21, 6);
      final b = Bitmask.fromInt(13, 6);
      final result = a ^ b;
      expect(result.flags, 21 ^ 13);
    });

    test('NOT', () {
      final mask = Bitmask.fromInt(21, 6);
      final result = ~mask;
      expect(result.flags, (~21) & 0x3F);
    });

    test('AND throws on different sizes', () {
      final a = Bitmask(6);
      final b = Bitmask(8);
      expect(() => a & b, throwsArgumentError);
    });

    test('OR throws on different sizes', () {
      final a = Bitmask(6);
      final b = Bitmask(8);
      expect(() => a | b, throwsArgumentError);
    });

    test('XOR throws on different sizes', () {
      final a = Bitmask(6);
      final b = Bitmask(8);
      expect(() => a ^ b, throwsArgumentError);
    });
  });

  group('shift operators', () {
    test('left shift', () {
      final mask = Bitmask.fromInt(5, 8); // bits 0 and 2
      final result = mask << 2;
      expect(result.flags, 20); // bits 2 and 4
      expect(result.length, 8);
    });

    test('right shift', () {
      final mask = Bitmask.fromInt(20, 8); // bits 2 and 4
      final result = mask >> 2;
      expect(result.flags, 5); // bits 0 and 2
      expect(result.length, 8);
    });

    test('left shift discards bits beyond length', () {
      final mask = Bitmask.fromInt(0xC0, 8); // bits 6 and 7
      final result = mask << 4;
      expect(result.flags, 0);
    });

    test('right shift discards bits shifted out', () {
      final mask = Bitmask.fromInt(3, 8); // bits 0 and 1
      final result = mask >> 2;
      expect(result.flags, 0);
    });

    test('shift by zero returns same bits', () {
      final mask = Bitmask.fromInt(21, 8);
      expect((mask << 0).flags, 21);
      expect((mask >> 0).flags, 21);
    });

    test('shift by negative throws', () {
      final mask = Bitmask(8);
      expect(() => mask << -1, throwsArgumentError);
      expect(() => mask >> -1, throwsArgumentError);
    });
  });

  group('toList', () {
    test('returns indices of set bits', () {
      final mask = Bitmask.fromInt(13, 6);
      expect(mask.toList(), [0, 2, 3]);
    });

    test('returns empty list for all zeros', () {
      final mask = Bitmask(10);
      expect(mask.toList(), []);
    });
  });

  group('countSetBits', () {
    test('counts set bits correctly', () {
      final mask = Bitmask.fromInt(13, 6); // bits 0, 2, 3
      expect(mask.countSetBits(), 3);
    });

    test('returns zero for empty mask', () {
      final mask = Bitmask(10);
      expect(mask.countSetBits(), 0);
    });

    test('returns length for all set', () {
      final mask = Bitmask(8);
      for (var i = 0; i < 8; i++) {
        mask[i] = true;
      }
      expect(mask.countSetBits(), 8);
    });
  });

  group('toString', () {
    test('prints bits MSB to LSB', () {
      final mask = Bitmask.fromInt(21, 6); // binary: 010101
      expect(mask.toString(), '010101');
    });

    test('prints leading zeros', () {
      final mask = Bitmask(8);
      expect(mask.toString(), '00000000');
    });
  });

  group('equality and hashCode', () {
    test('equal bitmasks are equal', () {
      final a = Bitmask.fromInt(21, 6);
      final b = Bitmask.fromInt(21, 6);
      expect(a == b, true);
      expect(a.hashCode, b.hashCode);
    });

    test('different sizes are not equal', () {
      final a = Bitmask.fromInt(21, 6);
      final b = Bitmask.fromInt(21, 8);
      expect(a == b, false);
    });

    test('different values are not equal', () {
      final a = Bitmask.fromInt(21, 6);
      final b = Bitmask.fromInt(13, 6);
      expect(a == b, false);
    });
  });

  group('example program output', () {
    test('matches expected example output', () {
      var mask1 = Bitmask(6);
      mask1[1] = true;
      mask1.set(3);
      mask1[5] = true;
      mask1.unset(5);

      var mask2 = Bitmask.fromInt(13, 6);
      var mask3 = Bitmask.fromList(
          [_Maskbits.zero.index, _Maskbits.three.index, _Maskbits.four.index], 6);

      expect(mask1.flags.toRadixString(2), '1010');
      expect(mask2.flags.toRadixString(2), '1101');
      expect(mask3.flags.toRadixString(2), '11001');

      expect((mask1 & mask2).flags.toRadixString(2), '1000');
      expect((mask1 & mask3).flags.toRadixString(2), '1000');
      expect((mask2 & mask3).flags.toRadixString(2), '1001');

      expect((mask1 | mask2).flags.toRadixString(2), '1111');
      expect((mask1 | mask3).flags.toRadixString(2), '11011');
      expect((mask2 | mask3).flags.toRadixString(2), '11101');

      expect((~mask1).flags.toRadixString(2), '110101');
      expect((~mask2).flags.toRadixString(2), '110010');
      expect((~mask3).flags.toRadixString(2), '100110');

      var mask4 = Bitmask.fromBitmask(mask3);
      expect(mask4.flags.toRadixString(2), '11001');
      expect(mask4 == mask3, true);
      expect(identical(mask4, mask3), false);

      mask3.clear();
      expect(mask3.flags.toRadixString(2), '0');

      expect(mask4.isSet(4), true);
      expect(mask4[2], false);
    });
  });
}
