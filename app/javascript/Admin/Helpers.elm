module Helpers exposing (..)

import Time exposing (Time)
import Task exposing (Task)
import Process exposing (..)
import Field.ValidationResult exposing (..)
import Regex exposing (Regex)


validateEmpty : String -> String -> ValidationResult String String
validateEmpty fieldName fieldValue =
    case fieldValue of
        "" ->
            Failed <| fieldName ++ " cannot be empty"

        _ ->
            Passed fieldValue


validateEmail : String -> ValidationResult String String
validateEmail s =
    case (Regex.contains validEmail s) of
        True ->
            Passed s

        False ->
            Failed "Please enter a valid email"


validEmail : Regex
validEmail =
    Regex.regex "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        |> Regex.caseInsensitive


delayedTask : Time -> msg -> Task x msg
delayedTask time msg =
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)



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
