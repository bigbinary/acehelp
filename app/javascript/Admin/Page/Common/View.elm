module Page.Common.View exposing (..)

import Data.CommonData exposing (Error)


renderError : Error -> String
renderError error =
    if (error == Nothing) then
        ""
    else
        "Error : " ++ (toString error)
