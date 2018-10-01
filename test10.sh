# Test for branch command
legit.pl branch
legit.pl branch -a
legit.pl init
legit.pl branch
touch a
legit.pl add a
legit.pl commit -m 'a1'
legit.pl branch
legit.pl branch -d
legit.pl branch -a
legit.pl branch -d master
legit.pl branch -d abc
legit.pl branch -d ''
legit.pl branch -d '_a'
legit.pl branch '_a'
legit.pl branch ''
legit.pl branch a
legit.pl branch a