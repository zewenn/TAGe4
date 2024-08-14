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

        pub fn round(K: type, self: *Self) Vec2(K) {
            return Vec2(K).init(@intFromFloat(@round(self.x)), @intFromFloat(@round(self.y)));
        }

        pub fn isInBounds(self: *Self, x_start: T, x_end: T, y_start: T, y_end: T) bool {
            if ((self.x < x_start or self.x > x_end) or (self.y < y_start or self.y > y_end)) {
                return false;
            }
            return true;
        }

        pub fn add(self: *Self, other: Self) Self {
            return .{
                .x = self.x + other.x,
                .y = self.y + other.y,
            };
        }

        pub fn sub(self: *Self, other: Self) Self {
            return .{
                .x = self.x - other.x,
                .y = self.y - other.y
            };
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

        pub fn assureUnsigned(self: *Self) void {
            if (self.x < 0) self.x = 0;
            if (self.y < 0) self.y = 0;
        }
    };
}
