module Helpers exposing (..)

import Time exposing (Time)
import Task
import Process
import Field.ValidationResult exposing (..)


validateEmpty : String -> String -> ValidationResult String String
validateEmpty fieldName fieldValue =
    case fieldValue of
        "" ->
            Failed <| fieldName ++ " cannot be empty"

        _ ->
            Passed fieldValue


delayedCmd : Time -> msg -> Cmd msg
delayedCmd time msg =
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity
