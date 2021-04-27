module Pages.SignIn exposing (Model, Msg, page)

import Gen.Params.SignIn exposing (Params)
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Page
import Request
import Shared
import Storage exposing (Storage)
import UI
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.element
        { init = init
        , update = update shared.storage
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { name : String }


init : ( Model, Cmd Msg )
init =
    ( { name = "" }
    , Cmd.none
    )



-- UPDATE


type Msg
    = UpdatedName String
    | SubmittedSignInForm


update : Storage -> Msg -> Model -> ( Model, Cmd Msg )
update storage msg model =
    case msg of
        UpdatedName name ->
            ( { model | name = name }
            , Cmd.none
            )

        SubmittedSignInForm ->
            ( model
            , Storage.signIn { name = model.name } storage
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Sign in"
    , body =
        UI.layout
            [ Html.form [ Events.onSubmit SubmittedSignInForm ]
                [ Html.label []
                    [ Html.span [] [ Html.text "Name" ]
                    , Html.input
                        [ Attr.type_ "text"
                        , Attr.value model.name
                        , Events.onInput UpdatedName
                        ]
                        []
                    ]
                , Html.button [ Attr.disabled (String.isEmpty model.name) ]
                    [ Html.text "Sign in" ]
                ]
            ]
    }
