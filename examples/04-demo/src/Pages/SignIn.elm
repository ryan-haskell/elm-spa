module Pages.SignIn exposing (Model, Msg, page)

import Effect exposing (Effect)
import Gen.Params.SignIn exposing (Params)
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Page
import Request
import Shared
import UI
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { name : String }


init : ( Model, Effect Msg )
init =
    ( { name = "" }
    , Effect.none
    )



-- UPDATE


type Msg
    = UpdatedName String
    | SubmittedSignInForm


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UpdatedName name ->
            ( { model | name = name }
            , Effect.none
            )

        SubmittedSignInForm ->
            ( model
            , Effect.fromShared (Shared.SignedIn model.name)
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
