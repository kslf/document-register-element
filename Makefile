.PHONY: build duk var node amd size hint clean test web preview pages dependencies

# repository name
REPO = document-register-element

# make var files
VAR = src/$(REPO).js

# make var files
IE8 = src/$(REPO)-ie8.js

# make node files
NODE = $(VAR)

# make amd files
AMD = $(VAR)

# README constant


# default build task
build:
	make clean
	make var
	make ie8
#	make node
#	make amd
	make test
#	make hint
	make size

# build generic version
var:
	mkdir -p build
	cat template/var.before $(VAR) template/var.after >build/no-copy.$(REPO).max.js
	node node_modules/uglify-js/bin/uglifyjs --verbose build/no-copy.$(REPO).max.js >build/no-copy.$(REPO).js
	cat template/license.before LICENSE.txt template/license.after build/no-copy.$(REPO).max.js >build/$(REPO).max.js
	cat template/copyright build/no-copy.$(REPO).js >build/$(REPO).js
	rm build/no-copy.$(REPO).max.js
	rm build/no-copy.$(REPO).js

# build IE8 specific version
ie8:
	mkdir -p build
	cat template/var.before $(IE8) template/var.after >build/no-copy.$(REPO)-ie8.max.js
	node node_modules/uglify-js/bin/uglifyjs --verbose build/no-copy.$(REPO)-ie8.max.js >build/no-copy.$(REPO)-ie8.js
	cat template/license.before LICENSE.txt template/license.after build/no-copy.$(REPO)-ie8.max.js >build/$(REPO)-ie8.max.js
	cat template/copyright build/no-copy.$(REPO)-ie8.js >build/$(REPO)-ie8.js
	rm build/no-copy.$(REPO)-ie8.max.js
	rm build/no-copy.$(REPO)-ie8.js

# build node.js version
node:
	mkdir -p build
	cat template/license.before LICENSE.txt template/license.after template/node.before $(NODE) template/node.after >build/$(REPO).node.js

# build AMD version
amd:
	mkdir -p build
	cat template/amd.before $(AMD) template/amd.after >build/no-copy.$(REPO).max.amd.js
	node node_modules/uglify-js/bin/uglifyjs --verbose build/no-copy.$(REPO).max.amd.js >build/no-copy.$(REPO).amd.js
	cat template/license.before LICENSE.txt template/license.after build/no-copy.$(REPO).max.amd.js >build/$(REPO).max.amd.js
	cat template/copyright build/no-copy.$(REPO).amd.js >build/$(REPO).amd.js
	rm build/no-copy.$(REPO).max.amd.js
	rm build/no-copy.$(REPO).amd.js

# build self executable for duktape
duk:
	node -e 'var fs=require("fs");\
          fs.writeFileSync(\
            "test/duk.js",\
            fs.readFileSync("node_modules/wru/build/wru.console.js") +\
            "\n" +\
            fs.readFileSync("build/$(REPO).js") +\
            "\n" +\
            fs.readFileSync("test/$(REPO).js").toString().replace(/^[^\x00]+?\/\/:remove\s*/,"")\
          );'


size:
	wc -c build/$(REPO).max.js
	gzip -c build/$(REPO).js | wc -c

# hint built file
hint:
	node node_modules/jshint/bin/jshint build/$(REPO).max.js

# clean/remove build folder
clean:
	rm -rf build

# tests, as usual and of course
test:
	npm test

# launch polpetta (ctrl+click to open the page)
web:
	node node_modules/polpetta/build/polpetta ./

# markdown the readme and view it
preview:
	node_modules/markdown/bin/md2html.js README.md >README.md.htm
	cat template/md.before README.md.htm template/md.after >README.md.html
	open README.md.html
	sleep 3
	rm README.md.htm README.md.html

pages:
	git pull --rebase
	make var
	mkdir -p ~/tmp
	mkdir -p ~/tmp/$(REPO)
	cp .gitignore ~/tmp/
	cp -rf src ~/tmp/$(REPO)
	cp -rf build ~/tmp/$(REPO)
	cp -rf test ~/tmp/$(REPO)
	cp index.html ~/tmp/$(REPO)
	git checkout gh-pages
	cp ~/tmp/.gitignore ./
	mkdir -p test
	rm -rf test
	cp -rf ~/tmp/$(REPO) test
	git add .gitignore
	git add test
	git add test/.
	git commit -m 'automatic test generator'
	git push
	git checkout master
	rm -r ~/tmp/$(REPO)

# modules used in this repo
dependencies:
	rm -rf node_modules
	mkdir node_modules
	npm install wru
	npm install polpetta
	npm install uglify-js@1
	npm install jshint
	npm install markdown
