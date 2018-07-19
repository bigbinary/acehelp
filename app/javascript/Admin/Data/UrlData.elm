module Data.UrlData exposing (..)

import Json.Decode as JD exposing (..)
import Json.Decode.Pipeline as Pipeline exposing (decode, required, optional)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


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


requestUrlsQuery : GQLBuilder.Document GQLBuilder.Query (List UrlData) vars
requestUrlsQuery =
    GQLBuilder.queryDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "urls"
                []
                (GQLBuilder.list
                    (GQLBuilder.object UrlData
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "url" [] GQLBuilder.string)
                    )
                )
            )


createUrlMutation : GQLBuilder.Document GQLBuilder.Mutation UrlData CreateUrlInput
createUrlMutation =
    let
        urlVar =
            Var.required "url" .url Var.string
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract <|
                GQLBuilder.field "url"
                    [ ( "url", Arg.variable urlVar ) ]
                    (GQLBuilder.object UrlData
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "url" [] GQLBuilder.string)
                    )
