module Helpers exposing (..)

import Time exposing (Time)
import Task exposing (Task)
import Process exposing (..)
import Field.ValidationResult exposing (..)


validateEmpty : String -> String -> ValidationResult String String
validateEmpty fieldName fieldValue =
    case fieldValue of
        "" ->
            Failed <| fieldName ++ " cannot be empty"

        _ ->
            Passed fieldValue


delayedTask : Time -> msg -> Task x Id
delayedTask time msg =
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)
        |> Process.spawn



-- Natrual transformations


maybeToBool : Maybe a -> Bool
maybeToBool maybe =
    case maybe of
        Just _ ->
            True

        Nothing ->
            False


stringToMaybe : String -> Maybe String
stringToMaybe str =
    case String.isEmpty str of
        True ->
            Nothing

        False ->
            Just str
