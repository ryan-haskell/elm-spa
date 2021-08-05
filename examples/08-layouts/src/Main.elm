module Main exposing (main)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Effect exposing (Effect)
import Gen.Layouts exposing (Layout)
import Gen.Model
import Gen.Pages_ as Pages
import Gen.Route as Route
import Request exposing (Request)
import Shared
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
    }


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
    in
    ( Model url key shared (Maybe.map toKindAndModel maybeLayout) page
    , Cmd.batch
        [ Cmd.map Shared sharedCmd
        , Effect.toCmd ( Shared, Page ) pageEffect
        , Effect.toCmd ( Shared, Layout ) (toLayoutEffect maybeLayout)
        ]
    )


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
                    ( { model | url = url, page = page }
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
                      }
                    , Cmd.batch
                        [ Effect.toCmd ( Shared, Page ) effect
                        , Effect.toCmd ( Shared, Layout ) (toLayoutEffect maybeLayout)
                        ]
                    )

            else
                ( { model | url = url }, Cmd.none )

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



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        viewPage =
            Pages.view model.page model.shared model.url model.key
                |> View.map Page

        viewLayout =
            case model.layout of
                Just layout ->
                    Gen.Layouts.view layout.model
                        { viewPage = viewPage
                        , toMainMsg = Layout
                        }
                        model.shared
                        (Request.create () model.url model.key)

                Nothing ->
                    viewPage
    in
    View.toBrowserDocument viewLayout



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Pages.subscriptions model.page model.shared model.url model.key |> Sub.map Page
        , Shared.subscriptions (Request.create () model.url model.key) model.shared |> Sub.map Shared
        ]
