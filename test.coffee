
wire = null

test_1 =() ->
  render = $ID 'render'
  resistor1 = new Resistor
    x:10
    y:55
  resistor2 = new Resistor
    x:50
    y:25
  wire = resistor1.nodes.snd.connect resistor2.nodes.fst
  [
    resistor1
    resistor2
    wire
  ].forEach (widget)-> widget.renderTo render

test_2 = () ->
    do wire.destroy

test_3 = () ->
  $XHR.get('img/resister.svg')
    .then (data)->
      (new DOMParser).parseFromString data,"text/xml"
    .then (xml)->
      Devices.resister = DeviceFromXML xml
    .then ->
      resister3 = new Devices.resister
        x: 10
        y: 30
      $L resister3
      #resister3.renderTo render
