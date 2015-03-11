
$X = do->
	defaults =
		ns:
			svg: "http://www.w3.org/2000/svg"
			html: "http://www.w3.org/1999/xhtml"
			xul: "http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul"
			xslt: "http://www.w3.org/1999/XSL/Transform"
			fo: "http://www.w3.org/1999/XSL/Format"
			xlink: "http://www.w3.org/1999/xlink"
		resolver: (ns)->(prefix)-> ns[prefix] or null
		type: 0
	class Class extends [].constructor
		constructor: -> super
		clone: ->
			result = new @constructor
			result.push.apply result, @
			result
		xpath: (xp, config)->
			result = new @constructor
			for element in @
				result.push.apply result, @constructor.XPath xp, element, config
			result
		xpathFilter: (xp)->
			result = new @constructor
			result.push.apply result, @filter (item)=>
				(@constructor.XPath xp, item, {type:3})[0]
			result
		unique: if typeof Set == 'function'
			->
				result = new @constructor
				set = new Set
				@forEach (item)-> unless set.has item
					set.add item
					result.push item
				result
		else
			->
				result = new @constructor
				@forEach (item)-> if item not in result
					result.push item
				result
		addListener: (event, callback)->
			for item in @
				try item.addEventListener event, callback, false
			@
		removeListener: (event, callback)->
			for item in @
				try item.removeEventListener event, callback, false
			@
		on: ->@addListener.apply @, arguments
		off: ->@removeListener.apply @, arguments
		one: (event, callback)->
			oneCallback = ->
				try @removeEventListener event, oneCallback, false
				callback.apply @, arguments
			for item in @
				try item.addEventListener event, oneCallback, false
			@
		once: (event, callback)->
			copy = @clone()
			onceCallback = ->
				try for item in copy
					item.removeEventListener event, onceCallback, false
				callback.apply @, arguments
			for item in @
				try item.addEventListener event, onceCallback, false
			@
		dispatch: (name, params={})->
			for element in @ when typeof element.dispatchEvent == 'function'
				event = document.createEvent 'Events'
				for key, value of params
					event[key] = value
				element.dispatchEvent event
		fire: -> @dispatch.apply @, arguments
		addClass: (cls)->
			for item in @ when item instanceof Element
				item.setAttribute 'class', if item.hasAttribute 'class'
					classValue = item.getAttribute 'class'
					if cls in classValue.split /\s+/
						classValue
					else
						"#{classValue} #{cls}"
				else cls
			@
		removeClass: (cls)->
			test = (className)-> className != cls
			for item in @ when item instanceof Element
				if newClass = item.getAttribute('class').split(/\s+/).filter(test).join(' ')
					item.setAttribute 'class', newClass
				else item.removeAttribute 'class'
			@
		attr: (attrs)->
			for item in @ when item instanceof Element
				for name, value of attrs
					try
						if value?
							item.setAttribute name, value
						else
							item.removeAttribute name
			@
		css: (attrs)->
			for item in @ when item instanceof Element
				for name, value of attrs
					item.style[name] = value
			@
		empty: ->
			for item in @ when item instanceof Element
				while item.hasChildNodes()
					item.removeChild item.firstChild
			@
		remove: ->
			for item in @ when item instanceof Node
				if item.parentNode instanceof Node
					item.parentNode.removeChild item
		prepend: (args...)->
			return @ unless args.length
			prependArrayMain = (arr)->
				for value, index in arr by -1
					if value instanceof Node
						element.insertBefore value, element.firstChild
					else if value instanceof [].constructor
						prependArray value
					else
						element.insertBefore (document.createTextNode "#{value}"), element.firstChild
			prependArray = (arr)->
				if element.firstChild
					prependArray = prependArrayMain
					prependArrayMain arr
				else if arr[arr.length-1] instanceof [].constructor
					prependArray arr[arr.length-1]
					prependArray arr[0...-1]
				else
					if arr[arr.length-1] instanceof Node
						element.appendChild arr[arr.length-1]
					else
						element.appendChild document.createTextNode "#{value}"
					prependArray = prependArrayMain
					prependArray arr[0...-1]
			for item in @
				if item instanceof Node
					element = item
					break
			if element
				prependArray args
			@
		append: (args...)->
			return @ unless args.length
			appendArray = (arr)->
				for value in arr
					if value instanceof Node
						element.appendChild value
					else if value instanceof [].constructor
						appendArray value
					else
						element.appendChild document.createTextNode "#{value}"
			for item in @
				if item instanceof Node
					element = item
					break
			if element
				appendArray args
			@
		val: (value)->
			if arguments.length
				for item in @ when item.value?
					item.value = value
				return @
			else
				for item in @ when item.value?
					return item.value
	XPath = (xpath, root = document, config)->
		resolver = (config?.resolver? or defaults.resolver) (config?.ns? or defaults.ns)
		type = if config?.type? then config.type else defaults.type
		iterator = try document.evaluate xpath, root, resolver, type, null
		result = new Class
		if iterator
			switch iterator.resultType
				when 1
					result.push iterator.numberValue
				when 2
					result.push iterator.stringValue
				when 3
					result.push iterator.booleanValue
				when 4, 5
					while (item = iterator.iterateNext())?
						result.push item
				when 6, 7
					for index in [0...iterator.snapshotLength]
						result.push iterator.snapshotItem(index)
				when 8, 9
					result.push iterator.singleNodeValue
		result
	XPath.Class = Class
	Class.XPath = XPath
	XPath.defaults = defaults
	XPath.clone = ->
		newXPath = do(originalXPath = @)->->
			originalXPath.apply @, arguments
		for field in Object.keys @
			newXPath[field] = @[field]
		newClass = class extends @Class
			constructor: ->super
		newClass.XPath = newXPath
		newXPath.Class = newClass
		newXPath
	XPath

