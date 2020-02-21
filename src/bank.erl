%%%-------------------------------------------------------------------
%%% @author SATISH
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Jun 2019 11:09 PM
%%%-------------------------------------------------------------------

-module(bank).
-author("SATISH").

%% API
-export([bank_receive/2]).

bank_receive(Name,Funds) ->
  receive
    {Sender, {Amount,BankName,CustomerName}} ->
      money:gotoSleepState(),
      if
        (Funds >= Amount) ->
          Sender ! {true},
          money:display(1,CustomerName,Amount,BankName),
          bank_receive(Name,Funds - Amount);
          (Funds < Amount) ->
          Sender ! {false},
          money:display(2,CustomerName,Amount,Name),
          bank_receive(Name,Funds);
        true ->
            io:fwrite("Invalid arguments"),
            bank_receive(Name,Funds)
      end
      after 2000 ->
            whereis(master) ! {from_bank,final_bank,Name,Funds}
  end.