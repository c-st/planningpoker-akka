module View exposing (view)

import Model exposing (User, Model, Task, Page(..), Msg(..), State(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.LandingPage exposing (landingPageContent)
import Views.PokerRoomPage exposing (planningPokerPageContent)


view : Model -> Html Msg
view model =
    case model.activePage of
        LandingPage ->
            div [ class "full-height m0 p0 flex flex-column" ]
                [ header [ class "px3 py4 white p3 border-silver border-bottom bg-blue" ]
                    [ h1 [ class "m0 h0-responsive mt2 mb0 bold" ] [ text "Planning Poker" ]
                    ]
                , main'
                    [ class "flex-auto" ]
                    [ section [ class "container" ]
                        [ div
                            [ class "sm-col sm-col-3 p1 m0" ]
                            [ text "" ]
                        , div
                            [ class "sm-col sm-col-6 mt3 px2 border-silver p2" ]
                            [ landingPageContent model ]
                        ]
                    ]
                , footer [ class "p2 pt3 center gray border-silver border-top" ] [ text "Footer" ]
                ]

        PlanningPokerRoom ->
            planningPokerPageContent model
