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
