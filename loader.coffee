
Loader =
	devices:
		diode: "lib-cgs/gost-2.730-73/diode-v2.svg"
		resister: "lib-cgs/gost-2.728-74/резистор-постоянный.svg"
		coilSpiral: "lib-cgs/for_test/виток.svg"
	load: (names...)->
		Promise.all names.map (name)=>
			if Devices[name]?
				do Promise.resolve
			else
				if @devices[name]?
					$L "Нет устройства #{name}"
					do Promise.reject
				$XHR.get(@devices[name])
					.then (data)->
						(new DOMParser).parseFromString data,"text/xml"
					.then (xml)->
						 Devices[name] = DeviceFromXML xml
					.catch (e)=> 
						$L "Не загрузилось #{name} по ссылке #{@devices[name]}", e
						do Promise.reject
 