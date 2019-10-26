module Pages.Random exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Application
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


page =
    Application.element
        { init = always init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { url = Nothing }
    , fetchCat
    )


fetchCat : Cmd Msg
fetchCat =
    Http.get
        { url = "https://aws.random.cat/meow"
        , expect = Http.expectJson CatResponded decoder
        }


decoder : Decoder String
decoder =
    Json.field "file" Json.string


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchCat ->
            ( model
            , fetchCat
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


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
