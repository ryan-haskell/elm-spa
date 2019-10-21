module TransitionStuff exposing
    ( Animations
    , State
    , Visibility(..)
    , nextState
    , outIn
    , transition
    )

import Internals.Utils as Utils


type Visibility
    = Invisible
    | Visible


type alias State page =
    { page : page
    , visibility : Visibility
    }


type alias Animations =
    { entering : Int
    , exiting : Int
    }


outIn :
    { toAnimations : page -> Animations
    , current : State page
    , next : State page
    }
    -> Int
outIn { toAnimations, current, next } =
    let
        animations =
            toAnimations current.page
    in
    case ( current.visibility, next.visibility ) of
        ( Visible, Invisible ) ->
            0

        ( Invisible, Invisible ) ->
            animations.exiting

        ( Invisible, Visible ) ->
            animations.entering

        ( Visible, Visible ) ->
            0


nextState : page -> State page -> State page
nextState target state =
    case state.visibility of
        Invisible ->
            if state.page == target then
                { visibility = Visible, page = target }

            else
                { visibility = Invisible, page = target }

        Visible ->
            if state.page == target then
                state

            else
                { visibility = Invisible, page = state.page }


isComplete : State page -> State page -> Bool
isComplete =
    (==)


transition :
    (page -> Animations)
    ->
        { delay : Int
        , target : page
        , state : State page
        , msg : page -> msg
        }
    -> { delay : Int, cmd : Cmd msg }
transition toAnimations { delay, target, state, msg } =
    if isComplete state (nextState target state) then
        { delay = delay
        , cmd = Cmd.none
        }

    else
        let
            nextDelay =
                outIn
                    { toAnimations = toAnimations
                    , current = state
                    , next = nextState target state
                    }
        in
        { delay = nextDelay
        , cmd = Utils.delay nextDelay (msg target)
        }



-- program stuff
