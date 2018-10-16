port module Ports exposing
    ( UserInfo
    , closeWidget
    , decodeUserInfo
    , insertArticleContent
    , onUrlChange
    , openArticle
    , openWidget
    , userInfo
    )

import Data.Article exposing (ArticleId)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode exposing (Value)


type alias UserInfo =
    { name : String
    , email : String
    }



-- INCOMING PORTS


port userInfo : (Value -> msg) -> Sub msg


port openArticle : (ArticleId -> msg) -> Sub msg


port openWidget : (() -> msg) -> Sub msg


port closeWidget : (() -> msg) -> Sub msg


port onUrlChange : (String -> msg) -> Sub msg



-- OUTGOING PORTS


port insertArticleContent : String -> Cmd msg



-- DECODERS


decodeUserInfo : Value -> UserInfo
decodeUserInfo userInfoValue =
    let
        decoder =
            Decode.succeed UserInfo
                |> optional "name" Decode.string ""
                |> optional "email" Decode.string ""

        result =
            Decode.decodeValue decoder userInfoValue
    in
    case result of
        Ok dUserInfo ->
            dUserInfo

        Err _ ->
            { name = "", email = "" }
