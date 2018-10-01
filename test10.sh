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
legit.pl branch -d a
legit.pl branch -d a
legit.pl branch a
legit.pl branch a -d
legit.pl branch b
legit.pl branch c
legit.pl branch d
legit.pl branch
legit.pl checkout b
echo 1 > a
legit.pl commit -a -m 'b1'
legit.pl checkout master
legit.pl branch -d b
legit.pl checkout b
legit.pl branch b2
legit.pl branch
legit.pl checkout b2
legit.pl branch b -d
legit.pl log
legit.pl checkout b
legit.pl checkout master