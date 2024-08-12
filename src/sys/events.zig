const std = @import("std");

const map_fn_type = *const fn () void;
const map_fn_struct_type = struct { func: map_fn_type };
const map_type = std.StringHashMap(std.ArrayListAligned(map_fn_struct_type, null));

const events = struct {
    var event_map: map_type = undefined;
    var allocator_ptr: *std.mem.Allocator = undefined;

    pub fn init(allocator: *std.mem.Allocator) void {
        event_map = map_type.init(allocator.*);
        allocator_ptr = allocator;
    }

    pub fn deinit() void {
        var iterator = event_map.keyIterator();

        while (iterator.next()) |item| {
            const arr = event_map.get(item.*);
            if (arr != null) arr.?.deinit();

            _ = event_map.remove(item.*);
        }
        event_map.deinit();
    }

    pub fn on(comptime id: []const u8, comptime func: map_fn_type) !void {
        const data = event_map.get(id);

        if (data == null) {
            var new_array = std.ArrayList(map_fn_struct_type).init(allocator_ptr.*);
            try new_array.append(map_fn_struct_type{ .func = func });
            try event_map.put(id, new_array);
            return;
        }

        try @constCast(&data.?).append(map_fn_struct_type{ .func = func });
        return;
    }

    pub fn call(comptime id: []const u8) !void {
        const data = event_map.get(id);

        if (data == null) {
            return;
        }

        for (data.?.items) |func_struct| {
            func_struct.func();
        }
    }

    pub fn delete(comptime id: []const u8) !void {
        _ = event_map.remove(id);
    }
};
