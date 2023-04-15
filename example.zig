const std = @import("std");
const Allocator = std.mem.Allocator;

//const include_path = "/usr/include/postgresql";

// GET include path
// pkg-config --cflags libpq
// URL: https://www.postgresql.org/docs/current/libpq-build.html

const c = @cImport({
    @cInclude("/usr/include/postgresql/libpq-fe.h");
});

pub fn main() void {
  const allocator = std.heap.page_allocator;
  _ = allocator;

  // Initialize connection parameters
  const connection_string = "host=localhost port=5432 dbname=portal_cms_dev user=postgres password=root123";

  // Connect to the PostgreSQL database
  const conn = c.PQconnectdb(connection_string);
  defer c.PQfinish(conn);

  if (c.PQstatus(conn) == c.CONNECTION_BAD) {
      std.debug.print("Connection to PostgreSQL database failed: {s}\n", .{c.PQerrorMessage(conn)});
      return;
  }

  // Execute a simple SQL query
  const query = "SELECT * FROM features";
  const result = c.PQexec(conn, query);
  defer c.PQclear(result);

  if (c.PQresultStatus(result) != c.PGRES_TUPLES_OK) {
      std.debug.print("Failed to execute the query: {s}\n", .{c.PQerrorMessage(conn)});
      return;
  }

  // Print the query results
  const num_rows = c.PQntuples(result);
  
  const num_columns = c.PQnfields(result);
  //_ = num_columns;

  std.debug.print("{}, ", .{num_columns});

  var i: i32 = 0;
  while (i < num_rows) : (i += 1) {
    var j: i32 = 0;
    while (j < num_columns) : (j += 1) {
        const value = c.PQgetvalue(result, i, j);
        std.debug.print("{s}, ", .{@ptrCast([*c]const u8, value)});
    }
    std.debug.print("\n", .{});
  }
}
