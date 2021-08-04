module Pages.SignIn exposing (view)

import Gen.Route as Route
import Html
import Html.Attributes as Attr
import View exposing (View)


view : View msg
view =
    { title = "Sign in"
    , body =
        [ Html.div [ Attr.class "col center fill-y gap-lg" ]
            [ Html.h1 [ Attr.class "h1" ] [ Html.text "Welcome back!" ]
            , Html.a [ Attr.href (Route.toHref Route.Home_) ] [ Html.text "Sign in" ]
            ]
        ]
    }
