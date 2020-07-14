module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Api.Data exposing (Data(..))
import Api.Token exposing (Token)
import Api.User exposing (User)
import Browser.Navigation as Nav
import Components.Layout
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Ports
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route exposing (Route)


type alias Flags =
    { githubClientId : String
    , token : Maybe String
    }


type alias Model =
    { key : Nav.Key
    , githubClientId : String
    , user : Data User
    }


init : Flags -> Nav.Key -> ( Model, Cmd Msg )
init flags key =
    let
        possibleToken =
            flags.token |> Maybe.map Api.Token.fromString

        user =
            if possibleToken == Nothing then
                NotAsked

            else
                Loading
    in
    ( Model key
        flags.githubClientId
        user
    , case possibleToken of
        Just token ->
            Api.User.current { token = token, toMsg = GotUser }

        Nothing ->
            Cmd.none
    )


type Msg
    = GotUser (Data User)
    | ClickedSignOut


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotUser user ->
            ( { model | user = user }
            , Cmd.none
            )

        ClickedSignOut ->
            ( { model | user = NotAsked }
            , Cmd.batch
                [ Ports.clearToken ()
                , Nav.pushUrl model.key (Route.toString Route.SignIn)
                ]
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view :
    { route : Route
    , page : Document msg
    , shared : Model
    , toMsg : Msg -> msg
    , isTransitioning : Bool
    }
    -> Document msg
view { route, page, shared, toMsg, isTransitioning } =
    { title = page.title
    , body =
        Api.Data.view shared.user
            { notAsked = page.body
            , loading = []
            , failure = text >> List.singleton
            , success =
                \user ->
                    Components.Layout.view
                        { model = { user = user }
                        , page =
                            [ div
                                [ class "column fill page"
                                , classList [ ( "page--invisible", isTransitioning ) ]
                                ]
                                page.body
                            ]
                        , onSignOutClicked = toMsg ClickedSignOut
                        , currentRoute = route
                        }
            }
    }
