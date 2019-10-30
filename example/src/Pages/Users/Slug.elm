module Pages.Users.Slug exposing (Model, Msg, page)

import Application.Page as Page exposing (Page)
import Html exposing (..)


type alias Model =
    { slug : String }


type alias Msg =
    Never


page : Page String Model Msg a b c d e
page =
    Page.sandbox
        { title = title
        , init = init
        , update = update
        , view = view
        }


init : String -> Model
init slug =
    { slug = slug
    }


update : Msg -> Model -> Model
update _ model =
    model


title : Model -> String
title model =
    capitalize model.slug


capitalize : String -> String
capitalize word =
    case String.toList word of
        first :: rest ->
            String.fromList (Char.toUpper first :: rest)

        _ ->
            word


view : Model -> Html msg
view model =
    div []
        [ h1 [] [ text "Users" ]
        , p [] [ text model.slug ]
        ]
