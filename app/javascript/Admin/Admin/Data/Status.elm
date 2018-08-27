module Admin.Data.Status exposing (AvailabilitySatus(..), availablityStatusIso)

import Monocle.Iso exposing (..)


type AvailabilitySatus
    = Online
    | Offline


availablityStatusToString : AvailabilitySatus -> String
availablityStatusToString status =
    case status of
        Offline ->
            "Online"

        Online ->
            "Offline"


stringToAvailablityStatus : String -> AvailabilitySatus
stringToAvailablityStatus status =
    case status of
        "online" ->
            Online

        _ ->
            Offline


availablityStatusIso : Iso AvailabilitySatus String
availablityStatusIso =
    Iso availablityStatusToString stringToAvailablityStatus
