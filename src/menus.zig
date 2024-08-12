const std = @import("std");
const print = std.debug.print;
const String = @import("./deps/zig-string.zig").String;

pub const Action = struct {
    const Self = @This();

    name: String,
    func: *const fn (*Menu) void,

    pub fn init(allocator: *std.mem.Allocator, name: []const u8, func: *const fn (*Menu) void) !Action {
        var new_name: String = undefined;
        new_name = try String.init_with_contents(allocator.*, name);

        return .{
            .name = new_name,
            .func = func,
        };
    }

    pub fn deinit(self: *Action) void {
        _ = self.name.deinit();
    }
};

pub var current_menu: *Menu = undefined;
pub var running = true;

pub fn loadNextMenu(menu: *Menu) void {
    current_menu = menu;
}

pub const Menu = struct {
    const Self = @This();
    id: String,
    title: String,
    description: String,
    allocator: *std.mem.Allocator,
    choice_index: i8 = 0,
    options: std.ArrayList(Action),

    pub fn init(allocator: *std.mem.Allocator, id: []const u8, title: []const u8, description: []const u8, options: []Action) !Menu {
        const new_id = try String.init_with_contents(allocator.*, id);
        const new_title = try String.init_with_contents(allocator.*, title);
        const new_description = try String.init_with_contents(allocator.*, description);

        var new_options = std.ArrayList(Action).init(allocator.*);
        for (options) |opt| {
            try new_options.append(opt);
        }

        return .{ .id = new_id, .title = new_title, .description = new_description, .options = new_options, .allocator = allocator };
    }

    /// This **WILL** `deinit`alise actions contained in `self.options` too
    pub fn deinit(self: *Menu) void {
        self.id.deinit();
        self.title.deinit();
        self.description.deinit();
        for (self.options.items) |item| {
            var x = @constCast(&item.name);
            x.deinit();
        }
        self.options.deinit();
    }

    pub fn render(self: *Menu) !void {
        const title_str = try self.title.toOwned();
        defer _ = self.allocator.free(title_str.?);

        const desc_str = try self.description.toOwned();
        defer _ = self.allocator.free(desc_str.?);

        print("{s}\n{s}\n\n", .{ title_str.?, desc_str.? });
        for (0.., self.options.items) |index, opt| {
            const str = try opt.name.toOwned();
            defer _ = self.allocator.free(str.?);

            var selected_char: u8 = ' ';
            if (index == self.choice_index) {
                selected_char = 'x';
            }

            print("[{c}] {s}\n", .{ selected_char, str.? });
        }
    }

    pub fn setDescription(self: *Menu, to: []const u8) !void {
        self.description.clear();
        try self.description.concat(to);
    }

    pub fn setChoiceIndex(self: *Menu, by: i8) void {
        if (self.choice_index == 0 and by < 0) return;
        if (self.choice_index == 127 and by > 0) return;
        if (self.choice_index == self.options.items.len - 1 and by > 0) return;

        self.choice_index += by;
    }

    pub fn interact(self: *Menu) void {
        var option = self.options.items[@intCast(self.choice_index)];
        option.func(self);
    }
};
