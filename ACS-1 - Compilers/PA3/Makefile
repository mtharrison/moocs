.PHONY: build lex compile

parse:
	docker run --rm -it -v "$$PWD":/src compilers-pa3 /bin/bash /src/support/run-parser.sh
build:
	docker rm compilers-PA3 || true
	docker run --name compilers-PA3 -it -v "$$PWD":/src cmc333333/compilers-docker /bin/bash /src/support/build.sh
	docker commit compilers-PA3 compilers-pa3
clone:
	docker run --rm -it -v "$$PWD":/src compilers-pa3 /bin/bash /src/support/clone.sh
