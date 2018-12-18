// Minimal fixed-point storage type.

pub fn Q(comptime M: comptime_int, comptime N: comptime_int) type {
    return struct {
        const Self = @This();
        const one = 1 << N;
        const Type = @IntType(false, M + N + 1);

        raw: Type,

        fn fromFloat(d: var) Self {
            return Self{ .raw = @floatToInt(Type, (if (d < 0) -d else d) * one) | ((if (d < 0) Type(1) else 0) << (M + N)) };
        }

        fn toFloat(f: Self, comptime FloatType: type) FloatType {
            return @intToFloat(FloatType, f.raw) * (if ((f.raw & (1 << (M + N))) != 0) FloatType(-1) else 1) / one;
        }

        fn fromParts(s: bool, m: @IntType(false, M), n: @IntType(false, N)) Self {
            return Self{ .raw = (Type(@boolToInt(s)) << (M + N)) | (Type(m) << N) | n };
        }
    };
}

pub fn UQ(comptime M: comptime_int, comptime N: comptime_int) type {
    return struct {
        const Self = @This();
        const one = 1 << N;
        const Type = @IntType(false, M + N);

        storage: Type,

        fn fromFloat(d: var) Self {
            if (d < 0) return Self{ .raw = 0 };
            return Self{ .raw = @floatToInt(Type, d * one) };
        }

        fn toFloat(f: Self, comptime FloatType: type) FloatType {
            return @intToFloat(FloatType, f.raw) / one;
        }

        fn fromParts(m: @IntType(false, M), n: @IntType(false, N)) Self {
            return Self{ .raw = (Type(m) << M) | n };
        }
    };
}

const std = @import("std");

test "fixpoint.Q" {
    const Q7p6 = Q(7, 6);

    const a = Q7p6.fromFloat(f64(1.016));
    const b = Q7p6.fromParts(false, 1, 1);

    std.debug.assert(a.toFloat(f32) == b.toFloat(f32));
}

test "fixpoint.UQ" {
    const UQ7p6 = Q(7, 6);

    const a = UQ7p6.fromFloat(f64(1.016));
    const b = UQ7p6.fromParts(false, 1, 1);

    std.debug.assert(a.toFloat(f32) == b.toFloat(f32));
}
