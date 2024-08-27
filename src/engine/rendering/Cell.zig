const Colour = @import("./Colour.zig");

const Self = @This();

value: u8 = ' ',
foreground: Colour = Colour{ .red = 255, .green = 255, .blue = 255 },
background: Colour = Colour{ .red = 0, .green = 0, .blue = 0 },

pub fn eql(cell1: *Self, cell2: Self) bool {
    if (cell1.value != cell2.value) return false;
    if (!cell1.foreground.eql(cell2.foreground)) return false;
    if (!cell1.background.eql(cell2.background)) return false;

    return true;
}
