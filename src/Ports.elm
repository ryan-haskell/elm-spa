port module Ports exposing (add, build, uhhh)

import Add.Application
import Add.Element
import Add.Sandbox
import Add.Static
import Generators.Pages as Pages
import Generators.Route as Route
import Path exposing (Path)


port addPort : { filepath : String, content : String } -> Cmd msg


port buildPort : List { filepath : String, content : String } -> Cmd msg


port uhhh : () -> Cmd msg


add : { name : String, pageType : String } -> Cmd msg
add { name, pageType } =
    let
        path =
            Path.fromModuleName name

        sendItBro : String -> Cmd msg
        sendItBro content =
            addPort
                { filepath = Path.toFilepath path
                , content = content
                }
    in
    case pageType of
        "static" ->
            path
                |> Add.Static.create
                |> sendItBro

        "sandbox" ->
            path
                |> Add.Sandbox.create
                |> sendItBro

        "element" ->
            path
                |> Add.Element.create
                |> sendItBro

        "application" ->
            path
                |> Add.Application.create
                |> sendItBro

        _ ->
            uhhh ()


build : List Path -> Cmd msg
build paths =
    buildPort
        [ { filepath = "Spa/Generated/Route.elm"
          , content = Route.generate paths
          }
        , { filepath = "Spa/Generated/Pages.elm"
          , content = Pages.generate paths
          }
        ]
