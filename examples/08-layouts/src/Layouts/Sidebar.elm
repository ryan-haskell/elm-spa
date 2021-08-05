module Layouts.Sidebar exposing (Model, Msg, layout)

import Gen.Layout as Layout
import Gen.Route as Route exposing (Route)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import List.Extra
import Request exposing (Request)
import Shared
import View exposing (View)


layout : Shared.Model -> Request -> Layout.With Model Msg mainMsg
layout shared req =
    Layout.sandbox
        { init = init
        , update = update
        , view = view req.route
        }



-- INIT


type alias Model =
    { expandedSections : List Section
    }


type Section
    = SystemOfRecord
    | Settings


init : Model
init =
    { expandedSections = []
    }



-- UPDATE


type Msg
    = Toggle Section


update : Msg -> Model -> Model
update msg model =
    case msg of
        Toggle section ->
            let
                expandedSections =
                    if List.member section model.expandedSections then
                        List.Extra.remove section model.expandedSections

                    else
                        section :: model.expandedSections
            in
            { model | expandedSections = expandedSections }



-- VIEW


view :
    Route
    ->
        { viewPage : View mainMsg
        , toMainMsg : Msg -> mainMsg
        }
    -> Model
    -> View mainMsg
view route { viewPage, toMainMsg } model =
    { title = viewPage.title
    , body =
        [ Html.div [ Attr.class "row align-top pad-xl gap-lg fill-y" ]
            [ Html.map toMainMsg (viewSidebar route model)
            , Html.div [ Attr.class "page" ] viewPage.body
            ]
        ]
    }


viewSidebar : Route -> Model -> Html Msg
viewSidebar route model =
    Html.aside [ Attr.class "col gap-xl fill-y border-right pad-right-lg" ]
        [ Html.div [ Attr.class "col gap-md" ]
            [ Html.a [ Attr.class "h3", Attr.href (Route.toHref Route.Home_) ] [ Html.text "Super App" ]
            , Html.div [ Attr.class "col gap-md" ]
                (List.map (viewSidebarSection route model.expandedSections) [ SystemOfRecord, Settings ])
            ]
        , viewSectionLink route { label = "Sign out", route = Route.SignIn }
        ]


viewSidebarSection : Route -> List Section -> Section -> Html Msg
viewSidebarSection route expandedSections section =
    let
        isExpanded =
            List.member section expandedSections

        viewExpandedItems =
            if isExpanded then
                Html.div [ Attr.class "col gap-sm pad-left-lg" ] (List.map (viewSectionLink route) (sectionLinks section))

            else
                Html.text ""

        icon =
            if isExpanded then
                "☝️ "

            else
                "👇 "
    in
    Html.section [ Attr.class "col gap-sm" ]
        [ Html.button [ Attr.class "h4", Events.onClick (Toggle section) ] [ Html.text (icon ++ sectionName section) ]
        , viewExpandedItems
        ]


viewSectionLink : Route -> { label : String, route : Route } -> Html msg
viewSectionLink active { label, route } =
    Html.a
        [ Attr.class "row h5"
        , Attr.classList [ ( "active", active == route ) ]
        , Attr.href (Route.toHref route)
        ]
        [ Html.text label ]



-- SECTION


sectionName : Section -> String
sectionName section =
    case section of
        SystemOfRecord ->
            "System of record"

        Settings ->
            "Settings"


sectionLinks : Section -> List { label : String, route : Route }
sectionLinks section =
    case section of
        SystemOfRecord ->
            [ { label = "Apps", route = Route.Apps }
            , { label = "Devices", route = Route.Devices }
            , { label = "People", route = Route.People }
            ]

        Settings ->
            [ { label = "General", route = Route.Settings__General }
            , { label = "Profile", route = Route.Settings__Profile }
            ]
