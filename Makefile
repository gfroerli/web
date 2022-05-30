SSH_HOST=coredump.ch
SSH_PORT=22
SSH_USER=coredump
SSH_TARGET_DIR=/srv/www/gfroerli/

help:
	@echo "Use one of the following commands: setup, test, run, clean, dist, deploy"

setup:
	npm install

test:
	npx elm-test

run:
	npx webpack serve --port 8000 --config webpack.dev.js

format:
	npx elm-format src/

clean:
	rm -rf dist/

dist: clean
	npx webpack --config webpack.prod.js

deploy: dist
	echo "Deploying"
	rsync -e "ssh -p $(SSH_PORT)" -P --chmod=ug=rwX,o=rX -rvzc --delete dist/ $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR) --cvs-exclude

.PHONY: setup test run clean dist deploy
