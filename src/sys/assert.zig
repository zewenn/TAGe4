

pub fn assert(statement: bool, comptime msg: []const u8) void {
    if (!statement) {
        @panic(msg);
    }
}