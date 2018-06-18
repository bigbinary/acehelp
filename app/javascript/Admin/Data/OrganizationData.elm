module Data.OrganizationData exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline as Pipeline exposing (decode, hardcoded, optional, required)


type alias OrganizationId =
    Int


type alias Organization =
    { id : OrganizationId
    , name : String
    }


type alias OrganizationResponse =
    { organization : Organization
    }


organization : Decoder OrganizationResponse
organization =
    decode OrganizationResponse
        |> required "organization" (organizationDecoder)


organizationDecoder : Decoder Organization
organizationDecoder =
    decode Organization
        |> required "id" int
        |> required "name" string
