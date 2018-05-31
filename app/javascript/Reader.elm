module Reader exposing (..)


type Reader ctx a
    = Reader (ctx -> a)


run : Reader ctx a -> ctx -> a
run (Reader f) ctx =
    f ctx


ask : Reader ctx ctx
ask =
    Reader identity


map : (a -> b) -> Reader ctx a -> Reader ctx b
map fn reader =
    Reader (\ctx -> fn (run reader ctx))


andThen : Reader ctx a -> (a -> Reader ctx b) -> Reader ctx b
andThen reader bindFn =
    Reader
        (\ctx ->
            run reader ctx
                |> bindFn
                |> (flip run) ctx
        )
