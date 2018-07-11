module Data.Common exposing (..)


type alias GQLError =
    { message : String }


type alias GQLErrors =
    { errors : List GQLError
    }
