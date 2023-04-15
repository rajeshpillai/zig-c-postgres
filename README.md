# Zig Postgres C
Using postgres c library with zig

# Important 
I have hardcoded  the include path of libpq-fe.h

```
const postgres_include_path = "/usr/include/postgresql/"; 
const c = @cImport({
    @cInclude(postgres_include_path ++ "libpq-fe.h");
});

```

# Connecton string
Update the connection string in demo/demo.zig

```
const connection_string = "host=localhost port=5432 dbname=portal_cms_dev user=postgres password=root123";
```

# Helpful commands
If you want to know where the libpq-fe.h is installed you can run the below command assuming postgres and related dependencies are installed.

```
pkg-config --cflags libpq
```

# References
URL: https://www.postgresql.org/docs/current/libpq-build.html


Please change this to work for your.  Will try to remove hardcoding.


# Run the demo with DB wrapper

```
zig run demo/demo.zig -lc -lpq
```





