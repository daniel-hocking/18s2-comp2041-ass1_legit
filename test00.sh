# Test to show very basic error messages show at correct times
legit.pl
legit.pl abc
legit.pl a b c d
legit.pl add
echo 1 > a
legit.pl add a
legit.pl add b
legit.pl add ''
legit.pl commit
legit.pl commit -m
legit.pl commit -m ''
legit.pl commit -m abc
legit.pl log
legit.pl show
legit.pl show 0:abc
legit.pl show 0:''
legit.pl init abc
legit.pl init
legit.pl init
legit.pl log
legit.pl show
legit.pl commit
legit.pl commit -m ''
legit.pl commit -m abc