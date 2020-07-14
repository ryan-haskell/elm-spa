module Components.Sidebar exposing (view)

{-|

@docs Options, view

-}

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Spa.Generated.Route as Route exposing (Route)
import Utils.String


type alias Section =
    { title : String
    , links : List Link
    }


type alias Link =
    { label : String
    , route : Route
    }


view : Route -> Html msg
view currentRoute =
    let
        viewSection : Section -> Html msg
        viewSection section =
            Html.section [ class "column spacing-small align-left" ]
                [ h3 [ class "font-h4" ] [ text section.title ]
                , div [ class "column spacing-small align-left" ]
                    (List.map viewLink section.links)
                ]

        viewLink : Link -> Html msg
        viewLink link =
            a
                [ href (Route.toString link.route)
                , if link.route == currentRoute then
                    class "color--green text-underline text-bold"

                  else
                    class "text-underline hoverable"
                ]
                [ text link.label ]
    in
    div [ class "hidden-mobile width--sidebar column pt-medium spacing-medium align-left" ]
        (List.map viewSection sections)


sections : List Section
sections =
    let
        guide : String -> Link
        guide label =
            Link label <|
                Route.Guide__Topic_String
                    { topic = Utils.String.sluggify label
                    }
    in
    [ { title = "Guide"
      , links =
            [ Link "Introduction" Route.Guide
            , guide "Getting Started"
            , guide "Installation"
            , guide "Routing"
            , guide "Pages"
            , guide "Shared"
            , guide "Components"
            , guide "Using APIs"
            , guide "Beyond HTML"
            , guide "Authentication"
            ]
      }
    ]
