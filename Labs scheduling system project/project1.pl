insert(X,L,[X|L]).
insert(X,[Y|L],[Y|L1]) :- insert(X,L,L1).

%%succeeds if element E, is in list L

in_List([E|T],E).
in_List([H|T],E):-
	in_List(T,E).


ta_slot_assignment(TAs,RemTAs,Name):-
    
	load_decrement(TAs,Name,RemTAs).

load_decrement([H|T],Name,RemTAs):-
	H=ta(Name,Load),
	Load1 is Load-1,
	Load1\=0,
	RemTAs=[ta(Name,Load1)|T].
	
load_decrement([H|T],Name,RemTAs):-
 
	H=ta(Name,Load),
	Load1 is Load-1,
	Load1=0,
	RemTAs=T.
 
load_decrement([H|T],Name,RemTAs):-
 
	H=ta(Name1,Load),
	Name\=Name1,
	load_decrement(T,Name,RemTAs1),
	RemTAs = [H|RemTAs1].
 
slot_assignment(0, TAs, TAs, []).
slot_assignment(LabsNum, TAs, RemTAs, [Name|T2]) :-
					LabsNum > 0, 
					TAs = [H|T], 
					H = ta(Name, _),
					ta_slot_assignment([H], Rem2, Name),
					LabsNum1 is LabsNum - 1, 
					slot_assignment(LabsNum1, T, T1, T2), 
					append(Rem2, T1, RemTAs).
slot_assignment(LabsNum, TAs, RemTAs, Assignment) :-
					LabsNum > 0, 
					TAs = [H|T], 
					slot_assignment(LabsNum, T, Rem2, Assignment),
					RemTAs = [H|Rem2].


max_slots_per_day([[],[],[],[],[]],_).
max_slots_per_day([],_).  
max_slots_per_day(DaySched,Max):-
    flatten(DaySched,NewDaySched),
	NewDaySched=[H|T],
	occurrences(NewDaySched,H,Occurences),
	Occurences =< Max,
	max_slots_per_day(T,Max).
 
occurrences([],_,0).
occurrences([X|T],X,Occ):- 
	occurrences(T,X,Occ1),
	Occ is Occ1+1.
 
occurrences([X1|T],X,Occ):- 
	occurrences(T,X,Occ),
	X1\=X. 	

day_schedule([], TAs, TAs, []).	
day_schedule([H|T],TAs,RemTAs,[H1|T1]) :- 
     slot_assignment(H, TAs, RemTAs2, H1),
     day_schedule(T, RemTAs2, RemTAs, T1).


week_schedule([], _, _, []).
week_schedule([H|T], TAs, DayMax, WeekSched) :- 
				day_schedule(H, TAs, RemTAs, DaySched), 
				max_slots_per_day(DaySched, DayMax),
				week_schedule(T, RemTAs, DayMax, T1),
				WeekSched = [DaySched|T1].
				









 