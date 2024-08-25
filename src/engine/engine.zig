pub const TAGe4 = struct {
    pub const EventHandler = @import("./events.zig").EventHandler;
    pub const EngineEvents = @import("./events.zig").EngineEvents;

    pub const Vec2 = @import("./vectors.zig").Vec2;

    // Input
    pub const Input = struct {
        pub const getInputter = @import("./input.zig").getInputter;
        pub const getKeyCodes = @import("./input.zig").getKeyCodes;
    };

    // Rendering
    pub const Display = @import("./renderer.zig").Display;
    pub const Sprite = @import("./renderer.zig").Sprite;
    pub const Cell = @import("./renderer.zig").Cell;
    pub const Point = @import("./renderer.zig").Point;
    pub const ScreenPoint = @import("./renderer.zig").ScreenPoint;

    pub const Time = @import("./time.zig").time;
};
