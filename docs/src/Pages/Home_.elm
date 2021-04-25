module Pages.Home_ exposing (Model, Msg, page)

import Gen.Params.Home_ exposing (Params)
import Html
import Html.Attributes as Attr
import Page
import Request
import Shared
import UI exposing (Html)
import UI.Layout
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page =
    UI.Layout.pageFullWidth
        { view = view
        }


type alias Model =
    UI.Layout.Model


type alias Msg =
    UI.Layout.Msg


view : View Msg
view =
    { title = "elm-spa"
    , body =
        [ Html.div [ Attr.class "row center-x" ]
            [ UI.hero
                { title = "elm-spa"
                , description = "single page apps made easy"
                }
            ]
        , alternatingMarkdownSections
            [ ( "😌", """
## Build reliable single page applications

With __elm-spa__, you can create production-ready applications with one command:

```terminal
npx elm-spa new
```

No need to configure webpack, gulp, or any other NPM dev tools. This single __zero-configuration__ CLI comes with a live-reloading dev server, production-ready build command, and even a few scaffolding commands for new and existing applications.
""" )
            , ( "\u{1FA84}", """
## Automatic routing

With __elm-spa__, routing is automatically generated for you based on a standard file-structure convention. This means you'll be able to navigate any project, making it great for onboarding new hires or collaborating with a team!
""" )
            , ( "🔒", """
## User authentication

The latest release comes with an easy way to setup user authentication. Use the `Page.protected` API to easily guarantee only logged-in users can view certain pages.
""" )
            , ( "🧠", """
## Ready to learn more?

Awesome! Check out [the official guide](/guide) to learn the concepts, or start by looking at a collection of examples.
        """ )
            ]
        ]
    }


alternatingMarkdownSections : List ( String, String ) -> Html msg
alternatingMarkdownSections sections =
    let
        viewSection ( emoji, str ) =
            Html.section [ Attr.class "home__section" ]
                [ Html.div [ Attr.class "container relative", Attr.style "padding" "8em 1rem" ]
                    [ Html.div [ Attr.class "home__section-icon" ] [ Html.text emoji ]
                    , UI.markdown { withHeaderLinks = False } str
                    ]
                ]
    in
    Html.main_ [ Attr.class "col" ]
        (List.map viewSection sections)
