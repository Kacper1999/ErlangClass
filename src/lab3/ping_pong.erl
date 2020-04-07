%%%-------------------------------------------------------------------
%%% @author Kacper
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. kwi 2020 15:51
%%%-------------------------------------------------------------------
-module(ping_pong).
-author("Kacper").

%% API
-export([start/0, play/1, ping_fun/1, pong_fun/0, stop/0]).

ping_fun(Count) ->
    Wait = 200,
    receive
        N when is_integer(N) ->
            timer:sleep(Wait),
            pong ! {N, ping_sig},
            io:format("Ping sent ~B to Pong~n", [N]),
            ping_fun(Count);
        {N, pong_sig} ->
            case N of
                0 ->
                    timer:sleep(Wait),
                    io:format("0 recieved from Pong, Sygnals received: ~B, ended sending signals.~n", [Count + 1]);
                _ ->
                    timer:sleep(Wait),
                    io:format("Ping recieved ~B from Pong, Sygnals received: ~B~n", [N, Count + 1]),
                    timer:sleep(Wait),
                    pong ! {N, ping_sig},
                    io:format("Ping sent ~B to Pong~n", [N]),
                    ping_fun(Count + 1)
            end;
        break ->
            io:format("Ping interrupted~n"),
            exit(interrupted)
    after
        20000 ->
            io:format("Ping time exceeded~n"),
            exit(time_exceeded)
    end.


pong_fun() ->
    Wait = 200,
    receive
        {N, ping_sig} ->
            case N of
                1 ->
                    timer:sleep(Wait),
                    io:format("Pong recieved ~B from Ping~n", [N]),
                    timer:sleep(Wait),
                    ping ! {N - 1, pong_sig},
                    io:format("0 sent to Ping, ended sending signals.~n");
                _ ->
                    timer:sleep(Wait),
                    io:format("Pong recieved ~B from Ping~n", [N]),
                    timer:sleep(Wait),
                    ping ! {N - 1, pong_sig},
                    io:format("Pong sent ~B to Ping~n", [N - 1]),
                    pong_fun()
            end;
        break ->
            io:format("Pong interrupted~n"),
            exit(interrupted)
    after
        20000 ->
            io:format("Pong time exceeded~n"),
            exit(time_exceeded)
    end.


start() ->
    Ping_pid = spawn(ping_pong, ping_fun, [0]),
    Pong_pid = spawn(ping_pong, pong_fun, []),
    io:format("~w~n", [Ping_pid]),
    io:format("~w~n", [Pong_pid]),
    register(ping, Ping_pid),
    register(pong, Pong_pid).

%% end with error but I don't know if I should care, its Erlang after all, just crush
stop() ->
    pong ! break,
    ping ! break.

play(N)  when is_integer(N) and (N > 0) -> ping ! N.
