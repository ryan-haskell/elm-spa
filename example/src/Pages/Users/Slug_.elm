module Pages.Users.Slug_ exposing (Model, Msg, page)

import Application
import Html exposing (..)


type alias Model =
    { slug : String
    }


type Msg
    = Msg


page : Application.PageWithParams Model Msg a b String
page =
    Application.elementWithParams
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : String -> ( Model, Cmd Msg )
init slug =
    ( Model slug, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    h1 [] [ text ("New Element for: " ++ model.slug) ]
