;; extends

(
  ((comment) @injection.language)
  ; strip comment characters and whitespace
  (#gsub! @injection.language "/%*%s*(.-)%s*%*/" "%1")
  (#gsub! @injection.language "#%s*(.*)" "%1")
  .
  (string (string_content) @injection.content)
  (#set! "injection.combined" 1))