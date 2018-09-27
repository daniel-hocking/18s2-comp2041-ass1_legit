# Test for files with non ASCII chars - this test may break your shell a little
legit.pl init
head -c 200 /bin/bash > a
legit.pl add a
legit.pl commit -m 'a'
head -c 300 /bin/bash > a
legit.pl add a
legit.pl commit -m 'b'
legit.pl log
legit.pl status
legit.pl show 0:a
legit.pl show 1:a
legit.pl show :a