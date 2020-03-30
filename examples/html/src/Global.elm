module Global exposing
    ( Flags
    , Model
    , Msg
    , init
    , openSignInModal
    , signOut
    , subscriptions
    , update
    , view
    )

import Browser exposing (Document)
import Browser.Navigation as Nav
import Components
import Data.Modal as Modal exposing (Modal)
import Data.SignInForm as SignInForm exposing (SignInForm)
import Data.User exposing (User)
import Task
import Url exposing (Url)



-- INIT


type alias Flags =
    ()


type alias Model =
    { flags : Flags
    , url : Url
    , key : Nav.Key
    , user : Maybe User
    , modal : Maybe Modal
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model
        flags
        url
        key
        Nothing
        Nothing
    , Cmd.none
    )



-- UPDATE


type Msg
    = AttemptSignIn
    | SignOut
    | UpdateSignInForm SignInForm.Field String
    | OpenModal Modal
    | CloseModal


openSignInModal : Cmd Msg
openSignInModal =
    send (OpenModal (Modal.SignInModal SignInForm.empty))


signOut : Cmd Msg
signOut =
    send SignOut


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- SIGN IN
        AttemptSignIn ->
            model.modal
                |> Maybe.andThen Modal.signInForm
                |> Maybe.map (attemptSignIn model)
                |> Maybe.withDefault ( model, Cmd.none )

        SignOut ->
            ( { model | user = Nothing }
            , Cmd.none
            )

        UpdateSignInForm field value ->
            let
                updateFieldWith : String -> SignInForm -> SignInForm
                updateFieldWith =
                    case field of
                        SignInForm.Email ->
                            SignInForm.updateEmail

                        SignInForm.Password ->
                            SignInForm.updatePassword
            in
            ( model.modal
                |> Maybe.map (Modal.updateSignInForm (updateFieldWith value))
                |> (\modal -> { model | modal = modal })
            , Cmd.none
            )

        -- MODAL
        OpenModal modal ->
            ( { model | modal = Just modal }
            , Cmd.none
            )

        CloseModal ->
            ( { model | modal = Nothing }
            , Cmd.none
            )


attemptSignIn : Model -> SignInForm -> ( Model, Cmd Msg )
attemptSignIn model form =
    if form.email == "ryan.nhg@gmail.com" && form.password == "password" then
        ( { model
            | user =
                Just
                    (User
                        "https://avatars2.githubusercontent.com/u/6187256?s=128&v=4"
                        { first = "Ryan", last = "Haskell-Glatz" }
                        form.email
                    )
            , modal = Nothing
          }
        , Cmd.none
        )

    else
        ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view :
    { page : Document msg
    , global : Model
    , toMsg : Msg -> msg
    }
    -> Document msg
view { page, global, toMsg } =
    let
        actions =
            { onSignOut = toMsg <| SignOut
            , openSignInModal = toMsg <| OpenModal (Modal.SignInModal SignInForm.empty)
            , closeModal = toMsg <| CloseModal
            , attemptSignIn = toMsg <| AttemptSignIn
            , onSignInEmailInput = toMsg << UpdateSignInForm SignInForm.Email
            , onSignInPasswordInput = toMsg << UpdateSignInForm SignInForm.Password
            }
    in
    Components.layout
        { page = page
        , global = global
        , actions = actions
        }



-- UTILS


send : msg -> Cmd msg
send msg =
    Task.succeed msg |> Task.perform identity
