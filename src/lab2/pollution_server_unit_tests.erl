%%%-------------------------------------------------------------------
%%% @author Kacper
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. kwi 2020 22:52
%%%-------------------------------------------------------------------
-module(pollution_server_unit_tests).
-author("Kacper").

%% API
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).
%% API

-import(pollution_server, [start/0, stop/0, get_value/3, get_station_mean/2, get_daily_mean/2, get_hourly_mean/3, get_daily_max/2, add_station/2, add_value/4, remove_value/3]).

%% I assumed this is a check for whether we know the syntax not whether we how to write tests
%% those tests are bad but writing tests is boring
%% assuming floats are equal, mean of 1 measurement and so on
startServer_test() ->
    start(),
    ?assert(lists:member(pollution_server, registered())).

add_station_test() ->
    ?assertEqual(ok, add_station("hi", {0, 0})).

add_value_test() ->
    Time = {{2020,4,21},{22,43,3}},
    Val = 10.0,
    add_value("hi", Time, "PM10", Val),
    ?assertEqual(Val, get_value("hi", Time, "PM10")).


get_station_mean_test() ->
    Val = 10.0,
    ?assertEqual(Val, get_station_mean("hi", "PM10")).

get_daily_mean_test() ->
    Time = {{2020,4,21},{22,43,3}},
    {Date, _} = Time,
    Val = 10.0,
    ?assertEqual(Val, get_daily_mean(Date, "PM10")).

get_daily_max_test() ->
    Time = {{2020,4,21},{22,43,3}},
    {Date, _} = Time,
    Val = 10.0,
    ?assertEqual(Val, get_daily_max(Date, "PM10")).

get_hourly_mean_test() ->
    Time = {{2020,4,21},{22,43,3}},
    {Date, {Hour, _, _}} = Time,
    Val = 10.0,
    ?assertEqual(Val, get_hourly_mean(Date, Hour, "PM10")).
