module Templates.Pages.Static exposing (contents)

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
    ()


type alias Msg =
    Never


page =
    Page.static
        { title = title
        , view = view
        }


title : String
title =
    "{{moduleName}}"


view : Html msg
view =
    h1 [] [ text "{{moduleName}}" ]

"""
        |> String.replace "{{moduleName}}" (Shared.moduleName path)
