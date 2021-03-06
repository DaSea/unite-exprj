"=============================================================================
" FILE: exprj.vim
" AUTHOR: DaSea
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================
"TODO list{{{
"1, 加载文件 $HOME/.cache/exprj/exlist
"2, 保存文件; 保存文件时需要判断读取文件时, 与文件的最后修改时间是否相同,不同的话,需要进行重新load
"3, 添加条令;
"}}}

function! s:substitute_path_separator(path) "{{{
  return s:is_windows ? substitute(a:path, '\\', '/', 'g') : a:path
endfunction "}}}

" Variables{{{
let s:is_windows = has('win16') || has('win32') || has('win64') || has('win95')

if !exists('g:exprj_list_cache_directory')
    let g:exprj_list_cache_directory = expand('~/.cache')
endif

let s:cache_file = s:substitute_path_separator(g:exprj_list_cache_directory . '/exprj/exlist')

let s:cache_time = -1

" Use dictionary: {path: saved}
let s:prj_dict = {}

" If append new item ,set it to 1
let s:list_updated = 0

" title
let s:win_title = '-EXPRJ_LIST-'
"}}}

function! exprj#load() abort "{{{
    " Load exvim project list when start vim
    " echo s:cache_file
    if !filereadable(s:cache_file)
        return
    endif
    let s:cache_time = getftime(s:cache_file)

    let plist = readfile(s:cache_file)
    if empty(plist)
        echo "No exvim project list cache!"
        return
    endif

    for item in plist
        " TODO 需要验证item是否存在
        if filereadable(expand(item))
            let s:prj_dict[item] = 1
        endif
    endfor
endfunction "}}}

function! exprj#reload() abort "{{{
    " Reload exvim project list because list item changed
    if !filereadable(s:cache_file)
        return
    endif

    let plist = readfile(s:cache_file)
    if empty(plist)
        echo "Empty cache!"
        return
    endif

    " plist 中的项是否在s:prj_dict中
    for item in plist
        if !has_key(s:prj_dict, item)
            s:prj_dict[item] = 0
        endif
    endfor
endfunction "}}}

function! exprj#gather_candidates(args, context) abort "{{{
    " 返回list
    let l:candidates = []
    for item in keys(s:prj_dict)
        call extend(l:candidates, [{
            \ 'word': item,
            \ 'action__path': item,
            \ }])
    endfor

    return l:candidates
endfunction "}}}

function! exprj#append(path) abort "{{{
    " Append new exvim project to list
    " echo a:path
    if 0 == strlen(a:path)
        echo 'Unit-exprj: Invalid path!'
        return
    endif

    " Judge whether a:path is in s:prj_dict
    if !has_key(s:prj_dict, a:path)
        let s:prj_dict[a:path] = 0
        let s:list_updated = 1
    endif
endfunction "}}}

function! exprj#save() abort "{{{
    if !s:list_updated
        " echo 'No update item'
        return
    endif

    " Save exvim project list to file
    let last_cache_time = getftime(s:cache_file)
    if last_cache_time != s:cache_time
        " Only need to get new project list
        call exprj#reload()
    endif

    let prj_list = keys(s:prj_dict)
    call s:savelist(s:cache_file, prj_list)
endfunction "}}}

" Private function{{{
function! s:savelist(path, list) abort
    let path = fnamemodify(a:path, ':p')
    if !isdirectory(fnamemodify(path, ':h'))
        call mkdir(fnamemodify(path, ':h'), 'p')
    endif

    call writefile(a:list, path)
endfunction
"}}}