"""
click dblclick mousedown mouseup mouseover mousemove mouseout dragstart drag dragenter
dragleave dragover drop dragend keydown keypress keyup load unload abort
error resize scroll select change submit reset focus blur focusin
focusout DOMActivate DOMSubtreeModified DOMNodeInserted DOMNodeRemoved
DOMNodeRemovedFromDocument DOMNodeInsertedIntoDocument DOMAttrModified DOMCharacterDataModified
touchstart touchend touchmove touchenter touchleave
touchcancel pointerdown pointerup pointercancel pointermove
pointerover pointerout pointerenter pointerleave gotpointercapture
lostpointercapture cut copy paste beforecut
beforecopy beforepaste afterupdate beforeupdate cellchange
dataavailable datasetchanged datasetcomplete errorupdate rowenter
rowexit rowsdelete rowinserted contextmenu
selectstart help beforeunload stop beforeeditfocus
start finish bounce beforeprint afterprint
propertychange filterchange readystatechange losecapture DOMMouseScroll
dragdrop dragexit draggesture CheckboxStateChange RadioStateChange close command input
DOMMenuItemActive DOMMenuItemInactive overflow overflowchanged
underflow popuphidden popuphiding popupshowing popupshown broadcast commandupdate
""".split(/\s/).forEach (event)->
	$X.Class::[event] = (callback)->@on event, callback

$A = (arrs...)->
	result = new $X.Class
	for arr in arrs
		result.push.apply result, arr
	result
$svg = (tag)-> $A [document.createElementNS "http://www.w3.org/2000/svg", tag]
$html = (tag)-> $A [document.createElementNS "http://www.w3.org/1999/xhtml", tag]
$ID = (id, root=document)->
	element = try
		root.getElementById id
	catch e then null
	result = new $X.Class
	if element? then result.push element
	result
$C = (cls, root=document)-> $A root.getElementsByClassName cls
$N = (name, root)-> $X "//*[@name=#{JSON.stringify name}]", root
$L = console.log.bind console

