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


createUrl : NodeEnv -> ApiKey -> JE.Value -> Http.Request String
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
            field "_id" JD.string
    in
        httpRequest requestData decoder
