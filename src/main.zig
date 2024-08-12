const std = @import("std");
const print = std.debug.print;
const String = @import("./deps/zig-string.zig").String;
const keys = @import("./deps/keys.zig");

const menus = @import("./menus.zig");
const entities = @import("./entities.zig");

const clang = @cImport({
    @cInclude("stdlib.h");
    @cInclude("stdio.h");
    @cInclude("conio.h");
});

const menu_objs = @import("./menu_setup.zig");

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

    update: while (menus.running) {
        print("\x1b[2J\x1b[H", .{});
        print("[DEBUG] Last char: {?}\n\n", .{lastchar});
        try menus.current_menu.render();

        if (!menus.current_menu.id.cmp("main_menu")) {
            const barlen: i32 = 20;

            const hp_precent: i32 = @intFromFloat(@round(player.health / player.max_health * 20));

            print("\nHealth: [", .{});
            for (0..barlen) |i| {
                if (i <= hp_precent) {
                    print("|", .{});
                    continue;
                }
                print(" ", .{});
            }
            print("]", .{});
        }

        print("\n\nw - Up | s - Down | ENTER - Interact | q - Main Menu\n\n", .{});

        const char: u8 = @intCast(clang.getch());

        lastchar = char;

        switch (char) {
            // ESC
            keys.ESCAPE => {
                break :update;
            },
            keys.H => {
                menus.current_menu.setChoiceIndex(-1);
            },
            keys.P => {
                menus.current_menu.setChoiceIndex(1);
            },
            keys.ENTER => {
                menus.current_menu.interact();
            },
            keys.q => {
                menus.loadNextMenu(main_menu);
            },
            keys.PLUS_SIGN => {
                player.health += 5;
            },
            keys.MINUS_SIGN => {
                player.health -= 5;
            },
            else => {},
        }
    }

    print("\x1b[2J\x1b[H", .{});
}
