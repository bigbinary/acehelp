module Request.Category exposing (..)

import Http
import Task exposing (Task)
import Reader exposing (Reader)
import Data.Category exposing (Categories, decodeCategories)
import Request.Helpers exposing (..)


requestCategories : Reader ( NodeEnv, ApiKey ) (Task Http.Error Categories)
requestCategories =
    -- Http.get "http://www.mocky.io/v2/5b06b0362f00004f00c61e7b" decodeCategories
    Reader.Reader (\( env, apiKey ) -> Http.toTask (httpGet apiKey NoContext (apiUrl env "all") [] decodeCategories))
