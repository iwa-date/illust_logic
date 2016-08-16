:- use_module(library(csv)).
:- use_module(library(clpfd)).

% メイン述語 ----------------------------
% illg(+Nr, +Nc, +FName, -Solution)
% Nr:行数、Nc：列数、FName：データファイル名、Solution：結果の2次元配列
% ---------------------------------------
illg(Nr, Nc, FName, Solution) :-
    read_question_data(FName, Qs) % 問題データ読み込み
  , devide_qlist(Qs, QRs, QCs) % 問題を行と列に分ける
  , ilust_board(Nr, Nc, QRs, QCs, Solution)
  , maplist(print_list, Solution) % 結果をマトリックス表示
  .

% CSVの問題データ読み込み ----------------------------
read_question_data(FName, Qs) :-
    csv_read_file(FName, Rows, [ignore_quotes(true)])
  , maplist(row_to_list, Rows, Qs)
  .
row_to_list(Row, List):-
    Row =.. [row|List1]
  , delete(List1, '', List) % ここで空文字は削除してしまう
  .

% 問題リストを行と列に分離 -----------------------
% 先頭データが0なら列、1なら行
devide_qlist([], [], []).
devide_qlist([[0,_|Data]|T], QRs, QCs) :-
    devide_qlist(T, QRs, QCs1)
  , append([Data], QCs1, QCs)
  .
devide_qlist([[1,_|Data]|T], QRs, QCs) :-
    devide_qlist(T, QRs1, QCs)
  , append([Data], QRs1, QRs)
  .

% イラストボードの作成 ----------------------------
ilust_board(Nr, Nc, QRs, QCs, Mtx) :-
    matrix(Nr, Nc, Mtx)
  , maplist(ones, QRs, QR1s)
  , maplist(ones, QCs, QC1s)
  , maplist(sum_list, QRs, QRSums)
  , maplist(sum_list, QCs, QCSums)
  , transpose(Mtx, TMtx)
  %, maplist(print_list, Mtx)
  , maplist(line, Mtx, QRSums)
  , maplist(line, TMtx, QCSums)
  % 主に以下でバックトラックする想定
  , maplist(ones_in_zeros, Mtx, QR1s)
  , maplist(ones_in_zeros, TMtx, QC1s)
  .

matrix(Nr, Nc, Xs) :-
    length(Xs, Nr)
  , length(Ys, Nr), Ys ins Nc
  , maplist(length, Xs, Ys)
  , flatten(Xs, Zs), Zs ins 0..1
  .

% 行のルールを定義したが、枝刈の結果合計値の制約のみになった…
line(List, Sum) :- sum(List, #=, Sum).

% 「連続する1の塊が最低でも1つ以上の0を間に挟んで並ぶ」という
% ルールを表現しているつもり。
ones_in_zeros(X,Vs) :- ones_in_zeros(X, Vs, 0).
ones_in_zeros(_,[],_) :- !.
ones_in_zeros([],_,_) :- !.
ones_in_zeros([0|T1],Vs, _) :- ones_in_zeros(T1, Vs, 0).
ones_in_zeros([1|T1],[H|T2], 0) :-
    append(H, R, [1|T1])
  , ones_in_zeros(R, T2, 1)
  .

% 数値を「連続する１の塊」に変換する
ones(Ls, Ones) :-
    maplist(length, Ones, Ls)
  , flatten(Ones, Tmp)
  , Tmp ins 1
  .

% 2次元配列出力用
print_list([]) :- write('\n').
print_list([X | Xr]) :-
    (integer(X) -> format('~d ', X) ; format('~w ', X))
  , print_list(Xr)
  .