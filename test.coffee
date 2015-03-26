
test_1 = -> alert "none!"
test_2 = ->
    do wire.destroy

test_3 = ->
 resisterLoader = 
   $XHR.get('lib-cgs/gost-2.728-74/резистор-постоянный.svg')
     .then (data)->
       (new DOMParser).parseFromString data,"text/xml"
     .then (xml)->
       Devices.resister = DeviceFromXML xml
 diodeLoader = 
   $XHR.get('lib-cgs/gost-2.730-73/diode-v2.svg')
     .then (data)->
       (new DOMParser).parseFromString data,"text/xml"
     .then (xml)->
       Devices.diode = DeviceFromXML xml
       Devices.coilSpiral = Devices.diode

	Promise.all([resisterLoader, diodeLoader])
    .then ->
      resister3 = new Devices.resister
        x: 200
        y: 60
      resister3.renderTo render

      diode1 = new Devices.diode
        x: 30
        y: 30
      diode1.renderTo render
      
      wire1 = diode1.nodes.snd.connect resister3.nodes.fst
      wire1.renderTo render

test_4 = -> alert "none!"

$R ->
  render = $ID 'render'
  $ID("test_1").click test_1
  $ID("test_2").click test_2
  $ID("test_3").click test_3
  $ID("test_4").click test_4
