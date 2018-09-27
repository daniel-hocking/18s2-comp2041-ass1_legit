# Test focusing on the commit -a option
legit.pl init
echo 1 > a
echo 1 > b
echo 1 > c
echo 1 > d
echo 1 > e
legit.pl commit -a -m 'a'
legit.pl commit -m 'a' -a
legit.pl status
legit.pl add a b
legit.pl commit -a -m 'b'
legit.pl status
echo 1 > a
echo 2 > b
legit.pl status
legit.pl commit -a -m 'c'
legit.pl commit -a -m 'd'
legit.pl status
echo 3 > a
echo 3 > b
legit.pl add c d
legit.pl status
echo 4 > c
echo 4 > d
legit.pl commit -a -m 'd'
legit.pl log
legit.pl status
echo 5 > a
legit.pl commit -a -a -a -a -a -a -m 'e' -a -a -a -a -a -a
legit.pl status
legit.pl log
legit.pl show 3:a
legit.pl show 4:a
echo 6 > a
legit.pl commit -a -a -a -a -a -m -m 'f' -a -a -a -a -a -a
legit.pl status
legit.pl commit -a -a -a -a -a -m 'f' 'f' -a -a -a -a -a -a
legit.pl status
rm a
legit.pl add a
legit.pl commit -a -m 'g'
legit.pl status
echo 7 > a
legit.pl status
legit.pl add a
legit.pl rm a --cached
legit.pl commit -a -m 'h'
legit.pl status