module Pages.Examples exposing (Model, Msg, Params, page)

import Html exposing (..)
import Html.Attributes exposing (alt, class, href, src, style, target)
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)


page : Page Params Model Msg
page =
    Page.static
        { view = view
        }


type alias Model =
    Url Params


type alias Msg =
    Never



-- VIEW


type alias Params =
    ()


type alias Example =
    { name : String
    , githubUser : String
    , description : String
    , image : String
    , demoUrl : String
    , srcUrl : String
    }


examples : List Example
examples =
    [ Example "Realworld Example App"
        "ryannhg"
        "The official RealWorld application for elm-spa"
        "https://github.com/ryannhg/rhg-dev/blob/master/public/images/realworld-homepage.png?raw=true"
        "https://realworld.elm-spa.dev"
        "https://github.com/ryannhg/elm-spa-realworld"
    , Example "elm-spa.dev"
        "ryannhg"
        "The website you're on right now!"
        "/images/elm-spa-homepage.png"
        "https://elm-spa.dev"
        "https://github.com/ryannhg/elm-spa/tree/master/examples/elm-spa-dev"
    ]


view : Url Params -> Document Msg
view { params } =
    { title = "examples | elm-spa"
    , body =
        [ div [ class "column spacing-giant py-large center-x" ]
            [ div [ class "column spacing-tiny text-center" ]
                [ h1 [ class "font-h1" ] [ text "examples" ]
                , p [ class "font-h5 color--faint" ] [ text "featured example projects" ]
                ]
            , div [ class "column spacing-large" ] (List.map viewExample examples)
            , div [ class "row spacing-tiny" ]
                [ span [] [ text "Have a cool project?" ]
                , a
                    [ class "link link--external"
                    , href "https://github.com/ryannhg/elm-spa/issues/new?assignees=ryannhg&labels=examples&template=new-example.md&title=Featured+Example%3A+%5Bname%5D"
                    , target "_blank"
                    ]
                    [ text "Feature it here!" ]
                ]
            ]
        ]
    }


viewExample : Example -> Html msg
viewExample example =
    section [ class "row spacing-medium wrap" ]
        [ a [ href example.demoUrl, target "_blank", class "hoverable" ]
            [ img [ src example.image, alt example.name, style "width" "360px" ] []
            ]
        , div [ class "column spacing-large flex" ]
            [ div [ class "column spacing-tiny" ]
                [ h3 [ class "font-h3" ] [ text example.name ]
                , p [ class "font-body color--faint" ] [ text example.description ]
                , a [ class "link link--external", target "_blank", href ("https://github.com/" ++ example.githubUser) ] [ text ("@" ++ example.githubUser) ]
                ]
            , div [ class "row spacing-small" ]
                [ a [ href example.demoUrl, target "_blank", class "link link--external" ] [ text "Demo" ]
                , a [ href example.srcUrl, target "_blank", class "link link--external" ] [ text "Source" ]
                ]
            ]
        ]
