const std = @import("std");
const print = std.debug.print;
const String = @import("./deps/zig-string.zig").String;

const menus = @import("./menus.zig");
const systems = @import("./systems.zig");

fn test_fn() void {
    print("Test fn", .{});
}

// fn update() void {
//     print("a", .{});
// }

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();

    var my_action = try menus.Action.init(
        &allocator,
        "Test Action",
        test_fn,
    );
    defer my_action.deinit();

    var actions = [_]menus.Action{
        my_action,
    };

    var my_menu = try menus.Menu.init(
        &allocator,
        "menu1",
        "Test",
        "Hello World!",
        &actions,
    );
    defer my_menu.deinit();
    try my_menu.render();

    // try systems.System.init(allocator);
    // defer systems.System.deinit();

    // var my_task = try systems.Task.init(allocator, "Test", &update, false);
    // defer my_task.deinit();

    // try systems.System.queue(my_task);

    // while (true) {
    //     try systems.System.execute();
    // }

    // print("Value: {s}", .{xy_as_u8.?});
}
