%%%-------------------------------------------------------------------
%%% @author SATISH
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Jun 2019 4:26 PM
%%%-------------------------------------------------------------------
-module(money).
-author("SATISH").
-export([start/0,customer_processes/5,bank_processes/4,gotoSleepState/0,display/4]).

start() ->
  register(master,self()),
  Pids = #{},
  CustomersMap = maps:from_list(element(2,file:consult("customers.txt"))),
  CustomersKeys = maps:keys(CustomersMap),
  io:fwrite("** Customers and loan objectives **\n"),
  Display = fun(Key,Value, ok) -> io:format("~s: ~w\n",[Key,Value]) end,
  maps:fold(Display,ok,CustomersMap),
  Banks = maps:from_list(element(2,file:consult("banks.txt"))),
  BanksKeys = maps:keys(Banks),
  io:fwrite("\n** Banks and financial resources **\n"),
  maps:fold(Display,ok,Banks),
  io:fwrite("\n\n"),
  BankPids = bank_processes(length(BanksKeys),Banks,BanksKeys,Pids),
  CustomersPids = customer_processes(length(CustomersKeys),CustomersMap,CustomersKeys,BanksKeys,Pids),
  get_feedback(CustomersMap,Banks).

customer_processes(0,CustomersMap,CustomersKeys,BanksKeys,CustomersPids) ->
  CustomersPids;
customer_processes(Size,CustomersMap,CustomersKeys,BanksKeys,CustomersPids) ->
  Key = lists:nth(Size,CustomersKeys),
  Loan = maps:get(Key,CustomersMap),
  Pid = spawn(customer,request_for_loan,[Key,Loan,BanksKeys]),
  register(Key,Pid),
  customer_processes(Size-1,CustomersMap,CustomersKeys,BanksKeys,CustomersPids#{Key => Pid}).

bank_processes(0,BanksMap,BanksKeys,BanksPids) ->
  BanksPids;
bank_processes(Size,BanksMap,BanksKeys,BanksPids)->
  Key = lists:nth(Size,BanksKeys),
  Funds = maps:get(Key,BanksMap),
  Pid = spawn(bank,bank_receive,[Key,Funds]),
  register(Key,Pid),
  bank_processes(Size-1,BanksMap,BanksKeys,BanksPids#{Key => Pid}).

get_feedback(CMap,BMap) ->
  receive
    {from_customer,final_customer,Name,Loan} ->
      if
        (Loan == 0) -> io:fwrite("~p has reached the Objective of ~w dollar(s). Woo Hoo!\n",[Name,maps:get(Name,CMap)]);
        true -> io:fwrite("~p was only able to borrow ~w dollar(s). Boo Hoo!\n",[Name,maps:get(Name,CMap) - Loan])
      end,
      get_feedback(CMap,BMap);
    {from_bank,final_bank,Name,Funds} ->
      if
        (Funds == 0) -> io:fwrite("");
        true -> io:fwrite("~p has ~w dollar(s) remaining.\n",[Name,Funds])
      end,
      get_feedback(CMap,BMap);
    {from_bank,approves,BankName,Amount,CustomerName} ->
      io:fwrite("~p approves a loan of ~w dollars from ~p~n",[BankName,Amount,CustomerName]),
      get_feedback(CMap,BMap);
    {from_bank,denies,BankName,Amount,CustomerName} ->
      io:fwrite("~p denies a loan of ~w dollars from ~p~n",[BankName,Amount,CustomerName]),
      get_feedback(CMap,BMap);
     {from_customer,CustomerName,Amount,BankName} ->
      io:fwrite("~p requests a loan of ~w dollar(s) from ~p~n",[CustomerName,Amount,BankName]),
      get_feedback(CMap,BMap)
  end.

display(Id,CustomerName,Amount,BankName) ->
  if
    (Id == 0) ->
      io:fwrite("~p requests a loan of ~w dollar(s)  from ~p~n",[CustomerName,Amount,BankName]);
    (Id == 1 ) ->
      io:fwrite("~p approves a loan of ~w dollars from ~p~n",[BankName,Amount,CustomerName]);
    (Id == 2) ->
      io:fwrite("~p denies a loan of ~w dollars from ~p~n",[BankName,Amount,CustomerName]);
    true ->
      io:fwrite("Invalid ~w\n",[Id])
  end.

gotoSleepState() ->
  random:seed(now()),
  SleepTime = random:uniform(91)+9,
  timer:sleep(SleepTime).