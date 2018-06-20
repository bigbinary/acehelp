module Section.ContactUs exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, id, type_, placeholder, style)


-- MODEL


type alias Model =
    { name : String
    , email : String
    , title : String
    , message : String
    }


init : Model
init =
    { name = ""
    , email = ""
    , title = ""
    , message = ""
    }



-- UPDATE
-- VIEW


view : Model -> Html msg
view model =
    div [ id "content-wrapper" ]
        [ div [ id "contact-us-wrapper" ]
            [ h2 [] [ text "Send us a message" ]
            , div [ class "contact-user" ]
                [ span [ class "contact-name" ] [ input [ type_ "text", placeholder "Your Name" ] [] ]
                , span [ class "contact-email" ] [ input [ type_ "text", placeholder "Your Email" ] [] ]
                ]
            , input [ type_ "text", class "contact-subject", placeholder "Subject" ] []
            , textarea [ placeholder "How can we help?" ] []
            , div [ class "regular-button", style [ ( "background-color", "rgb(60, 170, 249)" ) ] ] [ text "Send Message" ]
            ]
        ]
