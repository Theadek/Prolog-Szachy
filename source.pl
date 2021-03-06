% przyjmujemy że oś X szachownicy to litery, a Y to cyfry 

% zwraca przykładową planszę z zadania
example([[e, [n, w], e, e, [b, b], e],
         [e, e, e, e, e, [r, b]],
         [e, e, [q, w], e, e, e],
         [e, e, [p, b], e, [p, b], [k, b]],
         [[k, w], [p, w], e, e, e, e],
         [e, [p, w], [n, w], e, e, e]]).

example_two([[e, [n, w], e, e, [b, b], e],
         [e, e, e, e, e, [r, b]],
         [e, e, [q, w], e, e, e],
         [e, e, [p, b], e, [p, b], [k, b]],
         [[k, w], [p, w], [b, w], e, e, e],
         [e, [p, w], [n, w], e, e, e]]).


example_three([[e, e, e, e, e, e],
		 [[k, b], e, e, e, e, e],
		 [[r, b], [r, b], e, e, e, e],
		 [e, e, e, e, e, e],
		 [e, [r, b], e, e, e, e],
		 [e, e, e, e, e, [k, w]]]).

% zrwaca figurę, B - plansza
get_chessman(B, X, Y, Chessman) :-
    nth0(X, B, Column), 
    nth0(Y, Column, Chessman).

% zmiana litery na cyfrę
ch2idx(a, 0).
ch2idx(b, 1).
ch2idx(c, 2).
ch2idx(d, 3).
ch2idx(e, 4).
ch2idx(f, 5).

num2idx(1, 0).
num2idx(2, 1).
num2idx(3, 2).
num2idx(4, 3).
num2idx(5, 4).
num2idx(6, 5).

y_pawn_movement(w, 1).
y_pawn_movement(b, -1).

% pion do przodu X, Y -> indeksy
possible_move(B, X, Y, XT, YT) :-
    get_chessman(B, X, Y, [Ch, Co|_]),
    Ch = p,
    y_pawn_movement(Co, M),
    XT is X, YT is Y + M,
    get_chessman(B, XT, YT, E),
    E = e.
% pion do przodu, w prawo X, Y -> indeksy
possible_move(B, X, Y, XT, YT) :-
    get_chessman(B, X, Y, [Ch, Co|_]),
    Ch = p,
    y_pawn_movement(Co, M),
    XT is X + 1, YT is Y + M,
    neg_col(Co, ECo),
    get_chessman(B, XT, YT, [_, ECo|_]).
% pion do przodu, w lewo X, Y -> indeksy
possible_move(B, X, Y, XT, YT) :-
    get_chessman(B, X, Y, [Ch, Co|_]),
    Ch = p,
    y_pawn_movement(Co, M),
    XT is X - 1, YT is Y + M,
    neg_col(Co, ECo),
    get_chessman(B, XT, YT, [_, ECo|_]).

% skoczek/konik
possible_move(B, X, Y, XT, YT) :-
    get_chessman(B, X, Y, [Ch, _|_]),
    Ch = n,
    move(Ch, Xm, Ym),
    XT is X + Xm, YT is Y + Ym,
    get_chessman(B, XT, YT, e).
possible_move(B, X, Y, XT, YT) :-
    get_chessman(B, X, Y, [Ch, Co|_]),
    Ch = n,
    move(Ch, Xm, Ym),
    XT is X + Xm, YT is Y + Ym,
    neg_col(Co, NCo),
    get_chessman(B, XT, YT, [_, ECo|_]),
    ECo = NCo.

% inne figury
possible_move(B, X, Y, XT, YT) :-
    get_chessman(B, X, Y, [Ch, _|_]),
    move(Ch, Xm, Ym),
    XT is X + Xm, YT is Y + Ym,
    get_chessman(B, XT, YT, e),
    is_empty_between(B, X, Y, XT, YT).
