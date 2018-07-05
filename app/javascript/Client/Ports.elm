port module Ports exposing (..)

import Json.Encode exposing (Value)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)


type alias UserInfo =
    { name : String
    , email : String
    }



-- INCOMING PORTS


port userInfo : (Value -> msg) -> Sub msg



-- OUTGOING PORTS
-- DECODERS


decodeUserInfo : Value -> UserInfo
decodeUserInfo userInfoValue =
    let
        decoder =
            decode UserInfo
                |> optional "name" Decode.string ""
                |> optional "email" Decode.string ""

        result =
            Decode.decodeValue decoder userInfoValue
    in
        case result of
            Ok userInfo ->
                userInfo

            Err _ ->
                { name = "", email = "" }
