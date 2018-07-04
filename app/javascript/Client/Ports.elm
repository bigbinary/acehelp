port module Ports exposing (..)


type alias UserInfo =
    { name : String
    , email : String
    }



-- INCOMING PORTS


port userInfo : (UserInfo -> msg) -> Sub msg



-- OUTGOING PORTS
