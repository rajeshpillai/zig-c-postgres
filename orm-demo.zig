const std = @import("std");
const Database = @import("lib/database.zig").Database;
const Model = @import("lib/postgres_orm.zig").Model;

pub fn main() void {
    const connection_string = "host=localhost port=5432 dbname=portal_cms_dev user=postgres password=root123";
    
    const db_result = Database.connect(connection_string) catch |err| {
        std.debug.print("Connection to PostgreSQL database failed: {}\n", .{err});
        return;
    };
    var db = db_result;

    const select_result = db.query("SELECT * FROM apps") catch |err| {
        std.debug.print("Failed to execute the query: {}\n", .{err});
        db.close();
        return;
    };

    for (select_result.items) |row| {
        std.debug.print("{s}\n", .{row});
    }

    // Insert a new row
    // Model.create(&db, "apps", "name", "'App 2'") catch |err| {
    //     std.debug.print("Failed to insert row: {}\n", .{err});
    // };

    Model.create(&db, "apps", "name, user_id", "'App 2', 1") catch |err| {
        std.debug.print("Failed to insert row: {}\n", .{err});
    };

    Model.create(&db, "apps", "name, user_id", "'App 4', 1") catch |err| {
        std.debug.print("Failed to insert row: {}\n", .{err});
    };

    Model.create(&db, "apps", "name, user_id", "'App 5', 1") catch |err| {
        std.debug.print("Failed to insert row: {}\n", .{err});
    };

    // Update an existing row
    Model.update(&db, "apps", "name = 'App 5.1'", "name = 'App 2'") catch |err| {
        std.debug.print("Failed to update row: {}\n", .{err});
    };

    // Delete a row
    Model.delete(&db, "apps", "name = 'App 3'") catch |err| {
        std.debug.print("Failed to delete row: {}\n", .{err});
    };

    db.close();
}
