const std = @import("std");
const print = std.debug.print;
const String = @import("./deps/zig-string.zig").String;

pub const Action = struct {
    const Self = @This();

    name: String,
    func: *const fn () void,

    pub fn init(allocator: *std.mem.Allocator, name: []const u8, func: *const fn () void) !Action {
        const new_name = try String.init_with_contents(allocator.*, name);

        return .{
            .name = new_name,
            .func = func,
        };
    }

    pub fn deinit(self: *Action) void {
        _ = self.name.deinit();
    }
};

pub const Menu = struct {
    const Self = @This();
    id: String,
    title: String,
    description: String,
    allocator: *std.mem.Allocator,
    choice_index: u8 = 0,
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

    pub fn deinit(self: *Menu) void {
        self.id.deinit();
        self.title.deinit();
        self.description.deinit();
        self.options.deinit();
        // allocator.free(self);
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
};
