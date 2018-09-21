module Request.Helpers exposing
    ( ApiErrorMessage
    , ApiKey
    , Context(..)
    , NodeEnv
    , QueryParameters
    , Url
    , apiUrl
    , constructUrl
    , contextToMaybe
    , defaultRequestHeaders
    , graphqlUrl
    , httpGet
    , httpPost
    , requestOptions
    )

import GraphQL.Client.Http exposing (RequestOptions)
import Http exposing (Header, header, request)
import Json.Decode exposing (Decoder)


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


type alias ApiErrorMessage =
    { error : String }


contextToMaybe : Context -> Maybe String
contextToMaybe context =
    case context of
        Context value ->
            Just value

        _ ->
            Nothing


apiUrl : String -> String -> String
apiUrl env str =
    case env of
        "production" ->
            "https://staging.acehelp.com/api/v1/" ++ str

        _ ->
            "/api/v1/" ++ str


graphqlUrl : String -> String
graphqlUrl env =
    case env of
        "production" ->
            "https://staging.acehelp.com/graphql/"

        _ ->
            "/graphql/"


requestOptions : NodeEnv -> ApiKey -> RequestOptions
requestOptions nodeEnv apiKey =
    let
        headers =
            [ Http.header "api-key" apiKey
            ]

        url =
            graphqlUrl nodeEnv
    in
    { method = "POST"
    , headers = headers
    , url = url
    , timeout = Nothing
    , withCredentials = False
    }


constructUrl : String -> List ( String, String ) -> String
constructUrl baseUrl queryParams =
    case queryParams of
        [] ->
            baseUrl

        -- NOTE: since we do not decode server side at the moment - removed encodeUri for value part of query parameter to get things working
        _ ->
            baseUrl
                ++ "?"
                ++ String.join "&"
                    (List.map
                        (\( key, value ) ->
                            key ++ "=" ++ value
                        )
                        queryParams
                    )


httpGet : ApiKey -> Context -> Url -> QueryParameters -> Decoder a -> Http.Request a
httpGet apiKey context url queryParams decoder =
    let
        -- NOTE: This should not be hardcoded or needed at all. It is right now hardcoded since this is the only entry we have in db
        tempBase =
            "http://aceinvoice.com"

        headers =
            List.concat
                [ defaultRequestHeaders
                , [ header "api-key" apiKey ]
                ]

        contextKeyValue =
            case context of
                Context value ->
                    [ ( "url", tempBase ++ value ) ]

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


httpPost : ApiKey -> Url -> Http.Body -> Decoder a -> Http.Request a
httpPost apiKey url body decoder =
    let
        headers =
            List.concat
                [ defaultRequestHeaders
                , [ header "api-key" apiKey ]
                ]

        callUrl =
            constructUrl url []
    in
    request
        { method = "POST"
        , headers = headers
        , url = callUrl
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


defaultRequestHeaders : List Header
defaultRequestHeaders =
    [ header "Accept" "application/json, text/javascript, */*; q=0.01"
    , header "X-Requested-With" "XMLHttpRequest"
    ]
