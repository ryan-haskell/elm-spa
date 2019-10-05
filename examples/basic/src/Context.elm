module Context exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Application
import Data.User exposing (User)
import Flags exposing (Flags)
import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Html.Events as Events
import Route exposing (Route)
import Utils.Cmd


type alias Model =
    { user : Maybe User
    }


type Msg
    = SignIn (Result String User)
    | SignOut


init : Route -> Flags -> ( Model, Cmd Msg )
init route flags =
    ( { user = Nothing }
    , Cmd.none
    )


update :
    Application.Messages Route msg
    -> Route
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Cmd msg )
update { navigateTo } route msg model =
    case msg of
        SignIn (Ok user) ->
            ( { model | user = Just user }
            , Cmd.none
            , navigateTo Route.Homepage
            )

        SignIn (Err _) ->
            Utils.Cmd.pure model

        SignOut ->
            Utils.Cmd.pure { model | user = Nothing }


view :
    { route : Route
    , context : Model
    , toMsg : Msg -> msg
    , viewPage : Html msg
    }
    -> Html msg
view { context, route, toMsg, viewPage } =
    div [ class "layout" ]
        [ Html.map toMsg (viewNavbar route context)
        , div [ class "container" ] [ viewPage ]
        , Html.map toMsg (viewFooter context)
        ]


viewNavbar : Route -> Model -> Html Msg
viewNavbar currentRoute model =
    header [ class "navbar" ]
        [ div [ class "navbar__links" ]
            (List.map
                (viewLink currentRoute)
                [ Route.Homepage, Route.Counter, Route.Random ]
            )
        , case model.user of
            Just _ ->
                button [ Events.onClick SignOut ] [ text <| "Sign out" ]

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


viewFooter : Model -> Html Msg
viewFooter model =
    footer [ Attr.class "footer" ]
        [ model.user
            |> Maybe.map Data.User.username
            |> Maybe.withDefault "not signed in"
            |> (++) "Current user: "
            |> text
        ]


subscriptions : Route -> Model -> Sub Msg
subscriptions route model =
    Sub.none
