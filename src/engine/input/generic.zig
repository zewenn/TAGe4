const std = @import("std");
const builtin = @import("builtin");

// ================================================
//
//                       TYPES
//
// ================================================

const Allocator = @import("std").mem.Allocator;
const OSNotSupportedError = error{ OSNotSupported, NoDefaultGiven };

// ================================================
//
//                     INPUTTER
//
// ================================================

/// The interface for handling input.
/// Implementation varies based on platforms.
pub const Inputter = struct {
    /// Heap allocated array of booleans corresponding to keycodes.
    /// When an element of the array is `true`, the key is pressed.
    keymap: *[]bool,

    /// The appropriate set of keycodes bound to a lookup-struct.
    keys: KeyCodes,

    /// Returns the current state of the key; `true` if the key is pressed
    /// `false` if not.
    getKey: *const fn (?u8) bool,

    /// Only returns `true` if the queried key wasn't pressed during the last
    /// `update()` call and it is now.
    getKeyDown: *const fn (?u8) bool,

    /// Only returns `true` if the queried key was pressed during the last
    /// `update()` call and it isn't now.
    getKeyUp: *const fn (?u8) bool,

    /// Allocates heap memory for the `keymap` and initalises the platform
    /// specific handlers
    init: *const fn (*Allocator) void,

    /// Free the `keymap` and deinitalises all platform specific handles
    deinit: *const fn () void,

    /// This function needs to run every tick to maintain cross-platform
    /// keypress detection.
    update: *const fn () void,
};

// ================================================
//
//                     KEYCODES
//
// ================================================

/// The KeyCodes interface.
/// Contains a binding for each unicode key.
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

// ================================================
//
//                     OUT-FNs
//
// ================================================

fn Setting(comptime T: type) type {
    return struct {
        const Self = @This();

        use_default: bool = false,
        override_correct: bool = false,
        default: ?T = null,

        pub fn use(self: *Self) OSNotSupportedError!T {
            if (!self.use_default) return OSNotSupportedError.OSNotSupported;
            if (self.default == null) return OSNotSupportedError.NoDefaultGiven;
            return self.default.?;
        }
    };
}

pub inline fn getInputter(settings: Setting(Inputter)) OSNotSupportedError!Inputter {
    if (settings.override_correct) return @constCast(&settings).use();

    return switch (@import("builtin").target.os.tag) {
        .windows => @import("./os_inputs/win.zig").WindowsInputter.get(),
        .macos => @import("./os_inputs/osx.zig").OsXInputter.get(),
        else => @constCast(&settings).use(),
    };
}

/// **DEPRECATED**, `KeyCodes` are now bound to `Inputter`s
pub inline fn getKeyCodes(settings: Setting(KeyCodes)) OSNotSupportedError!KeyCodes {
    if (settings.override_correct) return @constCast(&settings).use();

    return switch (@import("builtin").target.os.tag) {
        .windows => @import("./os_inputs/.generics.zig").ASCIIKeyCodes,
        .macos => @import("./os_inputs/osx.zig").OsXInputter,
        else => @constCast(&settings).use(),
    };
}
