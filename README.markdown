# vim-metarw-rest: REST API用vim-metarwプラグイン

REST APIをvim-metarwでアクセスするためのプラグインです。

仕事でREST APIを作った際に、
リソースを簡単にVimから編集したい場面がよくあるので。

`:Edit`等のコマンドの引数として、`rest:`の後にリソースのURLを指定して使います。

例: `:Edit rest:http://localhost:8080/countries/`

リクエスト・レスポンスボディはJSON形式のみ対応。

## 必要なもの

* vim-metarw
* webapi-vim
* curlもしくはwget

## リソースの一覧取得
`:Edit`コマンドの引数の最後が/で終わっている場合は、
GETした結果をリソースのリストとみなして一覧表示します。

このとき、'labelkey'で指定されたプロパティの値を一覧に表示します。
('labelkey'のデフォルト値は'id')

例:
1. `:Edit rest:http://localhost:8080/countries/`
2. レスポンスJSON: `[{'Code': 'FR', 'Name': 'France'},{'Code': 'US', 'Name': 'United States'}]`
3. 一覧表示
        FR
        US

## リソースの取得(GET)
一覧表示上で対象のリソースを`<CR>`等で選択するとGETして開きます。
このとき、/の後に、'idkey'で指定されたプロパティの値を付けたURLを開きます。
('idkey'のデフォルト値は'id')

例: FRを選択した場合、`rest:http://localhost:8080/countries/FR`

```
{
  'Code': 'FR',
  'Name': 'France'
}
```

## リソースの更新(PUT)
リソースの取得で開いたバッファで`:Write`すると、PUTしてリソースを更新します。

## リソースの作成(POST)
`:Write`で最後が/で終わっているURLを指定すると、POSTしてリソースを作成します。

例: FRを編集して、`:Write rest:http://localhost:8080/countries/`

```
{
  'Code': 'JP',
  'Name': 'Japan'
}
```

なお、リソースの取得で開いたバッファを編集して
`:RestCreate`コマンドを実行すると、
該当リソースのURLの末尾を削って、/で終わるURLにPOSTします。

## リソースの削除(DELETE)
リソースを削除する場合は、対象のリソースを開いているバッファで、
`:RestDelete`コマンドを実行してください。

## 設定

```
let g:metarw_rest_apiprops = [
  \ {'pat': '/countries', 'labelkey': 'Code', 'idkey': 'Code', 'dofmt': 1},
\ ]
call metarw#define_wrapper_commands(1)
```

+ pat: rest:以降の文字列に対してマッチさせるパターン
+ labelkey: リスト表示に使うキー名
+ idkey: REST URL中でリソース指定に使うキー名
+ dofmt: レスポンスをg:metarw_rest_fmtcmdで整形する場合は1

```
let g:metarw_rest_fmtcmd = 'jq .'
```

## HTTP認証
BASIC認証のみ対応。URL中で指定。`:Edit rest:http://user:password@localhost:8080/users/`

## 参考
* [Big Sky :: モテる Vim 使いに読み書き出来ないファイルなどなかったんだよ!](http://mattn.kaoriya.net/software/vim/20121204090702.htm)
