module Pages.Users.Slug exposing (Model, Msg, Params, page)

import Application
import Html exposing (..)
import Html.Attributes exposing (href)


type alias Model =
    { slug : String
    }


type Msg
    = Msg


type alias Params =
    String


page : Application.Page Params Model Msg a b
page =
    Application.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : Params -> ( Model, Cmd Msg )
init slug =
    ( Model slug, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text ("Now viewing: " ++ model.slug) ]
        , p [] [ text "Supports dynamic routes!" ]
        , ul [] <|
            List.map viewUser
                [ ( "Alice", "alice" )
                , ( "Bob", "bob" )
                , ( "Carol", "carol" )
                ]
        ]


viewUser : ( String, String ) -> Html msg
viewUser ( label, slug ) =
    li []
        [ h4 [] [ a [ href ("/users/" ++ slug) ] [ text label ] ]
        , ul []
            (List.map
                (\num ->
                    li []
                        [ a [ href ("/users/" ++ slug ++ "/posts/" ++ String.fromInt num) ]
                            [ text ("Post " ++ String.fromInt num)
                            ]
                        ]
                )
                (List.range 1 3)
            )
        ]
