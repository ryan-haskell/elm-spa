module Components.Markdown exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Markdown


view : String -> Html msg
view =
    Markdown.toHtmlWith
        { githubFlavored = Just { tables = True, breaks = False }
        , defaultHighlighting = Nothing
        , sanitize = False
        , smartypants = False
        }
        [ class "markdown readable column spacing-small" ]
