module Request.Category exposing (..)

import Http
import Data.Category exposing (Categories, decodeCategories)
import Request.Helpers exposing (..)


requestCategories : Http.Request Categories
requestCategories =
    -- Http.get "https://www.mocky.io/v2/5afd46c63200005f00f1ab39" decodeArticles
    -- Http.get "http://www.mocky.io/v2/5b06b0362f00004f00c61e7b" decodeCategories
    Http.get (apiUrl "all") decodeCategories
