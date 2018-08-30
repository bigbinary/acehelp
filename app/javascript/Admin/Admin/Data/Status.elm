module Admin.Data.Status exposing (AvailabilitySatus(..), availablityStatusIso, reverseCurrentAvailabilityStatus)

import Monocle.Iso exposing (..)


type AvailabilitySatus
    = Active
    | Inactive


availablityStatusToString : AvailabilitySatus -> String
availablityStatusToString status =
    case status of
        Inactive ->
            "Inactive"

        Active ->
            "Active"


stringToAvailablityStatus : String -> AvailabilitySatus
stringToAvailablityStatus status =
    case status of
        "active" ->
            Active

        _ ->
            Inactive


availablityStatusIso : Iso AvailabilitySatus String
availablityStatusIso =
    Iso availablityStatusToString stringToAvailablityStatus


reverseCurrentAvailabilityStatus : String -> String
reverseCurrentAvailabilityStatus status =
    case status of
        "Active" ->
            "inactive"

        _ ->
            "active"
