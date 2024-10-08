const std = @import("std");
const print = std.debug.print;

pub inline fn Matrix2(comptime T: type, comptime x: comptime_int, comptime y: comptime_int) type {
    return [y][x]T;
}

pub inline fn HeapMatrix(T: type) type {
    return [][]T;
}

pub fn Vec2(comptime T: type) type {
    return struct {
        const Self = @This();
        x: T,
        y: T,

        pub fn init(x: T, y: T) Vec2(T) {
            return .{
                .x = x,
                .y = y,
            };
        }

        pub fn round(K: type, self: *Self) Vec2(K) {
            return Vec2(K).init(@intFromFloat(@round(self.x)), @intFromFloat(@round(self.y)));
        }

        pub fn isInBounds(self: *Self, x_start: T, x_end: T, y_start: T, y_end: T) bool {
            if ((self.x < x_start or self.x > x_end) or (self.y < y_start or self.y > y_end)) {
                return false;
            }
            return true;
        }

        pub fn assureUnsigned(self: *Self) void {
            if (self.x < 0) self.x = 0;
            if (self.y < 0) self.y = 0;
        }

        pub fn add(self: *Self, other: Self) Self {
            return .{
                .x = self.x + other.x,
                .y = self.y + other.y,
            };
        }

        pub fn sub(self: *Self, other: Self) Self {
            return .{ .x = self.x - other.x, .y = self.y - other.y };
        }

        pub fn mult(self: *Self, by: T) Self {
            return .{
                .x = self.x * by,
                .y = self.y * by,
            };
        }

        pub fn div(self: *Self, by: T) Self {
            return .{
                .x = @intCast(self.x / by),
                .y = @intCast(self.y / by),
            };
        }

        pub fn dot_prod(self: *Self, other: Self) T {
            const displacement = self.sub(other);
            const self_a = self.sub(displacement);
            const other_a = other.sub(displacement);

            return self_a.x * other_a.x + self_a.y * other_a.y;
        }

        pub fn magnitude(self: *Self) i32 {
            return @intCast(std.math.sqrt((self.x * self.x) + (self.x * self.x)));
        }

        pub fn direction(self: *Self) i32 {
            return @floatCast(std.math.radiansToDegrees(std.math.atan2(self.y, self.x)));
        }

        pub fn normalise(self: *Self) Self {
            const mag = self.magnitude();

            if (mag == 0) {
                return Self.init(0, 0);
            }

            return self.div(mag);
        }
    };
}
