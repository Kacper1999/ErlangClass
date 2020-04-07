%%%-------------------------------------------------------------------
%%% @author Kacper
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. kwi 2020 00:48
%%%-------------------------------------------------------------------
-module(parcel_lockers).
-author("Kacper").

%% API
-export([get_coords/3, seq_parcel_locator/2, very_par_parcel_locator/2, collector_fun/4, fit_to_collector/2, rev_slice/4, par_parcel_locator/2, fits_to_collector/2, time_parcel_locators/2]).

rand_int(From, To) -> random:uniform(To) + From - 1.

get_coords(Size, From, To) -> [{rand_int(From, To), rand_int(From, To)} || _ <- lists:seq(1, Size)].

%% not Euclidean distance
distance({X1, Y1}, {X2, Y2}) -> math:pow(X1 - X2, 2) + math:pow(Y1 - Y2, 2).

find_my_parcel_locker(Person_coords, Lockers_coords) ->
    [H | T] = Lockers_coords,
    Dist = distance(Person_coords, H),
    find_my_parcel_locker(Person_coords, T, H, Dist).

find_my_parcel_locker(Person_coords, Lockers_coords, Min, Min_dist) ->
    case Lockers_coords of
        [] -> Min;
        [H | T] ->
            Curr_dist = distance(Person_coords, H),
            case Curr_dist >= Min_dist of
                true -> find_my_parcel_locker(Person_coords, T, Min, Min_dist);
                false -> find_my_parcel_locker(Person_coords, T, H, Curr_dist)
            end
    end.

seq_parcel_locator(People_coords, Lockers_coords) ->
    seq_parcel_locator(People_coords, Lockers_coords, []).
seq_parcel_locator(People_coords, Lockers_coords, Output) ->
    case People_coords of
        [] -> Output;
        [H | T] ->
            Fit = {H, find_my_parcel_locker(H, Lockers_coords)},
            seq_parcel_locator(T, Lockers_coords, [Fit | Output])
    end.

is_fit(Fit) ->
    case Fit of
        {{X1, Y1}, {X2, Y2}} ->
            is_integer(X1) and is_integer(Y1) and is_integer(X2) and is_integer(Y2);
        _ -> false
    end.
is_list_of_fit(Fits) ->
    case Fits of
        [] -> true;
        [Fit | T] ->
            case is_fit(Fit) of
                true -> is_list_of_fit(T);
                false -> false
            end
    end.

rev_slice(List, From, To) ->
    rev_slice(List, From, To, []).
rev_slice(List, From, To, Output) ->
    if
        From =< 1 ->
            if
                To > 0 ->
                    [H | T] = List,
                    rev_slice(T, From, To -1, [H | Output]);
                true -> Output
            end;
        true ->
            [H | T] = List,
            rev_slice(T, From - 1, To - 1, Output)
    end.

collector_fun(Output, Curr_len, Output_len, Parent_pid) ->
    receive
        Fits ->
            case is_list_of_fit(Fits) of
                true ->
                    New_len = Curr_len + length(Fits),
                    if
                        New_len == Output_len ->
                            io:format("Collector sent to parent, ending.~n"),
                            Parent_pid ! Fits ++ Output;
                        true ->
                            collector_fun(Fits ++ Output, New_len, Output_len, Parent_pid)
                    end;
                false ->
                    io:format("Collector get sth that isn't a fit~n"),
                    io:format("~w~n", [Fits]),
                    exit(collector_failed)
            end
    end.

very_par_parcel_locator(People_coords, Lockers_coords) ->
    register(collector, spawn(parcel_lockers, collector_fun, [[], 0, length(People_coords), self()])),
    make_clones(People_coords, Lockers_coords),
    receive
        Output -> Output
    end.

fit_to_collector(Person_coords, Lockers_coords) ->
    collector ! [{Person_coords, find_my_parcel_locker(Person_coords, Lockers_coords)}].
fits_to_collector(People_coords, Lockers_coords) ->
    collector ! seq_parcel_locator(People_coords, Lockers_coords).

%% Bad name but I don't have a better idea
make_clones(People_coords, Lockers_coords) ->
    case People_coords of
        [] -> io:format("Making clones ended~n");
        [H | T] ->
            spawn(parcel_lockers, fit_to_collector, [H, Lockers_coords]),
            make_clones(T, Lockers_coords)
    end.
make_clones(People_coords, Lockers_coords, Cores_num) ->
    People_per_core = length(People_coords) div Cores_num,
    assign_to_clones(People_coords, Lockers_coords, Cores_num, People_per_core, 1).

%% looks terrible but again no better idea
assign_to_clones(People_coords, Lockers_coords, Cores_num, People_per_core, Clone_num) ->
    if
        Clone_num > Cores_num -> io:format("Making clones ended~n");
        true ->
            assign_to_clone(People_coords, Lockers_coords, Cores_num, People_per_core, Clone_num),
            assign_to_clones(People_coords, Lockers_coords, Cores_num, People_per_core, Clone_num + 1)
    end.
assign_to_clone(People_coords, Lockers_coords, Cores_num, People_per_core, Clone_num) ->
    From = People_per_core * (Clone_num - 1) + 1,
    if
        Clone_num == Cores_num ->
            Rem = length(People_coords) rem Cores_num,
            To = From + People_per_core - 1 + Rem;  %% not as equal as you can get but good enough I think
        true ->
            To = From + People_per_core - 1
    end,
    Slice = rev_slice(People_coords, From, To),
    spawn(parcel_lockers, fits_to_collector, [Slice, Lockers_coords]).


par_parcel_locator(People_coords, Lockers_coords) ->
    Cores_num = 4,
    register(collector, spawn(parcel_lockers, collector_fun, [[], 0, length(People_coords), self()])),
    make_clones(People_coords, Lockers_coords, Cores_num),
    receive
        Output -> Output
    end.

time_parcel_locators(People_num, Lockers_num) ->
    Lb = 0,
    Ub = 1000,
    People_coords = get_coords(People_num, Lb, Ub),
    Lockers_coords = get_coords(Lockers_num, Lb, Ub),
    {Seq_time, _} = timer:tc(parcel_lockers, seq_parcel_locator, [People_coords, Lockers_coords]),
    io:format("Seq time: ~B~n", [Seq_time]),
    {Very_par_time, _} = timer:tc(parcel_lockers, very_par_parcel_locator, [People_coords, Lockers_coords]),
    io:format("Very par time: ~B~n", [Very_par_time]),
    {Par_time, _} = timer:tc(parcel_lockers, par_parcel_locator, [People_coords, Lockers_coords]),
    io:format("Par time: ~B~n", [Par_time]).
