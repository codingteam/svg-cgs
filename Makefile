all: all.css all.js patch.js main.js test.js loader.js

all.css: test.css
	cat svgwm/test.css test.css > all.css
	autoprefixer all.css
all.js:
	cat svgwm/xpath-tools/core.coffee \
	svgwm/xpath-tools/events.coffee \
	svgwm/xpath-tools/utils.coffee \
	svgwm/xpath-tools/off.coffee \
	svgwm/xpath-tools/ajax.coffee \
	svgwm/main.coffee \
	> all.coffee
	coffee -c --bare all.coffee

patch.js: patch.coffee
	coffee -c --bare patch.coffee

main.js: main.coffee
	coffee -c --bare main.coffee

test.js: test.coffee
	coffee -c --bare test.coffee
	
loader.js: loader.coffee
	coffee -c --bare loader.coffee

clean:
	rm -f all.coffee
	rm -f all.js
	rm -f patch.js
	rm -f main.js
	rm -f test.js
	rm -f loader.js
