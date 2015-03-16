
$X.Class::attr = (attrs)-> #TODO протестировать этот метод, а потом перенести в xpath-tools
	for item in @ when item instanceof Element
		for name, value of attrs
		  splited = name.split ':'
		  if splited.length == 2
		    [ns, name] = splited
		    ns = @constructor.XPath.defaults.ns[ns]
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

$X.Class::getAttr = (attr)->
  (@constructor.Xpath "@#{attr}", @[0], {type:2})[0]
