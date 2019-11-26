module Pages.Guide.Dynamic exposing (Model, Msg, page)

import Components.Hero as Hero
import Element exposing (..)
import Element.Font as Font
import Generated.Guide.Params as Params
import Http
import Json.Decode as D exposing (Decoder)
import Spa.Page
import Ui
import Utils.Markdown as Markdown exposing (Markdown)
import Utils.Spa exposing (Page)


page : Page Params.Dynamic Model Msg model msg appMsg
page =
    Spa.Page.element
        { title = \{ model } -> model.slug ++ " | guide | elm-spa"
        , init = always init
        , update = always update
        , subscriptions = always subscriptions
        , view = always view
        }



-- INIT


type alias Model =
    { slug : String
    , markdown : Content
    }


type Content
    = Requesting
    | Found (Markdown Frontmatter)
    | NotFound Http.Error


type alias Frontmatter =
    { title : String
    }


frontmatterDecoder : Decoder Frontmatter
frontmatterDecoder =
    D.map Frontmatter
        (D.field "title" D.string)


init : Params.Dynamic -> ( Model, Cmd Msg )
init { param1 } =
    ( { slug = param1
      , markdown = Requesting
      }
    , Http.get
        { expect = Http.expectString ContentFetched
        , url = "/content/guide/" ++ param1 ++ ".md"
        }
    )



-- UPDATE


type Msg
    = ContentFetched (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ContentFetched (Ok content) ->
            ( { model
                | markdown = Found (Markdown.parse frontmatterDecoder content)
              }
            , Cmd.none
            )

        ContentFetched (Err error) ->
            ( { model | markdown = NotFound error }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Element Msg
view model =
    case model.markdown of
        Requesting ->
            text ""

        NotFound _ ->
            column [ width fill ]
                [ viewHeader
                    { title = "huh."
                    , subtitle = Just "Couldn't find a guide page there."
                    }
                , el [ centerX, Font.color Ui.colors.coral ] <|
                    link Ui.styles.link.enabled
                        { label = text "back to the guide"
                        , url = "/guide"
                        }
                ]

        Found markdown ->
            case markdown of
                Markdown.WithFrontmatter value ->
                    viewContent value

                Markdown.WithoutFrontmatter content ->
                    viewContent
                        { frontmatter = { title = model.slug |> String.replace "-" " " }
                        , content = content
                        }


viewHeader : { title : String, subtitle : Maybe String } -> Element msg
viewHeader options =
    column
        [ width fill
        , paddingEach { top = 32, left = 0, bottom = 16, right = 0 }
        , centerX
        , spacing 12
        ]
    <|
        List.concat
            [ [ el
                    [ Font.size 48
                    , Font.semiBold
                    , centerX
                    ]
                    (text options.title)
              ]
            , options.subtitle
                |> Maybe.map (text >> el [ alpha 0.5, centerX ] >> List.singleton)
                |> Maybe.withDefault []
            ]


viewContent : { frontmatter : Frontmatter, content : String } -> Element msg
viewContent options =
    Ui.sections
        [ viewHeader
            { title = options.frontmatter.title
            , subtitle = Nothing
            }
        , Ui.markdown options.content
        ]
