module Admin.Data.ReaderCmd exposing (..)

import Reader exposing (..)
import Admin.Request.Helper exposing (..)


type ReaderCmd msg
    = Strict (Reader ( NodeEnv, ApiKey, AppUrl ) (Cmd msg))
    | Open (Reader ( NodeEnv, AppUrl ) (Cmd msg))


map : (Cmd msg -> Cmd msg1) -> ReaderCmd msg -> ReaderCmd msg1
map fn readerCmd =
    case readerCmd of
        Strict reader ->
            Strict <| Reader.map fn reader

        Open reader ->
            Open <| Reader.map fn reader


readerCmdToCmd : NodeEnv -> ApiKey -> AppUrl -> (a -> msg) -> List (ReaderCmd a) -> Cmd msg
readerCmdToCmd nodeEnv apiKey appUrl mapMsg cmds =
    Cmd.batch <|
        List.map
            (\cmd ->
                case cmd of
                    Strict reader ->
                        Cmd.map mapMsg <|
                            Reader.run reader ( nodeEnv, apiKey, appUrl )

                    Open reader ->
                        Cmd.map mapMsg <|
                            Reader.run reader ( nodeEnv, appUrl )
            )
            cmds
