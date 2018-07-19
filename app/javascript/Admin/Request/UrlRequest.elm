module Request.UrlRequest exposing (..)

import Http
import Json.Decode as JsonDecoder exposing (field)
import Json.Encode as JsonEncoder
import Request.RequestHelper exposing (..)
import Data.UrlData exposing (..)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


urlList : NodeEnv -> Url
urlList nodeEnv =
    (baseUrl nodeEnv) ++ "/url"


urlCreate : NodeEnv -> Url
urlCreate nodeEnv =
    (baseUrl nodeEnv) ++ "/url"


requestUrls : NodeEnv -> ApiKey -> Http.Request UrlsListResponse
requestUrls nodeEnv apiKey =
    let
        requestData =
            { method = "GET"
            , url = urlList nodeEnv
            , params = []
            , body = Http.emptyBody
            , nodeEnv = nodeEnv
            , organizationApiKey = apiKey
            }
    in
        httpRequest requestData urlListDecoder


requestUrlsQuery : GQLBuilder.SelectionSpec GQLBuilder.Field (List UrlData) vars
requestUrlsQuery =
    GQLBuilder.field "urls"
        []
        (GQLBuilder.list
            (GQLBuilder.object UrlData
                |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                |> GQLBuilder.with (GQLBuilder.field "url" [] GQLBuilder.string)
            )
        )


createUrl : NodeEnv -> ApiKey -> JsonEncoder.Value -> Http.Request String
createUrl nodeEnv apiKey body =
    let
        requestData =
            { method = "POST"
            , url = urlCreate nodeEnv
            , params = []
            , body = Http.jsonBody <| body
            , nodeEnv = nodeEnv
            , organizationApiKey = apiKey
            }

        decoder =
            JsonDecoder.field "_id" JsonDecoder.string
    in
        httpRequest requestData decoder


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
