module Data.Article exposing (..)

import Json.Decode exposing (int, string, float, nullable, list, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)

type alias Article =
  { id: Int
  , title: String
  , summary: String
  , content: String
  }

type alias ArticleShort =
  { id: Int
  , title: String
  , summary: String
  }

-- ENCODERS


-- DECODERS


decodeArticles: Decoder (List ArticleShort)
decodeArticles =
  list decodeArticleShort


decodeArticleShort : Decoder ArticleShort
decodeArticleShort =
  decode ArticleShort
    |> required "id" int
    |> required "title" string
    |> required "summary" string


decodeArticle : Decoder Article
decodeArticle =
  decode Article
    |> required "id" int
    |> required "title" string
    |> required "summary" string
    |> required "content" string