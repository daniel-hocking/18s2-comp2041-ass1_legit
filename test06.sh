# Test focusing on the status command
legit.pl status
legit.pl init
legit.pl status
echo 1 > a
legit.pl status
legit.pl add a
legit.pl status
legit.pl commit -m 'a'
legit.pl status
legit.pl status -a
legit.pl status a b c d
touch 1 2 3 4 5
touch b c d e f
touch "b,a,c"
touch "__a__"
touch "-a"
legit.pl status
legit.pl add 2 4 b f "b,a,c"
legit.pl status
legit.pl commit -m 'b'
legit.pl status
legit.pl add 1 "__a__"
legit.pl status
touch "a__" "b--c"
legit.pl add "a__" "b--c"
legit.pl status
legit.pl commit -m 'c'
legit.pl status
echo 1 > "a__"
legit.pl commit -m 'd' -a
legit.pl status
echo 1 > g
legit.pl add g
legit.pl status
legit.pl add g
legit.pl status
legit.pl rm --cached g
legit.pl status
legit.pl commit -m 'e'
legit.pl status
echo 1 > f
legit.pl add f
legit.pl status
rm f
legit.pl status
legit.pl rm f --cached
legit.pl status
echo 1 > h
legit.pl add h
legit.pl commit -m 'f'
legit.pl status
echo 2 > h
legit.pl status
legit.pl add h
legit.pl status
echo 3 > h
legit.pl status
legit.pl rm h
legit.pl rm --force h
legit.pl status