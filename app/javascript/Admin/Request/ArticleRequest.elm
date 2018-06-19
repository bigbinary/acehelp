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
        url =
            (articleListUrl env) ++ "?url=" ++ orgUrl

        headers =
            List.concat
                [ defaultRequestHeaders
                , [ (Http.header "api-key" apiKey) ]
                ]

        decoder =
            field "_id" JD.string
    in
        Http.request
            { method = "GET"
            , headers = headers
            , url = url
            , body = Http.emptyBody
            , expect = Http.expectJson articles
            , timeout = Nothing
            , withCredentials = False
            }


requestCreateArticle : NodeEnv -> ApiKey -> JE.Value -> Http.Request String
requestCreateArticle env apiKey body =
    let
        url =
            articleCreateUrl env

        headers =
            List.concat
                [ defaultRequestHeaders
                , [ Http.header "api-key" apiKey ]
                ]

        decoder =
            field "_id" JD.string
    in
        Http.request
            { method = "POST"
            , headers = headers
            , url = url
            , body = Http.jsonBody <| body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }
