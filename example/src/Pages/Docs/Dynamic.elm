module Pages.Docs.Dynamic exposing (Model, Msg, page)

import App.Page
import Components.Hero
import Element exposing (..)
import Generated.Docs.Params as Params
import Global
import Utils.Spa exposing (Page)


type alias Model =
    { slug : String
    }


type alias Msg =
    Never


page : Page Params.Dynamic Model Msg model msg appMsg
page =
    App.Page.sandbox
        { title = always "Dynamic"
        , init = always init
        , update = always update
        , view = view
        }



-- INIT


init : Params.Dynamic -> Model
init { param1 } =
    { slug = param1
    }



-- UPDATE


update : Msg -> Model -> Model
update msg model =
    model



-- VIEW


view : Global.Model -> Model -> Element Msg
view global model =
    column
        [ width fill
        ]
        [ Components.Hero.view
            { title = "docs: " ++ model.slug
            , subtitle = text "\"it's not done until the docs are great.\""
            , buttons =
                [ { label = text "back to docs", action = Components.Hero.Link "/docs" }
                ]
            }
        , global.user
            |> Maybe.map (\name -> "Oh hey there, " ++ name ++ "!")
            |> Maybe.withDefault "Sign in if you want me to say hello!"
            |> text
            |> el [ centerX ]
        ]
