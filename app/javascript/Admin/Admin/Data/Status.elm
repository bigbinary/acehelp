module Admin.Data.Status exposing (AvailabilitySatus(..), availablityStatusIso)

import Monocle.Iso exposing (..)


type AvailabilitySatus
    = Active
    | Inactive


reverseAvailablityStatusToString : AvailabilitySatus -> String
reverseAvailablityStatusToString status =
    case status of
        Inactive ->
            "Active"

        Active ->
            "Inactive"


stringToAvailablityStatus : String -> AvailabilitySatus
stringToAvailablityStatus status =
    case status of
        "active" ->
            Active

        _ ->
            Inactive


availablityStatusIso : Iso AvailabilitySatus String
availablityStatusIso =
    Iso reverseAvailablityStatusToString stringToAvailablityStatus
