const std = @import("std");
const windows = std.os.windows;
const z = @import("../../z.zig");

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

    var stdin: windows.HANDLE = undefined;
    var stdout: windows.HANDLE = undefined;

    var keymap_buffer: []bool = undefined;
    var keymap_buffer_last_frame: []bool = undefined;

    var alloc: *Allocator = undefined;

    const utf8_codepage: c_uint = 65001;

    var initial_input_mode: windows.DWORD = undefined;
    var initial_output_mode: windows.DWORD = undefined;
    var initial_output_codepage: c_uint = undefined;

    /// Copied form https://github.com/rockorager/libvaxis/blob/main/src/windows/Tty.zig
    const Modes = struct {
        pub const Input = struct {
            const enable_window_input: u32 = 0x0008; // resize events
            const enable_mouse_input: u32 = 0x0010;
            const enable_extended_flags: u32 = 0x0080; // allows mouse events

            pub fn rawMode() u32 {
                return enable_window_input | enable_mouse_input | enable_extended_flags;
            }
        };

        pub const Output = struct {
            const enable_processed_output: u32 = 0x0001; // handle control sequences
            const enable_virtual_terminal_processing: u32 = 0x0004; // handle ANSI sequences
            const disable_newline_auto_return: u32 = 0x0008; // disable inserting a new line when we write at the last column
            const enable_lvb_grid_worldwide: u32 = 0x0010; // enables reverse video and underline

            fn rawMode() u32 {
                return enable_processed_output |
                    enable_virtual_terminal_processing |
                    disable_newline_auto_return |
                    enable_lvb_grid_worldwide;
            }
        };
    };

    fn _init(allocator: *Allocator) void {
        alloc = allocator;

        keymap_buffer = alloc.alloc(bool, std.math.maxInt(u8)) catch unreachable;
        keymap_buffer_last_frame = alloc.alloc(bool, std.math.maxInt(u8)) catch unreachable;

        stdin = windows.GetStdHandle(windows.STD_INPUT_HANDLE) catch @panic("Failed to get windows stdin");
        stdout = windows.GetStdHandle(windows.STD_OUTPUT_HANDLE) catch @panic("Failed to get windows stdout");

        initial_output_codepage = windows.kernel32.GetConsoleOutputCP();
        {
            if (windows.kernel32.GetConsoleMode(stdin, &initial_input_mode) == windows.FALSE) {
                z.panic(@intFromEnum(windows.kernel32.GetLastError()));
            }
            if (windows.kernel32.GetConsoleMode(stdout, &initial_output_mode) == windows.FALSE) {
                z.panic(@intFromEnum(windows.kernel32.GetLastError()));
            }
        }

        {
            if (windows.kernel32.SetConsoleMode(
                stdin,
                Modes.Input.rawMode(),
            ) == 0)
                z.panic(windows.kernel32.GetLastError());

            if (windows.kernel32.SetConsoleMode(
                stdout,
                Modes.Output.rawMode(),
            ) == 0)
                z.panic(windows.kernel32.GetLastError());

            if (windows.kernel32.SetConsoleOutputCP(utf8_codepage) == 0)
                z.panic(windows.kernel32.GetLastError());
        }
        // _ = c.setmode(c.STDIN_FILENO, c.O_RAW);
    }

    fn _update() void {
        @memcpy(keymap_buffer_last_frame, keymap_buffer);
        if (c.kbhit() != 0) _ = c.getch();
    }

    fn _deinit() void {
        alloc.free(keymap_buffer);
        alloc.free(keymap_buffer_last_frame);

        _ = windows.kernel32.SetConsoleOutputCP(initial_output_codepage);
        _ = windows.kernel32.SetConsoleMode(stdin, initial_input_mode);
        _ = windows.kernel32.SetConsoleMode(stdout, initial_output_mode);
        windows.CloseHandle(stdin);
        windows.CloseHandle(stdout);
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

    pub fn get() Inputter {
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
