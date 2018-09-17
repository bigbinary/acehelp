module Admin.Data.ReaderCmd exposing (ReaderCmd(..), map, navigateTo, readerCmdToCmd)

import Admin.Request.Helper exposing (..)
import Browser.Navigation exposing (Key, pushUrl)
import Reader exposing (..)
import Route exposing (..)


type ReaderCmd msg
    = Strict (Reader ( NodeEnv, ApiKey, AppUrl ) (Cmd msg))
    | Open (Reader ( NodeEnv, AppUrl ) (Cmd msg))
    | InternalRedirect (Reader ( Key, ApiKey ) (Cmd msg))
    | Unit (Reader () (Cmd msg))


map : (Cmd msg -> Cmd msg1) -> ReaderCmd msg -> ReaderCmd msg1
map fn readerCmd =
    case readerCmd of
        Strict reader ->
            Strict <| Reader.map fn reader

        Open reader ->
            Open <| Reader.map fn reader

        InternalRedirect reader ->
            InternalRedirect <| Reader.map fn reader

        Unit reader ->
            Unit <| Reader.map fn reader


readerCmdToCmd : Key -> NodeEnv -> ApiKey -> AppUrl -> (a -> msg) -> List (ReaderCmd a) -> Cmd msg
readerCmdToCmd navKey nodeEnv apiKey appUrl mapMsg cmds =
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

                    InternalRedirect reader ->
                        Cmd.map mapMsg <|
                            Reader.run reader ( navKey, apiKey )

                    Unit reader ->
                        Cmd.map mapMsg <|
                            Reader.run reader ()
            )
            cmds


navigateTo : (ApiKey -> Route) -> ReaderCmd msg
navigateTo route =
    InternalRedirect <| Reader.Reader (\( navKey, orgKey ) -> pushUrl navKey <| routeToString <| route orgKey)
