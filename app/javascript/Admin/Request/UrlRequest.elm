module Request.UrlRequest exposing (..)

import Http
import Json.Decode as JsonDecoder exposing (field)
import Json.Encode as JsonEncoder
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
            field "_id" JsonDecoder.string
    in
        httpRequest requestData decoder
