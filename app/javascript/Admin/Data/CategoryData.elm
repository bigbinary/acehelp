module Data.CategoryData exposing (..)

import Json.Decode as JD exposing (..)
import Json.Decode.Pipeline as Pipeline exposing (required, decode)


type alias CategoryId =
    Int


type alias Category =
    { id : CategoryId
    , name : String
    }


type alias CategoryList =
    { categories : List Category
    }


categoryDecoder : Decoder Category
categoryDecoder =
    decode Category
        |> required "id" int
        |> required "name" string


categoryListDecoder : Decoder CategoryList
categoryListDecoder =
    decode CategoryList
        |> required "categories" (list categoryDecoder)
