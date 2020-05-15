%%%-------------------------------------------------------------------
%%% @author Kacper
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. kwi 2020 02:21
%%%-------------------------------------------------------------------
-module(pollution).
-author("Kacper").

%% API
%% not sure if there is a nice way to do this
-export([test/0, create_monitor/0, add_station/3, add_value/5, remove_value/4, get_value/4, get_station_mean/3, get_daily_mean/3, get_hourly_mean/4, get_daily_max/3, print_monitor/1]).

%% pm10pct and temp are lists of tuples with some value and date of measurement
-record(station, {name, coords, pm10pct = [], temp = []}).
-record(monitor, {stations = []}).

create_monitor() -> #monitor{}.

get_every_meas(Stations, Type) ->
    case Stations of
        [] -> io:format("Trying to get measurements from 0 stations~n");
        _ -> get_every_meas(Type, Stations, [])
    end.
get_every_meas(Type, Stations, Output) ->
    case Stations of
        [] -> Output;
        [Station | T] ->
            case Type of
                "PM10" -> get_every_meas(Type, T, Station#station.pm10pct ++ Output);
                "TEMP" -> get_every_meas(Type, T, Station#station.temp ++ Output);
                _ -> {error, "Wrong Type~n"}
            end
    end.

print_meas(Meas, Type) ->
    case Meas of
        [] -> success;
        [{Value, Time} | T] ->
            io:format("~c~p measurement: ~p taken at ~p~n", [9, Type, Value, Time]),  %% 9 = tab
            print_meas(T, Type)
    end.


print_station(Station) ->
    io:format("Station ~p with coords ~p and meas:~n", [Station#station.name, Station#station.coords]),
    print_meas(Station#station.pm10pct, "PM10"),
    print_meas(Station#station.temp, "TEMP"),
    io:format("~n").


print_stations(Stations) ->
    case Stations of
        [] -> success;
        [Station | T] ->
            print_station(Station),
            print_stations(T)
    end.

print_monitor(Monitor) ->
    io:format("Monitor with stations:~n"),
    print_stations(Monitor#monitor.stations).

%% no better idea for a name
is_the_station(Station_identifier, Station) ->
    if
        is_tuple(Station_identifier) -> Station#station.coords == Station_identifier;
        true -> Station#station.name == Station_identifier
    end.

station_exists(Stations, Name, Coords) ->
    case Stations of
        [] -> false;
        [Station | T] ->
            if
                (Station#station.name == Name) or (Station#station.coords == Coords) -> {true, Station};
                true -> station_exists(T, Name, Coords)
            end
    end.

get_station(Station_identifier, Monitor) ->
    if
        is_tuple(Station_identifier) ->
            case station_exists(Monitor, null, Station_identifier) of
                {_, Station} -> Station;
                _ -> {error, "station not in monitor~n"}
            end;
        true ->
            case station_exists(Monitor#monitor.stations, Station_identifier, null) of
                {_, Station} -> Station;
                _ -> {error, "station not in monitor~n"}
            end
    end.

add_station(Name, Coords, Monitor) ->
    case station_exists(Monitor#monitor.stations, Name, Coords) of
        {true, _} ->
            {error, "Trying to add station with the same name or coords"};
        false ->
            Prev_stations = Monitor#monitor.stations,
            Station = #station{name = Name, coords = Coords},
            Monitor#monitor{stations = [Station | Prev_stations]}
    end.

time_matches(Meas, Time) ->
    case Meas of
        [] -> false;
        [{V, X_time} | T] ->
            if
                X_time == Time -> {true, {V, X_time}};
                true -> time_matches(T, Time)
            end
    end.

meas_exists(Station, Time, Type) ->
    case Type of
        "PM10" -> time_matches(Station#station.pm10pct, Time);
        "TEMP" -> time_matches(Station#station.temp, Time);
        _ -> {error, "Wrong Type"}
    end.

add_value(Station, Time, Type, Value) ->
    case Type of
        "PM10" -> Station#station{pm10pct = [{Value, Time} | Station#station.pm10pct]};
        "TEMP" -> Station#station{temp = [{Value, Time} | Station#station.temp]};
        _ -> {error, "Wrong Type"}
    end.
add_value(Station_identifier, Time, Type, Value, Monitor) ->
    Station = get_station(Station_identifier, Monitor),
    case meas_exists(Station, Time, Type) of
        false ->
            Prev_stations = [Some_station || Some_station <- Monitor#monitor.stations,
                not is_the_station(Station_identifier, Some_station)],
            Updated_station = add_value(Station, Time, Type, Value),
            Monitor#monitor{stations = [Updated_station | Prev_stations]};
        {true, _} -> {error, "Value cannot be added already exists"}
    end.

remove_value(Station, Time, Type) ->
    case Type of  %% don't know why I had to use V instead of _
        "PM10" -> Station#station{pm10pct = [{V, X_time} || {V, X_time} <- Station#station.pm10pct, X_time =/= Time]};
        "TEMP" -> Station#station{temp = [{V, X_time} || {V, X_time} <- Station#station.temp, X_time =/= Time]};
        _ -> {error, "Wrong Type"}
    end.
remove_value(Station_identifier, Time, Type, Monitor) ->
    Station = get_station(Station_identifier, Monitor),
    case meas_exists(Station, Time, Type) of
        {true, _} ->
            Prev_stations = [Some_station || Some_station <- Monitor#monitor.stations,
                not is_the_station(Station_identifier, Some_station)],
            Updated_station = remove_value(Station, Time, Type),
            Monitor#monitor{stations = [Updated_station | Prev_stations]};
        false ->
            {error, "Value to remove doesnt' exists"}
    end.

get_meas(Station_identifier, Time, Type, Monitor) ->
    Station = get_station(Station_identifier, Monitor),
    case meas_exists(Station, Time, Type) of
        {true, Meas} -> {true, Meas};
        false -> {error, "Value to get doesn't exists"}
    end.
get_value(Station_identifier, Time, Type, Monitor) ->
    case get_meas(Station_identifier, Time, Type, Monitor) of
        {true, {Value, Time}} -> Value;
        _ -> {error, "didn't found value"}
    end.

get_mean(Meas) ->
    if
        Meas == [] ->
            io:format("Trying to get mean of empty list~n"),
            0;
        true -> get_mean(Meas, 0, 0)
    end.
get_mean(Meas, Sum, Num) ->
    case Meas of
        [] -> Sum / Num;
        [{Value, _} | T] -> get_mean(T, Sum + Value, Num + 1)
    end.

get_max(Meas) ->
    case Meas of
        [] -> io:format("Trying to get max of empty list~n");
        [{Value, _} | T] -> get_max(T, Value)
    end.
get_max(Meas, Max) ->
    case Meas of
        [] -> Max;
        [{Value, _} | T] -> get_max(T, max(Value, Max))
    end.

get_station_mean(Station_identifier, Type, Monitor) ->
    Station = get_station(Station_identifier, Monitor),
    case Type of
        "PM10" -> get_mean(Station#station.pm10pct);
        "TEMP" -> get_mean(Station#station.temp);
        _ -> {error, "Wrong Type"}
    end.

get_meas_from_date(Date, Type, Monitor) ->
    Every_meas = get_every_meas(Monitor#monitor.stations, Type),
    [{V, {M_date, M_time}} || {V, {M_date, M_time}} <- Every_meas, M_date == Date].

get_meas_from_hour(Date, Hour, Type, Monitor) ->
    Every_meas = get_every_meas(Monitor#monitor.stations, Type),
    [{V, {M_date, {H, M, S}}} || {V, {M_date, {H, M, S}}} <- Every_meas, M_date == Date, H == Hour].

get_daily_mean(Date, Type, Monitor) ->
    Meas = get_meas_from_date(Date, Type, Monitor),
    get_mean(Meas).

get_hourly_mean(Date, Hour, Type, Monitor) ->
    Meas = get_meas_from_hour(Date, Hour, Type, Monitor),
    get_mean(Meas).

get_daily_max(Date, Type, Monitor) ->
    Meas = get_meas_from_date(Date, Type, Monitor),
    get_max(Meas).


test() ->
    P = create_monitor(),
    Date = {2020, 5, 7},
    H = 1,
    Some_time = {Date, {H, 11, 7}},
    P1 = add_station("hi", {1, 1}, P),
    P2 = add_station("hid", {2, 1}, P1),
    P3 = add_value("hi", Some_time, "PM10", 10, P2),
    P4 = remove_value("hi", Some_time, "PM10", P3),
    P5 = add_value("hid", Some_time, "TEMP", 3, P4),
    timer:sleep(1),

    P6 = add_value("hi", Some_time, "TEMP", 2, P5),
    P7 = add_value("hid", Some_time, "PM10", 11, P6),
    print_monitor(P7),

    io:format("hid temp station mean: ~p~n", [get_station_mean("hid", "TEMP", P7)]),
    io:format("hi pm10 station mean: ~p~n", [get_station_mean("hi", "PM10", P7)]),
    io:format("local time ~p~n", [Some_time]),
    io:format("hi pm10 curr time value: ~p~n", [get_value("hid", Some_time, "PM10", P7)]),

    io:format("daily temp mean: ~p~n", [get_daily_mean(Date, "TEMP", P7)]),
    io:format("daily pm10 mean: ~p~n", [get_daily_mean(Date, "PM10", P7)]),
    io:format("hourly pm10 mean: ~p~n", [get_hourly_mean(Date, H, "PM10", P7)]),
    io:format("daily temp max: ~p~n", [get_daily_max(Date, "TEMP", P7)]).
