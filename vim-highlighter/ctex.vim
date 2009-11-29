" Language:   Compilable TeX
" Maintainer: Spencer Tipping <spencer@spencertipping.com>
" Modified:   17 June 2008

if exists("b:current_syntax")
  finish
endif

runtime!	syntax/c.vim
unlet b:current_syntax

syn case match
syn region	literate_comment	start=/\\documentclass/ end=/\\begin{ccode}/
syn region	literate_comment	start=/\\end{ccode}/ end=/\\begin{ccode}\|\\end{document}/

hi link literate_comment Comment

let b:current_syntax = "ctex"
