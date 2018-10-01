# Test for checkout command
legit.pl checkout
legit.pl init
legit.pl checkout
touch a
legit.pl add a
legit.pl commit -m 'a1'
legit.pl checkout
legit.pl checkout master
legit.pl checkout a
legit.pl branch a
legit.pl branch
legit.pl checkout a
legit.pl checkout a
legit.pl log
legit.pl status
touch b
legit.pl status
legit.pl branch b
legit.pl branch c
legit.pl branch d
legit.pl branch e
legit.pl checkout b
legit.pl status
legit.pl commit -m 'b'
legit.pl status
legit.pl log
legit.pl checkout c
legit.pl status
legit.pl log
legit.pl branch
legit.pl checkout b
legit.pl branch -d e