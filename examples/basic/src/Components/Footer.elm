module Components.Footer exposing (view)

import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes as Attr


type alias Options =
    { user : Maybe User
    }


view : Options -> Html msg
view { user } =
    footer [ Attr.class "footer" ]
        [ user
            |> Maybe.map Data.User.username
            |> Maybe.withDefault "not signed in"
            |> (++) "Current user: "
            |> text
        ]
