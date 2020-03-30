module Pages.Posts.Dynamic exposing
    ( Flags
    , Model
    , Msg
    , page
    )

import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Page exposing (Document, Page)


type alias Flags =
    { param1 : String
    }


type alias Model =
    { postId : String
    }


type alias Msg =
    Never


page : Page Flags Model Msg
page =
    Page.element
        { init = \flags -> ( Model flags.param1, Cmd.none )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , view = view
        }


view : Model -> Document msg
view model =
    { title = model.postId ++ " | Post"
    , body =
        [ h1 [ class "font--h1" ] [ text ("Post " ++ model.postId) ]
        , p [] [ text "(but imagine an actual blog post here)" ]
        ]
    }
