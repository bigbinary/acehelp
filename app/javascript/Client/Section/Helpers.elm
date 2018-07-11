module Section.Helpers exposing (..)

import Reader exposing (..)
import Request.Helpers exposing (..)


type alias SectionCmd msg =
    Maybe (Reader NodeEnv (Cmd msg))
