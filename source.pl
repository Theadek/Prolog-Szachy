board(_,[],_).
board([],_,_).
board([A],[B],L) :- L = [[A,B]].
board([A],[B|D],L) :- append([[A,B]],L1,L),board([A],D,L1).
board([A|C],[B|D],L) :- board([A],[B|D],L1),board(C,[B|D],L2),append(L1,L2,L).


% przyjmujemy że oś X szachownicy to litery, a Y to cyfry 

% zwraca przykładową planszę z zadania
example([[e, [n, w], e, e, [b, b], e],
         [e, e, e, e, e, [r, b]],
         [e, e, [q, w], e, e, e],
         [e, e, [p, b], e, [p, b], [k, b]],
         [[k, w], [p, w], e, e, e, e],
         [e, [p, w], [n, w], e, e, e]]).

% zrwaca figurę, B - plansza
get_chessman(B, X, Y, C) :- nth0(X, B, L), 
                            nth0(Y, L, C).

% zmiana litery na cyfrę
ch2num(a, 1).
ch2num(b, 2).
ch2num(c, 3).
ch2num(d, 4).
ch2num(e, 5).
ch2num(f, 6).

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
    get_chessman(B, XT, YT, [_, ECo|_]),
    ECo = b.
% pion do przodu, w lewo X, Y -> indeksy
possible_move(B, X, Y, XT, YT) :-
    get_chessman(B, X, Y, [Ch, Co|_]),
    Ch = p,
    y_pawn_movement(Co, M),
    XT is X - 1, YT is Y + M,
    get_chessman(B, XT, YT, [_, ECo|_]),
    ECo = b.

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
    negCol(Co, NCo),
    get_chessman(B, XT, YT, [_, ECo|_]),
    ECo = NCo,
    is_empty_between(B, X, Y, XT, YT).

kek(B, X, Y, XT, YT) :-
    possible_move(B, X, Y, X1, Y1),
       X2 is X1 + 1,
    ch2num(XT, X2), YT is Y1 + 1.

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

is_empty_between(_, X1, Y1, X2, Y2) :-
    Xdiff is X1 - X2, Ydiff is Y1 - Y2,
    move(k, Xdiff, Ydiff).
is_empty_between(B, X1, Y1, X2, Y2) :-
    fields_between(X1, Y1, X2, Y2, XO, YO),
    get_chessman(B, XO, YO, e).

fields_between(X1, Y1, X2, Y2, X1, YO) :-
    Diff is X1 - X2,
    Diff = 0,
    range_ex(Y1, Y2, YList),
    member(YO, YList), !.
fields_between(X1, Y1, X2, Y2, XO, Y1) :-
    Diff is Y1 - Y2,
    Diff = 0,
    range_ex(X1, X2, XList),
    member(XO, XList), !.
fields_between(X1, Y1, X2, Y2, XO, YO) :-
    Xdiff is X1 - X2, Ydiff is Y1 - Y2,
    Xa is abs(Xdiff), Ya is abs(Ydiff),
    Xa = Ya, Xa > 1, Ya > 1,
    range_ex(X1, X2, XList),
    range_ex(Y1, Y2, YList),
    zip(XList, YList, Zipped),
    member([XO, YO], Zipped), !.

% neguje kolor
negCol(b, w).
negCol(w, b).

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

% sprawdzanie, czy pozycje znajdują się na planszy
pos(X1, Y1, X2, Y2) :-
    Y1 =< 6, Y1 >= 1,
    Y2 =< 6, Y2 >= 1,
    ch2num(X1, _), ch2num(X2, _).

