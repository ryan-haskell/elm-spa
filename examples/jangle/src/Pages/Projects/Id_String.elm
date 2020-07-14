module Pages.Projects.Id_String exposing (Model, Msg, Params, page)

import Api.Data exposing (Data(..))
import Api.Project
import Api.User exposing (User)
import Html exposing (..)
import Html.Attributes as Attr exposing (class, href, target)
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)


type alias Params =
    { id : String }


type alias Model =
    Page.Protected Params ProtectedModel


type Msg
    = GotReadme (Data String)


page : Page Params Model Msg
page =
    Page.protectedElement
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }



-- INIT


type alias ProtectedModel =
    { user : User
    , url : Url Params
    , readme : Data String
    }


init : User -> Url Params -> ( ProtectedModel, Cmd Msg )
init user url =
    ( ProtectedModel user url Loading
    , Api.Project.readme
        { user = user
        , repo = url.params.id
        , toMsg = GotReadme
        }
    )


update : Msg -> ProtectedModel -> ( ProtectedModel, Cmd Msg )
update msg model =
    case msg of
        GotReadme readme ->
            ( { model | readme = readme }
            , Cmd.none
            )



-- VIEW


view : ProtectedModel -> Document Msg
view model =
    let
        repoUrl : String
        repoUrl =
            "https://www.github.com/" ++ model.user.login ++ "/" ++ model.url.params.id
    in
    { title = model.url.params.id ++ " | Jangle"
    , body =
        [ div [ class "column overflow-hidden" ]
            [ div [ class "row wrap padding-medium spacing-small center-y bg--shell" ]
                [ h1 [ class "font-h3" ] [ text model.url.params.id ]
                , a [ class "font-h3 hoverable", href repoUrl, target "_blank" ] [ span [ class "fab fa-github-square" ] [] ]
                ]
            ]
        , Api.Data.view model.readme
            { notAsked = text ""
            , loading = text ""
            , failure = text
            , success =
                text
                    >> List.singleton
                    >> code []
                    >> List.singleton
                    >> pre
                        [ class "padding-medium"
                        , Attr.style "white-space" "pre-wrap"
                        , Attr.style "line-height" "1.2"
                        ]
            }
        ]
    }
