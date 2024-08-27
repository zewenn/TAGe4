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
