# Test for adding multiple files to a commit
legit.pl init
echo 1 > a
legit.pl add d c b a
legit.pl commit -m 'a'
echo 1 > b
echo 1 > c
echo 1 > d
legit.pl add e b c d
legit.pl commit -m 'b'
legit.pl add a b c d
legit.pl commit -m 'c'
legit.pl log
echo 2 > a
legit.pl add a b c d
legit.pl commit -m 'd'
legit.pl add a b c d
legit.pl commit -m 'e'
legit.pl log
echo 3 > a
echo 1 > .e
legit.pl add a b c d .e
legit.pl commit -m 'f'
legit.pl add a
echo 2 > b
echo 2 > c
legit.pl add b
legit.pl add c
legit.pl commit -m 'g'
echo 3 > c
legit.pl add c
legit.pl commit -m 'g'
echo 5 > e
legit.pl add e
legit.pl commit -m 'h'
legit.pl log
legit.pl show 0:a
legit.pl show 1:a
legit.pl show 2:a
legit.pl show 3:a
legit.pl show 4:a
legit.pl show :a
legit.pl show 0:e
legit.pl show 1:e
legit.pl show 2:e
legit.pl show 3:e
legit.pl show 4:e
legit.pl show :e