module Components.Layout exposing
    ( init
    , subscriptions
    , update
    , view
    )

import Application
import Components.Footer
import Components.Navbar
import Data.User exposing (User)
import Flags exposing (Flags)
import Global
import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Html.Events as Events
import Route exposing (Route)
import Utils.Cmd


init :
    { navigateTo : Route -> Cmd msg
    , route : Route
    , flags : Flags
    }
    -> ( Global.Model, Cmd Global.Msg, Cmd msg )
init _ =
    ( { user = Nothing }
    , Cmd.none
    , Cmd.none
    )


update :
    { navigateTo : Route -> Cmd msg
    , route : Route
    , flags : Flags
    }
    -> Global.Msg
    -> Global.Model
    -> ( Global.Model, Cmd Global.Msg, Cmd msg )
update { navigateTo } msg model =
    case msg of
        Global.SignIn (Ok user) ->
            ( { model | user = Just user }
            , Cmd.none
            , navigateTo Route.Homepage
            )

        Global.SignIn (Err _) ->
            Utils.Cmd.pure model

        Global.SignOut ->
            ( { model | user = Nothing }
            , Cmd.none
            , navigateTo Route.SignIn
            )


view :
    { route : Route
    , toMsg : Global.Msg -> msg
    , viewPage : Html msg
    }
    -> Global.Model
    -> Html msg
view { route, toMsg, viewPage } model =
    div [ class "layout" ]
        [ Html.map toMsg
            (Components.Navbar.view
                { currentRoute = route
                , user = model.user
                , signOut = Global.SignOut
                }
            )
        , div [ class "layout__page" ] [ viewPage ]
        , Html.map toMsg
            (Components.Footer.view { user = model.user })
        ]


subscriptions : Route -> Global.Model -> Sub Global.Msg
subscriptions route model =
    Sub.none
