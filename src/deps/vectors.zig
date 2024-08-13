const std = @import("std");
const print = std.debug.print;

// pub const IntVector2D = struct {
//     const Self = @This();
//     x: i32,
//     y: i32,
// };

// pub const Vector2D = struct {
//     const Self = @This();
//     x: f32,
//     y: f32,

//     pub fn init(x: f32, y: f32) Vector2D {
//         return .{
//             .x = x,
//             .y = y,
//         };
//     }

//     pub fn round(self: *Self) IntVector2D {
//         return IntVector2D{ .x = @intFromFloat(@round(self.x)), .y = @intFromFloat(@round(self.y)) };
//     }

//     pub fn isInBounds(self: *Self, x_start: f32, x_end: f32, y_start: f32, y_end: f32) bool {}
// };

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

        pub fn round(self: *Self) Vec2(i32) {
            return Vec2(i32).init(@intFromFloat(@round(self.x)), @intFromFloat(@round(self.y)));
        }

        pub fn isInBounds(self: *Self, x_start: T, x_end: T, y_start: T, y_end: T) bool {
            if ((self.x < x_start or self.x > x_end) or (self.y < y_start or self.y > y_end)) {
                return false;
            }
            return true;
        }
    };
}
