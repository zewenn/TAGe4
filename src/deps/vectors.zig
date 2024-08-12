const std = @import("std");
const print = std.debug.print;

pub const Vector2D = struct {
    x: i32,
    y: i32,

    pub fn init(x: i32, y: i32) Vector2D {
        return .{
            .x = x,
            .y = y,
        };
    }
};

pub fn Vec2(x: i32, y: i32) Vector2D {
    return Vector2D{
        .x = x,
        .y = y
    };
}