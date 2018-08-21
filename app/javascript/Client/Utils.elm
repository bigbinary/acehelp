module Utils exposing (..)

import Navigation


getUrlPathData : Navigation.Location -> String
getUrlPathData =
    .href
