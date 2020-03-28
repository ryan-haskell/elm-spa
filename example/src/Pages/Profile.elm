module Pages.Profile exposing
    ( Flags
    , Model
    , Msg
    , page
    )

import Browser.Navigation as Nav
import Data.User as User exposing (User)
import Global
import Html exposing (..)
import Html.Attributes exposing (alt, class, src)
import Html.Events as Events
import Page exposing (Document, Page)



-- PAGE


page : Page Flags Model Msg
page =
    Page.component
        { init = always init
        , update = always update
        , subscriptions = always subscriptions
        , view = view
        }



-- INIT


type alias Flags =
    ()


type alias Model =
    {}


init :
    Flags
    -> ( Model, Cmd Msg, Cmd Global.Msg )
init _ =
    ( Model
    , Cmd.none
    , Cmd.none
    )



-- UPDATE


type Msg
    = ClickedSignIn
    | ClickedSignOut


update : Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update msg model =
    case msg of
        ClickedSignIn ->
            ( model, Cmd.none, Global.openSignInModal )

        ClickedSignOut ->
            ( model, Cmd.none, Global.signOut )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view :
    Global.Model
    -> Model
    -> Document Msg
view global model =
    { title = "Profile"
    , body =
        [ h1 [ class "font--h1" ] [ text "Profile" ]
        , case global.user of
            Just user ->
                div [ class "row spacing--large" ]
                    [ img [ src user.avatar, alt (User.fullname user) ] []
                    , div [ class "column spacing--large align--left" ]
                        [ div [ class "column" ]
                            [ h3 [ class "font--h5 font--bold" ] [ text (User.fullname user) ]
                            , p [] [ text user.email ]
                            ]
                        , button [ Events.onClick ClickedSignOut, class "button" ] [ text "Sign out" ]
                        ]
                    ]

            Nothing ->
                div [ class "column spacing--medium align--left" ]
                    [ p [] [ text "You need to sign in to view this page!" ]
                    , button [ Events.onClick ClickedSignIn, class "button" ] [ text "Sign in" ]
                    ]
        ]
    }
