module Page.Error exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode exposing (string)
import Json.Decode.Pipeline exposing (decode, required)


-- MODEL


type alias ApiErrorMessage =
    { error : String }


type alias Model =
    Http.Error



-- UPDATE
-- VIEW


view : Model -> Html msg
view error =
    let
        ( text1, text2, text3 ) =
            case error of
                Http.BadUrl message ->
                    ( "OOPS!", "That should not have happend!", "" )

                Http.Timeout ->
                    ( "OOPS!", "Looks like your request timedout!", "" )

                Http.NetworkError ->
                    ( "UH OH!", "The network did not respond nicely!", "" )

                Http.BadPayload debugMsg response ->
                    ( "OOPS!", "Something went wrong!", debugMsg )

                Http.BadStatus response ->
                    let
                        apiMessage =
                            decode ApiErrorMessage
                                |> Json.Decode.Pipeline.required "error" string
                    in
                        ( toString response.status.code, response.status.message, "" )
    in
        div [ id "something-went-wrong" ]
            [ div [ class "error" ] []
            , div [ class "text text1" ] [ text text1 ]
            , div [ class "text text2" ] [ text text2 ]
            , div [ class "text text3" ] [ text text3 ]
            ]
