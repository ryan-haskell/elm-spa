module Pages.Guide.Dynamic.Intro exposing (Model, Msg, page)

import Spa.Page
import Components.Hero
import Element exposing (..)
import Generated.Guide.Dynamic.Params as Params
import Utils.Spa exposing (Page)


type alias Model =
    { slug : String
    }


type alias Msg =
    Never


page : Page Params.Intro Model Msg model msg appMsg
page =
    Spa.Page.sandbox
        { title = always "Guide.Dynamic.Intro"
        , init = always init
        , update = always update
        , view = always view
        }


init : Params.Intro -> Model
init { param1 } =
    { slug = param1
    }


update : Msg -> Model -> Model
update msg model =
    model



-- VIEW


view : Model -> Element Msg
view model =
    column
        [ width fill
        ]
        [ Components.Hero.view
            { title = "intro to " ++ model.slug
            , subtitle = text "\"you're gonna be great.\""
            , buttons = []
            }
        ]
