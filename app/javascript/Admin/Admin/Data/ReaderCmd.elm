module Admin.Data.ReaderCmd exposing (..)

import Reader exposing (..)
import Admin.Request.Helper exposing (..)
import Admin.Data.Session exposing (Token)


type ReaderCmd msg
    = Strict (Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Cmd msg))
    | SemiStrict (Reader ( Token, NodeEnv, AppUrl ) (Cmd msg))
    | Open (Reader ( NodeEnv, AppUrl ) (Cmd msg))


map : (Cmd msg -> Cmd msg1) -> ReaderCmd msg -> ReaderCmd msg1
map fn readerCmd =
    case readerCmd of
        Strict reader ->
            Strict <| Reader.map fn reader

        SemiStrict reader ->
            SemiStrict <| Reader.map fn reader

        Open reader ->
            Open <| Reader.map fn reader


readerCmdToCmd : Token -> NodeEnv -> ApiKey -> AppUrl -> (a -> msg) -> List (ReaderCmd a) -> Cmd msg
readerCmdToCmd tokens nodeEnv apiKey appUrl mapMsg cmds =
    Cmd.batch <|
        List.map
            (\cmd ->
                case cmd of
                    Strict reader ->
                        Cmd.map mapMsg <|
                            Reader.run reader ( tokens, nodeEnv, apiKey, appUrl )

                    SemiStrict reader ->
                        Cmd.map mapMsg <|
                            Reader.run reader ( tokens, nodeEnv, appUrl )

                    Open reader ->
                        Cmd.map mapMsg <|
                            Reader.run reader ( nodeEnv, appUrl )
            )
            cmds
