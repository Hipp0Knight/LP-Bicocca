lavoraA('Federico', blizzard).
lavoraA('Daniele', blizzard).
lavoraA('Giorgio',blizzard).

lavoraCon(X, K):-
    lavoraA(X, Y),
    lavoraA(Z, Y),
    X \= Z,
    K = Z.
