module Request.CategoryRequest exposing (..)

import Http
import Data.CategoryData exposing (..)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Request.RequestHelper exposing (..)


categoryListUrl : NodeEnv -> Url
categoryListUrl env =
    (baseUrl env) ++ "/api/v1/all"


requestCategories : NodeEnv -> ApiKey -> Http.Request CategoryList
requestCategories env apiKey =
    let
        url =
            categoryListUrl env

        headers =
            List.concat
                [ defaultRequestHeaders
                , [ Http.header "api-key" apiKey ]
                ]
    in
        Http.request
            { method = "GET"
            , url = url
            , headers = headers
            , body = Http.emptyBody
            , expect = Http.expectJson categoryListDecoder
            , timeout = Nothing
            , withCredentials = False
            }
