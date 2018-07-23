module Page.Common.View exposing (..)


renderError : Maybe String -> String
renderError error =
    if (error == Nothing) then
        ""
    else
        "Error : " ++ (toString error)
