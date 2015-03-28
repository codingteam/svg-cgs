Loader =
	devices:
		diode: "lib-cgs/gost-2.730-73/diode-v2.svg"
		resister: "lib-cgs/gost-2.728-74/резистор-постоянный.svg"
		coilSpiral: "lib-cgs/gost-2.730-73/diode-v2.svg"
	load: (names...)->
		Promise.all names.map (name)=>
			if Devices[name]?
				do Promise.resolve
			else
				$XHR.get(@devices[name])
					.then (data)->
       			(new DOMParser).parseFromString data,"text/xml"
     			.then (xml)->
      			 Devices[name] = DeviceFromXML xml