module Pages.Top exposing (Model, Msg, page)

import App.Page
import Components.Hero
import Components.Section
import Components.Styles as Styles
import Element exposing (..)
import Generated.Params as Params
import Html.Attributes as Attr
import Ports
import Utils.Page exposing (Page)


type alias Model =
    ()


page : Page Params.Top Model Msg model msg appMsg
page =
    App.Page.element
        { title = always "elm-spa"
        , init = always init
        , update = always update
        , view = always view
        , subscriptions = always subscriptions
        }



-- INIT


init : Params.Top -> ( Model, Cmd Msg )
init params =
    ( ()
    , Cmd.none
    )



-- UPDATE


type Msg
    = ScrollTo String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ScrollTo id ->
            ( model
            , Ports.scrollTo id
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Element Msg
view model =
    column [ width fill ]
        [ Components.Hero.view
            { title = "elm-spa"
            , subtitle = text "a framework for Elm."
            , buttons =
                [ { label = text "learn more"
                  , action = Components.Hero.Button (ScrollTo "page-content")
                  }
                ]
            }
        , column
            [ width fill
            , spacing 48
            , htmlAttribute (Attr.id "page-content")
            ]
            [ Components.Section.view
                { title = "does elm need a framework?"
                , content = """
__nope, not really__– it's kinda got one built in! so building something like _React_, _VueJS_, or _Angular_ wouldn't really make sense.

#### ...but even _frameworks_ need frameworks!

that's why projects like _VueJS_ also have awesome tools like [NuxtJS](#nuxt) that bring together the best tools in the ecosystem (and a set of shared best practices!)

welcome to __elm-spa__, a framework for Elm!
"""
                }
            , Components.Section.view
                { title = "what does it do?"
                , content = """
__elm-spa__ brings together the best of the Elm ecosystem in one place.

- [elm-ui](#elm-ui) – a package for creating layout and styles (without CSS!)

- [elm-live](#elm-live) – a dev server (without a webpack config!)

- [elm-spa](#elm-spa) – a package for composing pages (without all the typing!)
"""
                }
            , Components.Section.view
                { title = "new to programming?"
                , content = """
perfect! if you're able to read through this paragraph, you're already _overqualified_.

#### new to elm?

welcome aboard! we've got a series of short tutorials to help you get started.

#### new to elm-spa?

let's dive in and check out all the neat stuff that's ready for your next Elm app!
"""
                }
            , wrappedRow [ spacing 24 ]
                [ link Styles.button { label = text "new to programming", url = "/guide/programming" }
                , link Styles.button { label = text "new to elm", url = "/guide/elm" }
                , link Styles.button { label = text "new to elm-spa", url = "/guide/elm-spa" }
                ]
            ]
        ]
