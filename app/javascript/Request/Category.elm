module Request.Category exposing (..)

import Http
import Data.Category exposing (Categories, decodeCategories)
import Request.Helpers exposing (..)


requestCategories : Http.Request Categories
requestCategories =
    -- Http.get "http://www.mocky.io/v2/5b06b0362f00004f00c61e7b" decodeCategories
    Http.get (apiUrl "all") decodeCategories
