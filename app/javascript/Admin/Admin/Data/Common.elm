module Admin.Data.Common exposing (Option(..), Value, targetSelectedOptions)

import Json.Decode as Json
import Json.Decode.Extra as JsonEx


type alias Value =
    { id : String
    , value : String
    }


type Option a
    = Selected a
    | Unselected a


targetSelectedOptions : Json.Decoder (List String)
targetSelectedOptions =
    Json.at [ "target", "selectedOptions" ] <|
        JsonEx.collection <|
            Json.at [ "value" ] <|
                Json.string
