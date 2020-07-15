module Pages.Top exposing (Model, Msg, Params, page, view)

import Components.Markdown
import Html exposing (..)
import Html.Attributes exposing (alt, class, src)
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)


page : Page Params Model Msg
page =
    Page.static
        { view = view
        }


type alias Params =
    ()


type alias Model =
    Url Params


type alias Msg =
    Never


view : Url Params -> Document Msg
view _ =
    { title = "elm-spa"
    , body =
        [ div [ class "column spacing-medium center-x" ]
            [ hero
            , viewSection "No assembly required." """
Build reliable [Elm](https://elm-lang.org) applications with the wonderful tools created by the community– brought together in one place:
- Use __elm-ui__ to create UIs without CSS.
- Comes with __elm-live__, a hot-reloading web server.
- Create a test suite with __elm-test__
"""
            , span [] []
            , viewSection "Ready to learn more?" """
[Checkout the official guide](/guide)
"""
            , span [] []
            ]
        ]
    }


hero : Html msg
hero =
    div [ class "column spacing-medium py-large center-x text-center" ]
        [ div [ class "column spacing-tiny center-x" ]
            [ img [ alt "elm-spa logo", class "size--120", src "/images/logo.svg" ] []
            , h1 [ class "font-h1" ] [ text "elm-spa" ]
            , p [ class "font-h5 color--faint" ] [ text "single page apps made easy." ]
            ]
        , pre [ class "home-pre" ] [ code [ class "lang-terminal" ] [ text "npx elm-spa init" ] ]
        ]


viewSection : String -> String -> Html msg
viewSection title content =
    section [ class "column spacing-small center-x" ]
        [ h3 [ class "font-h2" ] [ text title ]
        , Components.Markdown.view content
        ]
