Class %ZTools.SimpleDDP Extends %Base
{

ClassMethod httpcommand(pCommand As %String, pUrl As %String, pPort As %Integer = 80, pStatus As %Status) As %String
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
	
	  set url = "http://"_address_"/csp/sys/%ZTools.SimpleDDPServer.cls"_"?command=get&namespace="_namespace_"&globalnode="_gloref
	  	  	
	  set value = ..httpcommand("get",url,port,.status)	  
	  if 'status do $system.Status.DisplayError(status)
	
    }
    
    Catch e {

	  set gloref = $ZReference

	  set url = "http://"_address_"/csp/sys/%ZTools.SimpleDDPServer.cls"_"?command=get&namespace="_namespace_"&globalnode="_gloref
	  	  	
	  set value = ..httpcommand("get",url,port, .status)
	  if 'status do $system.Status.DisplayError(status)
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
	  	  	
	  set value = ..httpcommand("post",url,port,.status)	  
	  if 'status do $system.Status.DisplayError(status)
	
    }
    
    Catch e {

	  set gloref = $ZReference

	  set url = "http://"_address_"/csp/sys/%ZTools.SimpleDDPServer.cls"_"?command=set&namespace="_namespace_"&globalnode="_gloref_"&value="_value
	  	  	
	  set value = ..httpcommand("post",url,port,.status)	  
	  if 'status do $system.Status.DisplayError(status)

    }
    
    quit value
}

ClassMethod ResolveServer(pGlobalNode As %String) As %String
{
    set status = $$$OK
    
    try {
	  set globalname = $piece(pGlobalNode,"(",1)
	  if $zv [ "IRIS" {
	    set namespace = $namespace
	  }
	  else {
            set namespace = $znspace
	  }
	  set serverinfo = $get(^%ZTools.SimpleDDP("GlobalMapping",namespace,globalname))
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
    
    if $zv [ "IRIS" {
      set namespace = $namespace
    }
    else {
      set namespace = $znspace
    }
    set ^%ZTools.SimpleDDP("GlobalMapping",namespace,"^ddp") = $listbuild("localhost",52773,"USER")
    
    quit status
}

ClassMethod Config(pFile As %String) As %Status [ Language = objectscript ]
{
  set status = $$$OK
  try {
    if $zv [ "IRIS" {
      set namespace = $namespace
    }
    else {
      set namespace = $znspace
    }
    set inputstream = ##class(%Stream.FileCharacter).%New()
    set inputstream.TranslateTable = "UTF8"
    set status = inputstream.LinkToFile(pFile) 
  
  	while 'inputstream.AtEnd {
	  	  
	  set line = $translate(inputstream.ReadLine(),$char(13),"")
	  set json = [].%FromJSON(line)
	  set iterator = json.%GetIterator()
	  while iterator.%GetNext(.index, .globalinfo) {
	    set  ^%ZTools.SimpleDDP("GlobalMapping",namespace,globalinfo.name) = $listbuild(globalinfo.address,globainfo.port,globalinfo.namespace)	  	 
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

  set Directory=pDir_delim_"local"
  set status=##class(%File).CreateDirectoryChain(Directory,.return)
  If ('status) {
    Write "Error Creating Directory Chain: "_return
  }
  Else {
    set db=##Class(SYS.Database).%New()
    set db.Directory=Directory
    set status=db.%Save()
    set DBName="local"
    set status=##class(Config.Configuration).AddDatabase(DBName,Directory)
    set NSName=DBName
    set status=##class(Config.Configuration).AddNamespace(NSName,DBName)
  }
    	  
  set Directory=pDir_delim_"remote"
  set status=##class(%File).CreateDirectoryChain(Directory,.return)
  If ('status) {
    Write "Error Creating Directory Chain: "_return
  }
  Else {
    set db=##Class(SYS.Database).%New()
    set db.Directory=Directory
    set status=db.%Save()
    set DBName="remote"
    set status=##class(Config.Configuration).AddDatabase(DBName,Directory)
    set NSName=DBName
    set status=##class(Config.Configuration).AddNamespace(NSName,DBName)
  }

  do $System.OBJ.ImportDir(pDir_delim_"src",,"ck",,1)
  
  set $namespace = "local"
  set file = pDir_delim_"config.json"
  do ..Config(file)
  
  set $namespace = "%SYS"

  set status=##Class(Config.Databases).Get("IRISLIB",.Properties)
  set db = ##class(SYS.Database).%OpenId(Properties("Directory"))
  set db.ReadOnly = 1
  set status = db.%Save()

  set $namespace = namespace

  quit status
}

}
