module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import Internals.Utils as Utils
import TransitionStuff


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { state : TransitionStuff.State Page
    , delay : Int
    }


type Page
    = Homepage
    | About
    | Contact


type Msg
    = NavigateTo Page


init : flags -> ( Model, Cmd Msg )
init _ =
    let
        state =
            { visibility = TransitionStuff.Invisible, page = Homepage }

        { cmd, delay } =
            TransitionStuff.transition delaysForPage
                { delay = 0
                , msg = NavigateTo
                , target = Homepage
                , state = state
                }
    in
    ( { delay = delay, state = state }
    , cmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavigateTo target ->
            let
                state =
                    TransitionStuff.nextState target model.state

                { cmd, delay } =
                    TransitionStuff.transition delaysForPage
                        { delay = model.delay
                        , msg = NavigateTo
                        , target = target
                        , state = state
                        }
            in
            ( { model | state = state, delay = delay }
            , cmd
            )


delaysForPage : Page -> TransitionStuff.Animations
delaysForPage page =
    case page of
        Homepage ->
            { entering = 200
            , exiting = 200
            }

        About ->
            { entering = 200
            , exiting = 200
            }

        Contact ->
            { entering = 200
            , exiting = 200
            }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    div
        [ Attr.style "transition" ("opacity " ++ String.fromInt model.delay ++ "ms ease-in-out")
        , Attr.style "opacity"
            (if model.state.visibility == TransitionStuff.Visible then
                "1"

             else
                "0"
            )
        ]
        [ p [] (List.map viewButton [ Homepage, About, Contact ])
        , p [] [ text (Debug.toString model.state.page) ]
        ]


viewButton : Page -> Html Msg
viewButton page =
    button
        [ Events.onClick (NavigateTo page) ]
        [ text (Debug.toString page) ]
