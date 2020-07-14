module Components.Layout exposing (view)

import Api.User exposing (User)
import Html exposing (..)
import Html.Attributes as Attr exposing (alt, class, classList, href, src)
import Html.Events as Events
import Spa.Generated.Route as Route exposing (Route)


view :
    { model : { model | user : User }
    , page : List (Html msg)
    , onSignOutClicked : msg
    , currentRoute : Route
    }
    -> List (Html msg)
view options =
    [ viewMobile options
    , viewDesktop options
    ]


type alias Options model msg =
    { model : { model | user : User }
    , onSignOutClicked : msg
    , page : List (Html msg)
    , currentRoute : Route
    }


viewMobile : Options model msg -> Html msg
viewMobile { onSignOutClicked, model, page } =
    div [ class "visible-mobile column fill" ]
        [ viewMobileNavbar onSignOutClicked model
        , main_ [ class "flex" ] page
        ]


viewDesktop : Options model msg -> Html msg
viewDesktop { currentRoute, onSignOutClicked, model, page } =
    div [ class "hidden-mobile fill relative" ]
        [ div [ class "relative bg--shell row fill-y align-top stretch" ]
            [ div [ class "fixed z-2 width--sidebar align-top align-left fill-y bg--orange color--white" ] [ viewSidebar currentRoute onSignOutClicked model ]
            , main_ [ class "offset--sidebar column flex" ] page
            ]
        ]


viewSidebar : Route -> msg -> { model | user : User } -> Html msg
viewSidebar currentRoute onSignOutClicked model =
    aside [ class "column fill-y py-medium spacing-large" ]
        [ a [ class "row font-h3 center-x", href (Route.toString Route.Projects) ] [ text "Jangle" ]
        , div [ class "column flex" ] <|
            List.map (viewSidebarLink currentRoute)
                [ { label = "Projects", icon = "fa-list", route = Route.Projects }
                , { label = "Users", icon = "fa-user", route = Route.NotFound }
                , { label = "Docs", icon = "fa-book", route = Route.NotFound }
                , { label = "Settings", icon = "fa-cog", route = Route.NotFound }
                ]
        , div [ class "column px-medium spacing-tiny" ]
            [ viewUser onSignOutClicked model.user
            ]
        ]


viewSidebarLink : Route -> { label : String, icon : String, route : Route } -> Html msg
viewSidebarLink currentRoute link =
    a
        [ class "row spacing-small px-medium py-small"
        , classList [ ( "bg--dark-orange", link.route == currentRoute ) ]
        , href (Route.toString link.route)
        ]
        [ span [ class ("fas " ++ link.icon) ] []
        , span [] [ text link.label ]
        ]


viewMobileNavbar : msg -> { model | user : User } -> Html msg
viewMobileNavbar onSignOutClicked model =
    header [ class "row padding-small relative z-2 bg--orange color--white spread center-y" ]
        [ a [ class "font-h3", href (Route.toString Route.Projects) ] [ text "Jangle" ]
        , div [ class "column center-x spacing-tiny" ]
            [ viewUser onSignOutClicked model.user
            ]
        ]


viewUser : msg -> User -> Html msg
viewUser onSignOutClicked user =
    button [ Events.onClick onSignOutClicked, class "button button--white font--small" ]
        [ div [ class "row spacing-tiny center-y" ]
            [ div [ class "row rounded-circle bg-orange size--avatar" ]
                [ img [ src user.avatarUrl, alt user.name ] [] ]
            , span [ class "ellipsis" ] [ text "Sign out" ]
            ]
        ]
