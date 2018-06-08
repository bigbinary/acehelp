module Data.Article exposing (..)

import Json.Decode exposing (int, string, float, nullable, list, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)


type alias ArticleId =
    Int


type alias ArticleListResponse =
    { articles : List ArticleSummary }


type alias ArticleResponse =
    { article : Article }


type alias Article =
    { id : ArticleId
    , title : String
    , content : String
    }


type alias ArticleSummary =
    { id : ArticleId
    , title : String
    }



-- ENCODERS
-- DECODERS


decodeArticles : Decoder ArticleListResponse
decodeArticles =
    decode ArticleListResponse
        |> required "articles" (list decodeArticleSummary)


decodeArticleSummary : Decoder ArticleSummary
decodeArticleSummary =
    decode ArticleSummary
        |> required "id" int
        |> required "title" string


decodeArticle : Decoder Article
decodeArticle =
    decode Article
        |> required "id" int
        |> required "title" string
        |> required "desc" string


decodeArticleResponse : Decoder ArticleResponse
decodeArticleResponse =
    decode ArticleResponse
        |> required "article" decodeArticle
