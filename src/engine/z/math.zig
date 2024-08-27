const std = @import("std");

pub const CastError = error{CastError};

pub fn to_f128(x: anytype) ?f128 {
    return switch (@typeInfo(@TypeOf(x))) {
        .Int, .ComptimeInt => @as(f128, @floatFromInt(@as(i128, @intCast(x)))),
        .Float, .ComptimeFloat => @as(f128, @floatCast(x)),
        .Bool => @as(f128, @floatFromInt(@as(i128, @intFromBool(x)))),
        else => null,
    };
}

pub fn f128_to(comptime T: type, x: f128) ?T {
    return switch (@typeInfo(T)) {
        .Int, .ComptimeInt => std.math.cast(T, @as(i128, @intFromFloat(x))),
        .Float, .ComptimeFloat => @as(T, @floatCast(x)),
        .Bool => if (x > 0) true else false,
        else => null,
    };
}

pub fn div(numerator: anytype, denominator: anytype) ?f128 {
    const cnv_n = to_f128(numerator);
    const cnv_d = to_f128(denominator);

    if (cnv_d == null or cnv_n == null) return null;

    const n = cnv_n.?;
    const d = cnv_d.?;

    if (d == 0) return null;

    return std.math.divTrunc(f128, n, d) catch null;
}

pub fn min(value1: anytype, value2: anytype) ?f128 {
    const _v1 = to_f128(value1);
    const _v2 = to_f128(value2);

    if (_v1 == null or _v2 == null) return null;

    const v1 = _v1.?;
    const v2 = _v2.?;

    if (v1 >= v2) {
        return v2;
    }
    return v1;
}

pub fn max(value1: anytype, value2: anytype) ?f128 {
    const _v1 = to_f128(value1);
    const _v2 = to_f128(value2);

    if (_v1 == null or _v2 == null) return null;

    const v1 = _v1.?;
    const v2 = _v2.?;

    if (v1 <= v2) {
        return v2;
    }
    return v1;
}
