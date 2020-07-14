module Utils.Maybe exposing (view)

import Html exposing (Html)


view : Maybe value -> (value -> Html msg) -> Html msg
view maybe toHtml =
    maybe
        |> Maybe.map toHtml
        |> Maybe.withDefault (Html.text "")
