module Templates.Pages.Sandbox exposing (contents)

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
    Page.sandbox
        { title = title
        , init = init
        , update = update
        , view = view
        }


title : Model -> String
title _ =
    "{{moduleName}}"


init : {{routeParam}} -> Model
init _ =
    {}


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model


view : Model -> Html Msg
view _ =
    h1 [] [ text "{{moduleName}}" ]

"""
        |> String.replace "{{moduleName}}" (Shared.moduleName path)
        |> String.replace "{{routeParam}}" (Shared.routeParam path)
