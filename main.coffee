class Resistor extends Base
  @defaults:
    x: 0
    y: 0
  constructor: ->
    super
    @body = $svg 'g'
@body.attr
      fill: 'red'
      fill: 'red'
      srtoke: 'black'
      'stroke-width': 1
      transform:"translate(#{@x} #{@y})"
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
      y1: 53
      x2: 20
      y2: 5
    @body.append rect, line0, line1
  render: ->
    @place.append @body
  renderTo: (@place)->
    do @render

->
    do @render

