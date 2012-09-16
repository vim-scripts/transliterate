" ============================================================================
" vim: set fdm=marker fdl=0:
"
" File: transliterate.vim
" Author: Fanael Linithien <fanael4@gmail.com>
" Version: 0.2.3
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
\ ['\V|\\|\\', 'ǁ'], ['\VJ\\_<', 'ʄ'], ['\VG\\_<', 'ʛ'], ['\Vr\\`', 'ɻ'],
\ ['\V_R_F', '᷈'], ['\V_H_T', '᷄'], ['\V_B_L', '᷅'], ['\V_?\\', 'ˤ'],
\ ['\V|\\', 'ǀ'], ['\Vz\\', 'ʑ'], ['\Vx\\', 'ɧ'], ['\Vv\\', 'ʋ'],
\ ['\Vs\\', 'ɕ'], ['\Vr\\', 'ɹ'], ['\Vp\\', 'ɸ'], ['\Vl\\', 'ɺ'],
\ ['\Vj\\', 'ʝ'], ['\Vh\\', 'ɦ'], ['\Vg_<', 'ɠ'], ['\Vd_<', 'ɗ'],
\ ['\Vb_<', 'ɓ'], ['\V_\\', '̂'], ['\VX\\', 'ħ'], ['\VU\\', 'ᵿ'],
\ ['\VR\\', 'ʀ'], ['\VO\\', 'ʘ'], ['\VN\\', 'ɴ'], ['\VM\\', 'ɰ'],
\ ['\VL\\', 'ʟ'], ['\VK\\', 'ɮ'], ['\VJ\\', 'ɟ'], ['\VI\\', 'ᵻ'],
\ ['\VH\\', 'ʜ'], ['\VG\\', 'ɢ'], ['\VB\\', 'ʙ'], ['\V@\\', 'ɘ'],
\ ['\V?\\', 'ʕ'], ['\V>\\', 'ʡ'], ['\V=\\', 'ǂ'], ['\V<\\', 'ʢ'],
\ ['\V<R>', '↗'], ['\V<F>', '↘'], ['\V:\\', 'ˑ'], ['\V3\\', 'ɞ'],
\ ['\V-\\', '͜'], ['\V!\\', 'ǃ'], ['\V||', '‖'], ['\Vz`', 'ʐ'],
\ ['\Vt`', 'ʈ'], ['\Vs`', 'ʂ'], ['\Vr`', 'ɽ'], ['\Vn`', 'ɳ'],
\ ['\Vl`', 'ɭ'], ['\Vd`', 'ɖ'], ['\V_~', '̃'], ['\V_}', '̚'],
\ ['\V_x', '̽'], ['\V_w', 'ʷ'], ['\V_v', '̬'], ['\V_t', '̤'],
\ ['\V_q', '̙'], ['\V_n', 'ⁿ'], ['\V_m', '̻'], ['\V_l', 'ˡ'],
\ ['\V_k', '̰'], ['\V_j', 'ʲ'], ['\V_h', 'ʰ'], ['\V_e', '̴'],
\ ['\V_d', '̪'], ['\V_c', '̜'], ['\V_a', '̺'], ['\V_^', '̯'],
\ ['\V_X', '̆'], ['\V_T', '̋'], ['\V_R', '̌'], ['\V_O', '̹'],
\ ['\V_O', '̹'], ['\V_N', '̼'], ['\V_M', '̄'], ['\V_L', '̀'],
\ ['\V_H', '́'], ['\V_G', 'ˠ'], ['\V_F', '̂'], ['\V_B', '̏'],
\ ['\V_A', '̘'], ['\V_>', 'ʼ'], ['\V_=', '̩'], ['\V_0', '̥'],
\ ['\V_/', '̌'], ['\V_-', '̠'], ['\V_+', '̟'], ['\V_"', '̈'],
\ ['\V~', '̃'], ['\V}', 'ʉ'], ['\V|', '|'], ['\V{', 'æ'],
\ ['\V`', '˞'], ['\V^', 'ꜛ'], ['\VZ', 'ʒ'], ['\VY', 'ʏ'],
\ ['\VX', 'χ'], ['\VW', 'ʍ'], ['\VV', 'ʌ'], ['\VU', 'ʊ'],
\ ['\VT', 'θ'], ['\VS', 'ʃ'], ['\VR', 'ʁ'], ['\VQ', 'ɒ'],
\ ['\VP', 'ʋ'], ['\VO', 'ɔ'], ['\VN', 'ŋ'], ['\VM', 'ɯ'],
\ ['\VL', 'ʎ'], ['\VK', 'ɬ'], ['\VJ', 'ɲ'], ['\VI', 'ɪ'],
\ ['\VH', 'ɥ'], ['\VG', 'ɣ'], ['\VF', 'ɱ'], ['\VE', 'ɛ'],
\ ['\VD', 'ð'], ['\VC', 'ç'], ['\VB', 'β'], ['\VA', 'ɑ'],
\ ['\V@', 'ə'], ['\V?', 'ʔ'], ['\V=', '̩'], ['\V:', 'ː'],
\ ['\V9', 'œ'], ['\V8', 'ɵ'], ['\V7', 'ɤ'], ['\V6', 'ɐ'],
\ ['\V5', 'ɫ'], ['\V4', 'ɾ'], ['\V3', 'ɜ'], ['\V2', 'ø'],
\ ['\V1', 'ɨ'], ['\V.', '.'], ['\V-', ''], ['\V''', 'ʲ'],
\ ['\V&', 'ɶ'], ['\V%', 'ˌ'], ['\V"', 'ˈ'], ['\V!', 'ꜜ']
\]

