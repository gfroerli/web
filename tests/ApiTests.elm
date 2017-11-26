module ApiTests exposing (..)

import Json.Decode as Decode
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Http
import Api exposing (..)
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
                                    }
                                    """
                        in
                            Expect.equal result <|
                                Ok (Sensor 1 "foo" (Just "A nice sensor."))
                , test "Null caption" <|
                    \() ->
                        let
                            result =
                                Decode.decodeString sensorDecoder
                                    """
                                    { "id": 1
                                    , "device_name": "foo"
                                    , "caption": null
                                    }
                                    """
                        in
                            Expect.equal result <|
                                Ok (Sensor 1 "foo" Nothing)
                , test "Extra fields" <|
                    \() ->
                        let
                            result =
                                Decode.decodeString sensorDecoder
                                    """
                                    { "id": 1
                                    , "device_name": "foo"
                                    , "caption": null
                                    , "blergh": "blubh"
                                    }
                                    """
                        in
                            Expect.equal result <|
                                Ok (Sensor 1 "foo" Nothing)
                , test "No caption" <|
                    \() ->
                        let
                            result =
                                Decode.decodeString sensorDecoder
                                    """
                                    { "id": 1
                                    , "device_name": "foo"
                                    }
                                    """
                        in
                            Expect.equal
                                result
                                (Err """Expecting an object with a field named `caption` but instead got: {"id":1,"device_name":"foo"}""")
                , test "No id" <|
                    \() ->
                        let
                            result =
                                Decode.decodeString sensorDecoder
                                    """
                                    { "device_name": "foo"
                                    , "caption": null
                                    }
                                    """
                        in
                            Expect.equal
                                result
                                (Err """Expecting an object with a field named `id` but instead got: {"device_name":"foo","caption":null}""")
                ]
            ]
        ]
