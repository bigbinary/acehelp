module Admin.Request.Helper exposing
    ( ApiKey
    , AppUrl
    , MethodType
    , NodeEnv
    , QueryParameters
    , RequestData
    , Url
    , baseUrl
    , constructUrl
    , defaultRequestHeaders
    , graphqlUrl
    , httpRequest
    , logoutRequest
    , requestOptions
    )

import GraphQL.Client.Http as GQLClient exposing (RequestOptions)
import Http
import Json.Decode exposing (Decoder)


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
    appUrl


defaultRequestHeaders : List Http.Header
defaultRequestHeaders =
    [ Http.header "Accept" "application/json, text/javascript, */*; q=0.01"
    , Http.header "X-Requested-With" "XMLHttpRequest"
    ]


requestOptions : NodeEnv -> ApiKey -> AppUrl -> RequestOptions
requestOptions env apiKey appUrl =
    let
        headers =
            [ Http.header "api-key" apiKey
            ]

        url =
            graphqlUrl env appUrl
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
            url
                ++ "?"
                ++ String.join "&"
                    (List.map
                        (\( key, value ) ->
                            key ++ "=" ++ value
                        )
                        params
                    )


graphqlUrl : NodeEnv -> AppUrl -> String
graphqlUrl env appUrl =
    "/graphql_execution/dashboard"


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
        , headers = defaultRequestHeaders
        , url = baseUrl env appUrl ++ "/users/sign_out"
        , body = Http.emptyBody
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }
