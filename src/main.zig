const std = @import("std");
const print = std.debug.print;
const String = @import("./deps/zig-string.zig").String;
const input = @import("./deps/zig-input.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // var allocator = gpa.allocator();

    var last_char: u8 = 0;

    while (true) {
        print("\x1b[H\n", .{});
        print("[DEBUG] Last char: {?}\n\n", .{last_char});

        const input_char = input.getKeyDown();
        last_char = input_char;

        switch (input_char) {
            input.keys.ESCAPE => break,
            else => {},
        }
    }
}
