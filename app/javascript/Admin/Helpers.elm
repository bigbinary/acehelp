module Helpers exposing
    ( flip
    , maybeToBool
    , maybeToList
    , stringToMaybe
    , unless
    , validEmail
    , validUrl
    , validateEmail
    , validateEmpty
    , validateUrl
    , when
    )

import Field.ValidationResult exposing (..)
import Process exposing (..)
import Regex exposing (Regex)
import Task exposing (Task)


validateEmpty : String -> String -> ValidationResult String String
validateEmpty fieldName fieldValue =
    case fieldValue of
        "" ->
            Failed <| fieldName ++ " cannot be empty"

        _ ->
            Passed fieldValue


validateEmail : String -> ValidationResult String String
validateEmail s =
    case Regex.contains validEmail s of
        True ->
            Passed s

        False ->
            Failed "Please enter a valid email"


validEmail : Regex
validEmail =
    Regex.fromStringWith { caseInsensitive = True, multiline = False }
        "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        |> Maybe.withDefault Regex.never


validateUrl : String -> ValidationResult String String
validateUrl s =
    case Regex.contains validUrl s of
        True ->
            Passed s

        False ->
            Failed "Please enter a valid Url"


validUrl : Regex
validUrl =
    Regex.fromStringWith { caseInsensitive = True, multiline = False }
        "^(?:http(s)?:\\/\\/)?[\\w.-]+(?:\\.[\\w\\.-]+)+[\\w\\-\\._~:/?#[\\]@!\\$&'\\(\\)\\*\\+,;=.]+$"
        |> Maybe.withDefault Regex.never



-- Natural transformations


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


flip : (a -> b -> c) -> b -> a -> c
flip function arg1 arg2 =
    function arg2 arg1


maybeToList : Maybe a -> List a
maybeToList maybe =
    case maybe of
        Just a ->
            [ a ]

        Nothing ->
            []


when : (a -> Bool) -> (a -> a) -> a -> a
when predFunc runFunc input =
    case predFunc input of
        True ->
            runFunc input

        False ->
            input


unless : (a -> Bool) -> (a -> a) -> a -> a
unless predFunc runFunc input =
    case predFunc input of
        True ->
            input

        False ->
            runFunc input