$R = do->
	list = []
	(callback)->
		unless document.readyState == "complete"
			($A [document]).on 'DOMContentLoaded', -> do callback
		else
			if list.length
				list.push callback
			else
				list.push callback
				while list.length
					try
						do list[0]
					catch e
						setTimeout (->throw e), 10
					finally
						list.shift()

"concat slice splice map filter".split(" ").forEach (name)->
	$X.Class::[name] = do(method=$X.Class::[name])-> ->
		result = new @constructor
		result.push.apply result, method.apply @, arguments
		result

do(XPath = $X)->
	lastAdd = XPath.Class::addListener
	lastRemove = XPath.Class::removeListener
	add = (element, event, callback)->
		element.__xpathinfo__ ?= {}
		element.__xpathinfo__.events ?= {}
		element.__xpathinfo__.eventsDeleted ?= {}
		element.__xpathinfo__.events[event] ?= []
		element.__xpathinfo__.eventsDeleted[event] ?= 0
		element.__xpathinfo__.events[event].push callback
	remove = (element, event, callback)->
		if element?.__xpathinfo__?.events?[event]?
			callbacks = element.__xpathinfo__.events[event]
			deletes = element.__xpathinfo__.eventsDeleted[event]
			deletes += delete callbacks[callbacks.indexOf callback]
			if deletes > 16 && deletes*2 > callbacks.length
				element.__xpathinfo__.events[event] = callbacks.filter (x)->x
				element.__xpathinfo__.eventsDeleted[event] = 0
	removeAllListeners = (event)->
		@forEach (element)->try
			if element?.__xpathinfo__?.events?[event]?
				element.__xpathinfo__.events[event].forEach (callback)->
					lastRemove.call [element], event, callback
				element.__xpathinfo__.events[event] = []
				element.__xpathinfo__.eventsDeleted[event] = 0
	XPath.Class::addListener = (event, callback)->
		for element in @
			add element, event, callback
		lastAdd.call @, event, callback
	XPath.Class::removeListener = (event, callback)->
		if arguments.length > 1
			for element in @
				remove element, event, callback
			lastRemove.call @, event, callback
		else removeAllListeners.call @, event
		@

$XHR = do->
	class XHRClass
		constructor: (options)->
			{url, method, sync, login, password, headers, @data} = options
			@xhr = new XMLHttpRequest()
			@xhr.open method, url, !sync, login, password
			@setCallbacks options
			@setHeaders headers
		send: (txt)-> @xhr.send txt ? @data
		abort: -> do @xhr.abort
		on: (event, callback)->
			@xhr.addEventListener event, callback, false
			@
		setCallbacks: ({progress, load, abort, error})->
			@on 'progress', progress if progress?
			@on 'load', load if load?
			@on 'abort', abort if abort?
			@on 'error', error if error?
		setHeaders: (headers)->
			if headers? then for name, value in headers
				@xhr.setHeader name, value
			@
		success: (callback)->
			@on 'load', => callback @xhr.response, @
		fail: (callback)->
			@on 'error', (evt) =>
				callback evt, @
			@on 'abort', (evt) =>
				callback evt, @
		done: (callback)->
			@success (result, self)->
				callback null, result, self
			@fail (evt, self)->
				callback evt, null, self
	Class: XHRClass
	send: (method, url, txt, options={})->
		options = Object.create options
		options.method = method
		options.url = url
		options.sync = false
		request = new @Class options
		promise = new Promise (done, fail)->
			request.success done
			request.fail fail
		try #TODO move this `try` to XHRClass
			request.send txt
		catch e
			fail e
		promise
	get: (args...)->@send 'GET', args...
	put: (args...)->@send 'PUT', args...
	post: (args...)->@send 'POST', args...
	del: (args...)->@send 'DELETE', args...
	
###
SVG Widget Manager v0.0.2
###
#TODO: move some param from defaults to prototypes

