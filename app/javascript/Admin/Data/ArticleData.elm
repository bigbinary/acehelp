module Data.ArticleData exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline as Pipeline exposing (decode, hardcoded, optional, required)


type alias ArticleId =
    String


type alias Article =
    { id : ArticleId
    , title : String
    , desc : String
    }


type alias ArticleSummary =
    { id : ArticleId
    , title : String
    }


type alias ArticleListResponse =
    { articles : List Article
    }


articles : Decoder ArticleListResponse
articles =
    decode ArticleListResponse
        |> required "articles" (list articlesDecoder)


articlesDecoder : Decoder Article
articlesDecoder =
    decode Article
        |> required "id" string
        |> required "title" string
        |> required "desc" string


decodeArticles : Decoder (List ArticleSummary)
decodeArticles =
    list decodeArticleSummary


decodeArticleSummary : Decoder ArticleSummary
decodeArticleSummary =
    decode ArticleSummary
        |> required "id" string
        |> required "title" string
