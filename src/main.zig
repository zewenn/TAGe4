const std = @import("std");
const print = std.debug.print;
const String = @import("./deps/zig-string.zig").String;
const keys = @import("./deps/keys.zig");

const menus = @import("./menus.zig");
const entities = @import("./entities.zig");

const c = @cImport({
    @cInclude("stdlib.h");
    @cInclude("stdio.h");
    @cInclude("conio.h");
});

const menu_objs = @import("./menu_objs.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();

    var player = try entities.Entity.init(&allocator, "player");
    defer player.deinit();

    try menu_objs.main_menu.init(&allocator);
    defer menu_objs.main_menu.deinit();

    try menu_objs.town_of_swinford_menu.init(&allocator);
    defer menu_objs.town_of_swinford_menu.deinit();

    const main_menu = menu_objs.main_menu.self();
    menus.loadNextMenu(main_menu);

    // const town_of_swinford_menu = menu_objs.town_of_swinford_menu.self();

    var lastchar: u8 = 1;

    while (menus.running) {
        print("\x1b[2J\x1b[H", .{});
        print("[DEBUG] Last char: {?}\n\n", .{lastchar});
        try menus.current_menu.render();


        print("\n\nw - Up | s - Down | ENTER - Interact | q - Main Menu\n\n", .{});

        const char: u8 = @intCast(c.getch());

        lastchar = char;

        switch (char) {
            // ESC
            keys.ESCAPE => {
                break;
            },
            keys.w => {
                menus.current_menu.setChoiceIndex(-1);
            },
            keys.s => {
                menus.current_menu.setChoiceIndex(1);
            },
            keys.ENTER => {
                menus.current_menu.interact();
            },
            keys.q => {
                menus.loadNextMenu(main_menu);
            },
            else => {},
        }
    }

    print("\x1b[2J\x1b[H", .{});
}
