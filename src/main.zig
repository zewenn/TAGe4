const std = @import("std");
const print = std.debug.print;

const String = @import("./deps/zig-string.zig").String;

const e =  @import("./engine/engine.zig").TAGe4;
const Vec2 = e.Vec2;

var pos = Vec2(f64).init(0, 5);
var rnd = std.Random.DefaultPrng.init(100);

const assets = @import(".temp/assets.zig");

pub fn testfn() void {
    const x: f64 = @floatFromInt(rnd.random().int(u4));

    e.Screen.blitString(Vec2(f64).init(pos.y + x, pos.x), "x");
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();

    e.Time.start(60);

    const KeyCodes = e.Input.getKeyCodes(.{}) catch {
        std.debug.print("OS Not Supported", .{});
        return;
    };
    const Inputter = e.Input.getInputter(.{}) catch {
        std.debug.print("OS Not Supported", .{});
        return;
    };
    Inputter.init(&allocator);
    defer Inputter.deinit();

    const Events = e.EventHandler(.{});

    Events.init(&allocator);
    defer Events.deinit();


    e.Screen.init(.{ .x = 120, .y = 30 });
    defer e.Screen.deinit();
    e.Screen.Cursor.hide();

    try Events.on(.Update, testfn);

    while (true) {
        Inputter.update();
        e.Screen.clearBuffer();

        if (Inputter.getKey(KeyCodes.A)) {
            pos.x -= 100 * e.Time.delta;
        }
        if (Inputter.getKey(KeyCodes.D)) {
            pos.x += 100 * e.Time.delta;
        }
        if (Inputter.getKey(KeyCodes.W)) {
            pos.y -= 100 * e.Time.delta;
        }
        if (Inputter.getKey(KeyCodes.S)) {
            pos.y += 100 * e.Time.delta;
        }

        if (Inputter.getKey(KeyCodes.ESCAPE)) {
            break;
        }
        

        assets.player_left_0.render(pos);
        assets.player_left_0.render(pos.add(Vec2(f64).init(5, 5)));

        try Events.call(.Update);
        e.Screen.apply();
        e.Time.tick(60);
    }
}
