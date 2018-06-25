module Request.ArticleRequest exposing (..)

import Http
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Request.RequestHelper exposing (..)
import Data.ArticleData as AD exposing (..)


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
            }
    in
        httpRequest env apiKey requestData articles


requestCreateArticle : NodeEnv -> ApiKey -> JE.Value -> Http.Request String
requestCreateArticle env apiKey body =
    let
        requestData =
            { url = articleCreateUrl env
            , method = "POST"
            , params = []
            , body = Http.jsonBody <| body
            }

        decoder =
            field "_id" JD.string
    in
        httpRequest env apiKey requestData decoder
