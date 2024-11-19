;; extends

((typed_parameter ":" @_start . type: (type) @type.inner)
 (#make-range! "type.outer" @_start @type.inner))

((assignment ":" @_start . type: (type) @type.inner)
 (#make-range! "type.outer" @_start @type.inner))

((function_definition "->" @_start . return_type: (type) @type.inner)
 (#make-range! "type.outer" @_start @type.inner))