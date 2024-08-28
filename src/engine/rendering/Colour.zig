const z = @import("../z/z.zig");

const Self = @This();

red: u8,
green: u8,
blue: u8,

pub fn eql(col1: *Self, col2: Self) bool {
    if (col1.red != col2.red) return false;
    if (col1.green != col2.green) return false;
    if (col1.blue != col2.blue) return false;

    return true;
}

pub fn blend(self: *Self, other: Self) Self {
    return .{
        .red = z.math.f128_to(
            u8,
            z.math.avg(
                self.red,
                other.red,
            ).?,
        ).?,
        .green = z.math.f128_to(
            u8,
            z.math.avg(
                self.green,
                other.green,
            ).?,
        ).?,
        .blue = z.math.f128_to(
            u8,
            z.math.avg(
                self.blue,
                other.blue,
            ).?,
        ).?,
    };
}
