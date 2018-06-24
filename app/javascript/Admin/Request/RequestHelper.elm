module Request.RequestHelper exposing (..)

import Http
import Json.Decode exposing (Decoder)


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
            ""

        _ ->
            ""


defaultRequestHeaders : List Http.Header
defaultRequestHeaders =
    [ Http.header "Accept" "application/json, text/javascript, */*; q=0.01"
    , Http.header "X-Requested-With" "XMLHttpRequest"
    ]


constructUrl : String -> List ( String, String ) -> String
constructUrl url params =
    case params of
        [] ->
            url

        _ ->
            url ++ "?" ++ String.join "&" (List.map (\( key, value ) -> Http.encodeUri key ++ "=" ++ value) params)


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
