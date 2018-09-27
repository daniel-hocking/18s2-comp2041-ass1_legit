# General test that tries to give all features a bit of a go
legit.pl init
echo 1 > a
echo 2 > b
echo 3 > "a.._"
legit.pl add a "a.._" "a..._"
legit.pl add a "a.._"
legit.pl commit -m 'Hello - this is a test.'
legit.pl log
legit.pl status
legit.pl show :"a.._"
echo 2 >> a
legit.pl add b x
legit.pl add b
legit.pl add b
legit.pl status
legit.pl commit -m 'Second message = (1)' -a
legit.pl log
legit.pl status
echo 3 >> a
legit.pl rm "a.._" a
legit.pl rm "a.._" a --force --force
legit.pl status