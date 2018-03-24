%% Maino Daria Carlotta - 803140
%% Presot Federico Davide - 817290
%% Valmacco Daniele - 816371

%% prima definisco i metodi di supporto
is_DQ(X) :-
    char_type(X, to_lower('"')),
    !.
is_SQ(X) :-
    char_type(X, to_lower('\'')),
    !.
is_Q(X):-
    is_SQ(X).
is_Q(X):-
    is_DQ(X).

is_str_start(X):-
    is_DQ(X),
    !.
is_str_start(X):-
    is_SQ(X),
    !.

is_number(X) :-
    X > 47,
    X < 58,
    !.
is_number(X) :-
    X = 46.
is_minus(X) :-
    X = 45.

is_comma(X) :-
    char_type(X, to_lower(',')).

is_white(X) :-
    char_type(X, to_lower(' ')),
    !.
is_white(X):-
    char_type(X, to_lower('\t')),
    !.
is_white(X):-
    char_type(X, to_lower('\n')).

is_closed_squareBracket(X) :-
    char_type(X, to_lower(']')).

is_open_squareBracket(X) :-
    char_type(X, to_lower('[')).

is_closed_curlyBracket(X) :-
    char_type(X, to_lower('}')).

is_open_curlyBracket(X) :-
    char_type(X, to_lower('{')).

is_colon(X):-
    char_type(X, to_lower(:)).

%% poi passo alla definizione della grammatica json
json_string(X) :-
    string(X).

json_number(X) :-
    number(X).

json_members([]).
json_members([Pair | MoreMembers]):-
    json_pair(Pair),
    json_members(MoreMembers).

json_elements([]).
json_elements([Value | MoreElements]) :-
    json_value(Value),
    json_elements(MoreElements).

json_obj(X) :-
    json_members(X).

json_array(X) :-
    json_elements(X).

json_JSON(X) :-
    json_obj(X),
    !.
json_JSON(X) :-
    json_array(X),
    !.

json_value(X) :-
    json_number(X),
    !.
json_value(X) :-
    json_string(X),
    !.
json_value(X) :-
    json_JSON(X),
    !.

json_pair((X, Y)) :-
    json_string(X),
    json_value(Y).

%% and now... for something completely different:
%% a man, trying to parse some json objects

%% parse string
parse_string(['"' | JSONString], json_string(Object)) :-
    support_string(JSONString, KNew, 1),
    !,
    string_chars(Object, KNew).
parse_string(['\'' | JSONString], json_string(Object)):-
    support_string(JSONString, KNew, 1),
    !,
    string_chars(Object, KNew).

%% metodo di supporto alla parse string
support_string(['"'], [], 1).
support_string(['\''], [], 1).
support_string([First | Rest], KNew, N) :-
    is_DQ(First),
    !,
    support_string(Rest, KBase, Z),
    N is Z + 1,
    KNew = KBase.
support_string([First | Rest], KNew, N) :-
    support_string(Rest, KBase, Z),
    !,
    N = Z,
    KNew = [First | KBase].

%% parse_number
parse_number(JSONNumber, json_number(Object)) :-
    sign_support(JSONNumber),
    !,
    number_codes(Object, JSONNumber).

%% metodo support number
support_number([X]) :-
    char_code(X, K),
    is_number(K).
support_number([First | Rest]) :-
    char_code(First, Value),
    is_number(Value),
    support_number(Rest).

%% metodo sign support, usato per i numeri negativi
%%caso in cui io abbia il meno
sign_support([First | Rest]):-
    char_code(First, Value),
    is_minus(Value),
    support_number(Rest).
%% caso in cui io non abbia il meno
sign_support(List):-
    support_number(List).

%% parse_value
%% caso in cui ho una string in ingresso
parse_value(JSONValue, json_value(Object)) :-
    parse_string(JSONValue, json_string(Object)),
    !.
%% caso in cui ho un object in ingresso
parse_value(JSONValue, json_value(Object)) :-
    json_parse(JSONValue, Object),
    !.
%% caso in cui ho un numero in ingresso
parse_value(JSONValue, json_value(Object)) :-
    parse_number(JSONValue, json_number(Object)),
    !.

