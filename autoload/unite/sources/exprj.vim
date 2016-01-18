" Vim plugin to run Cppcheck on the current buffer.
" Last Change:  31 Dec 2015
" Maintainer:   DaSea
" License:      Public Domain

" 1, 记录缓存文件;
" 2, 读取;

" save cpoptions and reset to avoid problems in the script
let s:save_cpo = &cpo
setlocal cpo&vim

let s:unite_source = {
      \ 'name': 'exprj',
      \ 'description': 'List your exvim project!',
      \ 'syntax': 'uniteSource__File',
      \ 'hooks': {},
      \ 'default_kind': 'file',
      \ }

function! s:get_SID()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

function! s:unite_source.gather_candidates(args, context)
    " let l:candidates =g[]
    " return l:candidates
    return exprj#gather_candidates(a:args, a:context)
endfunction

function! unite#sources#exprj#define()
  return s:unite_source
endfunction

" restore the original cpoptions
let &cpo = s:save_cpo
unlet s:save_cpo

