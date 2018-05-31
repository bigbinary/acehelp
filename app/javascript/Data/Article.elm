module Data.Article exposing (..)

import Json.Decode exposing (int, string, float, nullable, list, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)

type alias ArticleId = Int

type alias Article =
  { id: ArticleId
  , title: String
  , summary: String
  , content: String
  }

type alias ArticleSummary =
  { id: ArticleId
  , title: String
  }

-- ENCODERS


-- DECODERS


decodeArticles: Decoder (List ArticleSummary)
decodeArticles =
  list decodeArticleSummary


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
    |> required "summary" string
    |> required "content" string
