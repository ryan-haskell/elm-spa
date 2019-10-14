module Element.Pages.Random exposing (Model, Msg, page)

import Application.Element as Application
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import Http
import Json.Decode as Json exposing (Decoder)


type alias Model =
    { url : Maybe String
    }


type Msg
    = FetchCat
    | CatResponded (Result Http.Error String)


page : Application.Element () Model Msg
page =
    { init = init
    , update = update
    , view = view
    , subscriptions = always Sub.none
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { url = Nothing }
    , Cmd.none
    )


decoder : Decoder String
decoder =
    Json.field "file" Json.string


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchCat ->
            ( model
            , Http.get
                { url = "https://aws.random.cat/meow"
                , expect = Http.expectJson CatResponded decoder
                }
            )

        CatResponded (Ok url) ->
            ( { model | url = Just url }
            , Cmd.none
            )

        CatResponded (Err _) ->
            ( { model | url = Nothing }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Cat mode" ]
        , div []
            [ button [ Events.onClick FetchCat ] [ text "gimme a cat" ]
            , case model.url of
                Just url ->
                    p []
                        [ img [ Attr.style "width" "200px", Attr.src url ] []
                        ]

                Nothing ->
                    text ""
            ]
        ]
