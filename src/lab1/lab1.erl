%%%-------------------------------------------------------------------
%%% @author Kacper
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. mar 2020 10:10
%%%-------------------------------------------------------------------

-module(lab1).
-author("Kacper").
-import(math, [sqrt/1, cos/1, sin/1, tan/1]).
-import(string, [tokens/2]).

%% API
-export([power/2, contains/2, duplicate_elements/1, sum_floats/1, sum_floats_tail/1, onp_list_calc/1, check/1]).

power(_, 0) -> 1;
power(A, B) when (is_integer(B) and B >= 0) -> A * power(A, B - 1).

contains([], _) -> false;
contains([H | _], H) -> true;
contains([_ | T], A) -> contains(T, A).

duplicate_elements([]) -> [];
duplicate_elements([H | T]) -> [H | [H | duplicate_elements(T)]].

sum_floats([]) -> 0;
sum_floats([H | T]) when (is_float(H)) -> H + sum_floats(T);
sum_floats([_ | T]) -> sum_floats(T).

sum_floats_tail(List) -> sum_floats_tail(List, 0).
sum_floats_tail([], Acc) -> Acc;
sum_floats_tail([H | T], Acc) when is_float(H) -> sum_floats_tail(T, Acc + H);
sum_floats_tail([_ | T], Acc) -> sum_floats_tail(T, Acc).


onp_list_calc(X) -> onp_list_calc(X, []).
onp_list_calc([], []) -> 0;
onp_list_calc([], [H | []]) when is_number(H) -> H;
onp_list_calc([H | T], Stack) when is_number(H) -> onp_list_calc(T, [H | Stack]);
onp_list_calc([H | T], [H1 | [H2 | Stack]]) ->
  case H of
    "+" -> onp_list_calc(T, [H2 + H1 | Stack]);
    "-" -> onp_list_calc(T, [H2 - H1 | Stack]);
    "*" -> onp_list_calc(T, [H2 * H1 | Stack]);
    "/" -> onp_list_calc(T, [H2 / H1 | Stack]);
    "sqrt" -> onp_list_calc(T, [sqrt(H1) | Stack]);
    "sin" -> onp_list_calc(T, [sin(H1) | Stack]);
    "cos" -> onp_list_calc(T, [cos(H1) | Stack]);
    "tan" -> onp_list_calc(T, [tan(H1) | Stack])
  end;
%%onp_list_calc([H | T], [H1 |  Stack]) ->
%%  case H of
%%    "sqrt" -> onp_list_calc(T, [sqrt(H1) | Stack]);
%%    "sin" -> onp_list_calc(T, [sin(H1) | Stack]);
%%    "cos" -> onp_list_calc(T, [cos(H1) | Stack]);
%%    "tan" -> onp_list_calc(T, [tan(H1) | Stack])
%%  end;
onp_list_calc(_, _) -> "inproper formula".

onp_calc(X) -> onp_calc(tokens(X, " "), []).
onp_calc([], []) -> 0;
onp_calc([], [Sh | []]) -> Sh;
onp_calc([H | T], Stack) when is_number(H) -> onp_calc(T, [H | Stack]).


check(X) -> list_to_integer(tokens(X, " ")).
