const std = @import("std");
const z = @import("./z.zig");
const Allocator = @import("std").mem.Allocator;

const Inputter = struct {
    keymap: *[]bool,
    getKey: *const fn (u8) bool,
    getKeyDown: *const fn (u8) bool,
    getKeyUp: *const fn (u8) bool,
    init: *const fn (*Allocator) void,
    deinit: *const fn () void,
    update: *const fn () void,
};

pub const OsXInputter = struct {
    pub const c = @cImport({
        // @cInclude("ApplicationServices/ApplicationServices.h");
        // // @cInclude("IOKit/hidsystem/ev_keymap.h");
        // @cInclude("Carbon/Carbon.h");
        @cInclude("IOKit/hid/IOHIDManager.h");
        @cInclude("CoreFoundation/CoreFoundation.h");
        @cInclude("ncurses.h");
        // @cInclude("unistd.h");
    });

    var _keymap: []bool = undefined;
    var _keymap2: []bool = undefined;
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
            _keymap[key.?] = true;
            // std.debug.print("{any}\n\r", .{usage});
            return;
        }
        _keymap[key.?] = false;

        // if (pressed) {
        //     printf("Key pressed: %d\n", usage);
        // } else {
        //     printf("Key released: %d\n", usage);
        // }

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

        _keymap = allocator.alloc(bool, std.math.maxInt(u8)) catch unreachable;
        _keymap2 = allocator.alloc(bool, std.math.maxInt(u8)) catch unreachable;

        alloc = allocator;
    }

    fn _update() void {
        _ = c.CFRunLoopRunInMode(c.kCFRunLoopDefaultMode, 0.01, c.TRUE);
        _ = c.getch();
    }

    fn _deinit() void {
        _ = c.getch();
        _ = c.endwin();

        c.CFRelease(manager);
        
        alloc.free(_keymap);
        alloc.free(_keymap2);
    }

    fn _getKey(k: u8) bool {
        return _keymap[k];
    }

    fn _gKeyDown(k: u8) bool {
        if (_keymap[k]) return false;
        return _getKey(k);
    }

    fn _gKeyUp(k: u8) bool {
        if (!_keymap[k]) return false;
        return !_getKey(k);
    }

    pub fn get() Inputter {
        return Inputter{
            .keymap = &_keymap,
            .init = _init,
            .update = _update,
            .deinit = _deinit,
            .getKey = _getKey,
            .getKeyDown = _gKeyDown,
            .getKeyUp = _gKeyUp,
        };
    }
};

pub const OsXKeyCodes = struct {
	pub const A = 4;
	pub const B = 5;
	pub const C = 6;
	pub const D = 7;
	pub const E = 8;
	pub const F = 9;
	pub const G = 10;
	pub const H = 11;
	pub const I = 12;
	pub const J = 13;
	pub const K = 14;
	pub const L = 15;
	pub const M = 16;
	pub const N = 17;
	pub const O = 18;
	pub const P = 19;
	pub const Q = 20;
	pub const R = 21;
	pub const S = 22;
	pub const T = 23;
	pub const U = 24;
	pub const V = 25;
	pub const W = 26;
	pub const X = 27;
	pub const Y = 28;
	pub const Z = 29;
	pub const @"!" = 30;
	pub const @"@" = 31;
	pub const @"#" = 32;
	pub const @"$" = 33;
	pub const @"%" = 34;
	pub const @"^" = 35;
	pub const @"&" = 36;
	pub const @"*" = 37;
	pub const @"(" = 38;
	pub const @")" = 39;
	pub const ESCAPE = 41;
	pub const @"DELETE|BACKSPACE" = 42;
	pub const TAB = 43;
	pub const @" " = 44;
	pub const @"_" = 45;
	pub const @"+" = 46;
	pub const @"{" = 47;
	pub const @"}" = 48;
	pub const @"|" = 49;
	pub const @":" = 51;
	pub const @"\"" = 52;
	pub const @"~" = 53;
	pub const @"<" = 54;
	pub const @">" = 55;
	pub const @"?" = 56;
	pub const CAPSLOCK = 57;
	pub const @"F1" = 58;
	pub const @"F2" = 59;
	pub const @"F3" = 60;
	pub const @"F4" = 61;
	pub const @"F5" = 62;
	pub const @"F6" = 63;
	pub const @"F7" = 64;
	pub const @"F8" = 65;
	pub const @"F9" = 66;
	pub const @"F10" = 67;
	pub const @"F11" = 68;
	pub const @"F12" = 69;
	pub const PRINTSCREEN = 70;
	pub const @"SCROLL-LOCK" = 71;
	pub const PAUSE = 72;
	pub const INSERT = 73;
	pub const HOME = 74;
	pub const PAGEUP = 75;
	pub const @"DELETE-FORWARD" = 76;
	pub const END = 77;
	pub const PAGEDOWN = 78;
	pub const RIGHTARROW = 79;
	pub const LEFTARROW = 80;
	pub const DOWNARROW = 81;
	pub const UPARROW = 82;
	pub const CLEAR = 83;
	pub const @"/" = 84;
	pub const @"-" = 86;
	pub const ENTER = 88;
	pub const @"5" = 93;
	pub const DELETE = 99;
	pub const LC = 224;
	pub const LS = 225;
	pub const LA = 226;
	pub const LCMD = 227;
	pub const RC = 228;
	pub const RS = 229;
	pub const RA = 230;
	pub const RCMD = 231;
};


pub const input = struct {
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
