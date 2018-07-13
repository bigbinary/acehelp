module Data.Organization exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline as Pipeline exposing (decode, hardcoded, optional, required)
import Data.ArticleData exposing (ArticleSummary, decodeArticleSummary)


type alias OrganizationId =
    String


type alias Organization =
    { id : OrganizationId
    , name : String
    }


type alias OrganizationResponse =
    { organization : Organization
    , articles : List ArticleSummary
    }


organization : Decoder OrganizationResponse
organization =
    decode OrganizationResponse
        |> required "organization" (organizationDecoder)
        |> required "articles" (list decodeArticleSummary)


organizationDecoder : Decoder Organization
organizationDecoder =
    decode Organization
        |> required "id" string
        |> required "name" string
