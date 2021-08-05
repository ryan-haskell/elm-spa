module Main exposing (main)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Effect exposing (Effect)
import Gen.Layouts exposing (Layout)
import Gen.Model
import Gen.Pages_ as Pages
import Gen.Route as Route
import Process
import Request exposing (Request)
import Shared
import Task
import Transition
import Url exposing (Url)
import View


main : Program Shared.Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }



-- INIT


type alias Model =
    { url : Url
    , key : Key
    , shared : Shared.Model
    , layout : Maybe { kind : Layout, model : Gen.Layouts.Model }
    , page : Pages.Model
    , transition : Transition
    }


type Transition
    = InvisibleApp { before : Maybe Layout, after : Maybe Layout }
    | FadingOutPage { before : Maybe Layout, after : Maybe Layout }
    | VisiblePage { before : Maybe Layout, after : Maybe Layout }


init : Shared.Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        req =
            Request.create () url key

        ( shared, sharedCmd ) =
            Shared.init req flags

        ( page, pageEffect ) =
            Pages.init (Route.fromUrl url) shared url key

        maybeLayout =
            Pages.layout (Route.fromUrl url)
                |> Maybe.map (initializeLayout Nothing { shared = shared, request = req })

        transitionEffect =
            if Transition.duration > 0 then
                sendDelayedMsg Transition.duration FadeInApp

            else
                Cmd.none
    in
    ( { url = url
      , key = key
      , shared = shared
      , layout = Maybe.map toKindAndModel maybeLayout
      , page = page
      , transition = InvisibleApp { before = Nothing, after = Maybe.map .kind maybeLayout }
      }
    , Cmd.batch
        [ Cmd.map Shared sharedCmd
        , Effect.toCmd ( Shared, Page ) pageEffect
        , Effect.toCmd ( Shared, Layout ) (toLayoutEffect maybeLayout)
        , transitionEffect
        ]
    )


sendDelayedMsg : Int -> Msg -> Cmd Msg
sendDelayedMsg ms msg =
    Process.sleep (toFloat ms)
        |> Task.map (\_ -> msg)
        |> Task.perform identity


initializeLayout : Maybe Gen.Layouts.Model -> { shared : Shared.Model, request : Request } -> Layout -> { kind : Layout, model : Gen.Layouts.Model, effect : Effect Gen.Layouts.Msg }
initializeLayout maybeModel { shared, request } layoutKind =
    let
        ( model, effect ) =
            Gen.Layouts.init maybeModel layoutKind shared request
    in
    { kind = layoutKind
    , model = model
    , effect = effect
    }


toKindAndModel : { a | kind : b, model : c } -> { kind : b, model : c }
toKindAndModel x =
    { kind = x.kind, model = x.model }


