Class %ZTools.SimpleDDP Extends %Base
{

ClassMethod httpget(pUrl As %String, pPort As %Integer = 80, pStatus As %Status) As %String
{
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
	
	  set status = httprequest.Get(##class(%CSP.Page).EscapeURL(url))
	  set statuscode = httprequest.HttpResponse.StatusCode
	  set gzip = httprequest.HttpResponse.Data
	  set length = 360000
	  set contents = gzip.Read(.length,.status)
    }
    
    Catch e {
	  set estatus = e.AsStatus
	  do $system.Status.DisplayError(estatus)
	  set status = estatus
    }

    set pStatus = status
    
    quit contents
}

ClassMethod Get(pGlobalNode As %String) As %String
{
    set status = $$$OK
    
    try {
	    
	  set serverinfo = ..ResolveServer(pGlobalNode)
	  
	  if serverinfo = "" set value = $get(@pGlobalNode) quit
	  
	  set address = $list(serverinfo,1)
	  set port = $list(serverinfo,2)
	  set namespace = $list(serverinfo,3)
	  
	  set glorefcheck = @pGlobalNode
	  
	  set gloref = $ZReference
	
	  set url = "http://"_address_"/csp/sys/%ZTools.SimpleDDPServer.cls"_"?command=set&namespace="_namespace_"&globalnode="_gloref
	  	  	
	  set value = ..httpget(url,port)	  
	
    }
    
    Catch e {

	  set gloref = $ZReference

	  set url = "http://"_address_"/csp/sys/%ZTools.SimpleDDPServer.cls"_"?command=set&namespace="_namespace_"&globalnode="_gloref
	  	  	
	  set value = ..httpget(url,port)	  

	  //set estatus = e.AsStatus
	  //do $system.Status.DisplayError(estatus)
    }
    
    quit value
}

ClassMethod Set(pCommand As %String) As %Status
{
    set status = $$$OK
    
    try {
	  
	  set pCommand = $translate(pCommand," ","")
	  set global = $piece(pCommand,"=",1)
	  set value = $piece(pCommand,"=",2)  
	  set serverinfo = ..ResolveServer(global)
	  
	  if serverinfo = "" set @global = value quit
	  
	  set address = $list(serverinfo,1)
	  set port = $list(serverinfo,2)
	  set namespace = $list(serverinfo,3)
	  
	  set glorefcheck = @global
	  
	  set gloref = $ZReference
	
	  set url = "http://"_address_"/csp/sys/%ZTools.SimpleDDPServer.cls"_"?command=set&namespace="_namespace_"&globalnode="_gloref_"&value="_value
	  	  	
	  set value = ..httpget(url,port)	  
	
    }
    
    Catch e {

	  set gloref = $ZReference

	  set url = "http://"_address_"/csp/sys/%ZTools.SimpleDDPServer.cls"_"?command=set&namespace="_namespace_"&globalnode="_gloref_"&value="_value
	  	  	
	  set value = ..httpget(url,port)	  

	  //set estatus = e.AsStatus
	  //do $system.Status.DisplayError(estatus)
    }
    
    quit value
}

ClassMethod ResolveServer(pGlobalNode As %String) As %String
{
    set status = $$$OK
    
    try {
	  set globalname = $piece(pGlobalNode,"(",1)
	  set serverinfo = $get(^%ZTools.SimpleDDP("GlobalMapping",globalname))
    }
    
    Catch e {
	  set estatus = e.AsStatus
	  do $system.Status.DisplayError(estatus)
    }
    
    quit serverinfo
}

ClassMethod GlobalMapping() As %Status
{
    set status = $$$OK
    
    set ^%ZTools.SimpleDDP("GlobalMapping","^ddp") = $listbuild("localhost",52773,"USER")
    
    quit status
}

ClassMethod Config(pFile As %String) As %Status [ Language = objectscript ]
{
  set status = $$$OK
  try {
    set inputstream = ##class(%Stream.FileCharacter).%New()
    set inputstream.TranslateTable = "UTF8"
    set status = inputstream.LinkToFile(pFile) 
  
  	while 'inputstream.AtEnd {
	  	  
	  set line = $translate(inputstream.ReadLine(),$char(13),"")
	  set json = [].%FromJSON(line)
	  set iterator = json.%GetIterator()
	  while iterator.%GetNext(.index, .globalinfo) {
	  	 set  ^%ZTools.SimpleDDP("GlobalMapping",globalinfo.name) = $listbuild(globalinfo.address,globainfo.port,globalinfo.namespace)	  	 
	  }
	    	  
	}
  }
  catch e {
	do e.OutputToDevice()
	zwrite   
  }
 
  QUIT status
}

ClassMethod SetupLocal(pDir As %String) As %Status
{
  set status = $$$OK
    
  set namespace = $namespace
  set $namespace = "%SYS"

  set status=##Class(Config.Databases).Get("IRISLIB",.Properties)
  set db = ##class(SYS.Database).%OpenId(Properties("Directory"))
  set db.ReadOnly = 0
  set status = db.%Save()
  set ssl = ##class(Security.SSLConfigs).%New()
  set ssl.Name = "MYSSL"
  set status = ssl.%Save()
  
  set os = $system.Version.GetOS()
  
  if os = "Windows" {
    set delim = "\"
  }
  else {
	set delim = "/"
  }
    	  
  do $System.OBJ.ImportDir(pDir_delim_"src",,"ck",,1)
  
  set file = pDir_delim_"config.json"
  do ..Config(file)

  set status=##Class(Config.Databases).Get("IRISLIB",.Properties)
  set db = ##class(SYS.Database).%OpenId(Properties("Directory"))
  set db.ReadOnly = 1
  set status = db.%Save()

  set $namespace = namespace

  quit status
}

}
