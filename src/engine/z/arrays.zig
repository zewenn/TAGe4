const std = @import("std");

pub fn Array(comptime T: type, comptime len: usize, comptime val: [len]T) type {
    return struct {
        const Self = @This();

        pub inline fn this() [len]T {
            return val;
        }

        pub fn index(elem: T) ?usize {
            for (val, 0..len) |item, i| {
                if (elem == item) return i;
                if (@as(*anyopaque, @ptrCast(@constCast(&elem))) == @as(*anyopaque, @ptrCast(@constCast(&item)))) {
                    return i;
                }
            }
            return null;
        }

        pub fn at(i: usize) T {
            return val[i];
        }
    };
}
