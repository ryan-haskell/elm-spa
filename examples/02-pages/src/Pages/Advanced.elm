module Pages.Advanced exposing (Model, Msg, page)

import Effect exposing (Effect)
import Gen.Params.Advanced exposing (Params)
import Html
import Html.Events as Events
import Page
import Request
import Shared
import UI
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init
        , update = update
        , view = view shared
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    {}


init : ( Model, Effect Msg )
init =
    ( {}, Effect.none )



-- UPDATE


type Msg
    = IncrementShared
    | DecrementShared


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        IncrementShared ->
            ( model
            , Effect.fromShared Shared.Increment
            )

        DecrementShared ->
            ( model
            , Effect.fromShared Shared.Decrement
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "Advanced"
    , body =
        UI.layout
            [ UI.h1 "Advanced"
            , Html.p [] [ Html.text "An advanced page uses Effects instead of Cmds, which allow you to send Shared messages directly from a page." ]
            , Html.h2 [] [ Html.text "Shared Counter" ]
            , Html.h3 [] [ Html.text (String.fromInt shared.counter) ]
            , Html.button [ Events.onClick DecrementShared ] [ Html.text "-" ]
            , Html.button [ Events.onClick IncrementShared ] [ Html.text "+" ]
            , Html.p [] [ Html.text "This value doesn't reset as you navigate from one page to another (but will on page refresh)!" ]
            ]
    }
