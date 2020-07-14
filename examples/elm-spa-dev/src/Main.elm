module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Shared exposing (Flags)
import Spa.Document as Document exposing (Document)
import Spa.Generated.Pages as Pages
import Spa.Generated.Route as Route exposing (Route)
import Spa.Transition
import Url exposing (Url)
import Utils.Cmd


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view >> Document.toBrowserDocument
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


fromUrl : Url -> Route
fromUrl =
    Route.fromUrl >> Maybe.withDefault Route.NotFound



-- INIT


type alias Model =
    { url : Url
    , key : Nav.Key
    , shared : Shared.Model
    , page : Pages.Model
    , isTransitioning : { layout : Bool, page : Bool }
    , nextUrl : Url
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        shared =
            Shared.init flags key url

        route =
            fromUrl url

        ( page, pageCmd ) =
            Pages.init route shared
    in
    ( Model url key shared page { layout = True, page = True } url
    , Cmd.batch
        [ Cmd.map Pages pageCmd
        , Utils.Cmd.delay Spa.Transition.delays.layout (FadeIn url)
        ]
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | Shared Shared.Msg
    | Pages Pages.Msg
    | FadeIn Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked (Browser.Internal url) ->
            ( model
            , Nav.pushUrl model.key (Url.toString url)
            )

        LinkClicked (Browser.External href) ->
            ( model
            , Nav.load href
            )

        UrlChanged url ->
            if url == model.url then
                ( model, Cmd.none )

            else if url.path == model.url.path then
                loadPage url model

            else
                ( { model | isTransitioning = { layout = False, page = True }, nextUrl = url }
                , Utils.Cmd.delay Spa.Transition.delays.page (FadeIn url)
                )

        FadeIn url ->
            loadPage url model

        Shared sharedMsg ->
            let
                ( shared, cmd ) =
                    Shared.update sharedMsg model.shared

                ( page, pageCmd ) =
                    Pages.load model.page shared
            in
            ( { model | page = page, shared = shared }
            , Cmd.map Shared cmd
            )

        Pages pageMsg ->
            let
                ( page, cmd ) =
                    Pages.update pageMsg model.page

                shared =
                    Pages.save page model.shared
            in
            ( { model | page = page, shared = shared }
            , Cmd.map Pages cmd
            )


loadPage : Url -> Model -> ( Model, Cmd Msg )
loadPage url model =
    let
        route =
            fromUrl url

        ( page, cmd ) =
            Pages.init route model.shared

        shared =
            Pages.save page model.shared
    in
    ( { model
        | url = url
        , nextUrl = url
        , page = page
        , shared = shared
        , isTransitioning = { layout = False, page = False }
      }
    , Cmd.map Pages cmd
    )


view : Model -> Document Msg
view model =
    Shared.view
        { page = Pages.view model.page |> Document.map Pages
        , shared = model.shared
        , toMsg = Shared
        , isTransitioning = model.isTransitioning
        , route = fromUrl model.url
        , shouldShowSidebar = isSidebarPage model.url
        }


isSidebarPage : Url -> Bool
isSidebarPage { path } =
    String.startsWith "/docs" path || String.startsWith "/guide" path


subscriptions : Model -> Sub Msg
subscriptions model =
    Pages.subscriptions model.page
        |> Sub.map Pages
