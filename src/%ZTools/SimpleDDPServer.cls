Class %ZTools.SimpleDDPServer Extends %CSP.Page
{

Parameter CONVERTINPUTSTREAM = 1;

ClassMethod OnPage() As %Status
{
			// 戻り値
			//   正常　1;コマンドの戻り値
			//   異常　status値

  set status = $$$OK
	
  try {

    set namespace = %request.Get("namespace")
	set globalnode=%request.Get("globalnode")
	set zZznode = %request.Get("node")
	set command = %request.Get("command")
	set value = %request.Get("value")
	set $namespace = namespace
	if command = "get"  {
	  write status_";"_$get(@globalnode)
	}
	elseif command = "set" {
	  set @globalnode = value
	  write status
	}
	elseif command = "order" {
  	  set zZznode = $order(@globalnode@(zZznode))
  	  write status_";"_zZznode
    }
  }
  catch e {
    set status = e.AsStatus()
	write status
  }
																	

	Quit $$$OK
}

}

