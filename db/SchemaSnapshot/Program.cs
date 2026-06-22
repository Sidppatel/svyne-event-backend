using System.Text.Json;
using Npgsql;

if (args.Length < 1)
{
    Console.Error.WriteLine("usage: SchemaSnapshot <output.json> [schema1,schema2,...]");
    return 1;
}

var outputPath = args[0];
var includedSchemas = args.Length >= 2
    ? args[1].Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
    : new[] { "public", "extensions" };

var connStr = Environment.GetEnvironmentVariable("DATABASE_URL")
    ?? "Host=localhost;Port=5432;Database=event_platform;Username=ep_dev;Password=ep_dev_password";

if (connStr.StartsWith("postgres://") || connStr.StartsWith("postgresql://"))
{
    var uri = new Uri(connStr);
    var userInfo = uri.UserInfo.Split(':');
    connStr = $"Host={uri.Host};Port={uri.Port};Database={uri.AbsolutePath.TrimStart('/')};Username={userInfo[0]};Password={userInfo[1]};SSL Mode=Require;Trust Server Certificate=true";
}

await using var conn = new NpgsqlConnection(connStr);
await conn.OpenAsync();

var schemaList = string.Join(",", includedSchemas.Select(s => $"'{s.Replace("'", "''")}'"));
Console.WriteLine($"[snapshot] filtering to schemas: {string.Join(", ", includedSchemas)}");

var snapshot = new Dictionary<string, object>
{
    ["extensions"] = await Query(conn,
        "SELECT extname AS name FROM pg_extension WHERE extname NOT IN ('plpgsql') ORDER BY extname"),
    ["schemas"] = await Query(conn,
        $"SELECT schema_name AS name FROM information_schema.schemata WHERE schema_name IN ({schemaList}) ORDER BY schema_name"),
    ["tables"] = await Query(conn, $"""
        SELECT table_schema AS schema, table_name AS name
        FROM information_schema.tables
        WHERE table_type = 'BASE TABLE'
          AND table_schema IN ({schemaList})
        ORDER BY table_schema, table_name
        """),
    ["columns"] = await Query(conn, $"""
        SELECT table_schema AS schema, table_name AS table_name, column_name AS name,
               data_type, is_nullable, column_default, ordinal_position
        FROM information_schema.columns
        WHERE table_schema IN ({schemaList})
        ORDER BY table_schema, table_name, ordinal_position
        """),
    ["constraints"] = await Query(conn, $"""
        SELECT n.nspname AS schema, conrelid::regclass::text AS table_ref,
               conname AS name, contype::text AS type,
               pg_get_constraintdef(c.oid) AS definition
        FROM pg_constraint c
        JOIN pg_namespace n ON n.oid = c.connamespace
        WHERE n.nspname IN ({schemaList})
        ORDER BY n.nspname, conrelid::regclass::text, conname
        """),
    ["indexes"] = await Query(conn, $"""
        SELECT schemaname AS schema, tablename AS table_name, indexname AS name, indexdef AS definition
        FROM pg_indexes
        WHERE schemaname IN ({schemaList})
        ORDER BY schemaname, tablename, indexname
        """),
    ["views"] = await Query(conn, $"""
        SELECT schemaname AS schema, viewname AS name, definition
        FROM pg_views
        WHERE schemaname IN ({schemaList})
        ORDER BY schemaname, viewname
        """),
    ["functions"] = await Query(conn, $"""
        SELECT n.nspname AS schema, p.proname AS name,
               pg_get_function_identity_arguments(p.oid) AS args,
               pg_get_function_result(p.oid) AS result_type,
               l.lanname AS language
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        JOIN pg_language l ON l.oid = p.prolang
        WHERE n.nspname IN ({schemaList})
        ORDER BY n.nspname, p.proname, pg_get_function_identity_arguments(p.oid)
        """),
    ["enum_types"] = await Query(conn, $"""
        SELECT n.nspname AS schema, t.typname AS name,
               array_agg(e.enumlabel ORDER BY e.enumsortorder) AS values
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        JOIN pg_enum e ON e.enumtypid = t.oid
        WHERE n.nspname IN ({schemaList})
        GROUP BY n.nspname, t.typname
        ORDER BY n.nspname, t.typname
        """),
};

var json = JsonSerializer.Serialize(snapshot, new JsonSerializerOptions { WriteIndented = true });
await File.WriteAllTextAsync(outputPath, json);
Console.WriteLine($"[snapshot] wrote {outputPath}");

var counts = new Dictionary<string, int>();
foreach (var (k, v) in snapshot)
{
    counts[k] = ((List<Dictionary<string, object?>>)v).Count;
}
Console.WriteLine($"[snapshot] counts: {string.Join(", ", counts.Select(kv => $"{kv.Key}={kv.Value}"))}");

return 0;

static async Task<List<Dictionary<string, object?>>> Query(NpgsqlConnection conn, string sql)
{
    var rows = new List<Dictionary<string, object?>>();
    await using var cmd = new NpgsqlCommand(sql, conn);
    await using var reader = await cmd.ExecuteReaderAsync();
    while (await reader.ReadAsync())
    {
        var row = new Dictionary<string, object?>();
        for (var i = 0; i < reader.FieldCount; i++)
        {
            var name = reader.GetName(i);
            var value = reader.IsDBNull(i) ? null : reader.GetValue(i);
            if (value is Array arr)
            {
                value = arr.Cast<object>().ToArray();
            }
            row[name] = value;
        }
        rows.Add(row);
    }
    return rows;
}
