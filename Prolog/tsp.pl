edge(a,b,10).
edge(a,c,1).
edge(a,d,2).
edge(a,e,6).
edge(b,a,10).
edge(b,c,9).
edge(b,d,5).
edge(b,e,8).
edge(c,a,1).
edge(c,b,9).
edge(c,d,3).
edge(c,e,4).
edge(d,a,2).
edge(d,b,5).
edge(d,c,3).
edge(d,e,7).
edge(e,a,6).
edge(e,b,8).
edge(e,c,4).
edge(e,d,7).

len([], 0).
len([_|T], N):-
len(T, X),
N is X+1 .

best_path(Visited, Total):- path(a, b, Visited, Total).

path(Start, Fin, Visited, Total) :-
path(Start, Fin, [Start], Visited, 0, Total).

path(Start, Fin, CurrentLoc, Visited, Costn, Total) :-
edge(Start, StopLoc, Distance),
NewCostn is Costn + Distance,
\+ member(StopLoc, CurrentLoc),
path(StopLoc, Fin, [StopLoc|CurrentLoc], Visited, NewCostn, Total).

path(Start, Fin, CurrentLoc, Visited, Costn, Total) :-
edge(Start, Fin, Distance), reverse([Fin|CurrentLoc], Visited),
len(Visited, Q),
(Q\=5 -> Total is 100000; Total is Costn + Distance).

shortest_path(Path):-setof(Cost-Path, best_path(Path,Cost), Holder),pick(Holder,Path).

best(Cost-Holder,Bcost-_,Cost-Holder):-
Cost<Bcost,!.
best(_,X,X).

pick([Cost-Holder|R],X):-
pick(R,Bcost-Bholder),
best(Cost-Holder,Bcost-Bholder,X),!.

pick([X],X).
