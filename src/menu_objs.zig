const std = @import("std");
const print = std.debug.print;
const String = @import("./deps/zig-string.zig").String;

const Menu = @import("./menus.zig").Menu;
const Action = @import("./menus.zig").Action;
const menus = @import("./menus.zig");

// namespace
pub const main_menu = struct {
    var menu: Menu = undefined;
    var local_allocator: *std.mem.Allocator = undefined;
    var actions: []Action = undefined;

    const action_funcs = struct {
        pub fn start(_: *Menu) void {
            return;
        }
        pub fn quit(_: *Menu) void {
            menus.running = false;
        }
    };
    const actions_objs = struct {
        pub var start: Action = undefined;
        pub var quit: Action = undefined;
    };

    pub fn init(allocator: *std.mem.Allocator) !void {
        local_allocator = allocator;

        actions_objs.start = try Action.init(
            allocator,
            "Start Game",
            action_funcs.start,
        );
        actions_objs.quit = try Action.init(
            allocator,
            "Exit",
            action_funcs.quit,
        );

        var new_actions = [_]Action{
            actions_objs.start,
            actions_objs.quit,
        };
        actions = &new_actions;

        menu = try Menu.init(
            allocator,
            "menu1",
            "T.A.G. 4",
            "Text Advenutre Game v4",
            actions,
        );
    }

    pub fn deinit() void {
        menu.deinit();
        actions_objs.start.deinit();
        actions_objs.quit.deinit();
    }

    pub fn self() *Menu {
        return &menu;
    }
};
