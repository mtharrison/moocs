cd ~/workspace
cp /src/parser-phase.cc ~/workspace/parser-phase.cc
cp /src/cool.y ~/workspace/cool.y
cp /src/prog.cl ~/workspace/prog.cl

make parser
./myparser prog.cl
