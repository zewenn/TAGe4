const std = @import("std");
const print = std.debug.print;
const String = @import("./deps/zig-string.zig").String;

const Menu = @import("./menus.zig").Menu;
const Action = @import("./menus.zig").Action;
const menus = @import("./menus.zig");

const Entity = @import("./entities.zig").Entity;

// namespace
pub const main_menu = struct {
    var menu: Menu = undefined;
    var local_allocator: *std.mem.Allocator = undefined;
    var actions: []Action = undefined;

    const action_funcs = struct {
        pub fn start(_: *Menu) void {
            menus.loadNextMenu(town_of_swinford_menu.self());
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
            "main_menu",
            "T.A.G. 4",
            "Text Advenutre Game v4",
            actions,
        );
    }

    pub fn deinit() void {
        // actions_objs.start.deinit();
        // actions_objs.quit.deinit();
        // for (menu.options.items) |act| {
        //     act.deinit();
        // }
        menu.deinit();
    }

    pub fn self() *Menu {
        return &menu;
    }
};

// namespace
pub const town_of_swinford_menu = struct {
    var menu: Menu = undefined;
    var local_allocator: *std.mem.Allocator = undefined;
    var actions: []Action = undefined;

    const action_funcs = struct {
        pub fn blacksmithMenu(_: *Menu) void {
            return;
        }
        pub fn mayorMenu(_: *Menu) void {
            return;
        }
    };
    const actions_objs = struct {
        pub var blacksmith: Action = undefined;
        pub var mayor: Action = undefined;
    };

    pub fn init(allocator: *std.mem.Allocator) !void {
        local_allocator = allocator;

        actions_objs.blacksmith = try Action.init(
            allocator,
            "Talk to the blacksmith",
            action_funcs.blacksmithMenu,
        );
        actions_objs.mayor = try Action.init(
            allocator,
            "Talk to the mayor",
            action_funcs.mayorMenu,
        );

        var new_actions = [_]Action{
            actions_objs.blacksmith,
            actions_objs.mayor,
        };
        actions = &new_actions;

        menu = try Menu.init(
            allocator,
            "town_of_swinford",
            "Town of Swinford",
            "You are in the town of Swinford, Middlelands. It's a small - but cozy - town, full of life.",
            actions,
        );
    }

    pub fn deinit() void {
        menu.deinit();
        // actions_objs.blacksmith.deinit();
        // actions_objs.mayor.deinit();
    }

    pub fn self() *Menu {
        return &menu;
    }
};

pub const combat_menu = struct {
    var menu: Menu = undefined;
    var local_allocator: *std.mem.Allocator = undefined;
    var actions: []Action = undefined;
    var enemy: ?*Entity = null;
    var player: *Entity = undefined;

    pub fn setEnemy(entity: *Entity) void {
        enemy = entity;
    }

    pub fn dealDamage(entity: *Entity, amount: f32) void {
        entity.health -= amount;
        if (entity.health < 0) entity.health = 0;
        if (entity.health > entity.max_health) entity.health = entity.max_health;
    }

    const action_funcs = struct {
        pub fn blacksmithMenu(_: *Menu) void {
            return;
        }
        pub fn mayorMenu(_: *Menu) void {
            return;
        }
    };
    const actions_objs = struct {
        pub var blacksmith: Action = undefined;
        pub var mayor: Action = undefined;
    };

    pub fn init(allocator: *std.mem.Allocator, player_entity: *Entity) !void {
        local_allocator = allocator;

        actions_objs.blacksmith = try Action.init(
            allocator,
            "Talk to the blacksmith",
            action_funcs.blacksmithMenu,
        );
        actions_objs.mayor = try Action.init(
            allocator,
            "Talk to the mayor",
            action_funcs.mayorMenu,
        );

        var new_actions = [_]Action{
            actions_objs.blacksmith,
            actions_objs.mayor,
        };
        actions = &new_actions;

        player = player_entity;

        menu = try Menu.init(
            allocator,
            "combat_menu",
            "Combat",
            "",
            actions,
        );
    }

    pub fn deinit() void {
        menu.deinit();
        // actions_objs.blacksmith.deinit();
        // actions_objs.mayor.deinit();
    }

    pub fn self() *Menu {
        return &menu;
    }
};
