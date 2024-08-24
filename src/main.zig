const std = @import("std");
const print = std.debug.print;

const String = @import("./deps/zig-string.zig").String;
const Vec2 = @import("./deps/vectors.zig").Vec2;

const e =  @import("./engine/engine.zig").TAG4;

var pos = Vec2(f32).init(0, 5);
var rnd = std.Random.DefaultPrng.init(100);

const assets = @import(".temp/assets.zig");

pub fn testfn() void {
    const x: f32 = @floatFromInt(rnd.random().int(u4));

    e.Screen.blitString(Vec2(f32).init(pos.y + x, pos.x), "x");
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();

    const KeyCodes = e.Input.KeyCodes;
    const Inputter = e.Input.Inputter;
    Inputter.init(&allocator);
    defer Inputter.deinit();

    e.Events.init(&allocator);
    defer e.Events.deinit();


    e.Screen.init(.{ .x = 120, .y = 30 });
    defer e.Screen.deinit();
    e.Screen.Cursor.hide();

    try e.Events.on("update", testfn);

    while (true) {
        Inputter.update();
        e.Screen.clearBuffer();

        if (Inputter.getKey(KeyCodes.A)) {
            pos.x -= 1;
        }
        if (Inputter.getKey(KeyCodes.D)) {
            pos.x += 1;
        }
        if (Inputter.getKey(KeyCodes.W)) {
            pos.y -= 1;
        }
        if (Inputter.getKey(KeyCodes.S)) {
            pos.y += 1;
        }

        if (Inputter.getKey(KeyCodes.ESCAPE)) {
            break;
        }
        

        assets.player_left_0.render(pos);

        try e.Events.call("update");
        e.Screen.apply();
    }
}
