; extends

(
  ((comment) @injection.language)
  ; strip comment characters and whitespace
  (#gsub! @injection.language "/%*%s*(.-)%s*%*/" "%1")
  (#gsub! @injection.language "#%s*(.*)" "%1")
  .
  (indented_string_expression (string_fragment) @injection.content)
  (#set! "injection.combined" 1))