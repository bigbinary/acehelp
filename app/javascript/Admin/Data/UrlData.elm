module Data.UrlData exposing (..)

import Json.Decode as JD exposing (..)
import Json.Decode.Pipeline as Pipeline exposing (decode, required, optional)


type alias UrlId =
    String


type alias UrlData =
    { id : UrlId
    , url : String
    }


type alias CreateUrlInput =
    { url : String
    }


type alias UrlsListResponse =
    { urls : List UrlData
    }


urlDecoder : Decoder UrlData
urlDecoder =
    decode UrlData
        |> required "id" string
        |> required "url" string


urlListDecoder : Decoder UrlsListResponse
urlListDecoder =
    decode UrlsListResponse
        |> required "urls" (list urlDecoder)
