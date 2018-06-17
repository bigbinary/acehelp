module Organization.Show exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Msgs exposing (Msg)
import Models exposing (..)


view : Model -> Html Msg
view model =
    div [ class "p2" ]
        [ table []
            [ thead []
                [ tr []
                    [ th [] [ text "Id" ]
                    , th [] [ text "Name" ]
                    ]
                ]
            , tbody [] ([ organizationRow model.organization ])
            ]
        ]


organizationRow : Organization -> Html Msg
organizationRow organization =
    tr []
        [ td [] [ text organization.id ]
        , td [] [ text organization.name ]
        ]
