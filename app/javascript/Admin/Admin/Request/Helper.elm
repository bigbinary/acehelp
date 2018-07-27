module Admin.Request.Helper exposing (..)

import Http
import Json.Decode exposing (Decoder)
import GraphQL.Client.Http exposing (RequestOptions)


type alias ApiKey =
    String


type alias Url =
    String


type alias NodeEnv =
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


baseUrl : NodeEnv -> Url
baseUrl env =
    case env of
        "production" ->
            "https://staging.acehelp.com/"

        "development" ->
            "http://localhost:3000/"

        _ ->
            "http://localhost:3000/"


defaultRequestHeaders : List Http.Header
defaultRequestHeaders =
    [ Http.header "Accept" "application/json, text/javascript, */*; q=0.01"
    , Http.header "X-Requested-With" "XMLHttpRequest"
    ]


requestOptions : NodeEnv -> ApiKey -> RequestOptions
requestOptions env apiKey =
    let
        headers =
            [ Http.header "api-key" apiKey
            ]

        url =
            graphqlUrl env
    in
        { method = "POST"
        , url = url
        , headers = headers
        , timeout = Nothing
        , withCredentials = False
        }


constructUrl : String -> List ( String, String ) -> String
constructUrl url params =
    case params of
        [] ->
            url

        _ ->
            url ++ "?" ++ String.join "&" (List.map (\( key, value ) -> Http.encodeUri key ++ "=" ++ value) params)


graphqlUrl : String -> String
graphqlUrl env =
    case env of
        "production" ->
            "https://staging.acehelp.com/graphql/"

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


logoutRequest : NodeEnv -> Http.Request String
logoutRequest env =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (baseUrl env) ++ "users/sign_out"
        , body = Http.emptyBody
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }
