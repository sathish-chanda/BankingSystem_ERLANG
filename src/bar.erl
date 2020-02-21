%% @author eavis
%% @doc @todo Add description to bar.


-module(bar).

%% ====================================================================
%% API functions
%% ====================================================================
-export([baz/0, baz2/0 , greetings/0]).


%% ====================================================================
%% Internal functions
%% ====================================================================

% a simple receive that looks for a cat or dog object. 
% Note that this is not a looping receive, so it will
% only accept one message (either a cat or dog) before it
% ends.
baz() ->
	receive 
		{Sender, {dog, Name}} ->
			io:fwrite("Got the message from " ++ Name ++ "\n\n"),
			Sender ! {"Received dog: " ++ Name};
		{Sender, {cat, Name}} ->
			io:fwrite("Got the message from " ++ Name ++ "\n\n"),
			Sender ! {"Received cat: " ++ Name}
	end.


% baz2 will continously loop after it receives a message from the queue
% it will terminate only if nothing new arrives for at least 2 seconds
baz2() ->
	receive 
	  	{Sender, {dog, Name}} ->
			Sender ! {"Received dog: " ++ Name},
			io:fwrite("recieved in baz2/dog pattern from Sender: ~w\n\n", [Sender]),
			baz2();
		{Sender, {cat, Name}} ->
			Sender ! {"Received cat: " ++ Name},
			io:fwrite("received in baz2/cat pattern from Sender: ~w\n\n", [Sender]),
			baz2()
	    after 2000 -> true
	end.

greetings() ->
	receive
		{Sender,{student,Name}} ->
			io:fwrite("Name : ~s\n",[Name]),
			Sender ! {"Good morning my dear student " ++ Name};
		{Sender,{teacher,Name}} ->
			Sender ! {"Good morning my dear faculty " ++ Name}
	end.
