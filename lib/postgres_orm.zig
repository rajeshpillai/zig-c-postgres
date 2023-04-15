const std = @import("std");
const Database = @import("database.zig").Database;

pub const Model = struct {
    pub fn create(db: *Database, table: []const u8, fields: []const u8, values: []const u8) !void {
        const query = try std.fmt.allocPrint(std.heap.page_allocator, "INSERT INTO {s} ({s}) VALUES ({s});", .{ table, fields, values });
        std.debug.print("query: {s}", .{query});

        defer std.heap.page_allocator.free(query);
        _ = try db.execute(query);
    }

    pub fn read(db: *Database, table: []const u8, fields: []const u8, conditions: ?[]const u8) !std.ArrayList([]const u8) {
        const query = if (conditions) |_| try std.fmt.allocPrint(std.heap.page_allocator, "SELECT {s} FROM {s} WHERE {s};", .{ fields, table, conditions.? })
        else |_| try std.fmt.allocPrint(std.heap.page_allocator, "SELECT {s} FROM {s};", .{ fields, table });
        defer std.heap.page_allocator.free(query);
        return try db.query(query);
    }

    pub fn update(db: *Database, table: []const u8, updates: []const u8, conditions: []const u8) !void {
        const query = try std.fmt.allocPrint(std.heap.page_allocator, "UPDATE {s} SET {s} WHERE {s};", .{ table, updates, conditions });
        defer std.heap.page_allocator.free(query);

        std.debug.print("query: {s}", .{query});
        _ = try db.execute(query);
    }

    pub fn delete(db: *Database, table: []const u8, conditions: []const u8) !void {
        const query = try std.fmt.allocPrint(std.heap.page_allocator, "DELETE FROM {s} WHERE {s};", .{ table, conditions });
        defer std.heap.page_allocator.free(query);
        std.debug.print("query: {s}", .{query});

        _ = try db.execute(query);
    }
};
