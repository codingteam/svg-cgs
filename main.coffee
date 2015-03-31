
$X.defaults.ns.cgs = "CGS" #FEATURE здесь задаются префиксы пространств имён

class Stream extends Base
	@Erorr: class
	@getDefault: ->#FEATURE конструируируем объект не через new
		__proto__: @prototype
		constructor: @
	constructor: (@fst, @snd)->
		#TODO напридумывать разных типов ошибок
		throw new @constructor.Error if (@fst.constructor != @snd.constructor)
		throw new @constructor.Error if (not @fst instanceof StreamNode) or not (@snd instanceof StreamNode)
		throw new @constructor.Error if (@fst == @snd)
		throw new @constructor.Error if @fst.streams.length and (@fst.streams[0].constructor != @constructor)
		@fst.streams.push @
		@snd.streams.push @
		@body = $svg 'g'
		@line = $svg 'line'
		@line.attr
			'stroke-width': 1
			stroke: 'black'
		@body.append @line
	destroy: ->
		@fst.streams = @fst.streams.filter (stream)=> stream == @ #TODO тут можно оптимизировать, но выигрыш будет несущественен
		@snd.streams = @snd.streams.filter (stream)=> stream == @
		@place[0].removeChild @body[0]
		@destroyed = true
		@emit 'destroy'
		@
	redraw:->
		@line.attr
			x1: @fst.x
			y1: @fst.y
			x2: @snd.x
			y2: @snd.y
	render: ->
		@place.append @body
		@
	renderTo: (@place)->
		do @redraw
		do @render

class StreamNode extends Base
	@defaults:
		x:0
		y:0
	constructor: (config, StreamType)->
		super
		@streams = []
		@streams.push StreamType.getDefault() if StreamType?
		@circle = $svg 'circle'
		@circle.attr r: 3
	connect: (node)->
		new Stream @, node
	redraw: ->
		@circle.attr
			cx: @x
			cy: @y
	render: ->
		@place.append @circle
		@
	renderTo: (@place)->
		do @redraw
		do @render

Devices = {}
StreamTypes =
	wire: Stream

class AbstractDevice extends Base
	eventList = 'click dblclick mousedown mouseup mouseover mousemove mouseout'.split ' '
	@defaults:
		x: 0
		y: 0
	constructor: ->
		super
		@nodes = {}
		do @initNodes
		@body = $svg 'use'
		@body.attr
			x: @x
			y: @y
		for event in eventList
			@body.on event, =>
				@emit arguments...
	redraw: ->
		@body.attr 'xlink:href': "##{@ref}"
		do @apdateNodes
		for nodeName, node of @nodes
			do node.redraw
		@body.attr
			x: @x
			y: @y
		@
	render: ->
		@place.append @body
		for nodeName, node of @nodes
			do node.render
		do @redraw
	renderTo: (@place)->
		do @redraw
		for nodeName, node of @nodes
			node.renderTo @place
		do @render
	destroy: ->
		for node in @nodes
			do node.destroy
		@emit 'destroy'
		@

DeviceFromXML = (xml)->
	xml = $A xml
	#TODO придумать как создавать <svg:defs/> в документе если его нет
	defs = $X '(//svg:defs)[1]'
	image = $svg 'g'
	imageContent = xml.xpath('/*/svg:*').map (e)-> e.cloneNode true
	id = do Utils.generateID
	image.attr id: id
	image.append imageContent
	defs.append image
	nodes = xml.xpath('//*/cgs:node').map (e)->
		x: parseFloat e.getAttribute 'x'
		y: parseFloat e.getAttribute 'y'
		type: StreamTypes[e.getAttribute 'type']
		name: e.getAttribute 'name'
	class Device extends AbstractDevice
		ref: id
		initNodes: ->
			for node in nodes
				@nodes[node.name] = new StreamNode {}, node.type
			return
		apdateNodes: ->
			for node in nodes
				@nodes[node.name].x = @x + node.x
				@nodes[node.name].y = @y + node.y

class Scheme extends Base
	@defaults = {}
	constructor: (config, @place)->
		super
		@children = []

class SubScheme extends Scheme

class Coil extends SubScheme
	@defaults = Utils.inherit SubScheme.defaults, {
		times: 1
		x: 0
		y: 0
	}
	constructor: ->
		super
		Spiral = Devices.coilSpiral
		@spirals = for i in [0...@times]
			spiral =	new Spiral
			spiral
		#@renderTo @place
		@nodes = [@spirals[0].fst] #WTF тут вообщето должен быть объект с именоваными полями, но тут предпочтительней пронумерованые, потому сейчас массив
		@nodes.push (spiral.snd for spiral in @spirals)...
	redraw: ->
		@spirals[0].x = @x
		@spirals[0].y = @y
		for i in [1...@times]
			delta =
				x: @spirals[i].nodes.snd.x - @spirals[i].nodes.fst.x
				y: @spirals[i].nodes.snd.y - @spirals[i].nodes.fst.y
			@spirals[i].nodes.fst = @spirals[i - 1].nodes.snd
			@spirals[i].x = @spirals[i - 1].x + delta.x
			@spirals[i].y = @spirals[i - 1].y + delta.y
			do @spirals[i].redraw
		@
	render: ->
		for spiral in @spirals
			spiral.renderTo @place
		do @redraw
	renderTo: (@place)->
		do @render
 
class SchemeViewer extends Scheme
	add: (widgets...)->
		widgets.forEach (widget)=>
			widget.renderTo @place
			@children.push widget
			widget.on 'destroy', =>
				@del widget
		@children.push widgets...
	del: (widget)->
		@children = @children.filter (testingWidget)=>
			testingWidget != widget

class SchemeEditor extends Scheme
	add: (widgets...)->
		widgets.forEach (widget)=>
			widget.renderTo @place
			widget.on 'destroy', =>
				@children = @children.filter (testingWidget)=>
					testingWidget != widget
			do widget.setDragable
		@children.push widgets...
	del: (widget)->
		@children = @children.filter (testingWidget)=>
			testingWidget != widget
