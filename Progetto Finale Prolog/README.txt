Valmacco Daniele - 816371
Presot Federico Davide - 817290
Maino Daria Carlotta - 803140

Inizialmente, all'interno del progetto vegono definiti i metodi di supporto,
in modo che essi possano poi essere chiamati successivamente all'interno
dell'esecuzione del programma principale:

-   is_str_start(X) e is_Q(X) permettono di definire se un
    carattere sia un apice singolo o doppio
-   is_number(X) controlla che il carattere passato al suo interno
    corrisponda a una cifra da 0 a 9, a un punto o a un - nel caso dei numeri
    negativi.
-   is_comma(X), is colon(X), is_open_squareBracket(X),
    is_closed_squareBracket(X), is_open_curlyBracket(X) e
    is_closed_curlyBracket(X) vengono usati per controllare se il carattere
    passato al loro interno sia un token della grammatica jSON.
-   is_white(X) controlla che il carattere passato al suo interno
    sia uno spazio bianco.

Successivamente, viene definita la grammatica jSON in linguaggio Prolog, in
modo che in ogni passo della parse ad ogni oggetto passato in sintassi jSON
corrisponda l'oggetto corrispondente in linguaggio Prolog.

Dopo questa fase iniziale di preparazione, è possibile iniziare a creare la
json_parse(JSONString, Object). Essa si avvale dei seguenti predicati:

-   parse_string([JSONString], json_string(Object)) prende il
    contenuto della lista di caratteri [JSONString] e lo trasforma nella
    stringa contenuta in json_string(Object). Esso si avvale del predicato
    support_string([Chars], KNew, N) che rimuove dalla lista di caratteri
    [Chars] gli apici, per poi mettere il risultato in KNew; N è un contatore
    che controlla che non vi siano apici singoli o doppi nella stringa
    analizzata.
-   parse_number(JSONNumber, json_number(Object)) prende la lista
    di caratteri contenuto in JSONNumber e lo trasforma nel numero contenuto
    in json_number(Object). Esso si avvale dei predicati di supporto
    support_number([X]) che controlla che ogni carattere sia alfanumerico, e
    sign_support(List) che controlla se il numero passato sia negativo o 
    meno.
-   parse_value(JSONValue, json_value(Object)) prende la lista di
    caratteri contenuto in JSONValue e lo trasforma nel contenuto di
    json_value(Object); a seconda dell'object passato, vengono usati come
    predicati di supporto la parse_string, la parse_number o la json_parse per
    gli array/Object.
-   parse_elements(JSONElements, json_elements(X)) prende la lista
    di caratteri contenuto in JSONElements e lo trasforma in una lista di
    elementi jSON; essa usa come predicati di supporto support_elements(Array,
    ArrayEl, AtomToAnalyze) che ha il compito di riconoscere gli elementi e di
    metterli all'interno di ArrayEl, e support_elements2(ListElements, 
    ListValues) che ha il compito di parsare gli elementi in ListElements per
    poi mettere gli oggetti jSON corrispondenti in ListValues).
-   parse_array(JSONArray, json_array(X)) controlla, tramite
    l'utilizzo del predicato array_support(List, NewList), che la lista di
    caratteri passata con JSONArray corrisponda ad un array; successivamente,
    viene fatto il parsing del contenuto richiamando la parse_elements.
-   parse_pair(JSONPair, json_pair((X, Y))) prende la lista di caratteri
    contenuta in JSONPair, e la parsa utilizzando i metodi di supporto
    parse_value, parse string e support_pair(List, Value, AtomToAnalyze,
    PrevValues), che mi permette di ottenere i due elementi della pair;
    PrevValues viene utilizzato per controllare che vi siano solo due elementi
    nella pair.
-   parse_members(JSONMembers, json_members(X)) prende la lista di caratteri
    in JSONMembers e la trasforma nel contenuto di json_members(X),
    utilizzando i metodi di supporto support_members(List, ArrayEl,
    AtomToAnalyze), che mi fornisce una lista dei diversi members, e la
    support_members2(ListChars, ListPairs) che fa il parsing dei members così
    trovati tramite la parse_pair.
-   parse_obj(JSONObject, json_obj(X)) controlla che la lista di caratteri
    contenuti in JSONObject rappresenti un oggeto json, tramite l'aiuto di
    obj_support(ListChars, New) che fa il controllo sulle parentesi graffe;
    successivamente viene fatto il parsing del contenuto e viene posto
    all'interno di json_obj.
-   json_parse(JSONString, Object) esegue il parsing della stringa passata in
    JSONString, trasformandola in una lista di caratteri sulla quale vanno a
    lavorare i metodi di supporto remove_whitespace(X, Y), chiamato per primo,
    che rimuove gli spazi bianchi presenti in eccesso, e json_support(List,
    Object) che controlla se debba essere chiamata la parse_array o la
    parse_obj. 
 
Dopo aver creato la json_parse, è stato creato il predicato json_get(JSON_obj,
Field, Result) che risulta vero se Result è il contenuto del JSON_obj passato,
"dipanandolo" seguendo la catena disposta dal Field. Esso si basa sui seguenti
predicati:

-   json_get_array2(List, N, Result) e array_nested(List, N, Result), che
    vengono utilizzati come metodi di supporto nel caso si sia dentro ad un
    array.
-   json_get_obj(List, X, Result) che viene utilizzato nel caso si sia dentro
    ad un object.
-   json_get(JSON_obj, Field, Result) controlla se l'object passato sia un
    array o un object, e agisce di conseguenza, andando a chiamare i metodi di
    supporto appropriati.

Infine, sono stati creati i metodi json_load(Filename, JSON) e
json_write(JSON, FileName) per poter permettere la lettura e la scrittura da
file di oggetti jSON in sintassi jSON. In particolare, ho che:

-   json_load(FileName, JSON) prende in input la destinazione di un file
    json, e pone in JSON l'oggetto corrispondente contenuto nel file. Viene
    letto il file come stream che viene convertito in codici in modo da non
    avere problemi con il newline.
-   json_write(JSON, Filename) prende in input un oggetto jSON e ne stampa il
    contenuto nel file definito da Filename in formato jSON standard. Esso si
    avvale dei metodi di supporto string_get, number_get, value_get,
    elements_get, array_get, pair_get, members_get, obj_get e write_support
    per poter trasformare il contenuto dell'oggetto jSON in una stringa di
    caratteri, che verrà poi successivamente stampata sul nostro file 
    convertendola in stream di output.
