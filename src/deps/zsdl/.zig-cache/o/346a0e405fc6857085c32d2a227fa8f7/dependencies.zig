pub const packages = struct {
    pub const @"1220930ce0d568bd606112d38c3f16a38841a5fd9de5c224f627cd953e7febb90bfa" = struct {
        pub const available = true;
        pub const build_root = "/Users/zoltantakacs/.cache/zig/p/1220930ce0d568bd606112d38c3f16a38841a5fd9de5c224f627cd953e7febb90bfa";
        pub const build_zig = @import("1220930ce0d568bd606112d38c3f16a38841a5fd9de5c224f627cd953e7febb90bfa");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "sdl2-prebuilt", "1220930ce0d568bd606112d38c3f16a38841a5fd9de5c224f627cd953e7febb90bfa" },
};
