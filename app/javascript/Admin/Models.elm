module Models exposing (..)


type alias Model =
    { organization : Organization
    }


initialModel : Model
initialModel =
    { organization = Organization "1" "Sam"
    }


type alias OrganizationId =
    String


type alias Organization =
    { id : OrganizationId
    , name : String
    }
