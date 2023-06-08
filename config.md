#  サーバー情報

##  目的

このインタフェースを使ってアクセスするグローバルを透過的に参照するためにそれが実際にどこに存在しているかを示す情報を提供する

##  グローバル形式

###  グローバルノード

```^%ZTools.SimpleDDP("GlobalMapping",globalname)```

globalname = 任意のグローバル名

###   データ

```$list(tcpaddress,port,namespace)```

tcpaddress = http TCPアドレス
port = httpポート番号
namespace = グローバルが存在するネームスペース名


##  入力形式(JSON)

###   サンプルデータ

以下のようなJSON形式のファイルを準備する
複数行可能

```[{"name":"^test2","address":"161.0.0.8","port":"80","namespace":"accounting"},{"name":"^test2","address":"161.0.0.8","port":"80","namespace":"accounting"}]```

##  登録方法

```>Set filename = "c:\temp\simpleddp.json"```

```>do ##class(%ZTools.SimpleDDP).Config(filename)```

