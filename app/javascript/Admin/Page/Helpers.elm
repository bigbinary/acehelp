module Page.Helpers exposing (..)

import Reader exposing (..)
import Request.Helpers exposing (..)


type alias PageCmd msg =
    Maybe (Reader ( NodeEnv, ApiKey ) (Cmd msg))
