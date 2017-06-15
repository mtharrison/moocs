cd ~/workspace
cp /src/cool.flex ~/workspace/cool.flex
cp /src/prog.cl ~/workspace/prog.cl
make lexer

printf "\n"

coolc prog.cl
spim prog.s

printf "\n"

./mycoolc prog.cl
spim prog.s
