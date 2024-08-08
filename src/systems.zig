const std = @import("std");
const String = @import("./deps/zig-string.zig").String;

pub const Task = struct {
    const Self = @This();

    name: String,
    func: *const fn () void,
    /// 0 - not started
    /// 1 - in progress
    /// 2 - ended
    status: u8,
    repeating: bool,

    pub fn init(allocator: std.mem.Allocator, name: []const u8, func: *const fn () void, repeating: bool) !Task {
        const new_name = try String.init_with_contents(allocator, name);

        return .{
            .name = new_name,
            .func = func,
            .status = 0,
            .repeating = repeating,
        };
    }

    pub fn deinit(self: *Self) void {
        self.name.deinit();
    }
};

pub const System = struct {
    var tasks: std.ArrayListAligned(Task, null) = undefined;
    var inner_allocator: std.mem.Allocator = undefined;

    pub fn init(allocator: std.mem.Allocator) !void {
        inner_allocator = allocator;
        tasks = std.ArrayList(Task).init(allocator);
    }

    pub fn deinit() void {
        tasks.deinit();
    }

    pub fn queue(tsk: Task) !void {
        try tasks.append(tsk);
    }

    pub fn execute() !void {
        // for (0.., tasks.items) |index, tsk| {
        //     if (tsk.status != 2) continue;

        //     _ = tasks.orderedRemove(index);
        // }

        for (tasks.items) |tsk| {
            // if (!tsk.repeating) tsk.status = 1;
            tsk.func();
            // if (!tsk.repeating) tsk.status = 2;
        }
    }
};
