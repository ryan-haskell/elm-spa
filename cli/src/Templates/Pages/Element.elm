module Templates.Pages.Element exposing (contents)

import Templates.Pages.Shared as Shared


contents : { path : List String } -> String
contents { path } =
    """module Pages.{{moduleName}} exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page
import Html exposing (..)


type alias Model =
    {}


type Msg
    = NoOp


page =
    Page.element
        { title = title
        , init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


title : Model -> String
title _ =
    "{{moduleName}}"


init : {{routeParam}} -> ( Model, Cmd Msg )
init _ =
    ( {}
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view _ =
    h1 [] [ text "{{moduleName}}" ]

"""
        |> String.replace "{{moduleName}}" (Shared.moduleName path)
        |> String.replace "{{routeParam}}" (Shared.routeParam path)
