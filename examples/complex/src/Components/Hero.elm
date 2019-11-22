module Components.Hero exposing (Action(..), view)

import Utils.Styles as Styles
import Element exposing (..)
import Element.Input as Input


type Action msg
    = Link String
    | Button msg


view :
    { title : String
    , subtitle : Element msg
    , buttons : List { action : Action msg, label : Element msg }
    }
    -> Element msg
view config =
    column
        [ paddingEach
            { top = 128
            , bottom = 148
            , left = 0
            , right = 0
            }
        , spacing 20
        , centerX
        ]
    <|
        List.concat
            [ [ Styles.h1 [ centerX ] (text config.title)
              , el [ centerX, alpha 0.8 ] config.subtitle
              ]
            , config.buttons
                |> List.map (viewAction (centerX :: Styles.button))
                |> viewActions
            ]


viewAction : List (Attribute msg) -> { action : Action msg, label : Element msg } -> Element msg
viewAction attrs { action, label } =
    case action of
        Link url ->
            link attrs { url = url, label = label }

        Button msg ->
            Input.button attrs { onPress = Just msg, label = label }


viewActions : List (Element msg) -> List (Element msg)
viewActions links =
    if List.isEmpty links then
        []

    else
        [ wrappedRow [ spacing 24, centerX ] links
        ]
