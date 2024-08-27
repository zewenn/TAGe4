pub const TAGe4 = struct {
    pub const EventHandler = @import("./events.zig").EventHandler;
    pub const EngineEvents = @import("./events.zig").EngineEvents;

    pub const Vec2 = @import("./vectors.zig").Vec2;

    // Input
    pub const inputlib = @import("./input/generic.zig");
    pub const Input = inputlib.getInputter(.{}) catch @panic("OS not supported!");

    // Rendering
    pub const Display = @import("./renderer.zig").Display;
    pub const Sprite = @import("./renderer.zig").Sprite;
    pub const Cell = @import("./renderer.zig").Cell;
    pub const Point = @import("./renderer.zig").Point;
    pub const ScreenPoint = @import("./renderer.zig").ScreenPoint;

    pub const Time = @import("./time.zig").time;
    pub const Assets = @import("./assets.zig").assets;
};
