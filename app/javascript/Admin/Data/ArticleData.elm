module Data.ArticleData exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline as Pipeline exposing (decode, hardcoded, optional, required)


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


type alias ArticleListResponse =
    { id : Int
    , title : String
    , desc : String
    }


articles : Decoder (List ArticleListResponse)
articles =
    list articlesDecoder


articlesDecoder : Decoder ArticleListResponse
articlesDecoder =
    decode ArticleListResponse
        |> Pipeline.required "id" int
        |> Pipeline.required "title" string
        |> Pipeline.required "desc" string
        |> at [ "articles" ]


decodeArticles : Decoder (List ArticleSummary)
decodeArticles =
    list decodeArticleSummary


decodeArticleSummary : Decoder ArticleSummary
decodeArticleSummary =
    decode ArticleSummary
        |> required "id" int
        |> required "title" string
