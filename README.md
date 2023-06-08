# Simple DDP

httpを使用してECPの簡易エミュレーションを行う


## ビルドプロセス

### Build & Run
* ```docker-compose up -d --build```

## セットアップ

## 起動方法

セットアップ後に、テストプログラムを実行

```>zn "source"```
```>do ^simpleddp

ターゲットネームスペースにグローバルが設定されているか確認
```>zn "target"```


### 管理ポータル

[localhost:52774/csp/sys/%25CSP.Portal.Home.zen?IRISUsername=_system&IRISPassword=SYS](http://localhost:52774/csp/sys/%25CSP.Portal.Home.zen?IRISUsername=_system&IRISPassword=SYS)

##  ローカルセットアップ

src/%ZTools\simpleddp.clsを%SYSネームスペースにロードする

```>set file = "C:\git\simpleddp\src\%ZTools\SimpleDDP.cls"```
```>do $System.OBJ.Load(file,"ck",,1)```
```>set dir = "c:\git\simpleddp"```
```>write ##class(%ZTools.SimpleDDP).SetupLocal(dir)```
