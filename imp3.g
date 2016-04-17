parser IMP3:
    ignore:             '[ \\t]+'
    ignore:             '#.*?\r?\n+'
    token ID:           '[a-zA-Z_][a-zA-Z_0-9]*'
    token IDW:          '[a-zA-Z_\*]+[0-9\*]*'
    token IDP:          '[a-zA-Z_\.]+[0-9]*'
    token PRED:         '[a-zA-Z_\[\]]+[0-9]*'
    token LHS:          '[a-zA-Z_]+[0-9]*'
    token RHS:          '[a-zA-Z_]+[0-9]*'
    token F:            '[a-zA-Z_]+[0-9]*'
    token TY:           '[a-zA-Z_]+[0-9]*'
    token ARR:          '\[\]'
    token NL:           '[\\n;]+'
    token STR:          "\".*?\""
    token ST:           'skip|break|exit|return'
    token ATTR:         '@output|@input'
    token OST:          'allocate|get_field|set_field|clear_field|free|dispose'
    token TOF:          'true|false'

    rule signature:     "signature" ID {{ name = ID }} NL
                            structs
                            vars
                            functions
                        "end"
                        {{ return "signature", name, structs, vars, functions }}

    rule contracts:     {{ c = []; d = [] }}
                        "contracts" NL
                            vars
                            ( contract  {{ c.append(contract) }} NL
                            | prepost   {{ d.append(prepost)  }} NL )*
                            functions
                        "end"
                        {{ return "contracts", d, c, vars, functions }}

    rule contract:      {{ p = []; i = []; r = []; e = [] }}
                        "program" idwlist {{ progs = idwlist }}  NL
                            ( "init"     idlist {{ i.extend(idlist) }} NL
                            | "requires" idlist {{ r.extend(idlist) }} NL
                            | "ensures"  idlist {{ e.extend(idlist) }} NL)* 
                        "end"
                        {{ return "contract", progs, i, r, e }}

    rule prepost:       "condition" ID ":" STR
                        {{ return "condition", ID, STR }}

    rule idlist:        {{ l = [] }} (ID  {{ l.append(ID)  }})* {{ return l }}
    rule idwlist:       {{ l = [] }} (IDW {{ l.append(IDW) }})* {{ return l }}

    rule program:       "program" ID {{ name = ID; show = None }} NL
                            includes
                            structs
                            vars
                            functions
                        "begin" NL
                            body
                        ("show" NL
                            show)*
                        "end"
                        {{ return "program", name, includes, structs, vars, functions, body, show }}

    rule includes:      {{ i = []; p = []; a = []; c = [] }}
                        ( "import"     IDP {{ i.append(IDP) }} NL )*
                        ( "predicates" IDP {{ p.append(IDP) }} NL )*
                        ( "actions"    IDP {{ a.append(IDP) }} NL )*
                        ( "contracts"  IDP {{ c.append(IDP) }} NL )*
                        {{ return (i, p, a, c) }}

    rule structs:       {{ s = [] }}
                        ( struct {{ s.append(struct) }} NL
                        | data   {{ s.append(data)   }} NL
                        | case   {{ s.append(case)   }} NL )*
                        {{ return s }}

    rule vars:          {{ v = [] }}
                        ( var {{ v.append(var) }} NL )*
                        {{ return v }}

    rule sels:          {{ v = [] }}
                        ( sel {{ v.append(sel) }} NL )*
                        {{ return v }}

    rule functions:     {{ f = [] }}
                        ( function {{ f.append(function) }} NL )*
                        {{ return f }}

    rule overrides:     {{ o = [] }}
                        ( override {{ o.append(override) }} NL )*
                        {{ return o }}

    rule type:          TY {{ t = TY }} [ ARR {{ t += "[]" }} ]
                        {{ return t }}

    rule var:           "var" ID ":" type [ var_attrs ]
                        {{ return "var", ID, type, var_attrs }}

    rule sel:           "sel" ID ":" type [ var_attrs ]
                        {{ return "var", ID, type, var_attrs }}
                        
    rule var_attrs:     {{ a = [] }}
                        ( ATTR {{ a.append(ATTR) }} )*
                        {{ return a }}

    rule extends:         NL {{ return None }}
                        | "<" TY NL {{ return TY }}

    rule struct:        "type" TY extends
                        sels
                        overrides
                        "end"
                        {{ return "struct", TY, sels, extends, overrides }}

    rule data:          "data" TY {{ return "data", TY }}

    rule case:          "case" ID "of" TY NL
                        sels
                        "end"
                        {{ return "case", ID, TY, sels }}

    rule override:      "override" OST
                        {{ return "override", OST }}

    rule function:      "function" ID NL
                        [
                            vars
                            "begin" NL
                        ]
                        body
                        "end"
                        {{ return "function", ID, body }}

    rule body:          {{ s = [] }}
                        ( statement {{ s.append(statement) }} NL )*
                        {{ return s }}

    rule show:          {{ s = [] }}
                        ( STR {{ s.append(STR) }} NL )*
                        {{ return s }}

    rule statement:       "skip"      {{ return "skip",     }}
                        | "break"     {{ return "break",    }}
                        | "exit"      {{ return "exit",     }}
                        | "gc"        {{ return "gc",       }}
                        | "return"    {{ return "return",   }}
                        | while_      {{ return while_      }}
                        | if_         {{ return if_         }}
                        | clear       {{ return clear       }}
                        | copy        {{ return copy        }}
                        | copy_as     {{ return copy_as     }}
                        | get_field   {{ return get_field   }}
                        | clear_field {{ return clear_field }}
                        | set_field   {{ return set_field   }}
                        | allocate    {{ return allocate    }}
                        | free        {{ return free        }}
                        | dispose     {{ return dispose     }}
                        | assert_     {{ return assert_     }}
                        | mark        {{ return mark        }}
                        | unmark      {{ return unmark      }}
                        | call        {{ return call        }}
                        | inline      {{ return inline      }}
                        | call_args   {{ return call_args   }}
                        | choice      {{ return choice      }}
                        | optional    {{ return optional    }}
                        | assume      {{ return assume      }}
                        | focus       {{ return focus       }}
                        | select      {{ return select      }}
                        | do_         {{ return do_         }}
                        | "do" STR    {{ return "do", STR   }}
                        | "goto" STR  {{ return "goto", STR }}
                        | assign      {{ return assign      }}

    rule clear:         "clear" LHS                   {{ return "clear", LHS }}
    rule copy:          "copy" LHS RHS                {{ return "copy", LHS, RHS }}
    rule copy_as:       "copy_as" LHS RHS TY          {{ return "copy_as", LHS, RHS, TY }}
    rule get_field:     "get_field" LHS RHS '\.' F    {{ return "get_field", LHS, RHS, F }}
    rule clear_field:   "clear_field" LHS '\.' F      {{ return "clear_field", LHS, F }}
    rule set_field:     "set_field" LHS '\.' F RHS    {{ return "set_field", LHS, F, RHS }}

    rule allocate:      "allocate" LHS                {{ return "allocate", LHS }}
    rule free:          "free" LHS                    {{ return "free", LHS }}
    rule dispose:       "dispose" LHS                 {{ return "dispose", LHS }}

    rule mark:          "mark" LHS PRED               {{ return "mark", LHS, PRED }}
    rule unmark:        "unmark" LHS PRED             {{ return "unmark", LHS, PRED }}
    rule call:          "call" ID                     {{ return "call", ID }}
    rule inline:        "inline call" ID              {{ return "inline_call", ID }}
    rule call_args:     "call_args" ID args           {{ return "call_args", ID, args }}

    rule assign:        lhs ":=" rhs  {{ return "assign", lhs, rhs }}

    rule lhs:           expression {{ return expression }}

    rule rhs:             "\(" TY "\)" expression {{ return expression, TY }}
                        | expression   {{ return expression, None }}

    rule expression:      "null" {{ return "expression", None, None }}
                        | LHS expression2 {{ return "expression", LHS, expression2 }}
    rule expression2:     "\." LHS {{ return LHS }}
                        | {{ return None }}


    rule args:          "\(" {{ a = [] }}
                        ( ID {{ a.append(id) }} ) *
                        "\)" {{ return a }}

    rule while_:        "while" condition NL
                        body
                        "end"
                        {{ return ("while", condition, body) }} |

    rule if_:           "if" condition NL
                          body {{ true_branch  = body }}
                               {{ false_branch = [] }}
                        [ "else" NL
                          body {{ false_branch = body }} ]
                        "end"
                        {{ return "if", condition, true_branch, false_branch }}

    rule assert_:       "assert" condition
                        {{ return "assert", condition }}

    rule choice:        "choice" NL
                          body {{ choices = [body] }}
                        ( "or" NL
                          body {{ choices.append(body) }} )*
                        "end"
                        {{ return "choice", choices }}

    rule optional:      "optional" NL
                          body {{ choices = [[("skip",)], body] }}
                        ( "or" NL
                          body {{ choices.append(body) }} )*
                        "end"
                        {{ return "choice", choices }}


    rule assume:        "assume" condition
                        {{ return "assume", condition }}

    rule condition:       "true"  {{ return "true",  }}
                        | "false" {{ return "false", }}
                        | "not" condition {{ return "not", condition }}
                        | null    {{ return null  }}
                        | marked  {{ return marked }}
                        | rel     {{ return rel }}
                        | equal   {{ return equal }}

    rule null:          "null"  LHS      {{ return "null",  LHS }}

    rule equal:           "equal" LHS RHS  {{ return "equal", LHS, RHS }}
                        | LHS equal2       {{ return equal2[0], LHS, equal2[1] }}

    rule equal2:          "==" RHS {{ return "equal", RHS }}
                        | "!=" RHS {{ return "unequal", RHS }}
                        | "is" TY  {{ return "marked", TY }}
    
    rule marked:         "marked" LHS PRED  {{ return "marked", LHS, PRED }}
    rule rel:            "rel" LHS PRED RHS {{ return "rel", LHS, PRED, RHS }}

    rule focus:         "focus" LHS     {{ return "focus",  LHS }}
    rule select:        "select" LHS TY {{ return "select", LHS, TY }}

    rule do_:           "%" ID idlist {{ return "%", ID, idlist }}
