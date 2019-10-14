module Components.Navbar exposing (view)

import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Html.Events as Events
import Route exposing (Route)


type alias Options msg =
    { currentRoute : Route
    , user : Maybe User
    , signOut : msg
    }


view : Options msg -> Html msg
view { currentRoute, user, signOut } =
    header [ class "navbar" ]
        [ div [ class "navbar__links" ]
            (List.map
                (viewLink currentRoute)
                [ Route.Homepage
                , Route.Counter
                , Route.Random
                ]
            )
        , case user of
            Just _ ->
                button [ Events.onClick signOut ] [ text <| "Sign out" ]

            Nothing ->
                a [ Attr.href "/sign-in" ] [ text "Sign in" ]
        ]


viewLink : Route -> Route -> Html msg
viewLink currentRoute route =
    a
        [ class "navbar__link-item"
        , Attr.href (Route.toPath route)
        , Attr.style "font-weight"
            (if route == currentRoute then
                "bold"

             else
                "normal"
            )
        ]
        [ text (linkLabel route) ]


linkLabel : Route -> String
linkLabel route =
    case route of
        Route.Homepage ->
            "Home"

        Route.Counter ->
            "Counter"

        Route.SignIn ->
            "Sign In"

        Route.Random ->
            "Random"

        Route.NotFound ->
            "Not found"
