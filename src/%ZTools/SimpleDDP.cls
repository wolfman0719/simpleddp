Class %ZTools.SimpleDDP Extends %Base [ Not ProcedureBlock ]
{

// 以下のメソッド(Get,Set,Order)でグローバルリファレンス名の参照の際に任意のローカル変数を参照する可能性があるために、ProcedureBlockにしない

ClassMethod httpcommand(pCommand As %String, pUrl As %String, pPort As %Integer = 80, pStatus As %Status) As %String
{
  new status,protocol,https,server,url,params,i,kv,url,httprequest,gzip,length,contents
  set status = $$$OK
    
  try {

     set protocol = $piece(pUrl,":")
	 set https = $select(protocol="https":1,1:0)
	 set server = $piece(pUrl,"/",3)
	 set url = $piece(pUrl,"/",4,*)
	 set params = $piece(url,"?",2)
	 if params'="" {
	    	
	 for i = 1:1:$length(params,"&") {
	   set kv= $piece(params,"&",i)
	   set kv(i,"KEY") = $piece(kv,"=",1)
	   set kv(i,"VALUE") = $piece(kv,"=",2)
	   set kv = i
	 }
   }
		  
   set url = $piece(url,"?",1)
	  	
   set httprequest=##class(%Net.HttpRequest).%New()
	
   set httprequest.Server = server
   set httprequest.Port = pPort
   if https set httprequest.Port = 443
   set httprequest.Https = https
   set httprequest.SSLConfiguration = "MYSSL"
	
   for i = 1:1:$get(kv) {
     do httprequest.SetParam(kv(i,"KEY"),kv(i,"VALUE"))
   }	  
   if pCommand = "get" {
     set status = httprequest.Get(##class(%CSP.Page).EscapeURL(url))
   }
   else {
	 set status = httprequest.Post(##class(%CSP.Page).EscapeURL(url))
   }
	  
   $$$ThrowOnError(status)

   set statuscode = httprequest.HttpResponse.StatusCode
   if statuscode > 399 {
     $$$ThrowStatus($$$ERROR($$$GeneralError,"http status error "_statuscode))
   }
   if pCommand = "get" {
     set gzip = httprequest.HttpResponse.Data
	 set length = 360000
	 set contents = gzip.Read(.length,.status)
   }
   else {
     set contents = ""
   }
 }
    
 Catch e {
   set status = e.AsStatus()
 }

    set pStatus = status
    
    quit $get(contents)
}

ClassMethod Get(pGlobalNode As %String) As %String
{
  // 戻り値
  //   正常形　1;Getの結果
  //   異常値　status値
  
  new status,serverinfo,value,address,port,namespace,glorefcheck,gloref,url
  set status = $$$OK
    
  try {
	    
	  if $extract(pGlobalNode,1) = "@" {
		  set pGlobalNode = @($extract(pGlobalNode,2,*))
	  }
	  
    set serverinfo = ..ResolveServer(pGlobalNode)
	  
	if serverinfo = "" set value = status_";"_$get(@pGlobalNode) quit
	  
	set address = $list(serverinfo,1)
	set port = $list(serverinfo,2)
	set namespace = $list(serverinfo,3)
	  
	set glorefcheck = $get(@pGlobalNode)
	  
	set gloref = $ZReference
		
	// セキュリティの観点では、ユーザー名、パスワードをそのまま使用しているのはよくないプラクティスだが、とりあえずデフォルトのユーザー名、パスワードを使用
	
	set url = "http://"_address_"/csp/sys/%ZTools.SimpleDDPServer.cls"_"?command=get&namespace="_namespace_"&globalnode="_gloref_"&IRISUsername=_system&IRISPassword=SYS"
	  	  	
	set value = ..httpcommand("get",url,port,.status)
	if 'status set value = status
	
   }
    
   Catch e {
	  
     set value = e.AsStatus()

   }
    
   quit value
}

ClassMethod Set(pCommand As %String) As %Status
{
  // 戻り値
  //   正常形　1
  //   異常値　status値
  
  new status,global,serverinfo,serverinfo2,value,address,port,namespace,glorefcheck,gloref,url

  set status = $$$OK
    
  try {
	  
    set pCommand = $translate(pCommand," ","")
	 set global = $piece(pCommand,"=",1)
	 set value = $piece(pCommand,"=",2)

	  if $extract(global,1) = "@" {
		  set global = @($extract(global,2,*))
	  }
  
	  if $extract(value,1) = "@" {
		  set value = @($extract(value,2,*))
	  }

	 if $extract(value,1) '= "^" {
	  if value ["""" {
      // リテラル値の場合は、ダブルクオートを取り除いて、値だけ取り出す
	    set value = $translate(value,"""","")
	  }
	  else {
		// 変数の場合は、その値を取得
		set value = $get(@value)
	  }
	}
	set serverinfo = ..ResolveServer(global)
	set serverinfo2 = ..ResolveServer(value)
	  
	if serverinfo2 '= "" {
	  set value = $zddpget(value)
	}
	elseif serverinfo = "" {
	  set @global = value quit
	}
		  
	set address = $list(serverinfo,1)
	set port = $list(serverinfo,2)
	set namespace = $list(serverinfo,3)
	  
	set glorefcheck = $get(@global)
	  
	set gloref = $ZReference
	
	// セキュリティの観点では、ユーザー名、パスワードをそのまま使用しているのはよくないプラクティスプラクティスだが、とりあえずデフォルトのユーザー名、パスワードを使用
	  
	set url = "http://"_address_"/csp/sys/%ZTools.SimpleDDPServer.cls"_"?command=set&namespace="_namespace_"&globalnode="_gloref_"&value="_value_"&IRISUsername=_system&IRISPassword=SYS"
	  	  	
	set value = ..httpcommand("get",url,port,.status)	  

	if 'status {
	  set value = status
	}
	else {
	  set value = $$$OK
	}
	
  }
    
  Catch e {

    set value = e.AsStatus()

  }
    
  quit value
}

