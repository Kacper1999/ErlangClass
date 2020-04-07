%%%-------------------------------------------------------------------
%%% @author Kacper
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. mar 2020 18:23
%%%-------------------------------------------------------------------
-module(q_sort).
-author("Kacper").

%% API
-export([less_than/2, grt_eq_than/2, qs/1, random_elements/3, compare_speeds/3]).

less_than(List, Arg) -> [X || X <- List, X < Arg].
grt_eq_than(List, Arg) -> [X || X <- List, X >= Arg].

qs([Pivot|Tail]) -> qs(less_than(Tail,Pivot)) ++ [Pivot] ++ qs(grt_eq_than(Tail,Pivot));
qs([]) -> [].

random_elements(N, Min, Max) -> [rand:uniform(Max - Min + 1) + Min - 1 || _ <- lists:seq(1, N)].

%% I don't know if you can somehow pass modules for this function not to be so "stiff"
compare_speeds(List, Fun1, Fun2) ->
  Fun1_time = element(1, timer:tc(Fun1, [List])),
  Fun2_time = element(1, timer:tc(Fun2, [List])),
  io:format("Fun1 time: ~f[s], Fun2 time: ~f[s]~n", [Fun1_time / math:pow(10, 6), Fun2_time / math:pow(10, 6)]).

