module Page.Organization.Display exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Request.OrganizationRequest exposing (..)
import Data.ArticleData exposing (ArticleSummary)
import Data.Organization exposing (..)
import Request.Helpers exposing (NodeEnv)


-- Model


type alias Model =
    { organization : OrganizationResponse
    , error : Maybe String
    }


initModel : Model
initModel =
    { organization = { organization = Organization 1 "Not Found", articles = [] }
    , error = Nothing
    }


init : NodeEnv -> OrganizationId -> ( Model, Cmd Msg )
init env organizationId =
    ( initModel, (fetchOrganization env organizationId) )



-- Update


type Msg
    = FetchOrganization
    | OrganizationLoaded (Result Http.Error OrganizationResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OrganizationLoaded (Ok organization) ->
            ( { model | organization = organization }, Cmd.none )

        OrganizationLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- View


view : Model -> Html msg
view model =
    div [ id "content-wrapper" ]
        [ h1 [] [ text model.organization.organization.name ]
        , div [] (renderArticles model.organization.articles)
        ]


renderArticle : ArticleSummary -> Html msg
renderArticle article =
    let
        children =
            [ li [] [ text article.title ]
            ]
    in
        ul [] children


renderArticles : List ArticleSummary -> List (Html msg)
renderArticles articles =
    List.map renderArticle articles


fetchOrganization : NodeEnv -> OrganizationId -> Cmd Msg
fetchOrganization env organiztionId =
    let
        request =
            requestOrganization env "" organiztionId

        cmd =
            Http.send OrganizationLoaded request
    in
        cmd