%% parse_elements
parse_elements(JSONElements, json_elements(X)) :-
    support_elements(JSONElements, X2, W),
    support_elements2([W | X2], X),
    !.

%% support_elements
support_elements([], [], []).
support_elements([First | Rest], ArrayEl, AtomToAnalyze) :-
    is_comma(First),
    support_elements(Rest, ArrayEl2, AtomToAnalyze2),
    ArrayEl = [AtomToAnalyze2 | ArrayEl2],
    AtomToAnalyze = [].
support_elements([First | Rest], ArrayEl, AtomToAnalyze) :-
    support_elements(Rest, ArrayEl2, AtomToAnalyze2),
    ArrayEl = ArrayEl2,
    AtomToAnalyze = [First | AtomToAnalyze2].

%% support_members2
support_elements2([], []).
support_elements2([X | Xs], ListValues) :-
    support_elements2(Xs, BaseList),
    parse_value(X, json_value(Final)),
    ListValues = [(Final) | BaseList].

%% parse_array
parse_array(JSONArray, json_array(X)) :-
    JSONArray = ['[', ']'],
    !,
    X = [].
parse_array([First | RestArray], json_array(X)) :-
    is_open_squareBracket(First),
    array_support(RestArray, NewList),
    !,
    parse_elements(NewList, json_elements(X)).

%% metodo di supporto per il parsing dell'array
array_support([X | Rest], []):-
    is_closed_squareBracket(X),
    Rest = [],
    !.
array_support([X | Xs], New) :-
    array_support(Xs, Base),
    !,
    New = [X | Base].

%% parse_pair
parse_pair(JSONPair, json_pair((X, Y))) :-
    support_pair(JSONPair, SecondMember, FirstMember, void),
    parse_value(SecondMember, json_value(Y)),
    parse_string(FirstMember, json_string(X)),
    Y \= void.

%% metodo di supporto per il pair
%% PrevValues viene usato sia come supporto, sia per verificare che si abbia
%% un pair da due elementi
support_pair([], void, [], void).
support_pair([First | Rest], Value, AtomToAnalyze, PrevValues) :-
    is_colon(First),
    support_pair(Rest, Value2, AtomToAnalyze2, _),
    Value = AtomToAnalyze2,
    PrevValues = Value2,
    AtomToAnalyze = [].
support_pair([First | Rest], Value, AtomToAnalyze, RestValues) :-
    support_pair(Rest, Value2, AtomToAnalyze2, RestValues),
    Value = Value2,
    AtomToAnalyze = [First | AtomToAnalyze2].

%% parse_members
parse_members(JSONMembers, json_members(X)) :-
    support_members(JSONMembers, X2, W),
    support_members2([W | X2], X).
    %% qua X2 è una lista di membri che devo analizzare, e W è l'ultimo

%% support_members
support_members([], [], []).
support_members([First | Rest], ArrayEl, AtomToAnalyze) :-
    is_comma(First),
    support_members(Rest, ArrayEl2, AtomToAnalyze2),
    ArrayEl = [AtomToAnalyze2 | ArrayEl2],
    AtomToAnalyze = [].
support_members([First | Rest], ArrayEl, AtomToAnalyze) :-
    support_members(Rest, ArrayEl2, AtomToAnalyze2),
    ArrayEl = ArrayEl2,
    AtomToAnalyze = [First | AtomToAnalyze2].

%% support_members2
support_members2([], []).
support_members2([X | Xs], ListPairs) :-
    support_members2(Xs, BaseList),
    parse_pair(X, json_pair((M, Y))),
    ListPairs = [((M, Y)) | BaseList].

%% parse_object
parse_obj(JSONObject, json_obj(X)) :-
    JSONObject = ['{', '}'],
    !,
    X = [].
parse_obj([First | Rest], json_obj(X)) :-
    is_open_curlyBracket(First),
    obj_support(Rest, NewList),
    parse_members(NewList, json_members(X)),
    !.

%% metodo di supporto per il parsing dell'object
obj_support([X | Rest], []):-
    is_closed_curlyBracket(X),
    Rest = [],
    !.
obj_support([X | Xs], New) :-
    obj_support(Xs, Base),
    !,
    New = [X | Base].

