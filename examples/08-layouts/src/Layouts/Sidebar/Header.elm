module Layouts.Sidebar.Header exposing (layout)

import Gen.Layout exposing (Layout)
import Gen.Route as Route exposing (Route)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import List.Extra
import Request exposing (Request)
import Shared
import View exposing (View)


layout : Shared.Model -> Request -> Layout mainMsg
layout shared req =
    Gen.Layout.static
        { view = view req.route
        }



-- INIT
-- VIEW


view :
    Route
    -> { viewPage : View mainMsg }
    -> View mainMsg
view route { viewPage } =
    { title = viewPage.title
    , body =
        [ Html.div [ Attr.class "col align-top gap-lg fill-y" ]
            [ viewHeader viewPage.title route
            , Html.div [ Attr.class "page" ] viewPage.body
            ]
        ]
    }


viewHeader : String -> Route -> Html msg
viewHeader title route =
    Html.header [ Attr.class "col gap-md fill-y pad-right-lg" ]
        [ Html.span [ Attr.class "h1" ] [ Html.text title ]
        , Html.div [ Attr.class "row gap-md" ]
            [ viewTab route { label = "General", route = Route.Settings__General }
            , viewTab route { label = "Profile", route = Route.Settings__Profile }
            ]
        ]


viewTab : Route -> { label : String, route : Route } -> Html msg
viewTab active { label, route } =
    if active == route then
        Html.span [ Attr.class "tab tab--active" ] [ Html.text label ]

    else
        Html.a [ Attr.class "tab", Attr.href (Route.toHref route) ] [ Html.text label ]
