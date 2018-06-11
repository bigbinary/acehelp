module Data.ArticleData exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required)


type alias ArticleId =
    Int


type alias Article =
    { id : ArticleId
    , title : String
    , content : String
    , keywords : List String
    }


type alias ArticleSummary =
    { id : ArticleId
    , title : String
    }


decodeArticles : Decoder (List ArticleSummary)
decodeArticles =
    list decodeArticleSummary


decodeArticleSummary : Decoder ArticleSummary
decodeArticleSummary =
    decode ArticleSummary
        |> required "id" int
        |> required "title" string
