module MediaPlayer.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onMouseOver, onMouseOut)
import Date exposing (Date, Month(..), year, month, day)
import Date.Extra as Date exposing (Interval(..))
import MediaPlayer.Model exposing (..)
import MediaPlayer.Utils exposing (..)
import MediaPlayer.Msg exposing (..)
import Time


classNameFromState : DayState -> String
classNameFromState state =
    case state of
        Normal ->
            ""

        Dimmed ->
            "lastmonth"

        Disabled ->
            ""

        Selected ->
            "current"

        Hovered ->
            "hovered"


isSelected : Maybe Date -> Date -> Bool
isSelected selectedStartDay date =
    case selectedStartDay of
        Nothing ->
            False

        Just selectedDate ->
            Date.equal selectedDate date


isBetween : Maybe Date -> Maybe Date -> Date -> Bool
isBetween start end needle =
    case
        Maybe.map2
            (\start end ->
                let
                    isBeforeStart =
                        ((needle |> Date.toTime |> Time.inMilliseconds)
                            > (start |> Date.toTime |> Time.inMilliseconds)
                        )
                in
                    isBeforeStart && Date.isBetween start end needle
            )
            start
            end
    of
        Nothing ->
            False

        Just val ->
            val


isCurrentMonth : Date -> Int -> Bool
isCurrentMonth date selectedMonthIndex =
    Date.monthNumber date == selectedMonthIndex + 1


calendarDay : Date -> Model -> Html Msg
calendarDay date model =
    let
        state =
            case Maybe.oneOf [ model.selectedEndDay ] of
                Nothing ->
                    if isSelected model.selectedStartDay date then
                        Selected
                    else if isSelected model.selectedEndDay date then
                        Selected
                    else if isBetween model.selectedStartDay model.hoveredDay date then
                        Hovered
                    else if isCurrentMonth date model.selectedMonthIndex then
                        Normal
                    else
                        Dimmed

                Just endDate ->
                    if
                        isSelected model.selectedStartDay date
                            || isBetween model.selectedStartDay model.selectedEndDay date
                    then
                        Selected
                    else if isCurrentMonth date model.selectedMonthIndex then
                        Normal
                    else
                        Dimmed
    in
        td
            [ class <| classNameFromState state
            , onClick <| SelectDay date
            , onMouseOver <| HoverDay date
            , onMouseOut <| BlurDay date
            ]
            [ text <| toString (day date) ]


calendarRow : List Date -> Model -> Html Msg
calendarRow dateRow model =
    tr []
        (List.map (\day -> calendarDay day model) dateRow)


calenderHeader : String -> Html Msg
calenderHeader title =
    h1 []
        [ text title ]


calendarView : Model -> Html Msg
calendarView model =
    let
        weeks =
            model.currentDates |> chunk dayPerWeek

        _ =
            Debug.log "selectedStartDay" model.selectedStartDay

        _ =
            Debug.log "selectedEndDay" model.selectedEndDay
    in
        div [ id "calendar" ]
            [ calenderHeader (getMonthNameByIndex model.selectedMonthIndex)
            , table []
                (List.map (\row -> calendarRow row model) weeks)
            ]