%%%-------------------------------------------------------------------
%%% @author Kacper
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. kwi 2020 21:52
%%%-------------------------------------------------------------------
-module(pollution_unit_tests).
-author("Kacper").
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).
%% API

-import(pollution, [create_monitor/0, add_station/3, add_value/5, remove_value/4, get_value/4, get_station_mean/3, get_daily_mean/3, get_hourly_mean/4, get_daily_max/3]).

%% I assumed this is a check for whether we know the syntax not whether we how to write tests
%% those tests are bad but writing tests is boring
%% assuming floats are equal, mean of 1 measurement and so on
create_monitor_test() ->
    ?assertEqual({monitor,[]}, create_monitor()).

add_station_test() ->
    M = create_monitor(),
    ?assertEqual({monitor,[{station,"hi",{0,0},[],[]}]}, add_station("hi", {0, 0}, M)).

add_value_test() ->
    Time = {{2020,4,21},{22,43,3}},
    M = create_monitor(),
    M1 = add_station("hi", {0, 0}, M),
    Val = 10.0,
    M2 = add_value("hi", Time, "PM10", Val, M1),
    ?assertEqual(Val, get_value("hi", Time, "PM10", M2)).


get_station_mean_test() ->
    Time = {{2020,4,21},{22,43,3}},
    M = create_monitor(),
    M1 = add_station("hi", {0, 0}, M),
    Val = 10.0,
    M2 = add_value("hi", Time, "PM10", Val, M1),
    ?assertEqual(Val, get_station_mean("hi", "PM10", M2)).

get_daily_mean_test() ->
    Time = {{2020,4,21},{22,43,3}},
    {Date, _} = Time,
    M = create_monitor(),
    M1 = add_station("hi", {0, 0}, M),
    Val = 10.0,
    M2 = add_value("hi", Time, "PM10", Val, M1),
    ?assertEqual(Val, get_daily_mean(Date, "PM10", M2)).

get_daily_max_test() ->
    Time = {{2020,4,21},{22,43,3}},
    {Date, _} = Time,
    M = create_monitor(),
    M1 = add_station("hi", {0, 0}, M),
    Val = 10.0,
    M2 = add_value("hi", Time, "PM10", Val, M1),
    ?assertEqual(Val, get_daily_max(Date, "PM10", M2)).

get_hourly_mean_test() ->
    Time = {{2020,4,21},{22,43,3}},
    {Date, {Hour, _, _}} = Time,
    M = create_monitor(),
    M1 = add_station("hi", {0, 0}, M),
    Val = 10.0,
    M2 = add_value("hi", Time, "PM10", Val, M1),
    ?assertEqual(Val, get_hourly_mean(Date, Hour, "PM10", M2)).
