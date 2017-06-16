cd ~/workspace
cp /src/cool.flex ~/workspace/cool.flex
cp /src/prog.cl ~/workspace/prog.cl
cp /src/pa1-grading.pl ~/workspace/pa1-grading.pl

perl pa1-grading.pl
cp -r ./grading /src
