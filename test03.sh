# Test for deleting files
legit.pl init
echo 1 > a
rm a
legit.pl add a
echo 1 > a
legit.pl add a
rm a
legit.pl add a
legit.pl commit -m 'a'
echo 1 > a
legit.pl add a
rm a
legit.pl commit -m 'b'
echo 1 > a
legit.pl add a
legit.pl commit -m 'c'
legit.pl add a
echo 2 > a
legit.pl commit -m 'd'
rm a
legit.pl add a
legit.pl commit -m 'e'
echo 3 > b
legit.pl add b
legit.pl commit -m 'f'
echo 4 > a
legit.pl add a
legit.pl commit -m 'g'
legit.pl log
legit.pl show 0:a
legit.pl show 1:a
legit.pl show 2:a
legit.pl show 3:a
legit.pl show :a