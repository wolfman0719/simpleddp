Class %ZTools.SimpleDDPSetup Extends %Base
{

ClassMethod Config(pFile As %String) As %Status [ Language = objectscript ]
{
  
  set status = $$$OK
  try {
	  
    set namespace = $namespace

    kill ^%ZTools.SimpleDDP("GlobalMapping",namespace)  

    set inputstream = ##class(%Stream.FileCharacter).%New()
    set inputstream.TranslateTable = "UTF8"
    set status = inputstream.LinkToFile(pFile) 
  
    while 'inputstream.AtEnd {
	  	  
      set line = $translate(inputstream.ReadLine(),$char(13),"")
      set json = [].%FromJSON(line)
      set iterator = json.%GetIterator()
      while iterator.%GetNext(.index, .globalinfo) {
        set ^%ZTools.SimpleDDP("GlobalMapping",namespace,globalinfo.name) = $listbuild(globalinfo.address,globalinfo.port,globalinfo.namespace)	  	 
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

  set file = pDir_delim_"simpleddp.mac"
  do $system.OBJ.Load(file,"ck")

  set $namespace = "%SYS"

  set status=##Class(Config.Databases).Get("IRISLIB",.Properties)
  set db = ##class(SYS.Database).%OpenId(Properties("Directory"))
  set db.ReadOnly = 1
  set status = db.%Save()

  set $namespace = namespace

  quit status
}

}

