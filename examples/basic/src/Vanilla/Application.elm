module Vanilla.Application exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser
import Vanilla.Element as Random
import Vanilla.Sandbox as Counter
import Vanilla.Static as Homepage


type alias Model =
    { page : PageModel
    , flags : Flags
    , url : Url
    , key : Nav.Key
    }


type Msg
    = OnUrlChanged Url
    | OnUrlRequested Browser.UrlRequest
    | OnPageMsg PageMsg


type Route
    = Homepage
    | Counter
    | Random
    | NotFound


type PageModel
    = HomepageModel
    | CounterModel Counter.Model
    | RandomModel Random.Model
    | NotFoundModel


type PageMsg
    = HomepageMsg
    | CounterMsg Counter.Msg
    | RandomMsg Random.Msg


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = OnUrlChanged
        , onUrlRequest = OnUrlRequested
        }



-- INIT


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        route : Route
        route =
            routeFromUrl url

        page : { model : PageModel, cmd : Cmd PageMsg }
        page =
            initPage flags route
    in
    ( { url = url
      , flags = flags
      , key = key
      , page = page.model
      }
    , Cmd.map OnPageMsg page.cmd
    )


routeFromUrl : Url -> Route
routeFromUrl url =
    let
        routes =
            Parser.oneOf
                [ Parser.map Homepage Parser.top
                , Parser.map Counter (Parser.s "counter")
                , Parser.map Random (Parser.s "random")
                ]
    in
    Parser.parse routes url |> Maybe.withDefault NotFound


routeToPath : Route -> String
routeToPath route =
    case route of
        Homepage ->
            "/"

        Counter ->
            "/counter"

        Random ->
            "/random"

        NotFound ->
            "/not-found"


initPage : Flags -> Route -> { model : PageModel, cmd : Cmd PageMsg }
initPage flags route =
    case route of
        Homepage ->
            { model = HomepageModel
            , cmd = Cmd.none
            }

        Counter ->
            { model = CounterModel Counter.init
            , cmd = Cmd.none
            }

        Random ->
            let
                ( model, cmd ) =
                    Random.init flags
            in
            { model = RandomModel model
            , cmd = Cmd.map RandomMsg cmd
            }

        NotFound ->
            { model = NotFoundModel
            , cmd = Cmd.none
            }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnUrlChanged url ->
            let
                route : Route
                route =
                    routeFromUrl url

                page : { model : PageModel, cmd : Cmd PageMsg }
                page =
                    initPage model.flags route
            in
            ( { model
                | url = url
                , page = page.model
              }
            , Cmd.map OnPageMsg page.cmd
            )

        OnUrlRequested (Browser.Internal url) ->
            ( model
            , Nav.pushUrl model.key (Url.toString url)
            )

        OnUrlRequested (Browser.External url) ->
            ( model
            , Nav.load url
            )

        OnPageMsg pageMsg ->
            let
                page : { model : PageModel, cmd : Cmd PageMsg }
                page =
                    updatePage ( model.page, pageMsg )
            in
            ( { model | page = page.model }
            , Cmd.map OnPageMsg page.cmd
            )


updatePage : ( PageModel, PageMsg ) -> { model : PageModel, cmd : Cmd PageMsg }
updatePage ( pageModel, pageMsg ) =
    case ( pageModel, pageMsg ) of
        ( HomepageModel, _ ) ->
            { model = pageModel
            , cmd = Cmd.none
            }

        ( CounterModel model, CounterMsg msg ) ->
            { model = CounterModel (Counter.update msg model)
            , cmd = Cmd.none
            }

        ( CounterModel _, _ ) ->
            { model = pageModel
            , cmd = Cmd.none
            }

        ( RandomModel model, RandomMsg msg ) ->
            let
                ( updatedModel, updatedCmd ) =
                    Random.update msg model
            in
            { model = RandomModel updatedModel
            , cmd = Cmd.map RandomMsg updatedCmd
            }

        ( RandomModel _, _ ) ->
            { model = pageModel
            , cmd = Cmd.none
            }

        ( NotFoundModel, _ ) ->
            { model = pageModel
            , cmd = Cmd.none
            }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions { page } =
    Sub.map OnPageMsg <|
        case page of
            HomepageModel ->
                Sub.none

            CounterModel _ ->
                Sub.none

            RandomModel model ->
                Sub.map RandomMsg (Random.subscriptions model)

            NotFoundModel ->
                Sub.none


view : Model -> Browser.Document Msg
view model =
    let
        links : List ( String, Route )
        links =
            [ ( "Homepage", Homepage )
            , ( "Counter", Counter )
            , ( "Random", Random )
            ]

        { title, body } =
            viewPage model.page
    in
    { title = title
    , body =
        [ div []
            [ header [] (List.map viewLink links)
            , div [ Attr.class "page" ]
                (List.map (Html.map OnPageMsg) body)
            ]
        ]
    }


viewPage : PageModel -> Browser.Document PageMsg
viewPage pageModel =
    case pageModel of
        HomepageModel ->
            { title = "Homepage"
            , body = [ Html.map never Homepage.view ]
            }

        CounterModel model ->
            { title = "Counter"
            , body = [ Html.map CounterMsg (Counter.view model) ]
            }

        RandomModel model ->
            { title = "Random"
            , body = [ Html.map RandomMsg (Random.view model) ]
            }

        NotFoundModel ->
            { title = "Not Found"
            , body =
                [ h1 [] [ text "Page not found" ]
                , p [] [ text "Using elm-reactor? Just click a link above!" ]
                ]
            }


viewLink : ( String, Route ) -> Html msg
viewLink ( label, route ) =
    a
        [ Attr.href (routeToPath route)
        , Attr.style "margin-right" "1rem"
        ]
        [ text label ]
