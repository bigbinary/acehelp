module Admin.Request.Helper exposing (..)

import Http
import Json.Decode exposing (Decoder)
import Admin.Data.Session exposing (Token)
import GraphQL.Client.Http as GQLClient exposing (RequestOptions)
import GraphQL.Request.Builder as GQLBuilder
import Dict
import Reader exposing (Reader)
import Task exposing (Task)


type alias ApiKey =
    String


type alias Url =
    String


type alias NodeEnv =
    String


type alias AppUrl =
    String


type alias QueryParameters =
    List ( String, String )


type alias MethodType =
    String


type alias RequestData =
    { method : MethodType
    , url : Url
    , params : QueryParameters
    , body : Http.Body
    , nodeEnv : NodeEnv
    , organizationApiKey : ApiKey
    }


baseUrl : NodeEnv -> AppUrl -> Url
baseUrl env appUrl =
    case env of
        "production" ->
            case String.isEmpty <| appUrl of
                True ->
                    "https://staging.acehelp.com/"

                False ->
                    "https://" ++ appUrl ++ ".herokuapp.com"

        "development" ->
            "http://localhost:3000/"

        _ ->
            "http://localhost:3000/"


defaultRequestHeaders : List Http.Header
defaultRequestHeaders =
    [ Http.header "Accept" "application/json, text/javascript, */*; q=0.01"
    , Http.header "X-Requested-With" "XMLHttpRequest"
    ]


requestOptionsWithToken : Maybe Token -> NodeEnv -> ApiKey -> AppUrl -> RequestOptions
requestOptionsWithToken reqTokens env apiKey appUrl =
    let
        headers =
            [ Http.header "api-key" apiKey
            ]

        finalHeaders =
            Maybe.map
                (\tokens ->
                    List.append
                        [ Http.header "uid" tokens.uid
                        , Http.header "access_token" tokens.access_token
                        ]
                        headers
                )
                reqTokens
                |> Maybe.withDefault headers

        url =
            graphqlUrl env appUrl
    in
        { method = "POST"
        , url = url
        , headers = finalHeaders
        , timeout = Nothing
        , withCredentials = False
        }


requestOptions : NodeEnv -> ApiKey -> AppUrl -> RequestOptions
requestOptions =
    requestOptionsWithToken Nothing


constructUrl : String -> List ( String, String ) -> String
constructUrl url params =
    case params of
        [] ->
            url

        _ ->
            url
                ++ "?"
                ++ String.join "&"
                    (List.map
                        (\( key, value ) ->
                            Http.encodeUri key ++ "=" ++ value
                        )
                        params
                    )


graphqlUrl : NodeEnv -> AppUrl -> String
graphqlUrl env appUrl =
    case env of
        "production" ->
            case String.isEmpty <| appUrl of
                True ->
                    "https://staging.acehelp.com/graphql/"

                False ->
                    "https://" ++ appUrl ++ ".herokuapp.com/graphql"

        _ ->
            "/graphql/"


httpRequest : RequestData -> Decoder a -> Http.Request a
httpRequest requestData decoder =
    let
        headers =
            List.concat
                [ defaultRequestHeaders
                , [ Http.header "api-key" requestData.organizationApiKey ]
                ]

        callUrl =
            constructUrl requestData.url requestData.params
    in
        Http.request
            { method = requestData.method
            , headers = headers
            , url = constructUrl requestData.url requestData.params
            , body = requestData.body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


logoutRequest : NodeEnv -> AppUrl -> Http.Request String
logoutRequest env appUrl =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (baseUrl env appUrl) ++ "users/sign_out"
        , body = Http.emptyBody
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }


strictContextBuilder gqlRequest =
    (\( tokens, nodeEnv, apiKey, appUrl ) ->
        gqlRequest
            |> GQLClient.customSendQueryRaw (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl)
            |> Task.andThen
                (\response ->
                    let
                        decoder =
                            GQLBuilder.responseDataDecoder gqlRequest
                                |> Json.Decode.field "data"
                    in
                        case Json.Decode.decodeString decoder response.body of
                            Err err ->
                                Task.fail <| GQLClient.HttpError <| Http.BadPayload err response

                            Ok decodedValue ->
                                Task.succeed
                                    ( { access_token = Dict.get "access_token" response.headers
                                      , uid = Dict.get "uid" response.headers
                                      }
                                    , decodedValue
                                    )
                )
    )
