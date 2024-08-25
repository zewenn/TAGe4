const std = @import("std");

pub const time = struct {
    const tm = std.time;

    /// Seconds since UTC 1970-01-01
    pub var current: f64 = 0;

    /// Time passed since the last `time.update()` call
    pub var delta: f64 = 0;

    var max: f64 = 0;
    var stored_max: u16 = 0;

    pub fn start(max_fps: u16) void {
        setCurrentToNow();
        updateMax(max_fps);
    }

    fn updateMax(m: u16) void {
        stored_max = m;
        max = @as(f64, 1.0) / @as(f64, @floatFromInt(m));
    }

    fn setCurrentToNow() void {
        current = @floatFromInt(tm.milliTimestamp());
        current = current / @as(f64, 1000.0);
    }

    pub fn tick(max_fps: u16) void {
        const _curr = current;
        setCurrentToNow();
        delta = current - _curr;

        if (stored_max != max_fps) {
            updateMax(max_fps);
        }

        if (delta >= max) return;
        tm.sleep(@intFromFloat((max - delta) * @as(f64, 1000) * @as(f64, 1000)));
    }
};