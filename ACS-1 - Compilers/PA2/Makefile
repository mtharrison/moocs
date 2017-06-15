.PHONY: build lex compile

lex:
	docker run --rm -it -v "$$PWD":/src compilers-pa2 /bin/bash /src/support/run-lexer.sh
compile:
	docker run --rm -it -v "$$PWD":/src compilers-pa2 /bin/bash /src/support/run-compiler.sh
build:
	docker rm compilers-PA2
	docker run --name compilers-PA2 -it -v "$$PWD":/src cmc333333/compilers-docker /bin/bash /src/support/build.sh
	docker commit compilers-PA2 compilers-pa2