%% json_parse
%% caso in cui stia passando un atomo
json_parse(JSONString, Object) :-
    atom(JSONString),
    !,
    atom_chars(JSONString, ListChars),
    remove_whitespace(ListChars, FinalList),
    json_support(FinalList, Object).
%% caso in cui stia passando una stringa
json_parse(JSONString, Object) :-
    string(JSONString),
    !,
    string_to_atom(JSONString, ListChars),
    json_parse(ListChars, Object).
%% caso in cui stia passando una lista (sono già dentro al parsing)
json_parse(JSONList, Object) :-
    json_support(JSONList, Object).

%% supporto json
%% caso in cui io abbia un object
json_support([First | JSONList], Object) :-
    First = '{',
    !,
    parse_obj([First | JSONList], Object).
%% caso in cui io abbia un array
json_support([First | JSONList], Object) :-
    First = '[',
    !,
    parse_array([First | JSONList], Object).

%% metodo remove_whitespace, da implementare nella parse
%% in modo da togliere gli spazi, visto che creano problemi
remove_whitespace(X, Y) :-
    remove_whitespace(X, Y, _).
remove_whitespace([], [], 0).
remove_whitespace([First | Rest], FinalList, N) :-
    is_Q(First),
    remove_whitespace(Rest, List, M),
    !,
    N is M + 1,
    FinalList = [First | List].
remove_whitespace([First | Rest], FinalList, N) :-
    is_white(First),
    remove_whitespace(Rest, Array, N),
    0 is N mod 2,
    !,
    FinalList = Array.
remove_whitespace([First | Rest], FinalList, N) :-
    is_white(First),
    remove_whitespace(Rest, Array, N),
    !,
    FinalList = [First | Array].
remove_whitespace([First | Rest], FinalList, N) :-
    remove_whitespace(Rest, Array, N),
    FinalList = [First | Array].

%% metodo json_get
%% per Field vuoto
json_get(JSON_obj, [], JSON_obj):- !.
%% per l'array (potrei avere fields multipli)
json_get(JSON_obj, Field, Result):-
    JSON_obj = json_array(X),
    array_nested(X, Field, Result),
    !.
%% per un object
%% caso con singolo Field, ma posto come atomo
json_get(JSON_obj, Field, Result):-
    atom(Field),
    string_to_atom(FinalField, Field),
    json_get_obj(JSON_obj, FinalField, Result).
%% caso con singolo field, posto normalmente
json_get(JSON_obj, Field, Result) :-
    JSON_obj = json_obj(X),
    json_get_obj(X, Field, Result),
    !.
%%caso con singolo Field atomo dentro ad un object
json_get(JSON_obj, [Field], Result):-
    atom(Field),
    string_to_atom(FinalField, Field),
    json_get_obj(JSON_obj, FinalField, Result).
%% caso con singolo Field dentro ad un object
json_get(JSON_obj, [Fields], Result) :-
    JSON_obj = json_obj(X),
    json_get_obj(X, Fields, Result),
    !.
%% caso con multipli field, il primo è un atomo
json_get(JSON_obj, [Field1 | RestFields], FinalResult) :-
    atom(Field1),
    string_to_atom(FinalField, Field1),
    JSON_obj = json_obj(X),
    json_get_obj(X, FinalField, Result),
    !,
    json_get(Result, RestFields, FinalResult).
%% caso con multipli field
json_get(JSON_obj, [Field1 | RestFields], FinalResult) :-
    JSON_obj = json_obj(X),
    json_get_obj(X, Field1, Result),
    !,
    json_get(Result, RestFields, FinalResult).

%% supporto per l'array
json_get_array2([X | _], 0, X).
json_get_array2([_X | Rest], N, Result):-
    json_get_array2(Rest, Q, Result),
    N is Q + 1.
array_nested(Prova, N, Result):-
    json_get_array2(Prova, N, Result).
array_nested(Prova, [N], Result):-
    json_get_array2(Prova, N, Result).
array_nested(Prova, [First | Rest], FinalResult):-
    json_get_array2(Prova, First, PrimoResult),
    json_get(PrimoResult, Rest, X),
    X = FinalResult.

