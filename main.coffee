class Resistor extends Base
  @defaults:
    x: 0
    y: 0
  constructor: (defs)->
    super
    alert "test"
  render:->
  renderTo: (place)->