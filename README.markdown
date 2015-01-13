# vim-metarw-rest: vim-metarw scheme script for REST API

vim-metarw-rest is a [vim-metarw](https://github.com/kana/vim-metarw) scheme script
to read/write resources using REST API.

## Requirements

* vim-metarw
* webapi-vim
* curl

## Usage

### List resources (GET)

vim-metarw-rest treats URL which has trailing slash as resources list.

    :e rest:http://localhost:8080/countries/

### GET resource

    :e rest:http://localhost:8080/countries/FR

### PUT current buffer to update resource

    :w

### POST current buffer as new resource

    :w rest:http://localhost:8080/countries/

or

    :RestCreate

### DELETE current open resource

    :RestDelete

## Customization

### g:metarw_rest_apiprops

Example:

    let g:metarw_rest_apiprops = [
      \ {'pat': '/countries', 'labelkey': 'Name', 'idkey': 'id', 'dofmt': 1},
    \ ]

+ pat: match pattern for string after `rest:`.
+ labelkey: show this property in resoures list. Default: 'id'
+ idkey: add this property after trailing slash to make resource URL
  when a resource is selected on resources list. Default: 'id'
+ dofmt: do format JSON using g:metarw_rest_fmtprg. Default: 0

### g:metarw_rest_fmtprg

External program to format JSON. Default: 'jq .'

    let g:metarw_rest_fmtprg = 'jq .'

