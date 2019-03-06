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

% biały pion do przodu X, Y -> indeksy
possible_move(B, X, Y, 0, 1) :- get_chessman(B, X, Y, [Ch, Co|_]), 
                                Ch = p, Co = w,
                                TX is X, TY is Y + 1,
                                get_chessman(B, TX, TY, E), 
                                E = e.
% biały pion do przodu, w prawo X, Y -> indeksy
possible_move(B, X, Y, 1, 1) :- get_chessman(B, X, Y, [Ch, Co|_]), 
                                Ch = p, Co = w,
                                TX is X + 1, TY is Y + 1,
                                get_chessman(B, TX, TY, [_, ECo|_]), 
                                ECo = b.
% biały pion do przodu, w lewo X, Y -> indeksy
possible_move(B, X, Y, -1, 1) :- get_chessman(B, X, Y, [Ch, Co|_]), 
                                Ch = p, Co = w,
                                TX is X - 1, TY is Y + 1,
                                get_chessman(B, TX, TY, [_, ECo|_]), 
                                ECo = b.


% sprawdzanie, czy pozycje znajdują się na planszy
pos(X1, Y1, X2, Y2) :- Y1 =< 6, Y1 >= 1,
                       Y2 =< 6, Y2 >= 1,
                       ch2num(X1, _), ch2num(X2, _).

% TODO:
% zdefiniować ruchy figur,
% 
