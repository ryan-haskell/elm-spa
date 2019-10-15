module Application.Internals.Element.Routing exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Html exposing (..)
import Html.Events as Events


type alias Model route model msg =
    { init : route -> ( model, Cmd msg )
    , page : model
    }


type Msg route msg
    = RouteChange route
    | PageMsg msg



-- INIT


init :
    { init : route -> flags -> ( model, Cmd msg )
    , route : route
    }
    -> flags
    -> ( Model route model msg, Cmd (Msg route msg) )
init config flags =
    let
        ( model, cmd ) =
            config.init config.route flags
    in
    ( { init = \r -> config.init r flags
      , page = model
      }
    , Cmd.map PageMsg cmd
    )



-- UPDATE


update :
    { update : msg -> model -> ( model, Cmd msg ) }
    -> Msg route msg
    -> Model route model msg
    -> ( Model route model msg, Cmd (Msg route msg) )
update config msg model =
    case msg of
        RouteChange route ->
            Tuple.mapBoth
                (\page -> { model | page = page })
                (Cmd.map PageMsg)
                (model.init route)

        PageMsg pageMsg ->
            Tuple.mapBoth
                (\page -> { model | page = page })
                (Cmd.map PageMsg)
                (config.update pageMsg model.page)



-- VIEW


view :
    { routes : List ( String, route ), view : model -> Html msg }
    -> Model route model msg
    -> Html (Msg route msg)
view config model =
    div []
        [ p []
            (List.map
                (\( label, route ) ->
                    button [ Events.onClick (RouteChange route) ] [ text label ]
                )
                config.routes
            )
        , Html.map PageMsg (config.view model.page)
        ]



-- SUBSCRIPTIONS


subscriptions :
    { subscriptions : model -> Sub msg }
    -> Model route model msg
    -> Sub (Msg route msg)
subscriptions config model =
    Sub.map PageMsg (config.subscriptions model.page)
