%%%-------------------------------------------------------------------
%%% @author Kacper
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. kwi 2020 14:30
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("Kacper").
-behavior(gen_server).
%% API
-export([init/1, handle_call/3, handle_cast/2, start/0, stop/0, get_value/3, get_station_mean/2, get_daily_mean/2, get_hourly_mean/3, get_daily_max/2, add_station/2, add_value/4, remove_value/3, print_monitor/0, crash/0]).

start() ->
    io:format("pollution server start~n"),
    gen_server:start_link({local, pollution_server}, pollution_server, [], []).

init(_Args) ->
    {ok, pollution:create_monitor()}.

%% not sure if this is what it supposed to look like
handle_call(Request, _From, Monitor) ->
    case Request of
        {get_value, Station_identifier, Time, Type} ->
            {reply, pollution:get_value(Station_identifier, Time, Type, Monitor), Monitor};
        {get_station_mean, Station_identifier, Type} ->
            {reply, pollution:get_station_mean(Station_identifier, Type, Monitor), Monitor};
        {get_daily_mean, Date, Type} ->
            {reply, pollution:get_daily_mean(Date, Type, Monitor), Monitor};
        {get_hourly_mean, Date, Hour, Type} ->
            {reply, pollution:get_hourly_mean(Date, Hour, Type, Monitor), Monitor};
        {get_daily_max, Date, Type} ->
            {reply, pollution:get_daily_max(Date, Type, Monitor), Monitor};
        {print_monitor} ->
            pollution:print_monitor(Monitor),
            {reply, ok, Monitor};
        _ ->
            io:format("Uknown synchronic query~n"),
            {error, error, Monitor}
    end.


handle_cast(Request, Monitor) ->
    case Request of
        {add_station, Name, Coords} ->
            {noreply, pollution:add_station(Name, Coords, Monitor)};
        {add_value, Station_identifier, Time, Type, Value} ->
            {noreply, pollution:add_value(Station_identifier, Time, Type, Value, Monitor)};
        {remove_value, Station_identifier, Time, Type} ->
            {noreply, pollution:remove_value(Station_identifier, Time, Type, Monitor)};
        stop ->
            {stop, normal, Monitor};
        _ ->
            io:format("Uknown asynchronic query~n"),
            {error, error, Monitor}
    end.

get_value(Station_identifier, Time, Type) ->
    gen_server:call(pollution_server, {get_value, Station_identifier, Time, Type}).
get_station_mean(Station_identifier, Type) ->
    gen_server:call(pollution_server, {get_station_mean, Station_identifier, Type}).
get_daily_mean(Date, Type) ->
    gen_server:call(pollution_server, {get_daily_mean, Date, Type}).
get_hourly_mean(Date, Hour, Type) ->
    gen_server:call(pollution_server, {get_hourly_mean, Date, Hour, Type}).
get_daily_max(Date, Type) ->
    gen_server:call(pollution_server, {get_daily_max, Date, Type}).
add_station(Name, Coords) ->
    gen_server:cast(pollution_server, {add_station, Name, Coords}).
add_value(Station_identifier, Time, Type, Value) ->
    gen_server:cast(pollution_server, {add_value, Station_identifier, Time, Type, Value}).
remove_value(Station_identifier, Time, Type) ->
    gen_server:cast(pollution_server, {remove_value, Station_identifier, Time, Type}).
print_monitor() ->
    gen_server:call(pollution_server, {print_monitor}).

crash() ->
    gen_server:call(alla, {hi}).

stop() ->
    gen_server:cast(pollution_server, stop).