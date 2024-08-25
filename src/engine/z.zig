const std = @import("std");

pub fn assert(statement: bool, comptime msg: []const u8) void {
    if (!statement) {
        @panic(msg);
    }
}

pub const math = struct {
    pub const CastError = error{CastError};

    pub fn to_f128(x: anytype) f128 {
        if (@typeInfo(@TypeOf(x)) == .Int) {
            return @as(f128, @floatFromInt(x));
        }
        return @as(f128, @floatCast(x));
    }

    pub fn f128_to(comptime T: type, x: f128) ?T {
        if (@typeInfo(T) == .Int) {
            return std.math.cast(T, @as(i128, @intFromFloat(x)));
        }
        return @as(T, @floatCast(x));
    }
    
    pub fn min(value1: anytype, value2: anytype) f128 {
        const v1 = to_f128(value1);
        const v2 = to_f128(value2);

        if (v1 >= v2) {
            return v2;
        }
        return v1;
    }

    pub fn max(value1: anytype, value2: anytype) f128 {
        const v1 = to_f128(value1);
        const v2 = to_f128(value2);

        if (v1 <= v2) {
            return v2;
        }
        return v1;
    }
};