%% supporto per l'object
json_get_obj([(A, B) | _], A, B).
json_get_obj([(A, _B) | NextCouples], X, Result) :-
    X \= A,
    json_get_obj(NextCouples, X, Result).

%% json_load
json_load(FileName, JSON):-
    open(FileName, read, In),
    read_stream_to_codes(In, Codes),
    close(In),
    atom_codes(String, Codes),
    json_parse(String, JSON).

%% json_write
json_write(JSON, FileName):-
    open(FileName, write, Out),
    write_support(JSON, Result),
    write(Out, Result),
    nl(Out),
    close(Out).

%% metodi di supporto alla json_write: aiutano ad estrarre
%% dall'oggetto json il contenuto, seguendo gli standard json.
string_get(json_string(X), FinalString):-
    string_to_atom(X, Y),
    atom_chars(Y, Chars),
    append(Chars, ['\"'], Part1),
    append(['\"'], Part1, Content),
    atom_chars(FinalString, Content).

number_get(json_number(X), FinalNumber):-
   number_codes(X, Codes),
   atom_codes(FinalNumber, Codes).

value_get(json_value(X), FinalValue):-
    string(X),
    !,
    string_get(json_string(X), FinalValue).
value_get(json_value(X), FinalValue):-
    number(X),
    !,
    number_get(json_number(X), FinalValue).
value_get(json_value(X), FinalValue):-
    array_get(X, FinalValue),
    !.
value_get(json_value(X), FinalValue):-
    obj_get(X, FinalValue),
    !.

elements_get(json_elements([X]), FinalValue):-
   value_get(json_value(X), FinalValue),
   !.
elements_get(json_elements([First | Rest]), FinalValue):-
    elements_get(json_elements(Rest), CurrentValue),
    atom_chars(CurrentValue, Chars),
    append([','], Chars, MidValue),
    value_get(json_value(First), CurrentElement),
    !,
    atom_chars(CurrentElement, MoreChars),
    append(MoreChars, MidValue, FinalChars),
    atom_chars(FinalValue, FinalChars).

%% per l'array_get devo mettere anche il caso in cui io abbia l'array vuoto
array_get(json_array([]), FinalValue):-
    FinalValue = '[]',
    !.
array_get(json_array(X), FinalValue):-
    elements_get(json_elements(X), CurrentValue),
    !,
    atom_chars(CurrentValue, CurrentChars),
    append(['['], CurrentChars, MidValue),
    append(MidValue, [']'], FinalChars),
    atom_chars(FinalValue, FinalChars).

pair_get(json_pair((X, Y)), FinalValue):-
    string_get(json_string(X), FirstValue),
    value_get(json_value(Y), SecondValue),
    !,
    atom_chars(FirstValue, FirstChars),
    atom_chars(SecondValue, SecondChars),
    append(FirstChars, [':'], MidChars),
    append(MidChars, SecondChars, FinalChars),
    atom_chars(FinalValue, FinalChars).

members_get(json_members([X]), FinalValue):-
   pair_get(json_pair(X), FinalValue),
   !.
members_get(json_members([First | Rest]), FinalValue):-
    members_get(json_members(Rest), CurrentValue),
    atom_chars(CurrentValue, Chars),
    append([','], Chars, MidValue),
    pair_get(json_pair(First), CurrentPair),
    !,
    atom_chars(CurrentPair, MoreChars),
    append(MoreChars, MidValue, FinalChars),
    atom_chars(FinalValue, FinalChars).

%% per l'obj_get, così come per l'array, devo porre anche il caso in cui abbia
%% un object vuoto
obj_get(json_obj([]), FinalValue):-
    FinalValue = '{}',
    !.
obj_get(json_obj(X), FinalValue):-
    members_get(json_members(X), CurrentValue),
    !,
    atom_chars(CurrentValue, CurrentChars),
    append(['{'], CurrentChars, MidChars),
    append(MidChars, ['}'], FinalChars),
    atom_chars(FinalValue, FinalChars).

%% e, per finire in bellezza...
write_support(json_obj(X), FinalValue):-
    obj_get(json_obj(X), FinalValue),
    !.
write_support(json_array(X), FinalValue):-
    array_get(json_array(X), FinalValue),
    !.
