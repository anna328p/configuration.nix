; comments

(comment) @indent.ignore

; lists

((list_expression) @indent.align
 (#set! indent.open_delimiter "[")
 (#set! indent.close_delimiter "]")
 (#set! indent.increment 2))

(list_expression "]" @indent.end @indent.branch)

; parentheses

(parenthesized_expression) @indent.begin
(parenthesized_expression ")" @indent.end @indent.branch)

(
 [
  (attrset_expression)
  (rec_attrset_expression)
 ] @indent.align
 (#set! indent.open_delimiter "{")
 (#set! indent.close_delimiter "}")
 (#set! indent.increment 2))

(attrset_expression "}" @indent.end @indent.branch .)
(rec_attrset_expression "}" @indent.end @indent.branch .)

(
 (binding expression: (_) @_le) @indent.begin
 (#not-has-type? @_le
  function_expression
  with_expression
  let_expression))
  ; parenthesized_expression
  ; attrset_expression
  ; rec_attrset_expression
  ; indented_string_expression))

(binding ";" @indent.end .)

(let_expression) @indent.begin
(let_expression "in" @indent.branch)

; (let_expression
;   body: (_) @indent.dedent
;   (#has-type? @indent.dedent
;    with_expression
;    list_expression
;    parenthesized_expression
;    attrset_expression
;    rec_attrset_expression
;    indented_string_expression
;    binary_expression))

(with_expression) @indent.begin
(ERROR "with")

; indented strings

; ((indented_string_expression) @indent.align
;  (#set! indent.open_delimiter "''")
;  (#set! indent.close_delimiter "''")
;  (#set! indent.increment 2))

(indented_string_expression) @indent.begin

(indented_string_expression
  "''" @indent.branch @indent.end .)

(binary_expression
  left: (_) @indent.begin
  (#set! indent.immediate 1)
  (#set! indent.start_at_same_line 1))

(binary_expression
  right: (_) @indent.begin
  (#set! indent.immediate 1)
  (#set! indent.start_at_same_line 1))

; (binary_expression) @indent.begin
; 
; (
;  binary_expression
;  right: [
;    (list_expression)
;    (parenthesized_expression)
;    (attrset_expression)
;    (rec_attrset_expression)
;    (with_expression)
;    (indented_string_expression)
;  ] @indent.dedent)
; 
; (
;  binary_expression
;  left: [
;    (list_expression)
;    (parenthesized_expression)
;    (attrset_expression)
;    (rec_attrset_expression)
;    (with_expression)
;    (indented_string_expression)
;  ] @indent.dedent)

(
 (function_expression !formals) @indent.begin
 (#not-has-parent? @indent.begin source_code))

(
 (function_expression formals: (_) @indent.auto) @_fn_exp
 (#not-has-parent? @_fn_exp source_code))

(formal
  default: (_) @_def
  (#not-has-type? @_def
   list_expression
   attrset_expression
   rec_attrset_expression)) @indent.begin

(ERROR "let") @indent.begin

; if / then / else

(if_expression) @indent.auto

(ERROR "if" @indent.begin
 (#set! indent.immediate 1))

(apply_expression) @indent.begin
