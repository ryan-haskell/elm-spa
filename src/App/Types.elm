module App.Types exposing
    ( Bundle
    , Init
    , Page
    , Recipe
    , Update
    )

import Internals.Page as Page


type alias Page pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg =
    Page.Page pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg


type alias Recipe pageRoute pageModel pageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg =
    Page.Recipe pageRoute pageModel pageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg


type alias Init layoutModel layoutMsg globalModel globalMsg =
    Page.Init layoutModel layoutMsg globalModel globalMsg


type alias Update layoutModel layoutMsg globalModel globalMsg =
    Page.Update layoutModel layoutMsg globalModel globalMsg


type alias Bundle layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg =
    Page.Bundle layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg
