module Templates.Pages.Component exposing (contents)

import Templates.Pages.Shared as Shared


contents : { path : List String } -> String
contents { path } =
    """module Pages.{{moduleName}} exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page
import Global
import Html exposing (..)


type alias Model =
    {}


type Msg
    = NoOp


page =
    Page.component
        { title = title
        , init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


title : Global.Model -> Model -> String
title _ _ =
    "{{moduleName}}"


init : Global.Model -> {{routeParam}} -> ( Model, Cmd Msg, Cmd Global.Msg )
init _ _ =
    ( {}
    , Cmd.none
    , Cmd.none
    )


update : Global.Model -> Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update _ msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            , Cmd.none
            )


subscriptions : Global.Model -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


view : Global.Model -> Model -> Html Msg
view _ _ =
    h1 [] [ text "{{moduleName}}" ]

"""
        |> String.replace "{{moduleName}}" (Shared.moduleName path)
        |> String.replace "{{routeParam}}" (Shared.routeParam path)
