module Request.Category exposing (..)

import Http
import Data.Category exposing (Categories, decodeCategories)
import Request.Helpers exposing (..)


requestCategories : NodeEnv -> ApiKey -> Context -> Http.Request Categories
requestCategories env apiKey context =
    -- Http.get "http://www.mocky.io/v2/5b06b0362f00004f00c61e7b" decodeCategories
    httpGet apiKey context (apiUrl env "all") [] decodeCategories
