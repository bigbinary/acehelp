module Request.ArticleRequest exposing (..)

import Http
import Json.Decode as JsonDecoder exposing (field)
import Json.Encode as JsonEncoder
import Request.RequestHelper exposing (..)
import Data.ArticleData exposing (..)


articleListUrl : NodeEnv -> Url
articleListUrl env =
    (baseUrl env) ++ "/article"


articleCreateUrl : NodeEnv -> Url
articleCreateUrl env =
    (baseUrl env) ++ "/article"


requestArticles : NodeEnv -> Url -> ApiKey -> Http.Request ArticleListResponse
requestArticles env orgUrl apiKey =
    let
        requestData =
            { method = "GET"
            , url = articleListUrl env
            , params =
                [ ( "url", orgUrl )
                ]
            , body = Http.emptyBody
            , nodeEnv = env
            , organizationApiKey = apiKey
            }
    in
        httpRequest requestData articles


requestCreateArticle : NodeEnv -> ApiKey -> JsonEncoder.Value -> Http.Request String
requestCreateArticle env apiKey body =
    let
        requestData =
            { url = articleCreateUrl env
            , method = "POST"
            , params = []
            , body = Http.jsonBody <| body
            , nodeEnv = env
            , organizationApiKey = apiKey
            }

        decoder =
            field "_id" JsonDecoder.string
    in
        httpRequest requestData decoder
