module Data.Tab exposing
    ( Tab
    , ourMission
    , ourTeam
    , ourValues
    , toString
    )


type Tab
    = OurTeam
    | OurValues
    | OurMission


ourTeam : Tab
ourTeam =
    OurTeam


ourValues : Tab
ourValues =
    OurValues


ourMission : Tab
ourMission =
    OurMission


toString : Tab -> String
toString tab =
    case tab of
        OurTeam ->
            "Our Team"

        OurValues ->
            "Our Values"

        OurMission ->
            "Our Mission"
