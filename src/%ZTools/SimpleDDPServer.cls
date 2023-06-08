Class %ZTools.SimpleDDPServer Extends %CSP.Page
{

ClassMethod OnPage() As %Status
{
	set namespace = %request.Get("namespace")
	set globalnode=%request.Get("globalnode")
	set command = %request.Get("command")
	set value = %request.Get("value")
	zn namespace
	if command = "get"  {
	  write @globalnode
    }
    elseif command = "set" {
      set @globalnode = value
    }

    Quit $$$OK
}

}