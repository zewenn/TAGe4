const std = @import("std");
const Item = @import("./entities.zig").Item;

pub var items = struct {
    var test_sword: Item = undefined;
};

pub fn setupItems(allocator: *std.mem.Allocator) !void {
    items.test_sword = Item.init(
        allocator,
        "test sword",
        "dev sword for testing",
        0,
    );
}
