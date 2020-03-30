module Spa.Advanced exposing
    ( Page
    , static
    , sandbox
    , element
    , component
    , upgrade
    , Bundle
    )

{-|


## prefer elm-ui?

If you'd rather use something like [elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/)
or have your page's `view` functions return something besides `Html`, this module
extends the `Spa.Page` module's API with one additional parameter.

@docs Page


## avoid doing this

Instead of having all the pages in your app specify all 6 parameters
_every time_:

    import Browser exposing (Document)
    import Global
    import Spa

    page : Spa.Page Flags Model Msg Global.Model Global.Msg (Document Msg)
    page =
        Spa.static
            { view = view
            }


## try this instead!

It's recommended to create a single `src/Page.elm` file for your project, just
[like the one created by `elm-spa init`](https://github.com/ryannhg/elm-spa/blob/master/cli/projects/new/src/Page.elm).

The `Page` module exposes type aliases and functions that know which `Global.Model` and `Global.Msg`
to use, which allow the compiler to provide better error messages.

Additionally, it make your type annotations way easier to read!

    import Page exposing (Document, Page)

    page : Page Flags Model Msg
    page =
        Page.static
            { view = view
            }

(If you're doing things correctly you should only see `import Spa` or
`import Spa.Advanced` once in your entire project!)


## compatible with the cli tool!

Using the technique describe above means the [cli tool](https://npmjs.org/elm-spa)
will be able to work

These links are full `src/Page.elm` implementations you can drop
into your app:

  - [Using Html (with Browser.Document)](https://gist.github.com/ryannhg/914f45a83a980d7c765d62a093ad6f38)
  - [Using Elm UI](https://gist.github.com/ryannhg/c501f9a31727c4917fccd669ffbd9ef3)


# static pages

@docs static


# sandbox pages

@docs sandbox


# element pages

@docs element


# component pages

@docs component


## upgrading pages

The `Page` module discussed above should also export
an `upgrade` function. This means providing an extra function
to map one view to another.


### an example with elm/browser

    import Browser
    import Html

    type alias Document msg =
        Browser.Document msg

    upgrade =
        Spa.Advanced.upgrade
            (\fn doc ->
                { title = doc.title
                , body = List.map (Html.map fn) doc.body
                }
            )


### an example with mdgriffith/elm-ui

    import Element exposing (Element)

    type alias Document msg =
        { title : String
        , body : List (Element msg)
        }

    upgrade =
        Spa.Advanced.upgrade
            (\fn doc ->
                { title = doc.title
                , body = List.map (Element.map fn) doc.body
                }
            )

@docs upgrade

@docs Bundle

-}

-- PAGE


{-| Just like [Spa.Page](https://package.elm-lang.org/packages/ryannhg/elm-spa/latest/Spa#Page),
but the `view` function returns `view_msg` instead of enforcing the use of
[Browser.Document msg](https://package.elm-lang.org/packages/elm/browser/latest/Browser#Document)
-}
type alias Page flags model msg globalModel globalMsg view_msg =
    { init : globalModel -> flags -> ( model, Cmd msg, Cmd globalMsg )
    , update : globalModel -> msg -> model -> ( model, Cmd msg, Cmd globalMsg )
    , view : globalModel -> model -> view_msg
    , subscriptions : globalModel -> model -> Sub msg
    }


{-|

    import Page exposing (Page)

    page : Page Flags Model Msg
    page =
        Page.static
            { view = view
            }

-}
static :
    { view : view_msg
    }
    -> Page flags () msg globalModel globalMsg view_msg
static options =
    { init = \_ _ -> ( (), Cmd.none, Cmd.none )
    , update = \_ _ model -> ( model, Cmd.none, Cmd.none )
    , view = \_ _ -> options.view
    , subscriptions = \_ _ -> Sub.none
    }


{-|

    import Page exposing (Page)

    page : Page Flags Model Msg
    page =
        Page.sandbox
            { init = init
            , update = update
            , view = view
            }

-}
sandbox :
    { init : model
    , update : msg -> model -> model
    , view : model -> view_msg
    }
    -> Page flags model msg globalModel globalMsg view_msg
sandbox options =
    { init = \_ _ -> ( options.init, Cmd.none, Cmd.none )
    , update = \_ msg model -> ( options.update msg model, Cmd.none, Cmd.none )
    , view = always options.view
    , subscriptions = \_ _ -> Sub.none
    }


{-|

    import Page exposing (Page)

    page : Page Flags Model Msg
    page =
        Page.element
            { init = init
            , update = update
            , subscriptions = subscriptions
            , view = view
            }

-}
element :
    { init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> view_msg
    , subscriptions : model -> Sub msg
    }
    -> Page flags model msg globalModel globalMsg view_msg
element page =
    { init = \_ flags -> page.init flags |> (\( model, cmd ) -> ( model, cmd, Cmd.none ))
    , update = \_ msg model -> page.update msg model |> (\( model_, cmd ) -> ( model_, cmd, Cmd.none ))
    , subscriptions = always page.subscriptions
    , view = always page.view
    }


{-|

    import Page exposing (Page)

    page : Page Flags Model Msg
    page =
        Page.component
            { init = init
            , update = update
            , subscriptions = subscriptions
            , view = view
            }

-}
component :
    { init : globalModel -> flags -> ( model, Cmd msg, Cmd globalMsg )
    , update : globalModel -> msg -> model -> ( model, Cmd msg, Cmd globalMsg )
    , view : globalModel -> model -> view_msg
    , subscriptions : globalModel -> model -> Sub msg
    }
    -> Page flags model msg globalModel globalMsg view_msg
component =
    identity


{-| Same as [Spa.upgrade](https://package.elm-lang.org/packages/ryannhg/elm-spa/latest/Spa#upgrade), but needs an extra map function as the first argument
to upgrade one view to another!
-}
upgrade :
    ((pageMsg -> msg) -> view_pageMsg -> view_msg)
    -> (pageModel -> model)
    -> (pageMsg -> msg)
    -> Page pageFlags pageModel pageMsg globalModel globalMsg view_pageMsg
    ->
        { init : pageFlags -> globalModel -> ( model, Cmd msg, Cmd globalMsg )
        , update : pageMsg -> pageModel -> globalModel -> ( model, Cmd msg, Cmd globalMsg )
        , bundle : pageModel -> globalModel -> Bundle msg view_msg
        }
upgrade viewMap toModel toMsg page =
    { init =
        \flags global ->
            page.init global flags |> (\( model, cmd, globalCmd ) -> ( toModel model, Cmd.map toMsg cmd, globalCmd ))
    , update =
        \msg model global ->
            page.update global msg model |> (\( model_, cmd, globalCmd ) -> ( toModel model_, Cmd.map toMsg cmd, globalCmd ))
    , bundle =
        \model global ->
            { view = page.view global model |> viewMap toMsg
            , subscriptions = page.subscriptions global model |> Sub.map toMsg
            }
    }


{-| Bundle behaves the same as [Spa.Bundle](https://package.elm-lang.org/packages/ryannhg/elm-spa/latest/Spa#Bundle),
but supports more than just `Browser.Document msg` for the view's return type!
-}
type alias Bundle msg view_msg =
    { view : view_msg
    , subscriptions : Sub msg
    }