toLayoutEffect : Maybe { a | effect : Effect msg } -> Effect msg
toLayoutEffect maybeLayout =
    maybeLayout
        |> Maybe.map .effect
        |> Maybe.withDefault Effect.none



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | Shared Shared.Msg
    | Layout Gen.Layouts.Msg
    | Page Pages.Msg
    | FadeInApp
    | FadeInPage Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink (Browser.Internal url) ->
            ( model
            , Nav.pushUrl model.key (Url.toString url)
            )

        ClickedLink (Browser.External url) ->
            ( model
            , Nav.load url
            )

        ChangedUrl url ->
            if url.path /= model.url.path then
                if Transition.duration > 0 then
                    ( { model
                        | transition =
                            FadingOutPage
                                { before = Maybe.map .kind model.layout
                                , after = Pages.layout (Route.fromUrl url)
                                }
                      }
                    , sendDelayedMsg Transition.duration (FadeInPage url)
                    )

                else
                    updateModelFromUrl url model

            else
                ( { model | url = url }, Cmd.none )

        FadeInApp ->
            ( { model | transition = VisiblePage { before = Nothing, after = Maybe.map .kind model.layout } }, Cmd.none )

        FadeInPage url ->
            updateModelFromUrl url model

        Shared sharedMsg ->
            let
                ( shared, sharedCmd ) =
                    Shared.update (Request.create () model.url model.key) sharedMsg model.shared

                ( page, effect ) =
                    Pages.init (Route.fromUrl model.url) shared model.url model.key
            in
            if page == Gen.Model.Redirecting_ then
                ( { model | shared = shared, page = page }
                , Cmd.batch
                    [ Cmd.map Shared sharedCmd
                    , Effect.toCmd ( Shared, Page ) effect
                    ]
                )

            else
                ( { model | shared = shared }
                , Cmd.map Shared sharedCmd
                )

        Page pageMsg ->
            let
                ( page, effect ) =
                    Pages.update pageMsg model.page model.shared model.url model.key
            in
            ( { model | page = page }
            , Effect.toCmd ( Shared, Page ) effect
            )

        Layout layoutMsg ->
            case model.layout of
                Just layout ->
                    let
                        req =
                            Request.create () model.url model.key

                        ( newLayoutModel, effect ) =
                            Gen.Layouts.update layoutMsg layout.model model.shared req
                    in
                    ( { model | layout = Just { layout | model = newLayoutModel } }
                    , Effect.toCmd ( Shared, Layout ) effect
                    )

                Nothing ->
                    ( model, Cmd.none )


updateModelFromUrl : Url -> Model -> ( Model, Cmd Msg )
updateModelFromUrl url model =
    let
        route =
            Route.fromUrl url

        ( page, effect ) =
            Pages.init route model.shared url model.key

        currentLayout =
            model.layout

        newLayoutKind =
            Pages.layout route
    in
    if Maybe.map .kind currentLayout == newLayoutKind then
        ( { model
            | url = url
            , page = page
            , transition = VisiblePage { before = Maybe.map .kind currentLayout, after = newLayoutKind }
          }
        , Effect.toCmd ( Shared, Page ) effect
        )

    else
        let
            maybeLayout =
                newLayoutKind
                    |> Maybe.map
                        (initializeLayout (Maybe.map .model currentLayout)
                            { shared = model.shared
                            , request = Request.create () url model.key
                            }
                        )
        in
        ( { model
            | url = url
            , page = page
            , layout = Maybe.map toKindAndModel maybeLayout
            , transition = VisiblePage { before = Maybe.map .kind currentLayout, after = newLayoutKind }
          }
        , Cmd.batch
            [ Effect.toCmd ( Shared, Page ) effect
            , Effect.toCmd ( Shared, Layout ) (toLayoutEffect maybeLayout)
            ]
        )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        viewPage =
            Pages.view model.page model.shared model.url model.key
                |> View.map Page

        ( attrs, layoutKinds ) =
            case model.transition of
                InvisibleApp kinds ->
                    ( Transition.invisible, kinds )

                FadingOutPage kinds ->
                    ( Transition.invisible, kinds )

                VisiblePage kinds ->
                    ( Transition.visible, kinds )

        viewLayout =
            case model.layout of
                Just layout ->
                    Gen.Layouts.view
                        layoutKinds
                        { current = attrs }
                        layout.model
                        { viewPage = viewPage
                        , toMainMsg = Layout
                        }
                        model.shared
                        (Request.create () model.url model.key)

                Nothing ->
                    Transition.apply attrs viewPage
    in
    case ( layoutKinds.before, layoutKinds.after ) of
        ( Just _, Just _ ) ->
            View.toBrowserDocument (Transition.apply Transition.visible viewLayout)

        _ ->
            View.toBrowserDocument (Transition.apply attrs viewLayout)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Pages.subscriptions model.page model.shared model.url model.key |> Sub.map Page
        , Shared.subscriptions (Request.create () model.url model.key) model.shared |> Sub.map Shared
        ]
