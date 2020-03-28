module Pages.About exposing
    ( Flags
    , Model
    , Msg
    , page
    )

import Data.Tab as Tab exposing (Tab)
import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Html.Events as Events
import Page exposing (Document, Page)



-- PAGE


page : Page Flags Model Msg
page =
    Page.sandbox
        { init = init
        , update = update
        , view = view
        }



-- INIT


type alias Flags =
    ()


type alias Model =
    { tab : Tab
    }


init : Model
init =
    { tab = Tab.ourTeam
    }



-- UPDATE


type Msg
    = SelectedTab Tab


update : Msg -> Model -> Model
update msg model =
    case msg of
        SelectedTab tab ->
            { model | tab = tab }



-- VIEW


view :
    Model
    -> Document Msg
view model =
    { title = "About"
    , body =
        [ h1 [ class "font--h1" ] [ text "About" ]
        , tabs
            { selected = model.tab
            , choices =
                [ ( Tab.ourTeam, viewOurTeam )
                , ( Tab.ourMission, viewOurMission )
                , ( Tab.ourValues, viewOurValues )
                ]
            , toString = Tab.toString
            , onSelect = SelectedTab
            }
        ]
    }


viewOurTeam : Html msg
viewOurTeam =
    div [ class "column spacing--small" ]
        [ h3 [ class "font--h3" ] [ text "Our Team" ]
        , p [] [ text "Here's a short paragraph about our team." ]
        ]


viewOurValues : Html msg
viewOurValues =
    div [ class "column spacing--small" ]
        [ h3 [ class "font--h3" ] [ text "Our Values" ]
        , p [] [ text "Here's a short paragraph about our values." ]
        ]


viewOurMission : Html msg
viewOurMission =
    div [ class "column spacing--small" ]
        [ h3 [ class "font--h3" ] [ text "Our Mission" ]
        , p [] [ text "Here's a short paragraph about our mission." ]
        ]


tabs :
    { selected : a
    , choices : List ( a, Html msg )
    , toString : a -> String
    , onSelect : a -> msg
    }
    -> Html msg
tabs options =
    Html.div [ class "column spacing--medium" ]
        [ Html.div [ class "row spacing--small" ]
            (List.map
                (\( choice, _ ) ->
                    choice
                        |> options.toString
                        |> text
                        |> List.singleton
                        |> button [ class "button", Events.onClick (options.onSelect choice) ]
                )
                options.choices
            )
        , options.choices
            |> List.filterMap
                (\( value, html ) ->
                    if value == options.selected then
                        Just html

                    else
                        Nothing
                )
            |> List.head
            |> Maybe.withDefault (Html.text "")
        ]
