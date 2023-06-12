# Simple DDP

httpを使用してECPの簡易エミュレーションを行う


## ビルドプロセス

### Build & Run
* ```docker-compose up -d --build```

## セットアップ

## 起動方法

セットアップ後に、テストプログラムを実行

```
>zn "local"
>do ^simpleddp
```

ターゲットネームスペースにグローバルが設定されているか確認

```
>zn "remote"
>zwrite ^remote
```


### 管理ポータル

[localhost:52774/csp/sys/%25CSP.Portal.Home.zen?IRISUsername=_system&IRISPassword=SYS](http://localhost:52774/csp/sys/%25CSP.Portal.Home.zen?IRISUsername=_system&IRISPassword=SYS)

##  ローカルセットアップ

¥src¥%ZTools¥simpleddp.clsを%SYSネームスペースにロードする

```
>zn "%SYS"
>set file = "C:\git\simpleddp\src\%ZTools\SimpleDDPSetup.cls"
>do $System.OBJ.Load(file,"ck",,1)
>set dir = "c:\git\simpleddp"
>write ##class(%ZTools.SimpleDDPSetup).SetupLocal(dir)
```
##  仕様

### 関数

####  $zzddpget(arg)

##### 引数   

arg - グローバル参照
  
##### 例

   - $zddpget("^test(1)")   
   - $zddpget("^test(""aaa"")")
   - $zddpget("^test(aaa)")
   
####  $zzddporder(arg)

##### 引数   

arg - グローバル参照
  
##### 例

   - $zddporder("^test("""")")   
   - $zddporder("^test(""aaa"")")
   - $zddporder("^test(s1,s2)")

### コマンド

####  zddpset arg

#####  引数

arg - setコマンドの引数形式

######  例

- $zddpset "^test(1) = 123"
- $zddpset "^test(1) = ""test"""
- $zddpset "^test(""test"") = ""test"""
- $zddpset "^test(test) = test"
- $zddpset "^test(test) = ^test"

###  制限事項

本来のコマンド、関数とは異なり、引数は、"(ダブルクオート)で囲む必要がある

マクロを定義することで（simpleddp.macにサンプルあり）この制限はある程度解消できるが、リテラルを指定する際に、ダブルクオートが２個必要になる
