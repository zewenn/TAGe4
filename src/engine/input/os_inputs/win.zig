const std = @import("std");

// =========================================================

const Allocator = @import("std").mem.Allocator;
const Inputter = @import("../generic.zig").Inputter;
const KeyCodes = @import("../generic.zig").KeyCodes;
const ASCIIKeyCodes = @import("./.generics.zig").ASCIIKeyCodes;

// =========================================================

pub const WindowsInputter = struct {
    const c = @cImport({
        @cInclude("windows.h");
        @cInclude("conio.h");
        @cInclude("stdio.h");
        @cInclude("fcntl.h");
        @cInclude("io.h");
    });

    var keymap_buffer: []bool = undefined;
    var keymap_buffer_last_frame: []bool = undefined;

    var alloc: *Allocator = undefined;

    fn _init(allocator: *Allocator) void {
        alloc = allocator;

        keymap_buffer = alloc.alloc(bool, std.math.maxInt(u8)) catch unreachable;
        keymap_buffer_last_frame = alloc.alloc(bool, std.math.maxInt(u8)) catch unreachable;

        // _ = c.setmode(c.STDIN_FILENO, c.O_RAW);
    }

    fn _update() void {
        @memcpy(keymap_buffer_last_frame, keymap_buffer);
        if (c.kbhit() != 0) _ = c.getch();
    }

    fn _deinit() void {
        alloc.free(keymap_buffer);
        alloc.free(keymap_buffer_last_frame);

        // _ = c.setmode(c.fileno(c.stdin), c.O_TEXT);
    }

    fn _gKey(k: ?u8) bool {
        if (k == null) return false;

        if (c.GetKeyState(@intCast(k.?)) < 0) {
            keymap_buffer[k.?] = true;
            return true;
        }
        keymap_buffer[k.?] = false;
        return false;
    }

    fn _getKeyDown(k: ?u8) bool {
        if (k == null) return false;

        if (keymap_buffer_last_frame[k.?]) return false;
        return _gKey(k);
    }

    fn _getKeyUp(k: ?u8) bool {
        if (k == null) return false;

        if (!keymap_buffer_last_frame[k.?]) return false;
        return !_gKey(k);
    }

    fn get() Inputter {
        return Inputter{
            .keymap = &keymap_buffer,
            .keys = ASCIIKeyCodes,
            // Events
            .init = _init,
            .update = _update,
            .deinit = _deinit,
            // Keys
            .getKey = _gKey,
            .getKeyDown = _getKeyDown,
            .getKeyUp = _getKeyUp,
        };
    }
};
