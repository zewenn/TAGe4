const std = @import("std");
const print = std.debug.print;
const String = @import("./deps/zig-string.zig").String;
const Vec2 = @import("./deps/vectors.zig").Vec2;

pub const Item = struct {
    allocator: *std.mem.Allocator,

    name: String,
    description: String,

    health: i32,
    damage: i32,
    armour: i32,

    slot: u8,
    equipped: bool,

    pub fn init(allocator: *std.mem.Allocator, name: []const u8, description: []const u8, slot: u8) !Item {
        const new_name = try String.init_with_contents(allocator.*, name);
        const new_description = try String.init_with_contents(allocator.*, description);

        return .{
            .allocator = allocator,
            .name = new_name,
            .description = new_description,
            .health = 0,
            .damage = 0,
            .armour = 0,
            .slot = slot,
            .equipped = false,
        };
    }

    pub fn deinit(self: *Item) void {
        self.name.deinit();
        self.description.deinit();
    }
};

pub const Entity = struct {
    allocator: *std.mem.Allocator,

    name: String,

    position: Vec2,

    health: f32,
    max_health: f32,
    damage: u32,
    armour: u32,

    inventory: std.ArrayListAligned(Item, null),

    pub fn init(allocator: *std.mem.Allocator, name: []const u8) !Entity {
        const new_name = try String.init_with_contents(allocator.*, name);
        const inventory = std.ArrayList(Item).init(allocator.*);

        return .{
            .allocator = allocator,
            .name = new_name,
            .position = Vec2.init(0, 0),
            .health = 20,
            .max_health = 100,
            .armour = 0,
            .damage = 0,
            .inventory = inventory,
        };
    }

    pub fn deinit(self: *Entity) void {
        for (self.inventory.items) |it| {
            var item = @constCast(&it);
            item.deinit();
        }
        self.inventory.deinit();
        self.name.deinit();
    }
};
