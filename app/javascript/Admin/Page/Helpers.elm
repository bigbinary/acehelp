module Page.Helpers exposing (..)

import Reader exposing (..)
import Admin.Request.Helper exposing (..)


type alias PageCmd msg =
    Reader ( NodeEnv, ApiKey ) (Cmd msg)


pageCmdsToCmd : (a -> msg) -> NodeEnv -> ApiKey -> List (PageCmd a) -> Cmd msg
pageCmdsToCmd mapMsg nodeEnv apiKey cmds =
    Cmd.batch <|
        List.map
            (Cmd.map mapMsg
                << flip Reader.run ( nodeEnv, apiKey )
            )
            cmds
