module Admin.Data.Common exposing (..)

import Json.Decode as Json
import Json.Decode.Extra as JsonEx


type alias Value =
    { id : String
    , value : String
    }


type Option a
    = Selected a
    | Unselected a


type alias NotificationElement =
    { text : String
    , messageType : String
    }


targetSelectedOptions : Json.Decoder (List String)
targetSelectedOptions =
    Json.at [ "target", "selectedOptions" ] <|
        JsonEx.collection <|
            Json.at [ "value" ] <|
                Json.string
