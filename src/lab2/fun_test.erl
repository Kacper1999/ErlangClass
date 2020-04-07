%%%-------------------------------------------------------------------
%%% @author Kacper
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. mar 2020 00:17
%%%-------------------------------------------------------------------
-module(fun_test).
-author("Kacper").

%% API
-export([my_map/2, my_filter/2, digits_sum/1, get_digits/1, filter_mil/3]).

my_map(_, []) -> [];
my_map(Fun, [H | T]) -> [Fun(H) | my_map(Fun, T)].

my_filter(_, []) -> [];
my_filter(Fun, [H | T]) ->
  case Fun(H) of
    true -> [H | my_filter(Fun, T)];
    _ -> my_filter(Fun, T)
  end.

get_digits(X) -> get_digits(X, []).
get_digits(0, List) -> List;
get_digits(X, List) -> get_digits(X div 10, List) ++ [X rem 10].

digits_sum(X) ->
  Num = get_digits(X),
  lists:foldl(fun (A, Acc) -> A + Acc end, 0, Num).

%% to filter 1mil: List_len=1mil
filter_mil(List_len, Lower_b, Upper_b) ->
  Predicate = fun (X) -> digits_sum(X) rem 3 == 0 end,
  lists:filter(Predicate, q_sort:random_elements(List_len, Lower_b, Upper_b)).
