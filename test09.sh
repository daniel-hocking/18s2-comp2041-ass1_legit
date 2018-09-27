# Test to see if some more extreme inputs work, this may take a while
legit.pl init
touch files_{001..999}.txt
legit.pl add files_{001..999}.txt
legit.pl commit -m 'a'
legit.pl status
legit.pl rm files_{001..999}.txt
legit.pl status
legit.pl commit -m 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sodales urna et est malesuada auctor. Donec tincidunt urna vitae enim interdum, et feugiat quam vulputate. Pellentesque viverra, eros quis cursus pretium, quam dolor ornare tortor, in condimentum sapien magna eget lorem. Curabitur in justo mattis, sodales sem non, sollicitudin nibh. Donec non iaculis turpis, placerat commodo lacus. Sed non orci turpis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec vel tincidunt ante. Praesent dui eros, tempor sed vestibulum vitae, rhoncus ut nibh. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sodales urna et est malesuada auctor. Donec tincidunt urna vitae enim interdum, et feugiat quam vulputate. Pellentesque viverra, eros quis cursus pretium, quam dolor ornare tortor, in condimentum sapien magna eget lorem. Curabitur in justo mattis, sodales sem non, sollicitudin nibh. Donec non iaculis turpis, placerat commodo lacus. Sed non orci turpis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec vel tincidunt ante. Praesent dui eros, tempor sed vestibulum vitae, rhoncus ut nibh. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sodales urna et est malesuada auctor. Donec tincidunt urna vitae enim interdum, et feugiat quam vulputate. Pellentesque viverra, eros quis cursus pretium, quam dolor ornare tortor, in condimentum sapien magna eget lorem. Curabitur in justo mattis, sodales sem non, sollicitudin nibh. Donec non iaculis turpis, placerat commodo lacus. Sed non orci turpis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec vel tincidunt ante. Praesent dui eros, tempor sed vestibulum vitae, rhoncus ut nibh.'
legit.pl status
legit.pl log
echo {00001..99999} > a
legit.pl add a
legit.pl commit -m 'Big file'
echo 1 >> a
legit.pl commit -a -m 'Big file small update'
legit.pl status
legit.pl log
legit.pl show :a