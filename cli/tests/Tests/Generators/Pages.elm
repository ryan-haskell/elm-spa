module Tests.Generators.Pages exposing (suite)

import Expect exposing (Expectation)
import Generators.Pages as Pages
import Path exposing (Path)
import Test exposing (..)


paths :
    { empty : List Path
    , single : List Path
    , multiple : List Path
    }
paths =
    { empty = []
    , single =
        [ Path.fromFilepath "Top.elm"
        ]
    , multiple =
        [ Path.fromFilepath "Top.elm"
        , Path.fromFilepath "About.elm"
        , Path.fromFilepath "NotFound.elm"
        , Path.fromFilepath "Posts/Top.elm"
        , Path.fromFilepath "Posts/Dynamic.elm"
        , Path.fromFilepath "Authors/Dynamic/Posts/Dynamic.elm"
        ]
    }


suite : Test
suite =
    describe "Generators.Pages"
        [ describe "pagesImports"
            [ test "returns empty string when no paths" <|
                \_ ->
                    paths.empty
                        |> Pages.pagesImports
                        |> Expect.equal ""
            , test "returns single import for single path" <|
                \_ ->
                    paths.single
                        |> Pages.pagesImports
                        |> Expect.equal "import Pages.Top"
            , test "returns multiple import for multiple path" <|
                \_ ->
                    paths.multiple
                        |> Pages.pagesImports
                        |> Expect.equal (String.trim """
import Pages.Top
import Pages.About
import Pages.NotFound
import Pages.Posts.Top
import Pages.Posts.Dynamic
import Pages.Authors.Dynamic.Posts.Dynamic
""")
            , describe "pagesCustomType"
                [ test "works with single path" <|
                    \_ ->
                        paths.single
                            |> Pages.pagesCustomType "Model"
                            |> Expect.equal "type Model = Top_Model Pages.Top.Model"
                , test "works with multiple paths" <|
                    \_ ->
                        paths.multiple
                            |> Pages.pagesCustomType "Model"
                            |> Expect.equal (String.trim """
type Model
    = Top_Model Pages.Top.Model
    | About_Model Pages.About.Model
    | NotFound_Model Pages.NotFound.Model
    | Posts_Top_Model Pages.Posts.Top.Model
    | Posts_Dynamic_Model Pages.Posts.Dynamic.Model
    | Authors_Dynamic_Posts_Dynamic_Model Pages.Authors.Dynamic.Posts.Dynamic.Model
""")
                ]
            , describe "pagesUpgradedTypes"
                [ test "works with single path" <|
                    \_ ->
                        paths.single
                            |> Pages.pagesUpgradedTypes
                            |> Expect.equal "    { top : UpgradedPage Pages.Top.Flags Pages.Top.Model Pages.Top.Msg }"
                , test "works with multiple paths" <|
                    \_ ->
                        paths.multiple
                            |> Pages.pagesUpgradedTypes
                            |> Expect.equal """    { top : UpgradedPage Pages.Top.Flags Pages.Top.Model Pages.Top.Msg
    , about : UpgradedPage Pages.About.Flags Pages.About.Model Pages.About.Msg
    , notFound : UpgradedPage Pages.NotFound.Flags Pages.NotFound.Model Pages.NotFound.Msg
    , posts_top : UpgradedPage Pages.Posts.Top.Flags Pages.Posts.Top.Model Pages.Posts.Top.Msg
    , posts_dynamic : UpgradedPage Pages.Posts.Dynamic.Flags Pages.Posts.Dynamic.Model Pages.Posts.Dynamic.Msg
    , authors_dynamic_posts_dynamic : UpgradedPage Pages.Authors.Dynamic.Posts.Dynamic.Flags Pages.Authors.Dynamic.Posts.Dynamic.Model Pages.Authors.Dynamic.Posts.Dynamic.Msg
    }"""
                ]
            , describe "pagesUpgradedValues"
                [ test "works with single path" <|
                    \_ ->
                        paths.single
                            |> Pages.pagesUpgradedValues
                            |> Expect.equal "    { top = Pages.Top.page |> Spa.upgrade Top_Model Top_Msg }"
                , test "works with multiple paths" <|
                    \_ ->
                        paths.multiple
                            |> Pages.pagesUpgradedValues
                            |> Expect.equal """    { top = Pages.Top.page |> Spa.upgrade Top_Model Top_Msg
    , about = Pages.About.page |> Spa.upgrade About_Model About_Msg
    , notFound = Pages.NotFound.page |> Spa.upgrade NotFound_Model NotFound_Msg
    , posts_top = Pages.Posts.Top.page |> Spa.upgrade Posts_Top_Model Posts_Top_Msg
    , posts_dynamic = Pages.Posts.Dynamic.page |> Spa.upgrade Posts_Dynamic_Model Posts_Dynamic_Msg
    , authors_dynamic_posts_dynamic = Pages.Authors.Dynamic.Posts.Dynamic.page |> Spa.upgrade Authors_Dynamic_Posts_Dynamic_Model Authors_Dynamic_Posts_Dynamic_Msg
    }"""
                ]
            , describe "pagesInit"
                [ test "works with single path" <|
                    \_ ->
                        paths.single
                            |> Pages.pagesInit
                            |> Expect.equal (String.trim """
init : Route -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
init route =
    case route of
        Route.Top ->
            pages.top.init ()
""")
                , test "works with multiple path" <|
                    \_ ->
                        paths.multiple
                            |> Pages.pagesInit
                            |> Expect.equal (String.trim """
init : Route -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
init route =
    case route of
        Route.Top ->
            pages.top.init ()
        
        Route.About ->
            pages.about.init ()
        
        Route.NotFound ->
            pages.notFound.init ()
        
        Route.Posts_Top ->
            pages.posts_top.init ()
        
        Route.Posts_Dynamic params ->
            pages.posts_dynamic.init params
        
        Route.Authors_Dynamic_Posts_Dynamic params ->
            pages.authors_dynamic_posts_dynamic.init params
""")
                ]
            , describe "pagesUpdate" <|
                [ test "works with single path" <|
                    \_ ->
                        paths.single
                            |> Pages.pagesUpdate
                            |> Expect.equal (String.trim """
update : Msg -> Model -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( Top_Msg msg, Top_Model model ) ->
            pages.top.update msg model
""")
                , test "works with multiple paths" <|
                    \_ ->
                        paths.multiple
                            |> Pages.pagesUpdate
                            |> Expect.equal (String.trim """
update : Msg -> Model -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( Top_Msg msg, Top_Model model ) ->
            pages.top.update msg model
        
        ( About_Msg msg, About_Model model ) ->
            pages.about.update msg model
        
        ( NotFound_Msg msg, NotFound_Model model ) ->
            pages.notFound.update msg model
        
        ( Posts_Top_Msg msg, Posts_Top_Model model ) ->
            pages.posts_top.update msg model
        
        ( Posts_Dynamic_Msg msg, Posts_Dynamic_Model model ) ->
            pages.posts_dynamic.update msg model
        
        ( Authors_Dynamic_Posts_Dynamic_Msg msg, Authors_Dynamic_Posts_Dynamic_Model model ) ->
            pages.authors_dynamic_posts_dynamic.update msg model
        
        _ ->
            always ( bigModel, Cmd.none, Cmd.none )
""")
                ]
            , describe "pagesBundle" <|
                [ test "works with single path" <|
                    \_ ->
                        paths.single
                            |> Pages.pagesBundle
                            |> Expect.equal (String.trim """
bundle : Model -> Global.Model -> Spa.Bundle Msg
bundle bigModel =
    case bigModel of
        Top_Model model ->
            pages.top.bundle model
""")
                , test "works with multiple paths" <|
                    \_ ->
                        paths.multiple
                            |> Pages.pagesBundle
                            |> Expect.equal (String.trim """
bundle : Model -> Global.Model -> Spa.Bundle Msg
bundle bigModel =
    case bigModel of
        Top_Model model ->
            pages.top.bundle model
        
        About_Model model ->
            pages.about.bundle model
        
        NotFound_Model model ->
            pages.notFound.bundle model
        
        Posts_Top_Model model ->
            pages.posts_top.bundle model
        
        Posts_Dynamic_Model model ->
            pages.posts_dynamic.bundle model
        
        Authors_Dynamic_Posts_Dynamic_Model model ->
            pages.authors_dynamic_posts_dynamic.bundle model
""")
                ]
            ]
        ]
