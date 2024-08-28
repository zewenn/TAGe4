const std = @import("std");

pub fn assert(statement: bool, comptime msg: []const u8) void {
    if (!statement) {
        @panic(msg);
    }
}

pub fn panic(msg: anytype) noreturn {
    std.debug.print("{any}", .{msg});
    unreachable;
}

pub const math = @import("math.zig");
pub const arrays = @import("arrays.zig");