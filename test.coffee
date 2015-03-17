
render = null
wire = null

test_1 =() ->
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
      resister3.renderTo render

test_4 = () ->
  $XHR.get('lib-cgs/gost-2.730-73/diode-v2.svg')
    .then (data)->
      (new DOMParser).parseFromString data,"text/xml"
    .then (xml)->
      Devices.resister = DeviceFromXML xml
    .then ->
      resister4 = new Devices.resister
        x: 10
        y: 30
      $L resister4
      resister4.renderTo render

$R ->
  render = $ID 'render'
  $ID("test_1").click -> test_1()
  $ID("test_2").click -> test_2()
  $ID("test_3").click -> test_3()
  $ID("test_4").click -> test_4()