possible_move(B, X, Y, XT, YT) :-
    get_chessman(B, X, Y, [Ch, Co|_]),
    move(Ch, Xm, Ym),
    XT is X + Xm, YT is Y + Ym,
    neg_col(Co, NCo),
    get_chessman(B, XT, YT, [_, ECo|_]),
    ECo = NCo,
    is_empty_between(B, X, Y, XT, YT).

pos_B(B, X1, Y1, X2, Y2) :-
	pos_B_col(B, _, X1, Y1, X2, Y2).

pos_B_col(B, Col, X1, Y1, X2, Y2) :-
    possible_move(B, X1, Y1, X2, Y2),
    get_chessman(B, X1, Y1, [_, Col|_]),
    do_move(B, X1, Y1, X2, Y2, BNew),
    \+king_checked(BNew, Col).

% Metody do zaimplementowania:
pos(X1, Y1, X2, Y2) :-
    example(B),
    ch2idx(X1, Xi1), ch2idx(X2, Xi2),
    num2idx(Y1, Yi1), num2idx(Y2, Yi2),
    pos_B(B, Xi1, Yi1, Xi2, Yi2).

wszystkie_pos_bialych(X1, Y1, X2, Y2) :-
    example(B),
    ch2idx(X1, Xi1), ch2idx(X2, Xi2),
    num2idx(Y1, Yi1), num2idx(Y2, Yi2),
    get_chessman(B, Xi1, Yi1, [_, w|_]),
    pos_B(B, Xi1, Yi1, Xi2, Yi2).

is_mated(B, Col) :-
	king_checked(B, Col),
	\+pos_B_col(B, Col, _, _, _, _).

checkmate_B(B, List, List, Col, N) :-
	N > 0,
	is_mated(B, Col), ! .
checkmate_B(B, List, ListOut, Col, N) :-
	N > 0,
	pos_B_col(B, Col, X1, Y1, X2, Y2),
	do_move(B, X1, Y1, X2, Y2, Bnew),
	neg_col(Col, NCol),
	N1 is N - 1,
	ch2idx(XN1, X1),
	num2idx(YN1, Y1),
	ch2idx(XN2, X2),
	num2idx(YN2, Y2),
	append(List, [[XN1, YN1, XN2, YN2]], NList),
	checkmate_B(Bnew, NList, ListOut, NCol, N1).

% na dodatkowe punkty
checkmate(List, Col, N) :-
	example_two(B),
	N1 is N + 1,
	checkmate_B(B, [], List, Col, N1).


% sprawdza czy król jest szachowany
king_checked(B, Color) :-
    get_king_pos(B, Color, Xk, Yk),
    neg_col(Color, EnemyColor),
    covered_field(B, Xk, Yk, EnemyColor).

% zwraca pozycję króla
get_king_pos(B, Color, X, Y) :-
    get_chessman(B, X, Y, [k, Color|_]).

% sprawdza czy pole jest rażone przez figury danego koloru
covered_field(B, X, Y, Color) :-
    get_chessman(B, Xa, Ya, [_, Color|_]),
    possible_move(B, Xa, Ya, X, Y).     
    
% damka/królowa
move(q, 0, Y) :- range(-7, 7, O), member(Y, O).
move(q, X, 0) :- range(-7, 7, O), member(X, O).
move(q, X, Y) :-
    range(-7, 7, O),
    member(X, O),
    member(Y, O),
    Xa is abs(X),
    Ya is abs(Y),
    Xa = Ya.
% król
move(k, 0, 1).
move(k, 1, 1).
move(k, 1, 0).
move(k, 1, -1).
move(k, 0, -1).
move(k, -1, -1).
move(k, -1, 0).
move(k, -1, 1).

% wieża
move(r, 0, Y) :- range(-7, 7, O), member(Y, O).
move(r, X, 0) :- range(-7, 7, O), member(X, O).

% goniec
move(b, X, Y) :-
    range(-7, 7, O),
    member(X, O),
    member(Y, O),
    Xa is abs(X),
    Ya is abs(Y),
    Xa = Ya.

