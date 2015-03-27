all: unilib patchlib mainlib testlib loader

unilib:
	cat svgwm/test.css test.css > all.css
	autoprefixer all.css
	cat svgwm/xpath-tools/core.coffee \
	svgwm/xpath-tools/events.coffee \
	svgwm/xpath-tools/utils.coffee \
	svgwm/xpath-tools/off.coffee \
	svgwm/xpath-tools/ajax.coffee \
	svgwm/main.coffee \
	> all.coffee
	coffee -c --bare all.coffee

patchlib:
	coffee -c --bare patch.coffee

mainlib:
	coffee -c --bare main.coffee

testlib:
	coffee -c --bare test.coffee
	
loader:
	coffee -c --bare loader.coffee

clean:
	rm -f all.coffee
	rm -f all.js
	rm -f patch.js
	rm -f main.js
	rm -f test.js
	rm -f loader.js
