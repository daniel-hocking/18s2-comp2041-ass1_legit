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