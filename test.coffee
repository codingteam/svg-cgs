
$R ->
  render = $ID 'render'
  resistor1 = new Resistor
    x:10
    y:15
  resistor2 = new Resistor
    x:50
    y:25
  wire = resistor1.nodes.snd.connect resistor2.nodes.fst
  [
    resistor1
    resistor2
    wire
  ].forEach (widget)-> widget.renderTo render