let s:ruscyrMode = [
\ ['\Vshch', 'щ'], ['\VShch', 'Щ'], ['\Vzh', 'ж'], ['\Vts', 'ц'],
\ ['\Vsh', 'ш'], ['\Vkh', 'х'], ['\Vyu', 'ю'], ['\Vyo', 'ё'],
\ ['\Vye', 'э'], ['\Vya', 'я'], ['\Vch', 'ч'], ['\VZh', 'Ж'],
\ ['\VTs', 'Ц'], ['\VSh', 'Ш'], ['\VKh', 'Х'], ['\VYu', 'Ю'],
\ ['\VYo', 'Ё'], ['\VYe', 'Э'], ['\VYa', 'Я'], ['\VCh', 'Ч'],
\ ['\Vz', 'з'], ['\Vy', 'ы'], ['\Vx', 'х'], ['\Vv', 'в'],
\ ['\Vu', 'у'], ['\Vt', 'т'], ['\Vs', 'с'], ['\Vr', 'р'],
\ ['\Vp', 'п'], ['\Vo', 'о'], ['\Vn', 'н'], ['\Vm', 'м'],
\ ['\Vl', 'л'], ['\Vk', 'к'], ['\Vj', 'й'], ['\Vi', 'и'],
\ ['\Vh', 'х'], ['\Vg', 'г'], ['\Vf', 'ф'], ['\Ve', 'е'],
\ ['\Vd', 'д'], ['\Vb', 'б'], ['\Va', 'а'], ['\VZ', 'З'],
\ ['\VY', 'Ы'], ['\VX', 'Х'], ['\VV', 'В'], ['\VU', 'У'],
\ ['\VT', 'Т'], ['\VS', 'С'], ['\VR', 'Р'], ['\VP', 'П'],
\ ['\VO', 'О'], ['\VN', 'Н'], ['\VM', 'М'], ['\VL', 'Л'],
\ ['\VK', 'К'], ['\VJ', 'Й'], ['\VI', 'И'], ['\VH', 'Х'],
\ ['\VG', 'Г'], ['\VF', 'Ф'], ['\VE', 'Е'], ['\VD', 'Д'],
\ ['\VB', 'Б'], ['\VA', 'А'], ['\V''', 'ь'], ['\V"', 'ъ']
\]

let s:modes = {
\ 'identity': [],
\ 'xsampa': s:xsampaMode,
\ 'x-sampa': s:xsampaMode,
\ 'ruscyr': s:ruscyrMode,
\ 'russian': s:ruscyrMode
\}

" }}}

" Internal functions {{{

function! s:Comparator(a, b)
  let strA = a:a[0]
  let strB = a:b[0]
  let lenA = len(strA)
  let lenB = len(strB)
  if lenA !=# lenB
    return lenA <# lenB ? 1 : -1
  elseif strA !=# strB
    return strA <# strB ? 1 : -1
  else
    return 0
  endif
endfunction

function! s:TransliteratePrepareModeTable(modeTable)
  let modeTable = deepcopy(a:modeTable)
  call sort(modeTable, 's:Comparator')
  for elt in modeTable
    let elt[0] = '\V' . substitute(elt[0], '\V\\', '\\\\', 'g')
  endfor
  return modeTable
endfunction

function! s:TransliterateReplace(text, modeTable)
  let oldIgnorecase = &ignorecase
  set noignorecase
  try
    let result = a:text
    for [str, replacement] in a:modeTable
      let result = substitute(result, str, replacement, 'g')
    endfor
    return result
  finally
    let &ignorecase = oldIgnorecase
  endtry
endfunction

function! s:TransliterateWork(text)
  try
    let modeTable = s:modes[g:transliterateMode]
  catch
    echoerr 'Invalid Transliterate mode: ' . g:transliterateMode
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

function! s:TransliterateModesComplete(lead, line, pos)
  return join(keys(s:modes), "\n")
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

function! TransliterateGetModeNames()
  return keys(s:modes)
endfunction

nnoremap <unique> <Plug>TransliterateApply
\ :set operatorfunc=<SID>TransliterateOperator<CR>g@
vnoremap <unique> <Plug>TransliterateApply
\ :<C-u>call <SID>TransliterateOperator(visualmode())<CR>

command -nargs=1 -complete=custom,<SID>TransliterateModesComplete
\ TransliterateSetMode let g:transliterateMode=<f-args>

" }}}