Utils =
	times: (n, f)->
			i = 0
			loop
					r = f i
					i++
					break if i>=n

	timesA: (n, f)->
			i = 0
			while i < n
					r = f i
					i++
					r
	inherit: (base, data)->
		result = 	Object.create base
		for key,value of data
			result[key] = value
		result
	generateID: do->
		ids = {}
		$X("//*/@id").forEach (id)->
			ids[id.value] = true
		len = 3
		chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_"
		firstChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		->
			count = 0
			loop
				id = firstChars[Math.floor Math.random()*firstChars.length] + (Utils.timesA len, ->chars[Math.floor Math.random()*chars.length]).join ''
				if id in ids
					count++
				else
					ids[id] = true
				return id
				if count>len
					count = 0
					len++
	createNewFilter: (place)->
		filter = $svg "filter"
		feMerge = $svg "feMerge"
		feMergeNode = $svg "feMergeNode"
		feMergeNode.attr {'in':"SourceGraphic"}
		filter.attr
			x:0
			y:0
			id: do Utils.generateID
			filterUnits:"userSpaceOnUse"
		filter.append feMerge.append feMergeNode
		svg = place.xpath '(ancestor-or-self::svg:svg)[1]'
		defs = svg.xpath "svg:defs"
		unless defs.length
			defs = $svg 'defs'
			svg.append defs
		defs.append filter
		filter
EventProcessor = do->
	quire = []
	processEvent = (self, event, args...)->
		#if self?.__events__?.lists?[event]?
		if self && self.__events__ && self.__events__.lists && self.__events__.lists[event]
			eventList = self.__events__.lists[event]
			for callback in eventList
				if typeof callback == 'function'
					callback.apply self, args
	emit:->
		if quire.length
			quire.push arguments
		else
			quire.push arguments
			loop
				processEvent quire.pop()...
				break unless quire.length
	send: (args...)->processEvent args...
class Base
	@clone:->
		Cls = class extends @
		for key in Object.keys @
			Cls[key] = @[key]
		Cls
	constructor:(config)->
		@mixDefaults config, @constructor.defaults
	clone:->
	eventProcessor: EventProcessor
	mixDefaults:(conf, def)->
		for key of def
			@[key] = if conf?[key]? then conf[key] else def[key]
		@
	on: (event, callback)->
		@__events__ ?= {}
		@__events__.lists ?= {}
		@__events__.lists[event] ?= []
		@__events__.lists[event].push callback
		@__events__.counts ?= {}
		@__events__.counts[event] ?= 0
		@__events__.counts[event]++
		@
	off: (event, callback)->
		if @__events__?
			if @__events__.lists[event]?
				@__events__.lists[event].some (fn,i)->
					if fn == callback
						@__events__.counts[event][i]--
						delete @__events__.lists[event][i]
				if @__events__.counts[event] >= 16 && @__events__.counts[event]*2 < @__events__.lists[event].length
					@__events__.lists[event] = @__events__.lists[event].filter (x)->x
	emit: (event, args...)->@eventProcessor.emit @, event, args...
	send: (event, args...)->@eventProcessor.send @, event, args...
	destroy:->@emit 'destroy'

