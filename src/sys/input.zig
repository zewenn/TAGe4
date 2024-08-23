const std = @import("std");
const z = @import("./z.zig");
const Allocator = @import("std").mem.Allocator;

const Inputter = struct {
    keymap: *[]bool,
    getKey: *const fn (?u8) bool,
    getKeyDown: *const fn (?u8) bool,
    getKeyUp: *const fn (?u8) bool,
    init: *const fn (*Allocator) void,
    deinit: *const fn () void,
    update: *const fn () void,
};

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
            .init = _init,
            .update = _update,
            .deinit = _deinit,
            .getKey = _getKey,
            .getKeyDown = _gKeyDown,
            .getKeyUp = _gKeyUp,
        };
    }
};

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

pub const KeyCodes = struct {
    NULL: ?u8 = null,
    SOH: ?u8 = null,
    STX: ?u8 = null,
    ETX: ?u8 = null,
    EOT: ?u8 = null,
    ENQ: ?u8 = null,
    ACK: ?u8 = null,
    BEL: ?u8 = null,
    BACKSPACE: ?u8 = null,
    HORTIZONTAL_TAB: ?u8 = null,
    LINE_FEED: ?u8 = null,
    VERTICAL_TAB: ?u8 = null,
    FROM_FEED: ?u8 = null,
    ENTER: ?u8 = null,
    SHIFT_OUT: ?u8 = null,
    SHIFT_IN: ?u8 = null,
    DLE: ?u8 = null,
    DC1: ?u8 = null,
    DC2: ?u8 = null,
    DC3: ?u8 = null,
    DC4: ?u8 = null,
    NAK: ?u8 = null,
    SYN: ?u8 = null,
    ETB: ?u8 = null,
    CANCEL: ?u8 = null,
    EM: ?u8 = null,
    SUB: ?u8 = null,
    ESCAPE: ?u8 = null,
    FS: ?u8 = null,
    GS: ?u8 = null,
    RS: ?u8 = null,
    US: ?u8 = null,
    SPACE: ?u8 = null,
    EXCLAMATION_MARK: ?u8 = null,
    DOUBLE_QUOTE: ?u8 = null,
    HASHTAG: ?u8 = null,
    DOLLARSIGN: ?u8 = null,
    PERCENTAGE: ?u8 = null,
    ANDSIGN: ?u8 = null,
    SINGLE_QUOTE: ?u8 = null,
    ROUND_BRACKET_START: ?u8 = null,
    ROUND_BRACKET_END: ?u8 = null,
    STAR_SIGN: ?u8 = null,
    PLUS_SIGN: ?u8 = null,
    COMA: ?u8 = null,
    MINUS_SIGN: ?u8 = null,
    DOT: ?u8 = null,
    SLASH_SIGN: ?u8 = null,
    NUMBER_0: ?u8 = null,
    NUMBER_1: ?u8 = null,
    NUMBER_2: ?u8 = null,
    NUMBER_3: ?u8 = null,
    NUMBER_4: ?u8 = null,
    NUMBER_5: ?u8 = null,
    NUMBER_6: ?u8 = null,
    NUMBER_7: ?u8 = null,
    NUMBER_8: ?u8 = null,
    NUMBER_9: ?u8 = null,
    COLON: ?u8 = null,
    SEMI_COLON: ?u8 = null,
    LARGER_SIGN: ?u8 = null,
    EQUAL_SIGN: ?u8 = null,
    SMALLER_SIGN: ?u8 = null,
    QUESTION_MARK: ?u8 = null,
    AT_SIGN: ?u8 = null,
    A: ?u8 = null,
    B: ?u8 = null,
    C: ?u8 = null,
    D: ?u8 = null,
    E: ?u8 = null,
    F: ?u8 = null,
    G: ?u8 = null,
    H: ?u8 = null,
    I: ?u8 = null,
    J: ?u8 = null,
    K: ?u8 = null,
    L: ?u8 = null,
    M: ?u8 = null,
    N: ?u8 = null,
    O: ?u8 = null,
    P: ?u8 = null,
    Q: ?u8 = null,
    R: ?u8 = null,
    S: ?u8 = null,
    T: ?u8 = null,
    U: ?u8 = null,
    V: ?u8 = null,
    W: ?u8 = null,
    X: ?u8 = null,
    Y: ?u8 = null,
    Z: ?u8 = null,
    SQUARE_BRACKET_START: ?u8 = null,
    BACKSLASH: ?u8 = null,
    SQUARE_BRACKET_END: ?u8 = null,
    CIRCUMFLEX: ?u8 = null,
    UNDERSCORE: ?u8 = null,
    GRAVE_ACCENT: ?u8 = null,
    a: ?u8 = null,
    b: ?u8 = null,
    c: ?u8 = null,
    d: ?u8 = null,
    e: ?u8 = null,
    f: ?u8 = null,
    g: ?u8 = null,
    h: ?u8 = null,
    i: ?u8 = null,
    j: ?u8 = null,
    k: ?u8 = null,
    l: ?u8 = null,
    m: ?u8 = null,
    n: ?u8 = null,
    o: ?u8 = null,
    p: ?u8 = null,
    q: ?u8 = null,
    r: ?u8 = null,
    s: ?u8 = null,
    t: ?u8 = null,
    u: ?u8 = null,
    v: ?u8 = null,
    w: ?u8 = null,
    x: ?u8 = null,
    y: ?u8 = null,
    z: ?u8 = null,
    CURLY_BRACKET_START: ?u8 = null,
    VERTICAL_BAR: ?u8 = null,
    CURLY_BRACKET_END: ?u8 = null,
    SWUNG_DASH: ?u8 = null,
    DELETE: ?u8 = null,
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

pub const WindowsKeyCodes: KeyCodes = .{
    .NULL = 0,
    .SOH = 1,
    .STX = 2,
    .ETX = 3,
    .EOT = 4,
    .ENQ = 5,
    .ACK = 6,
    .BEL = 7,
    .BACKSPACE = 8,
    .HORTIZONTAL_TAB = 9,
    .LINE_FEED = 10,
    .VERTICAL_TAB = 11,
    .FROM_FEED = 12,
    .ENTER = 13,
    .SHIFT_OUT = 14,
    .SHIFT_IN = 15,
    .DLE = 16,
    .DC1 = 17,
    .DC2 = 18,
    .DC3 = 19,
    .DC4 = 20,
    .NAK = 21,
    .SYN = 22,
    .ETB = 23,
    .CANCEL = 24,
    .EM = 25,
    .SUB = 26,
    .ESCAPE = 27,
    .FS = 28,
    .GS = 29,
    .RS = 30,
    .US = 31,
    .SPACE = 32,
    .EXCLAMATION_MARK = 33,
    .DOUBLE_QUOTE = 34,
    .HASHTAG = 35,
    .DOLLARSIGN = 36,
    .PERCENTAGE = 37,
    .ANDSIGN = 38,
    .SINGLE_QUOTE = 39,
    .ROUND_BRACKET_START = 40,
    .ROUND_BRACKET_END = 41,
    .STAR_SIGN = 42,
    .PLUS_SIGN = 43,
    .COMA = 44,
    .MINUS_SIGN = 45,
    .DOT = 46,
    .SLASH_SIGN = 47,
    .NUMBER_0 = 48,
    .NUMBER_1 = 49,
    .NUMBER_2 = 50,
    .NUMBER_3 = 51,
    .NUMBER_4 = 52,
    .NUMBER_5 = 53,
    .NUMBER_6 = 54,
    .NUMBER_7 = 55,
    .NUMBER_8 = 56,
    .NUMBER_9 = 57,
    .COLON = 58,
    .SEMI_COLON = 59,
    .LARGER_SIGN = 60,
    .EQUAL_SIGN = 61,
    .SMALLER_SIGN = 62,
    .QUESTION_MARK = 63,
    .AT_SIGN = 64,
    .A = 65,
    .B = 66,
    .C = 67,
    .D = 68,
    .E = 69,
    .F = 70,
    .G = 71,
    .H = 72,
    .I = 73,
    .J = 74,
    .K = 75,
    .L = 76,
    .M = 77,
    .N = 78,
    .O = 79,
    .P = 80,
    .Q = 81,
    .R = 82,
    .S = 83,
    .T = 84,
    .U = 85,
    .V = 86,
    .W = 87,
    .X = 88,
    .Y = 89,
    .Z = 90,
    .SQUARE_BRACKET_START = 91,
    .BACKSLASH = 92,
    .SQUARE_BRACKET_END = 93,
    .CIRCUMFLEX = 94,
    .UNDERSCORE = 95,
    .GRAVE_ACCENT = 96,
    .a = 97,
    .b = 98,
    .c = 99,
    .d = 100,
    .e = 101,
    .f = 102,
    .g = 103,
    .h = 104,
    .i = 105,
    .j = 106,
    .k = 107,
    .l = 108,
    .m = 109,
    .n = 110,
    .o = 111,
    .p = 112,
    .q = 113,
    .r = 114,
    .s = 115,
    .t = 116,
    .u = 117,
    .v = 118,
    .w = 119,
    .x = 120,
    .y = 121,
    .z = 122,
    .CURLY_BRACKET_START = 123,
    .VERTICAL_BAR = 124,
    .CURLY_BRACKET_END = 125,
    .SWUNG_DASH = 126,
    .DELETE = 127,
};

const OSNotSupportedError = error{OSNotSupported};

pub inline fn getInputter() OSNotSupportedError!Inputter {
    return switch (@import("builtin").target.os.tag) {
        .windows => WindowsInputter.get(),
        .macos => OsXInputter.get(),
        .linux => OSNotSupportedError,
        else => OSNotSupportedError,
    };
}

// TODO: Make an interface for keycodes!!!
pub inline fn getKeyCodes() OSNotSupportedError!KeyCodes {
    return switch (@import("builtin").target.os.tag) {
        .windows => WindowsKeyCodes,
        .macos => OsXKeyCodes,
        else => OSNotSupportedError,
    };
}

/// **DEPRECATED**: This does not use the `Inputter` interface!
pub const NCursesInputter = struct {
    const c = @cImport({
        @cInclude("ncurses.h");
    });

    var keymap: []bool = undefined;
    var alloc: *Allocator = undefined;
    const uframes = 1;
    var frames: u32 = 0;

    var sourse: c.CGEventSourceRef = undefined;

    pub fn init(allocator: *Allocator) void {
        _ = c.initscr();
        _ = c.cbreak();
        _ = c.noecho();
        _ = c.keypad(c.stdscr, true);
        _ = c.nodelay(c.stdscr, true);
        _ = c.curs_set(c.FALSE);

        keymap = allocator.alloc(bool, std.math.maxInt(u8)) catch unreachable;
        alloc = allocator;
    }

    pub fn poll() void {
        frames += 1;
        if (frames >= uframes) {
            for (0..keymap.len) |key| {
                keymap[key] = false;
            }
        }

        const at = std.math.cast(u8, @as(i32, @intCast((c.getch()))));
        if (at == null) return;
        if (at.? >= keymap.len) return;

        keymap[at.?] = true;
    }

    pub fn getKey(key: u8) bool {
        return keymap[key];
    }

    pub fn deinit() void {
        _ = c.endwin();
        alloc.free(keymap);
    }

    /// Macros for the first 128 ASCII characters
    pub const keys = struct {
        pub const NULL: u8 = 0;
        pub const SOH: u8 = 1;
        pub const STX: u8 = 2;
        pub const ETX: u8 = 3;
        pub const EOT: u8 = 4;
        pub const ENQ: u8 = 5;
        pub const ACK: u8 = 6;
        pub const BEL: u8 = 7;
        pub const BACKSPACE: u8 = 8;
        pub const HORTIZONTAL_TAB: u8 = 9;
        pub const LINE_FEED: u8 = 10;
        pub const VERTICAL_TAB: u8 = 11;
        pub const FROM_FEED: u8 = 12;
        pub const ENTER: u8 = 13;
        pub const SHIFT_OUT: u8 = 14;
        pub const SHIFT_IN: u8 = 15;
        pub const DLE: u8 = 16;
        pub const DC1: u8 = 17;
        pub const DC2: u8 = 18;
        pub const DC3: u8 = 19;
        pub const DC4: u8 = 20;
        pub const NAK: u8 = 21;
        pub const SYN: u8 = 22;
        pub const ETB: u8 = 23;
        pub const CANCEL: u8 = 24;
        pub const EM: u8 = 25;
        pub const SUB: u8 = 26;
        pub const ESCAPE: u8 = 27;
        pub const FS: u8 = 28;
        pub const GS: u8 = 29;
        pub const RS: u8 = 30;
        pub const US: u8 = 31;
        pub const SPACE: u8 = 32;
        pub const EXCLAMATION_MARK: u8 = 33;
        pub const DOUBLE_QUOTE: u8 = 34;
        pub const HASHTAG: u8 = 35;
        pub const DOLLARSIGN: u8 = 36;
        pub const PERCENTAGE: u8 = 37;
        pub const ANDSIGN: u8 = 38;
        pub const SINGLE_QUOTE: u8 = 39;
        pub const ROUND_BRACKET_START: u8 = 40;
        pub const ROUND_BRACKET_END: u8 = 41;
        pub const STAR_SIGN: u8 = 42;
        pub const PLUS_SIGN: u8 = 43;
        pub const COMA: u8 = 44;
        pub const MINUS_SIGN: u8 = 45;
        pub const DOT: u8 = 46;
        pub const SLASH_SIGN: u8 = 47;
        pub const NUMBER_0: u8 = 48;
        pub const NUMBER_1: u8 = 49;
        pub const NUMBER_2: u8 = 50;
        pub const NUMBER_3: u8 = 51;
        pub const NUMBER_4: u8 = 52;
        pub const NUMBER_5: u8 = 53;
        pub const NUMBER_6: u8 = 54;
        pub const NUMBER_7: u8 = 55;
        pub const NUMBER_8: u8 = 56;
        pub const NUMBER_9: u8 = 57;
        pub const COLON: u8 = 58;
        pub const SEMI_COLON: u8 = 59;
        pub const LARGER_SIGN: u8 = 60;
        pub const EQUAL_SIGN: u8 = 61;
        pub const SMALLER_SIGN: u8 = 62;
        pub const QUESTION_MARK: u8 = 63;
        pub const AT_SIGN: u8 = 64;
        pub const A: u8 = 65;
        pub const B: u8 = 66;
        pub const C: u8 = 67;
        pub const D: u8 = 68;
        pub const E: u8 = 69;
        pub const F: u8 = 70;
        pub const G: u8 = 71;
        pub const H: u8 = 72;
        pub const I: u8 = 73;
        pub const J: u8 = 74;
        pub const K: u8 = 75;
        pub const L: u8 = 76;
        pub const M: u8 = 77;
        pub const N: u8 = 78;
        pub const O: u8 = 79;
        pub const P: u8 = 80;
        pub const Q: u8 = 81;
        pub const R: u8 = 82;
        pub const S: u8 = 83;
        pub const T: u8 = 84;
        pub const U: u8 = 85;
        pub const V: u8 = 86;
        pub const W: u8 = 87;
        pub const X: u8 = 88;
        pub const Y: u8 = 89;
        pub const Z: u8 = 90;
        pub const SQUARE_BRACKET_START: u8 = 91;
        pub const BACKSLASH: u8 = 92;
        pub const SQUARE_BRACKET_END: u8 = 93;
        pub const CIRCUMFLEX: u8 = 94;
        pub const UNDERSCORE: u8 = 95;
        pub const GRAVE_ACCENT: u8 = 96;
        pub const a: u8 = 97;
        pub const b: u8 = 98;
        pub const c: u8 = 99;
        pub const d: u8 = 100;
        pub const e: u8 = 101;
        pub const f: u8 = 102;
        pub const g: u8 = 103;
        pub const h: u8 = 104;
        pub const i: u8 = 105;
        pub const j: u8 = 106;
        pub const k: u8 = 107;
        pub const l: u8 = 108;
        pub const m: u8 = 109;
        pub const n: u8 = 110;
        pub const o: u8 = 111;
        pub const p: u8 = 112;
        pub const q: u8 = 113;
        pub const r: u8 = 114;
        pub const s: u8 = 115;
        pub const t: u8 = 116;
        pub const u: u8 = 117;
        pub const v: u8 = 118;
        pub const w: u8 = 119;
        pub const x: u8 = 120;
        pub const y: u8 = 121;
        pub const z: u8 = 122;
        pub const CURLY_BRACKET_START: u8 = 123;
        pub const VERTICAL_BAR: u8 = 124;
        pub const CURLY_BRACKET_END: u8 = 125;
        pub const SWUNG_DASH: u8 = 126;
        pub const DELETE: u8 = 127;
    };
};
