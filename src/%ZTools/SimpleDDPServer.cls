Class %ZTools.SimpleDDPServer Extends %CSP.Page
{

ClassMethod OnPage() As %Status
{
	set namespace = %request.Get("namespace")
	set globalnode=%request.Get("globalnode")
	set command = %request.Get("command")
	set value = %request.Get("value")
	if $zv [ "IRIS"  {
	set $namespace = namespace
	}
	else {
	znspace namespace
	}
	if command = "get"  {
	  write @globalnode
	}
	elseif command = "set" {
	set @globalnode = value
	}

	Quit $$$OK
}

}
