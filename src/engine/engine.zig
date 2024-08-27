pub const TAGe4 = struct {
    pub const EventHandler = @import("./events.zig").EventHandler;
    pub const EngineEvents = @import("./events.zig").EngineEvents;

    pub const Vec2 = @import("./vectors.zig").Vec2;

    // Input
    pub const inputlib = @import("./input/generic.zig");
    pub const Input = inputlib.getInputter(.{}) catch @panic("OS not supported!");

    // Rendering
    pub const Display = @import("./rendering/renderer.zig").Display;
    pub const ScreenPoint = @import("./rendering/renderer.zig").ScreenPoint;
    pub const Point = @import("./rendering/renderer.zig").Point;
    pub const Sprite = @import("./rendering/Sprite.zig");
    pub const Cell = @import("./rendering/Cell.zig");

    pub const Time = @import("./time.zig").time;
    pub const Assets = @import("./assets.zig");
};
