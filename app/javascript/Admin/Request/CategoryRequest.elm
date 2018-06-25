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
        requestData =
            { method = "GET"
            , params = []
            , url = categoryListUrl env
            , body = Http.emptyBody
            , nodeEnv = env
            , organizationApiKey = apiKey
            }
    in
        httpRequest requestData categoryListDecoder
