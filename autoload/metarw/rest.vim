" metarw scheme: rest

if !exists('g:metarw_rest_fmtcmd')
  let g:metarw_rest_fmtcmd = 'jq .'
endif

" let g:metarw_rest_apiprops = [
"   \ {'pat':'/countries','labelkey':'Code','idkey':'Code','dofmt':1},
" \ ]
if !exists('g:metarw_rest_apiprops')
  let g:metarw_rest_apiprops = []
endif

function! metarw#rest#complete(arglead, cmdline, cursorpos)
  let candidates = []
  if a:arglead !~ '[\/]$'
    let path = substitute(a:arglead, '/[^/]\+$', '', '')
  else
    let path = a:arglead[:-2]
  endif
  let _ = s:parse_incomplete_fakepath(path)
  let res = s:read_list(_)
  if res[0] == 'browse'
    return [filter(map(res[1], 'v:val["fakepath"]'), 'stridx(v:val, a:arglead)==0'), a:cmdline, '']
  endif
  return [[], '', '']
endfunction

function! metarw#rest#read(fakepath)
  let _ = s:parse_incomplete_fakepath(a:fakepath)
  if _.path == '' || _.path =~ '[\/]$'
    let result = s:read_list(_)
  else
    let result = s:read_content(_)
  endif
  return result
endfunction

function! metarw#rest#write(fakepath, line1, line2, append_p)
  let _ = s:parse_incomplete_fakepath(a:fakepath)
  let content = iconv(join(getline(a:line1, a:line2), "\n"), &encoding, 'utf-8')
  if _.path == '' || _.path =~ '[\/]$'
    let result = s:write_new(_, content)
  else
    let result = s:write_update(_, content)
  endif
  return result
endfunction

function! s:parse_incomplete_fakepath(incomplete_fakepath)
  let _ = {}
  let _.given_fakepath = a:incomplete_fakepath
  let _.scheme = 'rest'
  let _.path = substitute(a:incomplete_fakepath, '^rest:', '', '')
  let _.apiprop = {}
  for apiprop in g:metarw_rest_apiprops
    if match(_.path, apiprop.pat) >= 0
      let _.apiprop = apiprop
      break
    endif
  endfor
  return _
endfunction

function! s:resource_list(_)
  let result = webapi#http#get(a:_.path)
  if result.status != 200
    throw printf('%d %s: %s', result.status, result.message, a:_.path)
  endif
  return webapi#json#decode(result.content)
endfunction

function! s:read_content(_)
  let result = webapi#http#get(a:_.path)
  if result.status != 200
    return ['error', printf('%d %s: %s', result.status, result.message, a:_.path)]
  endif
  call setline(2, split(iconv(result.content, 'utf-8', &encoding), "\n"))
  if get(a:_.apiprop, 'dofmt', 0)
    " setl fenc=utf-8 " XXX: jq stops at EUC-JP chars
    execute '2,$!' . g:metarw_rest_fmtcmd
  endif
  return ['done', '']
endfunction

function! s:read_list(_)
  let result = []
  try
    let rsc_list = s:resource_list(a:_)
  catch
    return ['error', v:exception]
  endtry
  let labelkey = get(a:_.apiprop, 'labelkey', 'id')
  let idkey = get(a:_.apiprop, 'idkey', 'id')
  for rsc in rsc_list
    call add(result, {
       \ 'label': rsc[labelkey],
       \ 'fakepath': printf('%s:%s%s', a:_.scheme, a:_.path, rsc[idkey])
    \ })
  endfor
  return ['browse', result]
endfunction

function! s:write_new(_, content)
  let result = webapi#http#post(a:_.path, a:content, {
    \ 'Content-Type': 'application/json;charset=utf-8'
  \ })
  if result.status != 201
    return ['error', printf('%d %s: %s', result.status, result.message, a:_.path)]
  endif
  return ['done', '']
endfunction

function! s:write_update(_, content)
  let result = webapi#http#post(a:_.path, a:content, {
    \ 'Content-Type': 'application/json;charset=utf-8'
  \ }, 'PUT')
  if result.status != 200
    return ['error', printf('%d %s: %s', result.status, result.message, a:_.path)]
  endif
  return ['done', '']
endfunction
