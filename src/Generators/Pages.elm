module Generators.Pages exposing
    ( generate
    , pagesBundle
    , pagesCustomType
    , pagesImports
    , pagesInit
    , pagesUpdate
    , pagesUpgradedTypes
    , pagesUpgradedValues
    )

import Path exposing (Path)
import Utils.Generate as Utils


generate : List Path -> String
generate paths =
    String.trim """
module Spa.Generated.Pages exposing
    ( Model
    , Msg
    , init
    , load
    , save
    , subscriptions
    , update
    , view
    )

import Color exposing (Color)
{{pagesImports}}
import Shared
import Spa.Document as Document exposing (Document)
import Spa.Generated.Route as Route exposing (Route)
import Spa.Page exposing (Page)
import Spa.Url as Url
import Theme exposing (Theme)
import UI exposing (Components)


-- TYPES


{{pagesModels}}


{{pagesMsgs}}



-- INIT


{{pagesInit}}



-- UPDATE


{{pagesUpdate}}



-- BUNDLE - (view + subscriptions)


{{pagesBundle}}


view : Theme Color -> Model -> Document Msg
view theme model =
    (bundle model).view theme


subscriptions : Model -> Sub Msg
subscriptions model =
    (bundle model).subscriptions ()


save : Model -> Shared.Model -> Shared.Model
save model =
    (bundle model).save ()


load : Model -> Shared.Model -> ( Model, Cmd Msg )
load model =
    (bundle model).load ()



-- UPGRADING PAGES


type alias Upgraded params model msg =
    { init : params -> Shared.Model -> ( Model, Cmd Msg )
    , update : msg -> model -> ( Model, Cmd Msg )
    , bundle : model -> Bundle
    }


type alias Bundle =
    { view : Theme Color -> Document Msg
    , subscriptions : () -> Sub Msg
    , save : () -> Shared.Model -> Shared.Model
    , load : () -> Shared.Model -> ( Model, Cmd Msg )
    }


upgrade : (model -> Model) -> (msg -> Msg) -> Page params model msg -> Upgraded params model msg
upgrade toModel toMsg page =
    let
        init_ params shared =
            page.init shared (Url.create params shared.key shared.url) |> Tuple.mapBoth toModel (Cmd.map toMsg)

        update_ msg model =
            page.update msg model |> Tuple.mapBoth toModel (Cmd.map toMsg)

        bundle_ model =
            { view = \\theme -> page.view (UI.components theme) model |> Document.map toMsg
            , subscriptions = \\() -> page.subscriptions model |> Sub.map toMsg
            , save = \\() -> page.save model
            , load = \\() -> load_ model
            }

        load_ model shared =
            page.load shared model |> Tuple.mapBoth toModel (Cmd.map toMsg)
    in
    { init = init_
    , update = update_
    , bundle = bundle_
    }


pages :
{{pagesUpgradedTypes}}
pages =
{{pagesUpgradedValues}}
"""
        |> String.replace "{{pagesImports}}" (pagesImports paths)
        |> String.replace "{{pagesModels}}" (pagesModels paths)
        |> String.replace "{{pagesMsgs}}" (pagesMsgs paths)
        |> String.replace "{{pagesUpgradedTypes}}" (pagesUpgradedTypes paths)
        |> String.replace "{{pagesUpgradedValues}}" (pagesUpgradedValues paths)
        |> String.replace "{{pagesInit}}" (pagesInit paths)
        |> String.replace "{{pagesUpdate}}" (pagesUpdate paths)
        |> String.replace "{{pagesBundle}}" (pagesBundle paths)


pagesImports : List Path -> String
pagesImports paths =
    paths
        |> List.map Path.toModulePath
        |> List.map ((++) "import Pages.")
        |> String.join "\n"


pagesModels : List Path -> String
pagesModels =
    pagesCustomType "Model"


pagesMsgs : List Path -> String
pagesMsgs =
    pagesCustomType "Msg"


pagesCustomType : String -> List Path -> String
pagesCustomType name paths =
    Utils.customType
        { name = name
        , variants =
            List.map
                (\path ->
                    Path.toTypeName path
                        ++ "__"
                        ++ name
                        ++ " Pages."
                        ++ Path.toModulePath path
                        ++ "."
                        ++ name
                )
                paths
        }


pagesUpgradedTypes : List Path -> String
pagesUpgradedTypes paths =
    paths
        |> List.map
            (\path ->
                let
                    name =
                        "Pages." ++ Path.toModulePath path
                in
                ( Path.toVariableName path
                , "Upgraded "
                    ++ name
                    ++ ".Params "
                    ++ name
                    ++ ".Model "
                    ++ name
                    ++ ".Msg"
                )
            )
        |> Utils.recordType
        |> Utils.indent 1


pagesUpgradedValues : List Path -> String
pagesUpgradedValues paths =
    paths
        |> List.map
            (\path ->
                ( Path.toVariableName path
                , "Pages."
                    ++ Path.toModulePath path
                    ++ ".page |> upgrade "
                    ++ Path.toTypeName path
                    ++ "__Model "
                    ++ Path.toTypeName path
                    ++ "__Msg"
                )
            )
        |> Utils.recordValue
        |> Utils.indent 1


pagesInit : List Path -> String
pagesInit paths =
    Utils.function
        { name = "init"
        , annotation = [ "Route", "Shared.Model", "( Model, Cmd Msg )" ]
        , inputs = [ "route" ]
        , body =
            Utils.caseExpression
                { variable = "route"
                , cases =
                    paths
                        |> List.map
                            (\path ->
                                ( "Route."
                                    ++ Path.toTypeName path
                                    ++ (if Path.hasParams path then
                                            " params"

                                        else
                                            ""
                                       )
                                , "pages."
                                    ++ Path.toVariableName path
                                    ++ ".init"
                                    ++ (if Path.hasParams path then
                                            " params"

                                        else
                                            " ()"
                                       )
                                )
                            )
                }
        }


pagesUpdate : List Path -> String
pagesUpdate paths =
    Utils.function
        { name = "update"
        , annotation = [ "Msg", "Model", "( Model, Cmd Msg )" ]
        , inputs = [ "bigMsg bigModel" ]
        , body =
            Utils.caseExpression
                { variable = "( bigMsg, bigModel )"
                , cases =
                    paths
                        |> List.map
                            (\path ->
                                let
                                    typeName =
                                        Path.toTypeName path
                                in
                                ( "( "
                                    ++ typeName
                                    ++ "__Msg msg, "
                                    ++ typeName
                                    ++ "__Model model )"
                                , "pages." ++ Path.toVariableName path ++ ".update msg model"
                                )
                            )
                        |> (\cases ->
                                if List.length paths == 1 then
                                    cases

                                else
                                    cases ++ [ ( "_", "( bigModel, Cmd.none )" ) ]
                           )
                }
        }


pagesBundle : List Path -> String
pagesBundle paths =
    Utils.function
        { name = "bundle"
        , annotation = [ "Model", "Bundle" ]
        , inputs = [ "bigModel" ]
        , body =
            Utils.caseExpression
                { variable = "bigModel"
                , cases =
                    paths
                        |> List.map
                            (\path ->
                                let
                                    typeName =
                                        Path.toTypeName path
                                in
                                ( typeName ++ "__Model model"
                                , "pages." ++ Path.toVariableName path ++ ".bundle model"
                                )
                            )
                }
        }
