module Spa exposing
    ( static
    , sandbox
    , element
    , component
    , Page
    , upgrade
    , Bundle
    )

{-| When you create an app with the [elm/browser](/packages/elm/browser/latest) package,
you can build anything from a static `Html msg` page to a fully-fledged web `Browser.application`.

`elm-spa` uses the existing design at the page-level, so you can quickly add new pages to your Elm application!


## the four kinds of pages:

1.  [static](#static-pages) – a page that only renders HTML.
2.  [sandbox](#sandbox-pages) – a page with state.
3.  [element](#element-pages) – a page with side-effects.
4.  [component](#component-pages) – a page with global state.


# static pages

Just like [Elm's intro "Hello!" example](https://elm-lang.org/examples/hello),
sometimes you just want a page that renders some HTML, without having any state.

@docs static

**Note:** Static pages don't store data, so Model is always an empty tuple: ()


# sandbox pages

When you're ready to keep track of state, like in
[Elm's "Counter" example](https://elm-lang.org/examples/buttons),
you can use a sandbox page.

Similar to `Browser.sandbox`, this allows you to init your model, and update it with messages!

@docs sandbox


# element pages

If you're ready to [send HTTP requests](https://elm-lang.org/examples/cat-gifs) or [listen to events](https://elm-lang.org/examples/time) for updates, it's time to upgrade to an element page!

Additionally, an element will give you access to Flags, so you can access things like URL parameters.

@docs element

**New to Cmd or Sub?** I recommend checking out Elm's official guide , that's a great place to wrap your head around these two concepts.


# component pages

If you need to access shared state across all pages, or need to send a global commands like signing in/signing out a user, a component page is what you'll need.

Component pages gain access to the `Global.Model`, and return an additional `Cmd Global.Msg` so you can read/update the global state of your application.

@docs component

**Cool trick:** Don't need access to Global.Model in all of your functions? Use always to skip the first argument.

In the following example, only the view function receives Global.Model:

    import Global
    import Spa exposing (Page)

    page : Page Flags Model Msg Global.Model Global.Msg
    page =
        Spa.component
            { init = always init
            , update = always update
            , view = view -- not using "always"!
            , subscriptions = always subscriptions
            }


# putting pages together

**Note:** The [elm-spa cli tool](https://www.npmjs.com/package/elm-spa) will generate all the upcoming code
for you. You can continue reading to understand what it's doing under the hood!

@docs Page


## learning with an example

Let's imagine we are building a website for a restaurant! This website has the following routes:

1.  `/home` - the homepage
2.  `/menu` - the menu
3.  `/faqs` - frequently asked questions

With `elm-spa` we'd create a module for each page, and import them together in one file.

    module Pages exposing (Model, Msg, init, update, view, subscriptions)

    import Pages.Home
    import Pages.Menu
    import Pages.Faqs

If we want to implement the `Pages.init` function, we'll need to return the same type of value. This means we need to make a shared model and a shared msg type to handle all the different pages in our application:

    type Model
        = Home_Model Pages.Home.Model
        | Menu_Model Pages.Menu.Model
        | Faqs_Model Pages.Faqs.Model

    type Msg
        = Home_Msg Pages.Home.Msg
        | Menu_Msg Pages.Menu.Msg
        | Faqs_Msg Pages.Faqs.Msg

These two types allow `init` to return `( Model, Cmd Msg, Cmd Global.Msg )` for any page that the user is looking at!


## upgrading pages

With the custom types above:

1.  `Home_Model` can upgrade a `Pages.Home.Model` to a `Model`
2.  `Home_Msg` can upgrade a `Pages.Home.Msg` to a `Msg`

We use the upgrade function to return a record that makes writing the combined `init`/`update`/`view`/`subscriptions` functions clean and easy!

@docs upgrade

    import Pages.Faqs
    import Pages.Home
    import Pages.Menu
    import Spa

    type alias UpgradedPage pageFlags pageModel pageMsg =
        { init : pageFlags -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
        , update : pageMsg -> pageModel -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
        , bundle : pageModel -> Global.Model -> Spa.Bundle Msg
        }

    type alias UpgradedPages =
        { home : UpgradedPage Pages.Home.Flags Pages.Home.Model Pages.Home.Msg
        , menu : UpgradedPage Pages.Menu.Flags Pages.Menu.Model Pages.Menu.Msg
        , faqs : UpgradedPage Pages.Faqs.Flags Pages.Faqs.Model Pages.Faqs.Msg
        }

    pages : UpgradedPages
    pages =
        { home = Pages.Home.page |> Spa.upgrade Home_Model Home_Msg
        , menu = Pages.Menu.page |> Spa.upgrade Menu_Model Menu_Msg
        , faqs = Pages.Faqs.page |> Spa.upgrade Faqs_Model Faqs_Msg
        }

Now when we write `init`, we can use the upgraded `pages` variable to keep things easy to read.


## implementing `init`

    import Route exposing (Route)

    init : Route -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
    init route =
        case route of
            Route.Home ->
                pages.home.init ()

            Route.Menu ->
                pages.menu.init ()

            Route.Faqs ->
                pages.faqs.init ()


## implementing `update`

    update : Msg -> Model -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
    update bigMsg bigModel =
        case ( bigMsg, bigModel ) of
            ( Home_Msg msg, Home_Model model ) ->
                pages.home.update msg model

            ( Menu_Msg msg, Menu_Model model ) ->
                pages.menu.update msg model

            ( Faqs_Msg msg, Faqs_Model model ) ->
                pages.faqs.update msg model

            _ ->
                always ( bigModel, Cmd.none, Cmd.none )


## implementing `bundle`

With `elm-spa`, we don't need to write out a case expression for both `view` and `subscriptions`.
We can just write one that bundles them together.

We can create `view` and `subscriptions` from this single function:

@docs Bundle


# that's it!

You can check out <https://elm-spa.dev> or join #elm-spa-users on the official Elm slack channel for any questions ❤️

-}

import Browser exposing (Document)
import Html
import Spa.Advanced as Advanced



-- PAGE


{-| What was the point of using the functions above? They all return the `Page` type,
and we can use the `Spa.upgrade` function on any of them!

(The following example will illustrate why that's a good thing)

-}
type alias Page flags model msg globalModel globalMsg =
    { init : globalModel -> flags -> ( model, Cmd msg, Cmd globalMsg )
    , update : globalModel -> msg -> model -> ( model, Cmd msg, Cmd globalMsg )
    , view : globalModel -> model -> Document msg
    , subscriptions : globalModel -> model -> Sub msg
    }


{-|

    page : Page Flags Model Msg globalModel globalMsg
    page =
        Spa.static
            { view = view
            }

-}
static :
    { view : Document msg
    }
    -> Page flags () msg globalModel globalMsg
static =
    Advanced.static


{-|

    import Spa exposing (Page)

    page : Page Flags Model Msg globalModel globalMsg
    page =
        Spa.sandbox
            { init = init
            , update = update
            , view = view
            }

-}
sandbox :
    { init : model
    , update : msg -> model -> model
    , view : model -> Document msg
    }
    -> Page flags model msg globalModel globalMsg
sandbox =
    Advanced.sandbox


{-|

    page : Page Flags Model Msg globalModel globalMsg
    page =
        Spa.element
            { init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }

-}
element :
    { init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Document msg
    , subscriptions : model -> Sub msg
    }
    -> Page flags model msg globalModel globalMsg
element =
    Advanced.element


{-|

    import Global
    import Spa exposing (Page)

    page : Page Flags Model Msg Global.Model Global.Msg
    page =
        Spa.component
            { init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }

-}
component :
    { init : globalModel -> flags -> ( model, Cmd msg, Cmd globalMsg )
    , update : globalModel -> msg -> model -> ( model, Cmd msg, Cmd globalMsg )
    , view : globalModel -> model -> Document msg
    , subscriptions : globalModel -> model -> Sub msg
    }
    -> Page flags model msg globalModel globalMsg
component =
    Advanced.component


{-| For each page we export from our `Pages.*` modules, we should call the `upgrade` function with the corresponding `Model` and `Msg` variants, like this:

    pages : UpgradedPages
    pages =
        { home = Pages.Home.page |> Spa.upgrade Home_Model Home_Msg
        , menu = Pages.Menu.page |> Spa.upgrade Menu_Model Menu_Msg
        , faqs = Pages.Faqs.page |> Spa.upgrade Faqs_Model Faqs_Msg
        }

-}
upgrade :
    (pageModel -> model)
    -> (pageMsg -> msg)
    -> Page pageFlags pageModel pageMsg globalModel globalMsg
    ->
        { init : pageFlags -> globalModel -> ( model, Cmd msg, Cmd globalMsg )
        , update : pageMsg -> pageModel -> globalModel -> ( model, Cmd msg, Cmd globalMsg )
        , bundle : pageModel -> globalModel -> Bundle msg
        }
upgrade =
    Advanced.upgrade
        (\toMsg doc ->
            { title = doc.title
            , body = List.map (Html.map toMsg) doc.body
            }
        )


{-|

    import Spa

    bundle : Model -> Global.Model -> Spa.Bundle Msg
    bundle bigModel =
        case bigModel of
            Home_Model model ->
                pages.home.bundle model

            Menu_Model model ->
                pages.menu.bundle model

            Faqs_Model model ->
                pages.faqs.bundle model

    view : Model -> Global.Model -> Document Msg
    view model =
        bundle model >> .view

    subscriptions : Model -> Global.Model -> Sub Msg
    subscriptions model =
        bundle model >> .subscriptions

-}
type alias Bundle msg =
    { view : Document msg
    , subscriptions : Sub msg
    }