class ResizeableRect extends Base
	@defaults:
		x:0
		y:0
		width:300
		height:200
		minX:-Infinity
		minY:-Infinity
		maxX:Infinity
		maxY:Infinity
		maxBoundX:Infinity
		maxBoundY:Infinity
		minWidth:0
		minHeight:0
		maxWidth:Infinity
		maxHeight:Infinity
		canResizeNorth:false
		canResizeSouth:false
		canResizeWest:false
		canResizeEast:false
		transform:""
		boundClassName: 'wm-bound'
		leftResizerClassName: 'wm-left-resizer'
		rightResizerClassName: 'wm-right-resizer'
		topResizerClassName: 'wm-top-resizer'
		bottomResizerClassName: 'wm-bottom-resizer'
		backgroundClassName: 'wm-background'
		deniedClassName: 'wm-denied-resizer'
		dragable: false
	constructor: (config)->
		super
		@group = $svg "g"
		@body = $svg "g"
		@top = $svg "line"
		@bottom = $svg "line"
		@left = $svg "line"
		@right = $svg "line"
		@background = $svg "rect"
		@place = $A []
		@group.append @background, @body, @top, @bottom, @left, @right
		bound = $A @top, @bottom, @left, @right
		bound.addClass @boundClassName
		@right.addClass @rightResizerClassName
		@left.addClass @leftResizerClassName
		@top.addClass @topResizerClassName
		@bottom.addClass @bottomResizerClassName
		@background.addClass @backgroundClassName
		@group.click =>@place.append @group
		@background.mousedown downFn = (e)=>
			return unless @dragable
			return unless @widgetToDrag
			svg = @place.xpath '(ancestor-or-self::svg:svg)[1]'
			currentX = e.clientX
			currentY = e.clientY
			svg.mousemove moveFn = (e)=>
				return unless @widgetToDrag
				dr = @widgetToDrag
				newX = dr.x + e.clientX - currentX
				newY = dr.y + e.clientY - currentY
				newX = unless newX > dr.maxX - dr.width then newX else dr.maxX - dr.width
				newX = unless newX < dr.minX then newX else dr.minX
				newY = unless newY > dr.maxY - dr.height then newY else dr.maxY - dr.height
				newY = unless newY < dr.minY then newY else dr.minY
				dr.x = newX
				dr.y = newY
				do dr.redraw
				currentX = e.clientX
				currentY = e.clientY
			svg.mouseup =>
				svg.off 'mousemove', moveFn
		@right.mousedown downFn = (e)=>
			return unless e.keyCode == 0
			return unless @canResizeWest
			svg = @place.xpath '(ancestor-or-self::svg:svg)[1]'
			currentX = e.clientX
			svg.mousemove moveFn = (e)=>
				newWidth = @width + e.clientX - currentX
				newWidth = unless newWidth > @maxWidth then newWidth else @maxWidth
				newWidth = unless newWidth < @minWidth then newWidth else @minWidth
				newWidth = unless newWidth > @maxX - @x then newWidth else @maxX - @x
				@setWidth newWidth
				currentX = e.clientX
			svg.mouseup =>
				svg.off 'mousemove', moveFn
		@left.mousedown downFn = (e)=>
			return unless e.keyCode == 0
			return unless @canResizeEast
			svg = @place.xpath '(ancestor-or-self::svg:svg)[1]'
			currentX = e.clientX
			svg.mousemove moveFn = (e)=>
				newX = @x + e.clientX - currentX
				newX = unless newX > @maxX - @width then newX else @maxX - @width
				newX = unless newX < @minX then newX else @minX
				newX = unless newX > @x + @width - @minWidth then newX else @x + @width - @minWidth
				newX = unless newX < @x + @width - @maxWidth then newX else @x + @width - @maxWidth
				newWidth = @width - newX + @x
				newWidth = unless newWidth > @maxWidth then newWidth else @maxWidth
				newWidth = unless newWidth < @minWidth then newWidth else @minWidth
				@x = newX
				@width = newWidth
				currentX = e.clientX
				do @redraw
			svg.mouseup =>
				svg.off 'mousemove', moveFn
		@top.mousedown downFn = (e)=>
			return unless e.keyCode == 0
			return unless @canResizeSouth
			svg = @place.xpath '(ancestor-or-self::svg:svg)[1]'
			currentY = e.clientY
			svg.mousemove moveFn = (e)=>
				newY = @y + e.clientY - currentY
				newY = unless newY > @maxY - @height then newY else @maxY - @height
				newY = unless newY < @minY then newY else @minY
				newY = unless newY > @y + @height - @minHeight then newY else @y + @height - @minHeight
				newY = unless newY < @y + @height - @maxHeight then newY else @y + @height - @maxHeight
				newHeight = @height - newY + @y
				newHeight = unless newHeight > @maxHeight then newHeight else @maxHeight
				newHeight = unless newHeight < @minHeight then newHeight else @minHeight
				@y = newY
				@height = newHeight
				currentY = e.clientY
				do @redraw
			svg.mouseup =>
				svg.off 'mousemove', moveFn
		@bottom.mousedown downFn = (e)=>
			return unless e.keyCode == 0
			return unless @canResizeNorth
			svg = @place.xpath '(ancestor-or-self::svg:svg)[1]'
			currentY = e.clientY
			svg.mousemove moveFn = (e)=>
				newHeight = @height + e.clientY - currentY
				newHeight = unless newHeight > @maxHeight then newHeight else @maxHeight
				newHeight = unless newHeight < @minHeight then newHeight else @minHeight
				newHeight = unless newHeight > @maxY - @y then newHeight else @maxY - @y
				@setHeight newHeight
				currentY = e.clientY
			svg.mouseup =>
				svg.off 'mousemove', moveFn
	render: ->
		@place.append @group
		try do @filter.remove
		@filter = Utils.createNewFilter @place
		do @redraw
	renderTo: (@place)->
		do @render
	tryToResize:(p)->
		
	setX: (x)->
		@x = x
		do @redraw
	setY: (y)->
		@y =  y
		do @redraw
	setWidth: (width)->
		@width = width
		do @redraw
	setHeight: (height)->
		@height = height
		do @redraw
	resize: ({x1, y1, x2, y2})->
		try @x = x1
		try @y = y1
		try @width = x2 - x1
		try @height = y2 - y1
		do @redraw
	redraw: ->
		@body.attr
			transform: """
				translate(#{@x},#{@y})
			"""
			filter:"""url(##{@filter.xpath("concat(@id,'')")[0]})"""
		@top.attr
			x1: @x
			x2: @x + @width
			y1: @y
			y2: @y
		@bottom.attr
			x1: @x
			x2: @x + @width
			y1: @y + @height
			y2: @y + @height
		@left.attr
			x1: @x
			x2: @x
			y1: @y
			y2: @y + @height
		@right.attr
			x1: @x + @width
			x2: @x + @width
			y1: @y
			y2: @y + @height
		@background.attr
			x: @x
			y: @y
			width: @width
			height: @height
		@filter.attr
			width: @width
			height: @height
		if @canResizeNorth
			@top.addClass @topResizerClassName
			@top.removeClass @backgroundClassName
		else
			@top.removeClass @topResizerClassName
			@top.addClass @backgroundClassName
		if @canResizeSouth
			@top.addClass @bottomResizerClassName
			@bottom.removeClass @backgroundClassName
		else
			@bottom.removeClass @bottomResizerClassName
			@bottom.addClass @backgroundClassName
		if @canResizeWest
			@right.addClass @rightResizerClassName
			@right.removeClass @backgroundClassName
		else
			@right.removeClass @rightResizerClassName
			@right.addClass @backgroundClassName
		if @canResizeEast
			@left.addClass @leftResizerClassName
			@left.removeClass @backgroundClassName
		else
			@left.removeClass @leftResizerClassName
			@left.addClass @backgroundClassName
		@emit 'redraw'
		@
	setResizers:(flags="")->
		@canResizeSouth = 's' in falgs
		@canResizeWest = 'w' in falgs
		@canResizeEast = 'e' in falgs
		@canResizeNorth = 'n' in falgs
		do @redraw
	getResizers:->
		[
			if @canResizeSouth then 's' else ""
			if @canResizeWest then 'w' else ""
			if @canResizeEast then 'e' else ""
			if @canResizeNorth then 'n' else ""
		].join ""
	destroy:->
		try do @group.remove
		try do @filter.remove
		super
