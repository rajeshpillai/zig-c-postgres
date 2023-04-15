const std = @import("std");
const Database = @import("database.zig").Database;

pub fn main() void {
    const connection_string = "host=localhost port=5432 dbname=portal_cms_dev user=postgres password=root123";
    const db_result = Database.connect(connection_string) catch |err| {
        std.debug.print("Connection to PostgreSQL database failed: {}\n", .{err});
        return;
    };
    var db = db_result;

    const select_result = db.query("SELECT * FROM features") catch |err| {
        std.debug.print("Failed to execute the query: {}\n", .{err});
        db.close();
        return;
    };

    for (select_result.items) |row| {
        std.debug.print("{s}\n", .{row});
    }

    db.close();
}
