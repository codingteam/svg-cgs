
render = null

test_1 = -> alert "none!"
test_2 = -> alert "none!"
test_3 = ->
	Loader.load('diode','resister').then ->
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

test_4 = -> 
	Loader.load('coilSpiral').then ->
		coil = new Coil
			times: 4
			x:20
			y:30
		window.coil = coil
		coil.renderTo render

$R ->
	render = $ID 'render'
	$ID("test_1").click test_1
	$ID("test_2").click test_2
	$ID("test_3").click test_3
	$ID("test_4").click test_4
