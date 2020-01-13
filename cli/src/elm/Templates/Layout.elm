module Templates.Layout exposing (contents)


contents : { modulePath : List String, ui : String } -> String
contents options =
    """
module Layouts.{{moduleName}} exposing (view)

import {{ui}} exposing (..)
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> {{ui}} msg
view { page } =
    page


    """
        |> String.replace "{{moduleName}}" (String.join "." options.modulePath)
        |> String.replace "{{ui}}" options.ui
        |> String.trim