class Widget extends Base
	constructor:->
		super
		@children = []
	destroy:->
		@children.forEach (child)->
			try do child.destroy
		super
class Panel extends ResizeableRect
	eventList = 'click dblclick mousedown mouseup mouseover mousemove mouseout'.split ' '
	@defaults: Utils.inherit ResizeableRect.defaults,
		canResizeNorth:false
		canResizeSouth:false
		canResizeWest:false
		canResizeEast:false
	constructor:->
		super
		@children = []
		eventList.forEach (eventName)=>
			@group.on eventName, (event)=>
				@emit eventName, event
	addChild: (items...)->
		@children.push.apply @children, items
		items.forEach (item)=>
			item.renderTo @body
			item.parent = @
	render: ->
		super
		@children.forEach (item)-> do item.render
	destroy:->
		@children.forEach (child)->
			try do child.destroy
		super
class Window extends Widget
	@defaults:
		hederHeight: 25
		x:0
		y:0
		width:300
		height:200
	constructor:->
		super
		@bound = new Panel
			canResizeNorth:true
			canResizeSouth:true
			canResizeWest:true
			canResizeEast:true
			x:@x
			y:@y
			width:@width
			height:@height
		@header = new Panel
			x:0
			y:0
			width:@width
			height:@hederHeight
			dragable:true
			boundClassName: 'wm-hidden'
			leftResizerClassName: 'wm-hidden'
			rightResizerClassName: 'wm-hidden'
			topResizerClassName: 'wm-hidden'
			bottomResizerClassName: 'wm-hidden'
			backgroundClassName: 'wm-window-header'
		@content = new Panel
			x:0
			y:@hederHeight
			width:@width
			height:@height-@hederHeight
			boundClassName: 'wm-hidden'
			leftResizerClassName: 'wm-hidden'
			rightResizerClassName: 'wm-hidden'
			topResizerClassName: 'wm-hidden'
			bottomResizerClassName: 'wm-hidden'
			backgroundClassName: 'wm-window-background'
		@bound.addChild @header, @content
		@header.widgetToDrag = @bound
		@bound.on 'redraw', =>
			@header.resize
				x1:0
				y1:0
				x2:@bound.width
				y2:@hederHeight
			@content.resize
				x1:0
				y1:@hederHeight
				x2: Math.max @bound.width, 0
				y2: Math.max @bound.height, @hederHeight
		@header
	renderTo:(@place)->
		do @render
	render: ->
		@bound.renderTo @place
		@
	addChild: (items...)->
		@children.push.apply @children, items
		items.forEach (item)=>
			item.renderTo @content.body
			item.parent = @
	destroy:->
		try do @header.destroy
		try do @content.destroy
		try do @bound.destroy
		super
