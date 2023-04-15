const std = @import("std");

const c = @cImport({
    @cInclude("/usr/include/postgresql/libpq-fe.h");
});

pub const Database = struct {
    conn: *c.PGconn,

    pub fn connect(connectionString: []const u8) !Database {
      const conn = c.PQconnectdb(connectionString.ptr);
      if (conn == null) {
          return error.ConnectionFailed;
      }

      if (c.PQstatus(conn) == c.CONNECTION_BAD) {
          defer c.PQfinish(conn);
          return error.ConnectionFailed;
      }

      return Database{ .conn = conn.? };
   }

    pub fn isConnected(self: *Database) bool {
        return c.PQstatus(self.conn) != c.CONNECTION_BAD;
    }

    pub fn errorMessage(self: *Database) []const u8 {
        return std.mem.spanZ(c.PQerrorMessage(self.conn));
    }


    pub fn query(self: *Database, sql: []const u8) !std.ArrayList([]const u8) {
        const result = c.PQexec(self.conn, sql.ptr);
        defer c.PQclear(result);

        if (c.PQresultStatus(result) != c.PGRES_TUPLES_OK) {
            return error.QueryFailed;
        }

        var rows = std.ArrayList([]const u8).init(std.heap.page_allocator);
        const num_rows = c.PQntuples(result);
        const num_columns = c.PQnfields(result);

        // Add header row
        {
            var header_builder = std.ArrayList(u8).init(std.heap.page_allocator);
            defer header_builder.deinit();

            var j: i32 = 0;
            while (j < num_columns) : (j += 1) {
                const field_name = c.PQfname(result, j);
                const field_name_str = std.mem.span(@ptrCast([*c]const u8, field_name));
                try header_builder.appendSlice(field_name_str);
                if (j < num_columns - 1) {
                    try header_builder.append(',');
                }
            }
            const header_str = header_builder.toOwnedSlice();
            try rows.append(header_str);
        }

        // Add data rows
        var i: i32 = 0;
        while (i < num_rows) : (i += 1) {
            var row_builder = std.ArrayList(u8).init(std.heap.page_allocator);
            defer row_builder.deinit();

            var j: i32 = 0;
            while (j < num_columns) : (j += 1) {
                const value = c.PQgetvalue(result, i, j);
                const value_str = std.mem.span(@ptrCast([*c]const u8, value));
                try row_builder.appendSlice(value_str);
                if (j < num_columns - 1) {
                    try row_builder.append(',');
                }
            }
            const row_str = row_builder.toOwnedSlice();
            try rows.append(row_str);
        }

        return rows;
    }


    pub fn query2(self: *Database, sql: []const u8) !std.ArrayList([]const u8) {
      const result = c.PQexec(self.conn, sql.ptr);
      defer c.PQclear(result);

      if (c.PQresultStatus(result) != c.PGRES_TUPLES_OK) {
          return error.QueryFailed;
      }

      var rows = std.ArrayList([]const u8).init(std.heap.page_allocator);
      const num_rows = c.PQntuples(result);
      const num_columns = c.PQnfields(result);

      var i: i32 = 0;
      while (i < num_rows) : (i += 1) {
          var row_builder = std.ArrayList(u8).init(std.heap.page_allocator);
          defer row_builder.deinit();

          var j: i32 = 0;
          while (j < num_columns) : (j += 1) {
              const value = c.PQgetvalue(result, i, j);
              const value_str = std.mem.span(@ptrCast([*c]const u8, value));
              try row_builder.appendSlice(value_str);
              if (j < num_columns - 1) {
                  try row_builder.append(',');
              }
          }
          const row_str = row_builder.toOwnedSlice();
          try rows.append(row_str);
      }

      return rows;
    }

    pub fn close(self: *Database) void {
        c.PQfinish(self.conn);
    }
};
