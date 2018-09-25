module Admin.Data.Status exposing (AvailabilityStatus(..), availablityStatusIso, reverseCurrentAvailabilityStatus)

import Monocle.Iso exposing (..)


type AvailabilityStatus
    = Active
    | Inactive


availablityStatusToString : AvailabilityStatus -> String
availablityStatusToString status =
    case status of
        Inactive ->
            "Inactive"

        Active ->
            "Active"


stringToAvailablityStatus : String -> AvailabilityStatus
stringToAvailablityStatus status =
    case status of
        "active" ->
            Active

        _ ->
            Inactive


availablityStatusIso : Iso AvailabilityStatus String
availablityStatusIso =
    Iso availablityStatusToString stringToAvailablityStatus


reverseCurrentAvailabilityStatus : String -> String
reverseCurrentAvailabilityStatus status =
    case status of
        "Active" ->
            "inactive"

        _ ->
            "active"
