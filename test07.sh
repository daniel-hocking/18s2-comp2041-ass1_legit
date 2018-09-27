# Test focusing on the rm command
legit.pl rm
legit.pl init
legit.pl rm
legit.pl rm --force --cache
legit.pl rm --force a
echo 1 > a
legit.pl rm --force a
legit.pl add a
legit.pl rm --force a
legit.pl commit -m 'a'
legit.pl status
legit.pl rm a
legit.pl rm a
legit.pl rm --force a
legit.pl add a
legit.pl rm a
echo 1 > b
legit.pl add b
legit.pl commit -m 'b'
legit.pl status
legit.pl rm --force --cached --force --cached --force --cached --force --cached b -force --force --cached --force --cached --force --cached
legit.pl rm --force --cached --force --cached --force --cached --force --cached b --forced --force --cached --force --cached --force --cached
legit.pl rm --force --cached --force --cached --force --cached --force --cached b --force --cached --force --cached --force --cached
legit.pl status
touch c d e f g h i j k
legit.pl status
legit.pl add c d e f g h i j k
legit.pl status
legit.pl rm c d e f g h i j k --cached
legit.pl status
legit.pl add c d e f g h i j k k k
legit.pl status
legit.pl rm c d e f g --cached h i j k
legit.pl status
legit.pl rm c d e f g --cache h i j k
legit.pl status
legit.pl rm c d e f g -cache h i j k
legit.pl status
legit.pl rm c d e f g h i j k t
legit.pl status
legit.pl rm c d e f g h i j k k k --force
legit.pl status
touch 1 2 3
legit.pl add 1 2 3
legit.pl rm 1 2 3 _g --force
legit.pl status
touch x y z
legit.pl add x y z
legit.pl rm --force x y yy zz z
legit.pl status