% skoczek
move(n, -1, 2).
move(n, 1, 2).
move(n, 2, 1).
move(n, 2, -1).
move(n, 1, -2).
move(n, -1, -2).
move(n, -2, -1).
move(n, -2, 1).

% naprawić - zrobić że dla każdego pomiędzy jest empty
is_empty_between(_, X1, Y1, X2, Y2) :-
    Xdiff is X1 - X2, Ydiff is Y1 - Y2,
    move(k, Xdiff, Ydiff).
is_empty_between(B, X1, Y1, X2, Y2) :-
    fields_between(X1, Y1, X2, Y2, Fields),
    check_emptyness(B, Fields).

check_emptyness(_, []) :- !.
check_emptyness(B, [[X, Y]|T]) :-
    get_chessman(B, X, Y, e),
    check_emptyness(B, T). 

fields_between(X1, Y1, X2, Y2, Zipped) :-
    Diff is X1 - X2,
    Diff = 0,
    range_ex(Y1, Y2, YList),
    length(YList, Len),
    duplicates(Len, X1, XList),
    zip(XList, YList, Zipped).
fields_between(X1, Y1, X2, Y2, Zipped) :-
    Diff is Y1 - Y2,
    Diff = 0,
    range_ex(X1, X2, XList),
    length(XList, Len),
    duplicates(Len, Y1, YList),
    zip(XList, YList, Zipped).
fields_between(X1, Y1, X2, Y2, Zipped) :-
    Xdiff is X1 - X2, Ydiff is Y1 - Y2,
    Xa is abs(Xdiff), Ya is abs(Ydiff),
    Xa = Ya, Xa > 1, Ya > 1,
    range_ex(X1, X2, XList),
    range_ex(Y1, Y2, YList),
    zip(XList, YList, Zipped).

% zwraca planszę po przeniesieniu ruchu
do_move(B, X1, Y1, X2, Y2, Bout):-
    get_chessman(B, X1, Y1, C),
    nth0(X1, B, ColFrom),
    replace(Y1, e, ColFrom, ColFromNew),
    replace(X1, ColFromNew, B, Bnew),
    nth0(X2, Bnew, ColTo),
    replace(Y2, C, ColTo, ColToNew),
    replace(X2, ColToNew, Bnew, Bout).

% podmienia element na danym Index na Elem
replace(Index, Elem, [_|T], [Elem|T]) :-
    Index = 0, !. 
replace(Index, Elem, [H|T], [H|Out]) :-
    Index1 is Index - 1,
    replace(Index1, Elem, T, Out).  

% neguje kolor
neg_col(b, w).
neg_col(w, b).

% duplikuje Num razy Typ 
duplicates(Num, _, []) :- Num = 0, !.
duplicates(Num, Type, [Type|Rest]) :-
    Num1 is Num - 1,
    duplicates(Num1, Type, Rest).

zip([], [], []).
zip([X|Xs], [Y|Ys], [[X,Y]|Zs]) :- zip(Xs,Ys,Zs).

% generatory
% range_exclusive
range_ex(First, Last, Out) :-
    Diff is First - Last,
    abs(Diff) > 1,
    First < Last,
    F1 is First + 1, L1 is Last - 1,
    range(F1, L1, Out).
range_ex(First, Last, Out) :-
    Diff is First - Last,
    abs(Diff) > 1,
    First > Last,
    F1 is First - 1, L1 is Last + 1,
    range(F1, L1, Out).

range(First, Last, Out) :-
    First =< Last, range_asc(First, Last, Out).
range(First, Last, Out) :-
    First > Last, range_desc(First, Last, Out).

range_asc(Low, High, []) :- Low > High, !.
range_asc(Low, High, [Low | Rest]) :-
    Low1 is Low + 1,
    range_asc(Low1, High, Rest).

range_desc(Low, High, []) :- Low < High, !.
range_desc(Low, High, [Low | Rest]) :-
    Low1 is Low - 1,
    range_desc(Low1, High, Rest).
