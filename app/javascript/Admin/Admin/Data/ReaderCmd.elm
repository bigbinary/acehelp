module Admin.Data.ReaderCmd exposing (..)

import Reader exposing (..)
import Admin.Request.Helper exposing (..)


type ReaderCmd msg
    = Strict (Reader ( NodeEnv, ApiKey ) (Cmd msg))
    | Open (Reader NodeEnv (Cmd msg))


map : (Cmd msg -> Cmd msg1) -> ReaderCmd msg -> ReaderCmd msg1
map fn readerCmd =
    case readerCmd of
        Strict reader ->
            Strict <| Reader.map fn reader

        Open reader ->
            Open <| Reader.map fn reader


readerCmdToCmd : NodeEnv -> ApiKey -> (a -> msg) -> List (ReaderCmd a) -> Cmd msg
readerCmdToCmd nodeEnv apiKey mapMsg cmds =
    Cmd.batch <|
        List.map
            (\cmd ->
                case cmd of
                    Strict reader ->
                        Cmd.map mapMsg <|
                            Reader.run reader ( nodeEnv, apiKey )

                    Open reader ->
                        Cmd.map mapMsg <|
                            Reader.run reader nodeEnv
            )
            cmds
