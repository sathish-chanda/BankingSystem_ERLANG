%%%-------------------------------------------------------------------
%%% @author SATISH
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Jun 2019 11:09 PM
%%%-------------------------------------------------------------------
-module(customer).
-author("SATISH").

%% API
-export([request_for_loan/3]).

request_for_loan(Name,Loan,BanksList) ->
  money:gotoSleepState(),
  if
    (length(BanksList) > 0) and (Loan > 0) ->
      random:seed(now()),
      BankIndex = random:uniform(length(BanksList)),
      BankName = lists:nth(BankIndex,BanksList),
      BankPid = whereis(BankName),
      if
        (Loan < 50)  -> Amount = random:uniform(Loan);
        true ->
          Amount = random:uniform(50)
      end,
      money:display(0,Name,Amount,BankName),
      BankPid ! {self(), {Amount,BankName,Name}},
      Reply = get_feedback(),
      if
        (Reply == true) ->
          request_for_loan(Name,Loan-Amount,BanksList);
        (Reply == false) ->
          request_for_loan(Name,Loan,lists:delete(BankName,BanksList))
      end;
      true  ->
      timer:sleep(5000),
      whereis(master) ! {from_customer,final_customer,Name,Loan}
    end.

get_feedback() ->
  receive
    {Message} -> Message
  end.