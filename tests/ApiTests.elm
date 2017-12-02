module ApiTests exposing (..)

import Api exposing (..)
import Date
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Http
import Json.Decode as Decode
import Result.Extra exposing (..)
import Test exposing (..)


suite : Test
suite =
    describe "API"
        [ describe "Authentication"
            [ test "getHeaders" <|
                \() ->
                    Expect.equal
                        (getHeaders "foo")
                        [ Http.header "Authorization" "Bearer foo" ]
            ]
        , describe "Decoders"
            [ describe "sensorDecoder"
                [ test "Valid" <|
                    \() ->
                        let
                            result =
                                Decode.decodeString sensorDecoder
                                    """
                                    { "id": 1
                                    , "device_name": "foo"
                                    , "caption": "A nice sensor."
                                    , "latitude": 1.00
                                    , "longitude": 2.00
                                    , "sponsor_id": 7
                                    , "created_at": "2016-11-29T20:35:21.813Z"
                                    , "updated_at": "2016-11-29T20:36:48.016Z"
                                    }
                                    """
                        in
                            unpack
                                Expect.fail
                                (Expect.all
                                    [ \sensor -> Expect.equal sensor.id 1
                                    , \sensor -> Expect.equal sensor.deviceName "foo"
                                    , \sensor -> Expect.equal sensor.caption (Just "A nice sensor.")
                                    , \sensor -> Expect.equal sensor.latitude 1.0
                                    , \sensor -> Expect.equal sensor.longitude 2.0
                                    , \sensor -> Expect.equal sensor.sponsorId (Just 7)
                                    , \sensor ->
                                        Date.fromString "2016-11-29T20:35:21.813Z"
                                            |> unpack
                                                (\_ -> Expect.fail "Could not parse createdAt expectation date")
                                                (\expected -> Expect.equal sensor.createdAt expected)
                                    , \sensor ->
                                        Date.fromString "2016-11-29T20:36:48.016Z"
                                            |> unpack
                                                (\_ -> Expect.fail "Could not parse updatedAt expectation date")
                                                (\expected -> Expect.equal sensor.updatedAt expected)
                                    ]
                                )
                                result
                , test "Minimal" <|
                    \() ->
                        let
                            result =
                                Decode.decodeString sensorDecoder
                                    """
                                    { "id": 1
                                    , "device_name": "foo"
                                    , "caption": null
                                    , "latitude": 1.00
                                    , "longitude": 2.00
                                    , "sponsor_id": null
                                    , "created_at": "2016-11-29T20:35:21.813Z"
                                    , "updated_at": "2016-11-29T20:36:48.016Z"
                                    }
                                    """
                        in
                            unpack
                                Expect.fail
                                (Expect.all
                                    [ \sensor -> Expect.equal sensor.id 1
                                    , \sensor -> Expect.equal sensor.caption Nothing
                                    , \sensor -> Expect.equal sensor.sponsorId Nothing
                                    ]
                                )
                                result
                , test "Extra fields" <|
                    \() ->
                        let
                            result =
                                Decode.decodeString sensorDecoder
                                    """
                                    { "id": 1
                                    , "device_name": "foo"
                                    , "caption": null
                                    , "latitude": 1.00
                                    , "longitude": 2.00
                                    , "sponsor_id": null
                                    , "created_at": "2016-11-29T20:35:21.813Z"
                                    , "updated_at": "2016-11-29T20:36:48.016Z"
                                    , "blergh": "blubh"
                                    }
                                    """
                        in
                            case result of
                                Ok _ ->
                                    Expect.pass

                                Err errmsg ->
                                    Expect.fail <| "JSON with extra field could not be parsed: " ++ errmsg
                , test "No caption" <|
                    \() ->
                        let
                            result =
                                Decode.decodeString sensorDecoder
                                    """
                                    { "id": 1
                                    , "device_name": "foo"
                                    , "latitude": 1.00
                                    , "longitude": 2.00
                                    , "sponsor_id": null
                                    , "created_at": "2016-11-29T20:35:21.813Z"
                                    , "updated_at": "2016-11-29T20:36:48.016Z"
                                    , "blergh": "blubh"
                                    }
                                    """
                        in
                            unpack
                                (\errmsg ->
                                    Expect.true
                                        ("Error \"" ++ errmsg ++ "\" did not match expectation")
                                        (String.startsWith "Expecting an object with a field named `caption` but instead got:" errmsg)
                                )
                                (\_ -> Expect.fail "No parse error error for missing caption")
                                result
                ]
            ]
        ]
