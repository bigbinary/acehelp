module Data.Category exposing (..)

import Json.Decode exposing (int, string, float, nullable, list, dict, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Data.Article exposing (ArticleSummary, decodeArticleSummary)


type alias CategoryId =
    String


type alias Category =
    { id : CategoryId
    , name : String
    , articles : List ArticleSummary
    }


type alias Categories =
    { categories : List Category }



-- ENCODERS
-- DECODERS


decodeCategories : Decoder Categories
decodeCategories =
    decode Categories
        |> required "categories" decodeCategoryList


decodeCategoryList : Decoder (List Category)
decodeCategoryList =
    list decodeCategory


decodeCategory : Decoder Category
decodeCategory =
    decode Category
        |> required "id" string
        |> required "name" string
        |> required "articles" (list decodeArticleSummary)
