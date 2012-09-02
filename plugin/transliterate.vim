" ============================================================================
" vim: set fdm=marker fdl=0:
"
" File: transliterate.vim
" Author: Fanael Linithien <fanael4@gmail.com>
" Version: 0.2
" Description: vim plugin that allows transliteration of text
" License: Copyright (c) 2012, Fanael Linithien
" All rights reserved.
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
" 1. Redistributions of source code must retain the above copyright notice,
" this list of conditions and the following disclaimer.
" 2. Redistributions in binary form must reproduce the above copyright notice,
" this list of conditions and the following disclaimer in the documentation
" and/or other materials provided with the distribution.
" 3. Neither the name of the copyright holder(s) nor the names of any
" contributors may be used to endorse or promote products derived from this
" software without specific prior written permission.
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
" THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
" PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
" CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
" EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
" PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
" OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
" WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
" OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
" ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

" Initialization {{{

scriptencoding utf-8

if &compatible
  echoerr 'Transliterate won''t work in compatible mode.'
  finish
endif

if !exists('g:transliterateMode')
  let g:transliterateMode='identity'
endif

" }}}

" Built-in replacement tables {{{

let s:xsampaMode = [
\ ['b_<', 'ɓ'], ['d`', 'ɖ'], ['d_<', 'ɗ'], ['g_<', 'ɠ'], ['h\', 'ɦ'],
\ ['j\', 'ʝ'], ['l`', 'ɭ'], ['l\', 'ɺ'], ['n`', 'ɳ'], ['p\', 'ɸ'],
\ ['r`', 'ɽ'], ['r\`', 'ɻ'], ['r\', 'ɹ'], ['s`', 'ʂ'], ['s\', 'ɕ'],
\ ['t`', 'ʈ'], ['v\', 'ʋ'], ['x\', 'ɧ'], ['z`', 'ʐ'], ['z\', 'ʑ'],
\ ['A', 'ɑ'], ['B\', 'ʙ'], ['B', 'β'], ['C', 'ç'], ['D', 'ð'],
\ ['E', 'ɛ'], ['F', 'ɱ'], ['G\_<', 'ʛ'], ['G\', 'ɢ'], ['G', 'ɣ'],
\ ['H\', 'ʜ'], ['H', 'ɥ'], ['I\', 'ᵻ'], ['I', 'ɪ'], ['J\_<', 'ʄ'],
\ ['J\', 'ɟ'], ['J', 'ɲ'], ['K\', 'ɮ'], ['K', 'ɬ'], ['L\', 'ʟ'],
\ ['L', 'ʎ'], ['M\', 'ɰ'], ['M', 'ɯ'], ['N\', 'ɴ'], ['N', 'ŋ'],
\ ['O\', 'ʘ'], ['O', 'ɔ'], ['P', 'ʋ'], ['Q', 'ɒ'], ['R\', 'ʀ'],
\ ['R', 'ʁ'], ['S', 'ʃ'], ['T', 'θ'], ['U\', 'ᵿ'], ['U', 'ʊ'],
\ ['V', 'ʌ'], ['W', 'ʍ'], ['X\', 'ħ'], ['X', 'χ'], ['Y', 'ʏ'],
\ ['Z', 'ʒ'], ['.', '.'], ['"', 'ˈ'], ['%', 'ˌ'], ['''', 'ʲ'],
\ [':\', 'ˑ'], [':', 'ː'], ['@\', 'ɘ'], ['@', 'ə'], ['{', 'æ'],
\ ['}', 'ʉ'], ['1', 'ɨ'], ['2', 'ø'], ['3\', 'ɞ'], ['3', 'ɜ'],
\ ['4', 'ɾ'], ['5', 'ɫ'], ['6', 'ɐ'], ['7', 'ɤ'], ['8', 'ɵ'],
\ ['9', 'œ'], ['&', 'ɶ'], ['?', 'ʔ'], ['?\', 'ʕ'], ['<\', 'ʢ'],
\ ['>\', 'ʡ'], ['^', 'ꜛ'], ['!\', 'ǃ'], ['!', 'ꜜ'], ['|\|\', 'ǁ'],
\ ['||', '‖'], ['|\', 'ǀ'], ['|', '|'], ['=\', 'ǂ'], ['-\', '͜'],
\ ['_"', '̈'], ['_+', '̟'], ['_-', '̠'], ['_/', '̌'], ['_0', '̥'],
\ ['_=', '̩'], ['=', '̩'], ['_>', 'ʼ'], ['_?\', 'ˤ'], ['_\', '̂'],
\ ['_^', '̯'], ['_}', '̚'], ['`', '˞'], ['_~', '̃'], ['~', '̃'],
\ ['_A', '̘'], ['_a', '̺'], ['_B_L', '᷅'], ['_B', '̏'], ['_c', '̜'],
\ ['_d', '̪'], ['_e', '̴'], ['<F>', '↘'], ['_F', '̂'], ['_G', 'ˠ'],
\ ['_H_T', '᷄'], ['_H', '́'], ['_h', 'ʰ'], ['_j', 'ʲ'], ['_k', '̰'],
\ ['_L', '̀'], ['_l', 'ˡ'], ['_M', '̄'], ['_m', '̻'], ['_N', '̼'],
\ ['_n', 'ⁿ'], ['_O', '̹'], ['_O', '̹'], ['_q', '̙'], ['<R>', '↗'],
\ ['_R_F', '᷈'], ['_R', '̌'], ['_T', '̋'], ['_t', '̤'], ['_v', '̬'],
\ ['_w', 'ʷ'], ['_X', '̆'], ['_x', '̽'], ['-', '']
\]

let s:modes = {
\ 'identity': [],
\ 'xsampa': s:xsampaMode,
\ 'x-sampa': s:xsampaMode,
\}

" }}}

" Internal functions {{{

function! s:Comparator(a, b)
  let strA = a:a[0]
  let strB = a:b[0]
  let lenA = len(strA)
  let lenB = len(strB)
  return (lenA !=# lenB) ? (lenA <# lenB) : (strA <# strB)
endfunction

function! s:TransliteratePrepareModeTable(modeTable)
  let modeTable = deepcopy(a:modeTable)
  call sort(modeTable, 's:Comparator')
  return modeTable
endfunction

function! s:TransliterateReplace(text, modeTable)
  let result = ''
  let i = 0
  let textLength = len(a:text)

  while i < textLength
    let replaced = 0
    for [str, replacement] in a:modeTable
      let strLen = len(str)
      if a:text[i : i + strLen - 1] ==# str
        let result .= replacement
        let i += strLen
        let replaced = 1
        break
      endif
    endfor
    if !replaced
      let result .= a:text[i]
      let i += 1
    endif
  endwhile

  return result
endfunction

function! s:TransliterateWork(text)
  try
    let modeTable = s:modes[g:transliterateMode]
  catch
    echoerr 'Invalid Transliterate mode (' . g:transliterateMode . '), not doing anything.'
  endtry

  return s:TransliterateReplace(a:text, modeTable)
endfunction

function! <SID>TransliterateOperator(type)
  let oldUnnamed = @@
  try
    if a:type ==# 'v' || a:type ==# 'V' || a:type ==# "\<C-v>"
      normal! `<v`>y
    elseif a:type ==# 'char' || a:type ==# 'line'
      normal! `[v`]y
    else
      return
    endif

    let @@ = s:TransliterateWork(@@)
    execute "normal! gv\"_c\<C-r>\"\<Esc>"
  finally
    let @@ = oldUnnamed
  endtry
endfunction

" }}}

" Public stuff {{{

function! TransliterateAddMode(name, modeTable)
  if has_key(s:modes, a:name)
    echoerr 'Transliterate mode ''' . a:name . ''' already exists.'
  else
    let s:modes[a:name] = s:TransliteratePrepareModeTable(a:modeTable)
  endif
endfunction

function! TransliterateForceMode(name, modeTable)
  let s:modes[a:name] = s:TransliteratePrepareModeTable(a:modeTable)
endfunction

function! TransliterateHasMode(name)
  return has_key(s:modes, a:name)
endfunction

function! TransliterateRemoveMode(name)
  if has_key(s:modes, a:name)
    call remove(s:modes, a:name)
  endif
endfunction

nnoremap <unique> <Plug>TransliterateApply :set operatorfunc=<SID>TransliterateOperator<CR>g@
vnoremap <unique> <Plug>TransliterateApply :<C-u>call <SID>TransliterateOperator(visualmode())<CR>

" }}}
