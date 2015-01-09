# vim-metarw-rest: REST API用vim-metarwプラグイン

REST APIをvim-metarwで読み書きするためのプラグインです。

システムの内部サービス(マイクロサービス)のREST APIを作る際に、
リソースをVimから編集したい場面がよくあるので。

`:e`等のコマンドの引数として、`rest:`の後にリソースのURLを指定して使います。

例: `:e rest:http://localhost:8080/countries/`

リクエスト・レスポンスボディはJSON形式のみ対応。

## 必要なもの

* vim-metarw
* webapi-vim
* curlもしくはwget

## 読み書き操作
### リソースの一覧取得(GET)
`:e`コマンドの引数の最後が/で終わっている場合は、
GETした結果をリソースのリストとみなして一覧表示します。

一覧に表示する文字列は、JSON内のidプロパティの値です
(idプロパティ以外のプロパティの値を表示したい場合は、
'g:metarw_rest_apiprops'オプションのlabelkeyに、
一覧表示に使用するプロパティ名を設定してください)。

例:

1. `:e rest:http://localhost:8080/countries/`
2. レスポンスJSON: `[{'id': 'FR', 'Name': 'France'},{'id': 'US', 'Name': 'United States'}]`
3. 一覧表示
```
FR
US
```

### リソースの取得(GET)
一覧表示上で対象のリソースを`<CR>`等で選択するとGETして開きます。

このとき、/の後に、選択されたリソースのidプロパティの値を付けたURLを開きます。
(idプロパティ以外のプロパティの値を使いたい場合は、
'g:metarw_rest_apiprops'オプションのidkeyに、
使用するプロパティ名を設定してください)。

例: FRを選択した場合、`rest:http://localhost:8080/countries/FR`

```
{
  'id': 'FR',
  'Name': 'France'
}
```

### リソースの更新(PUT)
リソースの取得で開いたバッファで`:w`すると、PUTしてリソースを更新します。

### リソースの作成(POST)
`:w`で最後が/で終わっているURLを指定すると、POSTしてリソースを作成します。

例: FRを編集して、`:w rest:http://localhost:8080/countries/`

```
{
  'id': 'JP',
  'Name': 'Japan'
}
```

なお、リソースの取得で開いたバッファを編集して
`:RestCreate`コマンドを実行すると、
該当リソースのURLの末尾を削って、/で終わるURLにPOSTします。

### リソースの削除(DELETE)
リソースを削除する場合は、対象のリソースを開いているバッファで、
`:RestDelete`コマンドを実行してください。

## オプション
### g:metarw_rest_apiprops
labelkeyやidkeyとして、デフォルトの'id'以外を使いたい場合向けの設定。
デフォルトは空。

設定例:
```
let g:metarw_rest_apiprops = [
  \ {'pat': '/countries', 'labelkey': 'Name', 'idkey': 'id', 'dofmt': 1},
\ ]
```

+ pat: rest:以降の文字列に対してマッチさせるパターン。
  APIごとに異なるlabelkeyやidkeyを設定したい場合向け。
  g:metarw_rest_apiprops配列内で、最初にマッチしたパターンのみを使用します。
+ labelkey: リスト表示に使うキー名。デフォルトは'id'
+ idkey: REST URL中でリソース指定に使うキー名。デフォルトは'id'
+ dofmt: レスポンスをg:metarw_rest_fmtcmdで整形する場合は1。
  手で毎回`:%!jq .`するかわりに自動で整形したい場合用。

### g:metarw_rest_fmtcmd
g:metarw_rest_apipropsでdofmtを1に設定した場合に使用する、JSON整形コマンド。
デフォルトは'jq .'

```
let g:metarw_rest_fmtcmd = 'jq .'
```

## HTTP認証
BASIC認証のみ対応。URL中で指定。`:e rest:http://user:password@localhost:8080/users/`

## 参考
* [Big Sky :: モテる Vim 使いに読み書き出来ないファイルなどなかったんだよ!](http://mattn.kaoriya.net/software/vim/20121204090702.htm)
* Vimデフォルトで利用可能な[netrw](http://vim-jp.org/vimdoc-ja/pi_netrw.html#netrw-externapp)。
  HTTP GETやPUTは可能。`:e http://localhost:8080/countries/FR`
