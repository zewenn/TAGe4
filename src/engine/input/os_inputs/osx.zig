const std = @import("std");

// =========================================================

const Allocator = @import("std").mem.Allocator;
const Inputter = @import("../generic.zig").Inputter;
const KeyCodes = @import("../generic.zig").KeyCodes;

// =========================================================

pub const OsXInputter = struct {
    // ZLS ignore
    pub const c = @cImport({
        @cInclude("IOKit/hid/IOHIDManager.h");
        @cInclude("CoreFoundation/CoreFoundation.h");
        @cInclude("ncurses.h");
    });

    var keymap_buffer: []bool = undefined;
    var last_update_keymap_buffer: []bool = undefined;
    var manager: c.IOHIDManagerRef = undefined;
    var alloc: *Allocator = undefined;

    fn Handle_IOHIDInputValueCallback(_: ?*anyopaque, _: c.IOReturn, _: ?*anyopaque, value: c.IOHIDValueRef) callconv(.C) void {
        const element: c.IOHIDElementRef = c.IOHIDValueGetElement(value);
        const usagePage = c.IOHIDElementGetUsagePage(element);
        const usage = c.IOHIDElementGetUsage(element);

        if (usagePage != c.kHIDPage_KeyboardOrKeypad) return;

        const pressed = c.IOHIDValueGetIntegerValue(value);

        const key = std.math.cast(u8, usage);
        if (key == null) return;

        if (pressed != 0) {
            keymap_buffer[key.?] = true;
            return;
        }
        keymap_buffer[key.?] = false;
    }

    fn _init(allocator: *Allocator) void {
        manager = c.IOHIDManagerCreate(c.kCFAllocatorDefault, c.kIOHIDOptionsTypeNone);
        c.IOHIDManagerSetDeviceMatching(manager, null);

        c.IOHIDManagerRegisterInputValueCallback(manager, Handle_IOHIDInputValueCallback, c.NULL);
        c.IOHIDManagerScheduleWithRunLoop(manager, c.CFRunLoopGetCurrent(), c.kCFRunLoopDefaultMode);

        _ = c.IOHIDManagerOpen(manager, c.kIOHIDOptionsTypeNone);

        _ = c.initscr();
        _ = c.cbreak();
        _ = c.noecho();
        _ = c.keypad(c.stdscr, true);
        _ = c.nodelay(c.stdscr, true);
        _ = c.curs_set(c.FALSE);

        keymap_buffer = allocator.alloc(bool, std.math.maxInt(u8)) catch unreachable;
        last_update_keymap_buffer = allocator.alloc(bool, std.math.maxInt(u8)) catch unreachable;

        alloc = allocator;
    }

    fn _update() void {
        @memcpy(last_update_keymap_buffer, keymap_buffer);
        _ = c.CFRunLoopRunInMode(c.kCFRunLoopDefaultMode, 0.01, c.TRUE);
        _ = c.getch();
    }

    fn _deinit() void {
        _ = c.getch();
        _ = c.endwin();

        c.CFRelease(manager);

        alloc.free(keymap_buffer);
        alloc.free(last_update_keymap_buffer);
    }

    fn _getKey(k: ?u8) bool {
        if (k == null) return false;
        return keymap_buffer[k.?];
    }

    fn _gKeyDown(k: ?u8) bool {
        if (k == null) return false;
        if (last_update_keymap_buffer[k.?]) return false;
        return _getKey(k);
    }

    fn _gKeyUp(k: ?u8) bool {
        if (k == null) return false;
        if (!last_update_keymap_buffer[k.?]) return false;
        return !_getKey(k);
    }

    pub fn get() Inputter {
        return Inputter{
            .keymap = &keymap_buffer,
            .keys = OsXKeyCodes,
            .init = _init,
            .update = _update,
            .deinit = _deinit,
            .getKey = _getKey,
            .getKeyDown = _gKeyDown,
            .getKeyUp = _gKeyUp,
        };
    }
};

pub const OsXKeyCodes: KeyCodes = .{
    .NULL = null,
    .SOH = null,
    .STX = null,
    .ETX = null,
    .EOT = null,
    .ENQ = null,
    .ACK = null,
    .BEL = null,
    .BACKSPACE = 42,
    .HORTIZONTAL_TAB = null,
    .LINE_FEED = null,
    .VERTICAL_TAB = null,
    .FROM_FEED = null,
    .ENTER = 88,
    .SHIFT_OUT = null,
    .SHIFT_IN = null,
    .DLE = null,
    .DC1 = null,
    .DC2 = null,
    .DC3 = null,
    .DC4 = null,
    .NAK = null,
    .SYN = null,
    .ETB = null,
    .CANCEL = null,
    .EM = null,
    .SUB = null,
    .ESCAPE = 41,
    .FS = null,
    .GS = null,
    .RS = 229,
    .US = null,
    .SPACE = 44,
    .EXCLAMATION_MARK = 30,
    .DOUBLE_QUOTE = 52,
    .HASHTAG = 32,
    .DOLLARSIGN = 33,
    .PERCENTAGE = 34,
    .ANDSIGN = 36,
    .SINGLE_QUOTE = 52,
    .ROUND_BRACKET_START = 38,
    .ROUND_BRACKET_END = 39,
    .STAR_SIGN = 37,
    .PLUS_SIGN = 46,
    .COMA = 54,
    .MINUS_SIGN = 45,
    .DOT = 55,
    .SLASH_SIGN = 56,
    .NUMBER_0 = 39,
    .NUMBER_1 = 30,
    .NUMBER_2 = 31,
    .NUMBER_3 = 32,
    .NUMBER_4 = 33,
    .NUMBER_5 = 34,
    .NUMBER_6 = 35,
    .NUMBER_7 = 36,
    .NUMBER_8 = 37,
    .NUMBER_9 = 38,
    .COLON = 51,
    .SEMI_COLON = 51,
    .LARGER_SIGN = 54,
    .EQUAL_SIGN = 46,
    .SMALLER_SIGN = 55,
    .QUESTION_MARK = 56,
    .AT_SIGN = 31,
    .A = 4,
    .B = 5,
    .C = 6,
    .D = 7,
    .E = 8,
    .F = 9,
    .G = 10,
    .H = 11,
    .I = 12,
    .J = 13,
    .K = 14,
    .L = 15,
    .M = 16,
    .N = 17,
    .O = 18,
    .P = 19,
    .Q = 20,
    .R = 21,
    .S = 22,
    .T = 23,
    .U = 24,
    .V = 25,
    .W = 26,
    .X = 27,
    .Y = 28,
    .Z = 29,
    .SQUARE_BRACKET_START = 47,
    .BACKSLASH = null,
    .SQUARE_BRACKET_END = 48,
    .CIRCUMFLEX = 35,
    .UNDERSCORE = 45,
    .GRAVE_ACCENT = 53,
    .a = 4,
    .b = 5,
    .c = 6,
    .d = 7,
    .e = 8,
    .f = 9,
    .g = 10,
    .h = 11,
    .i = 12,
    .j = 13,
    .k = 14,
    .l = 15,
    .m = 16,
    .n = 17,
    .o = 18,
    .p = 19,
    .q = 20,
    .r = 21,
    .s = 22,
    .t = 23,
    .u = 24,
    .v = 25,
    .w = 26,
    .x = 27,
    .y = 28,
    .z = 29,
    .CURLY_BRACKET_START = 47,
    .VERTICAL_BAR = 49,
    .CURLY_BRACKET_END = 48,
    .SWUNG_DASH = 53,
    .DELETE = 42,
};
