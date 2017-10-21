%prima definisco un nodo
%
%
isNode(void).
isNode(node(_Key, _Value, Left, Right)):-
    isNode(Right),
    isNode(Left).

%poi un albero
isTree(tree(_Name, Root)):-
    isNode(Root).

%poi una foglia, per il is_BST
isLeaf(node(_Key, _Value, void, void)).

%bstSearch(key, tree, value)
bstSearch(Key, tree(_, Root), Value):-
    bstSearch(Key, Root, Value). %ho un albero? controllo dal nodo madre
bstSearch(Key, node(Key, Value, _Left, _Right), Value). %caso base
bstSearch(Key, node(K, _, Left, _), Value):- %controllo da sinistra
    Key < K,
    bstSearch(Key, Left, Value).
bstSearch(Key, node(K, _, _, Right), Value):- %controllo da destra
    Key > K,
    bstSearch(Key, Right, Value).

%bstInsert(K, V, Tree, NewTree)
bstInsert(Key, Value, tree(TreeName, Root), tree(TreeName, NewRoot)):-
          bstInsert(Key, Value, Root, NewRoot).
bstInsert(Key, Value, void, node(Key, Value, void, void)).
% il caso che sta venendo ora(Key dei nodi uguali) lo potrei fare con
% fail, dipende da che cosa decido
bstInsert(Key, Value, node(Key, _Value, L, R), node(Key, Value, L, R)).
bstInsert(Key, Value, node(KN, KV, L, R), node(KN, KV, NewL, R)):-
    Key < KN,
    bstInsert(Key, Value, L, NewL).
bstInsert(Key, Value, node(KN, KV, L, R), node(KN, KV, L, NewR)):-
    Key > KN,
    bstInsert(Key, Value, R, NewR).

%isBst(node(K, V, L, R)) da fare per conto nostro
isBst(tree(_TreeName, Root)):-
    isBst(Root).
isBst(node(Key, Value, Left, Right)):- %caso base, foglia
    isLeaf(node(Key, Value, Left, Right)).
isBst(node(Key, _Value, node(KL, VL, LL, RL), void)):-
    %non ho diramazioni a destra
    Key > KL,
    isBst(node(KL, VL, LL, RL)).
isBst(node(Key, _Value, void, node(KR, VR, LR, RR))):-
    %non ho diramazioni a sinistra
    Key < KR,
    isBst(node(KR, VR, LR, RR)).
isBst(node(Key, _Value, node(KL, VL, LL, RL), node(KR, VR, LR, RR))):-
    %ho entrambe le diramazioni
    Key > KL,
    isBst(node(KL, VL, LL, RL)),
    Key < KR,
    isBst(node(KR, VR, LR, RR)).


