
$X.defaults.ns.cgs = "CGS" #FEATURE здесь задаются префиксы пространств имён

class Resistor extends Base
  @defaults:
    x: 0
    y: 0
  constructor: ->
    super
    @body = $svg 'g'
    @body.attr
      fill: 'red'
      stroke: 'black'
      'stroke-width': 1
      transform: "translate(#{@x} #{@y})"
    rect = $svg 'rect'
    rect.attr
      x: 5
      y: 3
      width: 10
      height: 4
    line0 = $svg 'line'
    line0.attr
      x1: 0
      y1: 5
      x2: 5
      y2: 5
    line1 = $svg 'line'
    line1.attr
      x1: 15
      y1: 5
      x2: 20
      y2: 5
    @body.append rect, line0, line1
    @nodes =
      fst: new StreamNode {}, Stream
      snd: new StreamNode {}, Stream
  redraw: ->
    @nodes.fst.x = @x
    @nodes.fst.y = @y + 5
    @nodes.snd.x = @x + 20
    @nodes.snd.y = @y + 5
    @
  render: ->
    @place.append @body
    @
  renderTo: (@place)->
    do @redraw
    @nodes.fst.renderTo @place
    @nodes.snd.renderTo @place
    do @render

 
class Stream extends Base
  @Erorr: class
  @getDefault: ->#FEATURE конструируируем объект не через new
    __proto__: @::
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
  constructor: ->
    super
    @nodes = {}
    do @initNodes
    @body = $svg 'use'
    @body.attr
      x: @x
      y: @y
  redraw: ->
    @body.attr 'xlink:href': "##{@ref}"
    do @apdateNodes
    @
  render: ->
    @place.append @body
    @
  renderTo: (@place)->
    do @redraw
    for node of @nodes
      node.renderTo @place
    do @render
    

DeviceFromXML = (xml)->
  xml = $A [xml]
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
