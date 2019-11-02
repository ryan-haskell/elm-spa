module Templates.Pages.Layout exposing (contents)

import Templates.Pages.Shared as Shared


contents : { path : List String } -> String
contents { path } =
    """module Layouts.{{moduleName}} exposing (view)

import Global
import Html exposing (..)


view :
    { page : Html msg
    , global : Global.Model
    }
    -> Html msg
view { page } =
    page

"""
        |> String.replace "{{moduleName}}" (Shared.moduleName path)
