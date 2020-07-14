module Utils.Time exposing (format)

import DateFormat
import Time


format : Time.Posix -> String
format =
    DateFormat.format
        [ DateFormat.monthNameFull
        , DateFormat.text " "

        -- , DateFormat.dayOfMonthSuffix
        -- , DateFormat.text ", "
        , DateFormat.yearNumber
        ]
        Time.utc
