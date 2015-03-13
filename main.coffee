
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
      transform:"translate(#{@x} #{@y})"
    rect = $svg 'rect'
    rect.attr
      x: "5mm"#5
      y: "3mm"#3
      width: "10mm"#10
      height: "4mm"#4
    line0 = $svg 'line'
    line0.attr
      x1: 0
      y1: "5mm"#5
      x2: "5mm"#5
      y2: "5mm"#5
    line1 = $svg 'line'
    line1.attr
      x1: "15mm"#15
      y1: "5mm"#5
      x2: "20mm"#20
      y2: "5mm"#5
    @body.append rect, line0, line1
  render: ->
    @place.append @body
  renderTo: (@place)->
    do @render

class Stream extends Base
  @Erorr: class
  @getDefault: ->#FEATURE конструируируем объект не через new
    __proto__: @::
    constructor: @
  constructor: (@fst, @snd)->
    throw new @constructor.Error if (@fst.constructor != @snd.constructor) or (not @fst instanceof StreamNode) or not (@snd instanceof StreamNode) or (@fst == @snd)
    @fst.push @
    @snd.push @
  destroy: ->
    @fst.streams = @fst.streams.filter (stream)=> stream == @ #TODO тут можно оптимизировать, но выиграш будет несущественен
    @snd.streams = @snd.streams.filter (stream)=> stream == @
    @
    

class StreamNode extends Base
  constructor: (StreamType)->
    @streams = []
    @streams.push StreamType.getDefault() if StreamType?
  connect: (node)->
    new Stream @, node
