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

%!bstSearch(key, tree, value)
bstSearch(Key, tree(_, Root), Value):-
    bstSearch(Key, Root, Value). %ho un albero? controllo dal nodo madre
bstSearch(Key, node(Key, Value, _Left, _Right), Value). %caso base
bstSearch(Key, node(K, _, Left, _), Value):- %controllo da sinistra
    Key < K,
    bstSearch(Key, Left, Value).
bstSearch(Key, node(K, _, _, Right), Value):- %controllo da destra
    Key > K,
    bstSearch(Key, Right, Value).
%Questa bstSearch è stata modificata per poterla usare nella treeSuccessor, ora
%è un casino della Madonna
bstSearch(Key, node(Kn, Vn, Left, Right), Father, Father,
                node(Kn, Vn, Left, Right)):-
                Key = Kn.
bstSearch(Key, node(Kn, Vn, Left, Right), _, Father, Kfound):-
    Key < Kn,
    bstSearch(Key, Left, node(Kn, Vn, Left, Right), Father, Kfound).
bstSearch(Key, node(Kn, Vn, Left, Right), _, Father, Kfound):-
    Key >= Kn,
    bstSearch(Key, Right, node(Kn, Vn, Left, Right), Father, Kfound).

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

%isBst(node(K, V, L, R))
isBst(tree(_Name, Root)):-
    isBst(Root).
isBst(node(K, V, L, R)):-
    isBst(-10000, node(K, V, L, R), 10000).

isBst(_, void, _).
isBst(Min, node(K, _V, Left, Right), Max):-
    K >= Min,
    K < Max,
    isBst(Min, Left, K),
    isBst(K, Right, Max).

%treeTrasversal(node(K, V, Left, Right), KVs)
%Definisco i tre casi
treeTrasversal(inOrder, tree(_Name, Root), KVs):-
    treeInOrder(Root, KVs).

treeTrasversal(preOrder, tree(_Name, Root), KVs):-
    treePreOrder(Root, KVs).

treeTrasversal(postOrder, tree(_Name, Root), KVs):-
    treePostOrder(Root, KVs).

%prima definisco la treeInorder
treeInOrder(void, []).
treeInOrder(node(K, V, Left, Right), KVs):-
    treeInOrder(Left, LKVs),
    treeInOrder(Right, RKVs),
    append(LKVs, [{K, V} | RKVs], KVs).
%poi la treePreOrder
treePreOrder(void, []).
treePreOrder(node(K, V, Left, Right), KVs):-
    treePreOrder(Left, LKVs),
    treePreOrder(Right, RKVs),
    append([{K, V} | LKVs], RKVs, KVs).
%infine faccio la treePostOrder
treePostOrder(void, []).
treePostOrder(node(K, V, Left, Right), KVs):-
    treePostOrder(Left, LKVs),
    treePostOrder(Right, RKVs),
    append(LKVs, RKVs, LowerKVs),
    append(LowerKVs, [{K, V}], KVs).

%treeSuccessor la deve inserire Daniele
