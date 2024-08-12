const std = @import("std");
const print = std.debug.print;

const input = @import("./deps/zig-input.zig");
const String = @import("./deps/zig-string.zig").String;

const events = @import("./sys/events.zig");

pub fn testfn() void {
    print("x", .{});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();

    events.init(&allocator);
    defer events.deinit();

    try events.on("update", testfn);

    var last_char: u8 = 0;

    while (true) {
        print("\x1b[2J\x1b[H", .{});
        // print("\x1b[H\n", .{});
        print("[DEBUG] Last char: {?}\n\n", .{last_char});

        const input_char = input.getKeyDown();
        last_char = input_char;

        switch (input_char) {
            input.keys.ESCAPE => break,
            else => {},
        }
        try events.call("update");
    }
}
