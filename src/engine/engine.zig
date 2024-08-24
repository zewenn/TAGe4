pub const TAG4 = struct {
    pub const Events = @import("./events.zig").events;
    pub const Input = struct {
        pub const Inputter = @import("./input.zig").getInputter() catch unreachable;
        pub const KeyCodes = @import("./input.zig").getKeyCodes() catch unreachable;
    };
    pub const Screen = @import("./screen.zig").screen;
    pub const Sprite = @import("./screen.zig").Sprite;
    pub const Cell = @import("./screen.zig").Cell;
};
