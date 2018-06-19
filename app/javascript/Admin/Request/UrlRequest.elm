module Request.UrlRequest exposing (..)

import Http
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Request.RequestHelper exposing (..)
import Data.UrlData exposing (..)


urlList : NodeEnv -> Url
urlList nodeEnv =
    (baseUrl nodeEnv) ++ "/url"


urlCreate : NodeEnv -> Url
urlCreate nodeEnv =
    (baseUrl nodeEnv) ++ "/url"


requestUrls : NodeEnv -> ApiKey -> Http.Request UrlsListResponse
requestUrls nodeEnv apiKey =
    let
        headers =
            urlHeaders [ Http.header "api-key" apiKey ]
    in
        Http.request
            { method = "GET"
            , headers = headers
            , url = (urlList nodeEnv)
            , body = Http.emptyBody
            , expect = Http.expectJson urlListDecoder
            , timeout = Nothing
            , withCredentials = False
            }


createUrl : NodeEnv -> ApiKey -> JE.Value -> Http.Request String
createUrl nodeEnv apiKey body =
    let
        headers =
            urlHeaders [ Http.header "api-key" apiKey ]

        decoder =
            field "_id" JD.string
    in
        Http.request
            { method = "POST"
            , url = (urlCreate nodeEnv)
            , headers = headers
            , body = Http.jsonBody <| body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }
