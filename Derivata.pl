d(C, X, 0) :-
    C \= X,
    atomic(C),
    !.

d(X, X, 1) :- !.

d(C * X, X, C) :-
    atomic(C),
    C \= X,
    !.

d(X ^ C, X, C * X ^ C1) :-
    number(C),
    C1 is C - 1,
    !.

d(sin(X), X, cos(X)) :- !.

d(cos(X), X, -sin(X)) :- !.

d(exp(X), X, exp(X)) :- !.

d(log(X), X, C2) :-
    C2 is (1 / (X * log(X))),
    !.

d(C ^ X, X, C3) :-
    C3 is (C ^ X * log(C)),
    !.

d(F + G, X, DF + DG) :-
    d(F, X, DF),
    d(G, X, DG),
    !.

d(F - G, X, DF - DG) :-
    d(F, X, DF),
    d(G, X, DG),
    !.

d(F * G, X, DF * G + DG * F) :-
    d(F, X, DF),
    d(G, X, DG),
    !.

d(F / G, X, (DF * G - DG * F) / G^2) :-
    d(F, X, DF),
    d(G, X, DG),
    !.

d(FG, X, DG * DFG) :-
    FG =.. [_F, G],
    d(G, X, DG),
    d(FG, G, DFG),
    !.
