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
-export([test/0]).

%% pm10pct and temp are lists of tuples with some value and date of measurement
-record(station, {name, coords, pm10pct = [], temp = []}).
-record(monitor, {stations = []}).

create_monitor() -> #monitor{}.

print_pm_meas(Pm_meas, Type) ->
    case Pm_meas of
        [] -> success;
        [{Value, Time} | T] ->
            io:format("~cPM10 measurement: ~p taken at ~p~n", [9, Value, Time]),  %% 9 = tab
            print_pm_meas(T)
    end.


print_station(Station) ->
    io:format("Station ~p with coords ~p and meas:~n", [Station#station.name, Station#station.coords]),
    print_meas(Station).

print_stations(Stations) ->
    case Stations of
        [] -> success;
        [Station | T] ->
            print_station(Station),
            print_stations(T)
    end.

print_monitor(Monitor) ->
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
                _ -> io:format("station not in monitor")
            end;
        true ->
            case station_exists(Monitor, Station_identifier, null) of
                {_, Station} -> Station;
                _ -> io:format("station not in monitor")
            end
    end.

add_station(Name, Coords, Monitor) ->
    if
        Name == "" -> io:format("Station name can't be an empty string~n");
        true ->
            case station_exists(Monitor#monitor.stations, Name, Coords) of
                {true, _} ->
                    io:format("trying to add station with the same name or coords~n");
                false ->
                    Prev_stations = Monitor#monitor.stations,
                    Station = #station{name = Name, coords = Coords},
                    Monitor#monitor{stations = [Station | Prev_stations]};
                _ -> io:format("Very unexpected behaviour in add_station")
            end
    end.

value_can_be_added(Station, Time, Type, Value) ->
    case Type of
        "PM10" -> not lists:member({Value, Time}, Station#station.pm10pct);
        "TEMP" -> not lists:member({Value, Time}, Station#station.temp);
        _ -> io:format("Wrong Type~n")
    end.

add_value(Station, Time, Type, Value) ->
    case Type of
        "PM10" -> Station#station{pm10pct = [{Value, Time} | Station#station.pm10pct]};
        "TEMP" -> Station#station{temp = [{Value, Time} | Station#station.temp]};
        _ -> io:format("Wrong Type~n")
    end.
add_value(Station_identifier, Time, Type, Value, Monitor) ->
    Station = get_station(Station_identifier, Monitor),
    case value_can_be_added(Station, Time, Type, Value) of
        true ->
            Prev_stations = [Station || Station <- Monitor#monitor.stations,
                not is_the_station(Station_identifier, Station)],
            Updated_station = add_value(Station, Time, Type, Value),
            Monitor#monitor{stations = [Updated_station | Prev_stations]};
        false -> io:format("value cannot be added")
    end.


test() ->
    P = create_monitor(),
    P1 = add_station("hi", {1, 1}, P),
    P4 = add_station("hid", {2, 1}, P1),
    P3 = add_value("hi", 12, "PM10", 10, P4),
    P3 = add_value("hid", 1, "TEMP", 2, P4),

    print_monitor(P4).
