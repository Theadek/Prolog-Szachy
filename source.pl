board(_,[],_).
board([],_,_).
board([A],[B],L) :- L = [[A,B]].
board([A],[B|D],L) :- append([[A,B]],L1,L),board([A],D,L1).
board([A|C],[B|D],L) :- board([A],[B|D],L1),board(C,[B|D],L2),append(L1,L2,L).


% przyjmujemy że oś X szachownicy to litery, a Y to cyfry 

% zmiana litery na cyfrę
ch2num(a, 1).
ch2num(b, 2).
ch2num(c, 3).
ch2num(d, 4).
ch2num(e, 5).
ch2num(f, 6).

% sprawdzanie, czy pozycje znajdują się na planszy
pos(X1, Y1, X2, Y2, 'yes') :- Y1 =< 6, Y1 >= 1,
   							  Y2 =< 6, Y2 >= 1,
    						  ch2num(X1, X1N), ch2num(X2, X2N).
