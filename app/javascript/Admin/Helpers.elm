module Helpers exposing (..)

import Field.ValidationResult exposing (..)


validateEmpty : String -> String -> ValidationResult String String
validateEmpty fieldName fieldValue =
    case fieldValue of
        "" ->
            Failed <| fieldName ++ " cannot be empty"

        _ ->
            Passed fieldValue
