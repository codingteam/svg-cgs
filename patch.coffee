
$X.Class.attr = (attrs)-> #TODO протестировать этот метод, а потом перенести в xpath-tools
	for item in @ when item instanceof Element
		for name, value of attrs
		  splited = name.split ':'
		  if splited.length == 2
		    [ns, name] = splited
		    try
		      if value?
		        item.setAttributeNS ns, name, value
		      else
		        item.removeAttributeNS ns, name
  		else
  		  try
  		    if value?
  		      item.setAttribute name, value
  		    else
  		      item.removeAttribute name
	@
