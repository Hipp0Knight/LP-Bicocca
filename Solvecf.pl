solve_cf(true, 1.0) :- !.
solve_cf((A, B), Cf) :-
    !,
    solve_cf(A, CfA),
    solve_cf(B, CfB),
    minimum(CfA, CfB, Cf).
solve_cf(A, 1.0) :-
    builtin(A),
    !,
    call(A).
solve_cf(A, Cf) :-
    rule_cf(A, B, CfR),
    solve_cf(B, CfB),
    Cf is CfR * CfB.

minimum(X, Y, X) :- X =< Y, !.
minimum(X, Y, X) :- X > Y, !.


builtin(_ is _).
builtin(_ =< _).
builtin(_ >= _).
builtin(_ > _).
builtin(_ < _).
builtin(_ = _).
builtin(_ + _).
builtin(_ * _).
builtin(_ - _).
builtin(_ / _).
builtin(functor(_, _, _)).
builtin(arg(_, _, _)).
builtin(_ =.. _).
builtin(findall(_, _, _)).
builtin(bagof(_, _, _)).
builtin(setof(_, _, _)).
builtin(assert(_)).