ClassMethod Order(pGlobalNode As %String) As %String
{
  // 戻り値
  //   正常形　1;$Orderの結果
  //   異常値　status値
  // 予約語
  //   zZnode
  //   ZZnodename
  //   この２つの変数はバッテングすると動作に支障がでるので、このメソッドを呼び出すロジック上では利用できない
  
  new status,globalref,global,serverinfo,value,address,port,namespace,glorefcheck,gloref,url,zZnode,zZnodename

  set status = $$$OK
    
  try {
	    
	  if $extract(pGlobalNode,1) = "@" {
		  set pGlobalNode = @($extract(pGlobalNode,2,*))
	  }

    set serverinfo = ..ResolveServer(pGlobalNode)
	
	if pGlobalNode ["," {
	  // 2添え字以上
	  set globalref = $piece(pGlobalNode,",",1,*-1)_")"
	  set zZnodename = $translate($piece(pGlobalNode,",",*),")","")
	}
	else {
	  // 1添え字の場合
	  set globalref = $piece(pGlobalNode,"(",1)
	  set zZnodename = $piece($piece(pGlobalNode,"(",2),")",1)
	}
	
	if zZnodename > 0 {
	  set zZnode = $get(@zZnodename)
	}
	elseif zZnodename '[ """" {
	  set zZnode = $get(@zZnodename)
	} 
	else {
	  set zZnode = zZnodename
	}
	
	set glorefcheck = $get(@globalref)
	set gloref = $ZReference
        
    if serverinfo = "" {
	  set zZnode = status_";"_$order(@gloref@(zZnode)) quit
	}
	  
	set address = $list(serverinfo,1)
	set port = $list(serverinfo,2)
	set namespace = $list(serverinfo,3)
	  	
	// セキュリティの観点では、ユーザー名、パスワードをそのまま使用しているのはよくないプラクティスだが、とりあえずデフォルトのユーザー名、パスワードを使用
	
	set url = "http://"_address_"/csp/sys/%ZTools.SimpleDDPServer.cls"_"?command=order&namespace="_namespace_"&globalnode="_gloref_"&node="_zZnode_"&IRISUsername=_system&IRISPassword=SYS"
	  	  	
	set zZnode = ..httpcommand("get",url,port,.status)	  
	if 'status set zZnode = status
	
    }
    
    Catch e {
	    
	  set zZnode = e.AsStatus()
    }
    
    quit zZnode
}

ClassMethod ResolveServer(pGlobalNode As %String) As %String
{
  new status,globalname,namespace,serverinfo,estatus
  set status = $$$OK
    
  try {
    set globalname = $piece(pGlobalNode,"(",1)
	set namespace = $namespace
	set serverinfo = $get(^%ZTools.SimpleDDP("GlobalMapping",namespace,globalname))
  }
    
  Catch e {
    set estatus = e.AsStatus
	//do $system.Status.DisplayError(estatus)
  }
    
  quit serverinfo
}

}