class GridView
class TreeViewblend
class LayoutItem extends Base
	@defaults:
		minOffset:NaN
		maxOffset:NaN
		minSize:NaN
		maxSize:NaN
		size:0
		offset:0
		align:0
	constructor:->
		#debugger
		super
	
	getMinOffset:->@minOffset
	getMaxOffset:->@maxOffset
	getMinSize:->@minSize
	getMaxSize:->@maxSize
	tryToResize: ({offset,size})->
		size = unless size > @maxSize then size else @maxSize
		size = unless size < @minSize then size else @minSize
		if @align < 0
			offset = unless offset > @maxOffset-size then offset else @maxOffset-size
			offset = unless offset < @minOffset then offset else @minOffset
		else if @align > 0
			offset = unless offset < @minOffset then offset else @minOffset
			offset = unless offset > @maxOffset-size then offset else @maxOffset-size
		else
			if @minSize < @maxOffset - @minOffset
				offset = (@minOffset - @minSize + @maxOffset) / 2
			else
				offset = unless offset < @minOffset then offset else @minOffset
				offset = unless offset > @maxOffset-size then offset else @maxOffset-size
		last = {@offset, @size}
		@offset = offset
		@size = size
		@emit 'resize',{offset,size}, last if (size != last.size) or (offset != last.offset)
		@
class Layout extends LayoutItem
	@defaults:Utils.inherit LayoutItem.defaults,{}
	constructor:->
		super
class HBox extends Layout
	constructor:->
		super
		@items = []
