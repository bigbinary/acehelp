module Data.CategoryData exposing (..)

import Json.Decode as JD exposing (..)
import Json.Decode.Pipeline as Pipeline exposing (required, decode)


type alias CategoryId =
    String


type alias CategoryName =
    String


type alias Category =
    { id : CategoryId
    , name : CategoryName
    }


type alias CategoryList =
    { categories : List Category
    }


type alias CreateCategoryInputs =
    { name : CategoryName
    }


categoryDecoder : Decoder Category
categoryDecoder =
    decode Category
        |> required "id" string
        |> required "name" string


categoryListDecoder : Decoder CategoryList
categoryListDecoder =
    decode CategoryList
        |> required "categories" (list categoryDecoder)
