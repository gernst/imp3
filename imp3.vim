" Quit if syntax file is already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn keyword impStatement    skip break exit return goto do
syn keyword impStatement    allocate free dispose gc message focus select
syn keyword impStatement    copy clear get_field set_field clear_field fail_if assert
syn keyword impStatement    copy_as mark unmark call requires ensures init
syn match   impStatement    /%\w*/
syn keyword impStructure    if while else begin end choice or guard optional
syn keyword impStructure    function program signature contracts show type data case of override
syn keyword impDefinition   sel var predicates actions import condition alias
syn keyword impCondition    null not marked equal rel true false is
syn keyword impAttribute    output input
syn match   impComment      /#.*$/
syn region  impString       start="\""  end="\""

hi def link impStatement    PreProc
hi def link impStructure    Statement
hi def link impDefinition   Type
hi def link impCondition    Boolean
hi def link impAttribute    Keyword
hi def link impComment      Comment
hi def link impString       String

let b:current_syntax = "imp3"

