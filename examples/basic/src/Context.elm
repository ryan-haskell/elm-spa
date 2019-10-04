module Context exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Flags exposing (Flags)
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import Route exposing (Route)


type alias Model =
    { user : Maybe String
    }


type Msg
    = SignIn String
    | SignOut


init : Route -> Flags -> ( Model, Cmd Msg )
init route flags =
    ( { user = Nothing }
    , Cmd.none
    )


update : Route -> Msg -> Model -> ( Model, Cmd Msg )
update route msg model =
    case msg of
        SignIn user ->
            ( { model | user = Just user }
            , Cmd.none
            )

        SignOut ->
            ( { model | user = Nothing }
            , Cmd.none
            )


view :
    { route : Route
    , context : Model
    , toMsg : Msg -> msg
    , viewPage : Html msg
    }
    -> Html msg
view { context, route, toMsg, viewPage } =
    div [ Attr.class "layout" ]
        [ Html.map toMsg (viewNavbar route context)
        , br [] []
        , viewPage
        , br [] []
        , Html.map toMsg (viewFooter context)
        ]


viewNavbar : Route -> Model -> Html Msg
viewNavbar currentRoute model =
    header [ Attr.class "navbar" ]
        [ ul []
            (List.map
                (viewLink currentRoute)
                [ Route.Homepage, Route.Counter, Route.Random ]
            )
        , case model.user of
            Just _ ->
                button [ Events.onClick SignOut ] [ text <| "Sign out" ]

            Nothing ->
                button [ Events.onClick (SignIn "Ryan") ] [ text "Sign in" ]
        ]


viewLink : Route -> Route -> Html msg
viewLink currentRoute route =
    li []
        [ a
            [ Attr.href (Route.toPath route)
            , Attr.style "font-weight"
                (if route == currentRoute then
                    "bold"

                 else
                    "normal"
                )
            ]
            [ text (Route.title route) ]
        ]


viewFooter : Model -> Html Msg
viewFooter model =
    footer [ Attr.class "footer" ]
        [ model.user |> Maybe.withDefault "Not signed in" |> text
        ]


subscriptions : Route -> Model -> Sub Msg
subscriptions route model =
    Sub.none
