%definisco una lista.

%caso base - lista vuota.
isList([]).

%passo ricorsivo - la lista ha una testa ed una coda.
isList([_ | _]).

%creo un predicato che prende l'n-esimo elemento dellla lista.
%il predicato è del tipo nome(N, Lista, E).
%N è l'indice d'interesse, E è la variabile che dobbiamo ritornare.

%caso base - N = 0.
nthElem(0, [E | _], E).

% diminuisco N in modo tale che arrivi a 0 facendo arrivare il predicato
% al caso base.
nthElem(N, [_ | Es], E) :-
    N > 0,
    N1 is N - 1,
    nthElem(N1, Es, E).

%predicato che ritorna la lunghezza della lista.

%caso base - la lista è vuota e ha lunghezza 0.
listLength([], 0).

listLength([_ | Y], Length) :-
    listLength(Y, LengthYs),
    Length is LengthYs + 1.

%predicato che mi dice se un elemento è contenuto in una lista.

%caso base - l'elemento è in testa.
isIn(E, [E | _]).

isIn(E, [X | Y]) :-
    E \= X,
    isIn(E, Y).

%predicato che concatena due liste.

%i parametri sono L1, L2, L1L2.
%caso base - una lista è vuota.
concat([], L2, L2).

concat([X | Xs], L2, [X | L3]) :-
    concat(Xs, L2, L3).
