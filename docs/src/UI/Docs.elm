module UI.Docs exposing (Model, Msg, page)

import Http
import Page
import Request
import Shared
import UI
import UI.Layout
import Url exposing (Url)
import View exposing (View)


page : Shared.Model -> Request.With params -> Page.With Model Msg
page shared req =
    Page.element
        { init = init req.url
        , update = update
        , view = view shared req.url
        , subscriptions = \_ -> Sub.none
        }



-- INIT


type alias Model =
    { layout : UI.Layout.Model
    , markdown : Fetchable String
    }


type Fetchable data
    = Loading
    | Success data
    | Failure String


withDefault : value -> Fetchable value -> value
withDefault fallback fetchable =
    case fetchable of
        Success value ->
            value

        _ ->
            fallback


init : Url -> ( Model, Cmd Msg )
init url =
    ( Model UI.Layout.init Loading
    , Http.get
        { url = "/content" ++ url.path ++ ".md"
        , expect = Http.expectString GotMarkdown
        }
    )



-- UPDATE


type Msg
    = Layout UI.Layout.Msg
    | GotMarkdown (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Layout layoutMsg ->
            ( { model | layout = UI.Layout.update layoutMsg model.layout }
            , Cmd.none
            )

        GotMarkdown response ->
            let
                success markdown =
                    ( { model | markdown = Success markdown }
                    , Cmd.none
                    )

                failure =
                    ( { model | markdown = Failure "Couldn't find that section of the guide..." }
                    , Cmd.none
                    )
            in
            case response of
                Ok markdown ->
                    if String.startsWith "<!DOCTYPE" markdown then
                        failure

                    else
                        success markdown

                Err _ ->
                    failure



-- VIEW


view : Shared.Model -> Url -> Model -> View Msg
view shared url model =
    { title =
        case model.markdown of
            Loading ->
                ""

            Success content ->
                let
                    firstLine =
                        content
                            |> String.lines
                            |> List.head
                            |> Maybe.withDefault "Guide"
                in
                String.dropLeft 2 firstLine ++ " | elm-spa"

            Failure _ ->
                "Uh oh. | elm-spa"
    , body =
        UI.Layout.viewDocumentation
            { shared = shared
            , url = url
            , onMsg = Layout
            , model = model.layout
            }
            (withDefault "" model.markdown)
            [ case model.markdown of
                Loading ->
                    UI.none

                Failure reason ->
                    UI.markdown { withHeaderLinks = False } ("# Uh oh.\n\n" ++ reason)

                Success markdown ->
                    UI.markdown { withHeaderLinks = True } markdown
            , UI.gutter
            ]
    }
