module Request.Helpers exposing (apiUrl, constructUrl, httpGet, ApiKey, Url, QueryParameters, Context(..), NodeEnv)

import Http exposing (request, encodeUri, header, Header)
import Json.Decode exposing (Decoder)


import Http exposing (encodeUri)


-- Set True to access api calls from localhost


type alias Url =
    String


type alias NodeEnv =
    String


type alias QueryParameters =
    List ( String, String )


type Context
    = Context String
    | NoContext


type alias ApiKey =
    String


apiUrl : String -> String -> String
apiUrl env str =
    case env of
        "production" ->
            "https://staging.acehelp.com/api/v1/" ++ str

        _ ->
            -- If it is development environment or anything else fall back to local/relative api path
            "/api/v1/" ++ str


constructUrl : String -> List ( String, String ) -> String
constructUrl baseUrl queryParams =
    case queryParams of
        [] ->
            baseUrl

        _ ->
            baseUrl ++ "?" ++ String.join "&" (List.map (\( key, value ) -> encodeUri key ++ "=" ++ encodeUri value) queryParams)


httpGet : ApiKey -> Context -> Url -> QueryParameters -> Decoder a -> Http.Request a
httpGet apiKey context url queryParams decoder =
    let
        headers =
            List.concat
                [ defaultRequestHeaders
                , [ header "api-key" apiKey ]
                ]

        contextKeyValue =
            case context of
                Context value ->
                    [ ( "context", value ) ]

                NoContext ->
                    []

        callUrl =
            constructUrl url <| contextKeyValue ++ queryParams
    in
        request
            { method = "GET"
            , headers = headers
            , url = callUrl
            , body = Http.emptyBody
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


defaultRequestHeaders : List Header
defaultRequestHeaders =
    [ header "Accept" "application/json, text/javascript, */*; q=0.01"
    , header "X-Requested-With" "XMLHttpRequest"
    ]
