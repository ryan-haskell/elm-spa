module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Navigation exposing (Key)
import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href)
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Url exposing (Url)



-- INIT


type alias Flags =
    ()


type alias Model =
    { url : Url
    , key : Key
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model url key
    , Cmd.none
    )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view :
    { page : Document msg, toMsg : Msg -> msg }
    -> Model
    -> Document msg
view { page, toMsg } model =
    { title = page.title
    , body =
        [ div [ css [ margin (px 20), fontFamily sansSerif ] ]
            [ header [ css [ displayFlex ] ]
                [ a [ css [ color (rgb 0 100 200), textDecoration underline, marginRight (px 20) ], href (Route.toString Route.Top) ] [ text "Homepage" ]
                , a [ css [ color (rgb 0 100 200), textDecoration underline ], href (Route.toString Route.NotFound) ] [ text "Not found" ]
                ]
            , div [ css [ marginTop (px 20) ] ] page.body
            ]
        ]
    }
