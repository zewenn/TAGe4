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
    pub const Screen = @import("./screen.zig").screen;
    pub const Sprite = @import("./screen.zig").Sprite;
    pub const Cell = @import("./screen.zig").Cell;

    pub const Time = @import("./time.zig").time;
};
