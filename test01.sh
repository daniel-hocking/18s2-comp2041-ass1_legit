# Test for unusual filenames or commit messages
legit.pl init
echo 1 > _a
legit.pl add _a
legit.pl add _b
legit.pl add b
legit.pl add b_b
legit.pl add -a
echo 1 > .a
legit.pl add .a
legit.pl add .b
echo 1 > -a
legit.pl add -a
legit.pl add -b
echo 1 > 'a$'
legit.pl add 'a$'
legit.pl add 'b$'
echo 1 > 'a*'
legit.pl add 'a*'
legit.pl add 'b*'
echo 1 > 'a&'
legit.pl add 'a&'
legit.pl add 'b&'
echo 1 > 'a.....a'
legit.pl add 'a.....a'
legit.pl add 'b.....b'
legit.pl commit -m '-m'
legit.pl commit -m '_m'
legit.pl commit -m 'm'
echo 1 > a
legit.pl add a
legit.pl commit -m ' m'
echo 2 > a
legit.pl add a
legit.pl commit -m '.m'
echo 3 > a
legit.pl add a
legit.pl commit -m '.'
echo 4 > a
legit.pl add a
legit.pl commit -m 'm-'
echo 5 > a
legit.pl add a
legit.pl commit -m '*'
echo 1 > 'a b        c'
legit.pl add 'a b        c'
echo 1 > aaaaaaaaaaaaaaaaaaaaaaa_bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb_cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc_ddddddddddddddddddddddddddddddddddddddddddddddd
legit.pl add aaaaaaaaaaaaaaaaaaaaaaa_bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb_cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc_ddddddddddddddddddddddddddddddddddddddddddddddd
legit.pl commit -m aaaaaaaaaaaaaaaaaaaaaaa_bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb_cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc_ddddddddddddddddddddddddddddddddddddddddddddddd
legit.pl log