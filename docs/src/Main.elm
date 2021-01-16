module Main exposing (main)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Gen.Pages as Pages
import Gen.Route as Route
import Ports
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
    , page : Pages.Model
    }


init : Shared.Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( shared, sharedCmd ) =
            Shared.init (request { url = url, key = key }) flags

        ( page, pageCmd, sharedPageCmd ) =
            Pages.init (Route.fromUrl url) shared url key
    in
    ( Model url key shared page
    , Cmd.batch
        [ Cmd.map Shared sharedCmd
        , Cmd.map Shared sharedPageCmd
        , Cmd.map Page pageCmd
        ]
    )



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | Shared Shared.Msg
    | Page Pages.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink (Browser.Internal url) ->
            ( model
            , if url.path == model.url.path then
                Nav.replaceUrl model.key (Url.toString url)

              else
                Nav.pushUrl model.key (Url.toString url)
            )

        ClickedLink (Browser.External url) ->
            ( model
            , Nav.load url
            )

        ChangedUrl url ->
            if url.path == model.url.path then
                ( { model | url = url }
                , Ports.onUrlChange ()
                )

            else
                let
                    ( page, pageCmd, sharedPageCmd ) =
                        Pages.init (Route.fromUrl url) model.shared url model.key
                in
                ( { model | url = url, page = page }
                , Cmd.batch
                    [ Cmd.map Page pageCmd
                    , Cmd.map Shared sharedPageCmd
                    , Ports.onUrlChange ()
                    ]
                )

        Shared sharedMsg ->
            let
                ( shared, sharedCmd ) =
                    Shared.update (request model) sharedMsg model.shared
            in
            ( { model | shared = shared }
            , Cmd.map Shared sharedCmd
            )

        Page pageMsg ->
            let
                ( page, pageCmd, sharedPageCmd ) =
                    Pages.update pageMsg model.page model.shared model.url model.key
            in
            ( { model | page = page }
            , Cmd.batch
                [ Cmd.map Page pageCmd
                , Cmd.map Shared sharedPageCmd
                ]
            )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    Pages.view model.page model.shared model.url model.key
        |> View.map Page
        |> View.toBrowserDocument



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Pages.subscriptions model.page model.shared model.url model.key |> Sub.map Page
        , Shared.subscriptions (request model) model.shared |> Sub.map Shared
        ]



-- REQUESTS


request : { model | url : Url, key : Key } -> Request ()
request model =
    Request.create () model.url model.key
