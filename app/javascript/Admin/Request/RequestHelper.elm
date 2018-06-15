module Request.RequestHelper exposing (..)

import Http


type alias ApiKey =
    String


type alias Url =
    String


type alias NodeEnv =
    String


baseUrl : NodeEnv -> Url
baseUrl env =
    case env of
        "production" ->
            "https://staging.acehelp.com/"

        _ ->
            ""


urlHeaders : List Http.Header -> List Http.Header
urlHeaders headers =
    List.concat
        [ defaultRequestHeaders
        , headers
        ]


defaultRequestHeaders : List Http.Header
defaultRequestHeaders =
    [ Http.header "Accept" "application/json, text/javascript, */*; q=0.01"
    , Http.header "X-Requested-With" "XMLHttpRequest"
    ]
