path = Temp.path!()
{:ok, db} = Exqlite.Sqlite3.open(path)

:ok =
  Exqlite.Sqlite3.execute(db, "create table users (id integer primary key, name text)")

Enum.each(1..10_000, fn i ->
  :ok =
    Exqlite.Sqlite3.execute(
      db,
      "insert into users (id, name) values (#{i}, 'User-#{i}')"
    )
end)

:ok = Exqlite.Sqlite3.close(db)

Benchee.run(%{
  "old_fetch_all" => fn ->
    {:ok, db} = Exqlite.Sqlite3.open(path)

    {:ok, statement} =
      Exqlite.Sqlite3.prepare(
        db,
        "select * from users"
      )

    {:ok, _rows} = Exqlite.Sqlite3.old_fetch_all(db, statement)
  end,
  "new_fetch_all" => fn ->
    {:ok, db} = Exqlite.Sqlite3.open(path)

    {:ok, statement} =
      Exqlite.Sqlite3.prepare(
        db,
        "select * from users"
      )

    {:ok, _rows} = Exqlite.Sqlite3.fetch_all(db, statement)
  end
})

File.rm(path)