class VBox
class GBox
class Button extends Widget
	@defaults:
		x:0
		y:0
		width:25
		height:15
		shift:3
	constructor:->
		super
		@shadow = new Panel
			x:@x
			y:@y
			width:@width
			height:@height
			backgroundClassName: 'wm-button-shadow'
			boundClassName: 'wm-hidden'
		@content = new Panel
			x:@shift
			y:@shift
			width:@width-@shift*2
			height:@height-@shift*2
			backgroundClassName: 'wm-button-background'
			boundClassName: 'wm-hidden'
		@content.on 'click', (e)=>@emit 'click', e
		@content.on 'mousedown', =>
			@content.group.addClass 'wm-widget-pressed'
		@content.on 'mouseup', =>
			@content.group.removeClass 'wm-widget-pressed'
		@content.renderTo @shadow.body
	renderTo:(@place)->	
		@place = $A @place
		do @render
	render: ->
		@shadow.renderTo @place
		@
class Label extends Base
	eventList = 'click dblclick mousedown mouseup mouseover mousemove mouseout'.split ' '
	@defaults:
		text:""
		textClass:""
		gorizontalAlign:0
		textStyle:{}
		verticalAlign:0
		horisontalAlign:1
		x:0
		y:0
		width:NaN
		height:NaN
		minX:NaN
		minY:NaN
		maxX:NaN
		maxY:NaN
		maxBoundX:NaN
		maxBoundY:NaN
		minWidth:0
		minHeight:0
		maxWidth:NaN
		maxHeight:NaN
	constructor: ->
		super
		@textStyle = Object.create @textStyle
		@body = $svg 'g'
		@content = $svg 'text'
		@content.addClass 'wm-label-text'
		@content.selectstart ->false
		@body.append @content.append @text
		eventList.forEach (eventName)=> #TODO: apply this fiature in Panel
			@body.on eventName, (event)=>
				@parent?.emit? eventName, event
	render: ->
		try do @filter.remove
		@filter = Utils.createNewFilter @place
		do @redraw
	renderTo: (@place)->
		@place.append @body
		do @render
	redraw: ->
		@body.attr filter: null
		bound = @content[0].getBBox()
		posX = if @horisontalAlign>0
			@x
		else if @horisontalAlign<0
			@x + @width - bound.width
		else
			@x + (@width - bound.width)*.5
		posY = if @verticalAlign>0
			@y + bound.height
		else if @verticalAlign<0
			@y + @height + bound.height
		else
			@y + (@height + bound.height)*.5
		@content.attr
			x:posX
			y:posY
		try @filter.attr
			x:@x
			y:@y
			width: @width
			height: @height
		try @body.attr
			filter:"""url(##{@filter.xpath("concat(@id,'')")[0]})"""
		@
	setText:(@text)->
		@content.empty().append @text
		do @redraw
	destroy:->
		do @body.remove
		do @filter.remove
class Groupe extends Base
	defaults:{}
	constructor:(config)->
		super
class Picture extends Base
applyConfig = do->
	applyConfig = (conf)->
		for typeDefaults,typeName of conf when typeName of applyConfig.types
			for field,fieldName of typeDefaults
				if field?
					applyConfig.types[typeName].defaults[fieldName]=field
				else
					delete applyConfig.types[typeName].defaults[fieldName]
	applyConfig.types = {
		ResizeableRect
		Panel
		Window
		Widget
		Button
		Label
	}
	applyConfig
Forms=
	create:(config)->
		loop
			type = config.type
			preprocessors = @preprocessors[type] || []
			preprocessors.forEach (preprocessors)->
				newConfig = preprocessors.call config
				config = if newConfig? then newConfig else config
			break if config.type == type
		res = new @types[config.type] config
		if config.items
			for item in config.items
				res.addChild @create item
		postprocessors = @postprocessors[type] || []
		postprocessors.forEach (postprocessor)->
			postprocessor.call res
		res
	types:
		panel: Panel
		button: Button
		window: Window
		label: Label
	preprocessors:{}
	postprocessors:{}
class Diod extends Base
  @defaults:
    maxWidth: 10
    minWidth: 8
  constructor: (defs)->
    alert "test"