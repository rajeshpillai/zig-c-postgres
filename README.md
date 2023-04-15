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

Please change this to work for your.  Will try to remove hardcoding.


# Run the demo with DB wrapper

```
zig run demo/demo.zig -lc -lpq
```





