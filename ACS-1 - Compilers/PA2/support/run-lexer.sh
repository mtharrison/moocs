cd ~/workspace
cp /src/cool.flex ~/workspace/cool.flex
cp /src/prog.cl ~/workspace/prog.cl
make lexer

./lexer prog.cl
