module JsonCoding exposing (..)

import Model exposing (User, Task, Msg(..))
import Json.Decode as JD exposing ((:=), andThen)
import Json.Encode as JE exposing (encode)
import Date exposing (fromString)


stringToDate : JD.Decoder Date.Date
stringToDate =
    JD.string
        `andThen`
            \val ->
                case Date.fromString val of
                    Err err ->
                        JD.fail err

                    Ok date ->
                        JD.succeed date


payloadDecoder : JD.Decoder Msg
payloadDecoder =
    ("eventType" := JD.string)
        `andThen`
            \eventType ->
                case eventType of
                    "keepAlive" ->
                        JD.succeed ServerHeartbeat

                    "userJoined" ->
                        JD.map UserJoined
                            (JD.object4 User
                                ("userName" := JD.string)
                                ("isSpectator" := JD.bool)
                                (JD.succeed False)
                                (JD.succeed Nothing)
                            )

                    "userLeft" ->
                        JD.map UserLeft
                            (JD.object4 User
                                ("userName" := JD.string)
                                (JD.succeed False)
                                (JD.succeed False)
                                (JD.succeed Nothing)
                            )

                    "startEstimation" ->
                        JD.map StartEstimation
                            (JD.object2 Task
                                ("taskName" := JD.string)
                                ("startDate" := stringToDate)
                            )

                    "userHasEstimated" ->
                        JD.map UserHasEstimated
                            (JD.object4 User
                                ("userName" := JD.string)
                                (JD.succeed False)
                                (JD.succeed True)
                                (JD.succeed Nothing)
                            )

                    "estimationResult" ->
                        -- startDate/endDate
                        JD.map EstimationResult
                            (JD.at
                                [ "estimates" ]
                                (JD.list
                                    (JD.object4 User
                                        ("userName" := JD.string)
                                        (JD.succeed False)
                                        (JD.succeed True)
                                        (JD.maybe ("estimate" := JD.string))
                                    )
                                )
                            )

                    _ ->
                        JD.fail (eventType ++ " is not a recognized event type")


decodePayload : String -> Msg
decodePayload payload =
    case JD.decodeString payloadDecoder payload of
        Err err ->
            UnexpectedPayload err

        Ok msg ->
            msg


requestStartEstimationEncoded : User -> Task -> String
requestStartEstimationEncoded user task =
    let
        list =
            [ ( "eventType", JE.string "startEstimation" )
            , ( "userName", JE.string user.name )
            , ( "taskName", JE.string task.name )
            ]
    in
        list |> JE.object |> JE.encode 0


userEstimationEncoded : User -> Task -> String
userEstimationEncoded user task =
    let
        estimation =
            Maybe.withDefault "" user.estimation

        list =
            [ ( "eventType", JE.string "estimate" )
            , ( "userName", JE.string user.name )
            , ( "taskName", JE.string task.name )
            , ( "estimate", JE.string estimation )
            ]
    in
        list |> JE.object |> JE.encode 0


requestShowResultEncoded : User -> String
requestShowResultEncoded user =
    let
        list =
            [ ( "eventType", JE.string "showResult" )
            , ( "userName", JE.string user.name )
            ]
    in
        list |> JE.object |> JE.encode 0
