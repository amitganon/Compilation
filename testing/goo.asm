%define T_void 				0
%define T_nil 				1
%define T_char 				2
%define T_string 			3
%define T_symbol 			4
%define T_closure 			5
%define T_boolean 			8
%define T_boolean_false 		(T_boolean | 1)
%define T_boolean_true 			(T_boolean | 2)
%define T_number 			16
%define T_rational 			(T_number | 1)
%define T_real 				(T_number | 2)
%define T_collection 			32
%define T_pair 				(T_collection | 1)
%define T_vector 			(T_collection | 2)

%define SOB_CHAR_VALUE(reg) 		byte [reg + 1]
%define SOB_PAIR_CAR(reg)		qword [reg + 1]
%define SOB_PAIR_CDR(reg)		qword [reg + 1 + 8]
%define SOB_STRING_LENGTH(reg)		qword [reg + 1]
%define SOB_VECTOR_LENGTH(reg)		qword [reg + 1]
%define SOB_CLOSURE_ENV(reg)		qword [reg + 1]
%define SOB_CLOSURE_CODE(reg)		qword [reg + 1 + 8]

%define OLD_RDP 			qword [rbp]
%define RET_ADDR 			qword [rbp + 8 * 1]
%define ENV 				qword [rbp + 8 * 2]
%define COUNT 				qword [rbp + 8 * 3]
%define PARAM(n) 			qword [rbp + 8 * (4 + n)]
%define AND_KILL_FRAME(n)		(8 * (2 + n))

%macro ENTER 0
	enter 0, 0
	and rsp, ~15
%endmacro

%macro LEAVE 0
	leave
%endmacro

%macro assert_type 2
        cmp byte [%1], %2
        jne L_error_incorrect_type
%endmacro

%macro assert_type_integer 1
        assert_rational(%1)
        cmp qword [%1 + 1 + 8], 1
        jne L_error_incorrect_type
%endmacro

%define assert_void(reg)		assert_type reg, T_void
%define assert_nil(reg)			assert_type reg, T_nil
%define assert_char(reg)		assert_type reg, T_char
%define assert_string(reg)		assert_type reg, T_string
%define assert_symbol(reg)		assert_type reg, T_symbol
%define assert_closure(reg)		assert_type reg, T_closure
%define assert_boolean(reg)		assert_type reg, T_boolean
%define assert_rational(reg)		assert_type reg, T_rational
%define assert_integer(reg)		assert_type_integer reg
%define assert_real(reg)		assert_type reg, T_real
%define assert_pair(reg)		assert_type reg, T_pair
%define assert_vector(reg)		assert_type reg, T_vector

%define sob_void			(L_constants + 0)
%define sob_nil				(L_constants + 1)
%define sob_boolean_false		(L_constants + 2)
%define sob_boolean_true		(L_constants + 3)
%define sob_char_nul			(L_constants + 4)

%define bytes(n)			(n)
%define kbytes(n) 			(bytes(n) << 10)
%define mbytes(n) 			(kbytes(n) << 10)
%define gbytes(n) 			(mbytes(n) << 10)

section .data
L_constants:
	db T_void
	db T_nil
	db T_boolean_false
	db T_boolean_true
	db T_char, 0x00	; #\x0
	db T_string	; "whatever"
	dq 8
	db 0x77, 0x68, 0x61, 0x74, 0x65, 0x76, 0x65, 0x72
	db T_symbol	; whatever
	dq L_constants + 6
	db T_rational	; 0
	dq 0, 1
	db T_string	; "+"
	dq 1
	db 0x2B
	db T_symbol	; +
	dq L_constants + 49
	db T_string	; "all arguments need ...
	dq 32
	db 0x61, 0x6C, 0x6C, 0x20, 0x61, 0x72, 0x67, 0x75
	db 0x6D, 0x65, 0x6E, 0x74, 0x73, 0x20, 0x6E, 0x65
	db 0x65, 0x64, 0x20, 0x74, 0x6F, 0x20, 0x62, 0x65
	db 0x20, 0x6E, 0x75, 0x6D, 0x62, 0x65, 0x72, 0x73
	db T_string	; "-"
	dq 1
	db 0x2D
	db T_symbol	; -
	dq L_constants + 109
	db T_rational	; 1
	dq 1, 1
	db T_string	; "*"
	dq 1
	db 0x2A
	db T_symbol	; *
	dq L_constants + 145
	db T_string	; "/"
	dq 1
	db 0x2F
	db T_symbol	; /
	dq L_constants + 164
	db T_string	; "generic-comparator"
	dq 18
	db 0x67, 0x65, 0x6E, 0x65, 0x72, 0x69, 0x63, 0x2D
	db 0x63, 0x6F, 0x6D, 0x70, 0x61, 0x72, 0x61, 0x74
	db 0x6F, 0x72
	db T_symbol	; generic-comparator
	dq L_constants + 183
	db T_string	; "all the arguments m...
	dq 33
	db 0x61, 0x6C, 0x6C, 0x20, 0x74, 0x68, 0x65, 0x20
	db 0x61, 0x72, 0x67, 0x75, 0x6D, 0x65, 0x6E, 0x74
	db 0x73, 0x20, 0x6D, 0x75, 0x73, 0x74, 0x20, 0x62
	db 0x65, 0x20, 0x6E, 0x75, 0x6D, 0x62, 0x65, 0x72
	db 0x73
	db T_string	; "make-list"
	dq 9
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x6C, 0x69, 0x73
	db 0x74
	db T_symbol	; make-list
	dq L_constants + 261
	db T_string	; "Usage: (make-list l...
	dq 45
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x6C, 0x69, 0x73
	db 0x74, 0x20, 0x6C, 0x65, 0x6E, 0x67, 0x74, 0x68
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x69, 0x6E, 0x69, 0x74, 0x2D
	db 0x63, 0x68, 0x61, 0x72, 0x29
	db T_char, 0x41	; #\A
	db T_char, 0x5A	; #\Z
	db T_char, 0x61	; #\a
	db T_char, 0x7A	; #\z
	db T_string	; "make-vector"
	dq 11
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x76, 0x65, 0x63
	db 0x74, 0x6F, 0x72
	db T_symbol	; make-vector
	dq L_constants + 350
	db T_string	; "Usage: (make-vector...
	dq 43
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x76, 0x65, 0x63
	db 0x74, 0x6F, 0x72, 0x20, 0x73, 0x69, 0x7A, 0x65
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x64, 0x65, 0x66, 0x61, 0x75
	db 0x6C, 0x74, 0x29
	db T_string	; "make-string"
	dq 11
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x73, 0x74, 0x72
	db 0x69, 0x6E, 0x67
	db T_symbol	; make-string
	dq L_constants + 431
	db T_string	; "Usage: (make-string...
	dq 43
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x73, 0x74, 0x72
	db 0x69, 0x6E, 0x67, 0x20, 0x73, 0x69, 0x7A, 0x65
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x64, 0x65, 0x66, 0x61, 0x75
	db 0x6C, 0x74, 0x29
	db T_rational	; 2
	dq 2, 1

section .bss
free_var_0:	; location of null?
	resq 1
free_var_1:	; location of pair?
	resq 1
free_var_2:	; location of void?
	resq 1
free_var_3:	; location of char?
	resq 1
free_var_4:	; location of string?
	resq 1
free_var_5:	; location of symbol?
	resq 1
free_var_6:	; location of vector?
	resq 1
free_var_7:	; location of procedure?
	resq 1
free_var_8:	; location of real?
	resq 1
free_var_9:	; location of rational?
	resq 1
free_var_10:	; location of boolean?
	resq 1
free_var_11:	; location of number?
	resq 1
free_var_12:	; location of collection?
	resq 1
free_var_13:	; location of cons
	resq 1
free_var_14:	; location of display-sexpr
	resq 1
free_var_15:	; location of write-char
	resq 1
free_var_16:	; location of car
	resq 1
free_var_17:	; location of cdr
	resq 1
free_var_18:	; location of string-length
	resq 1
free_var_19:	; location of vector-length
	resq 1
free_var_20:	; location of real->integer
	resq 1
free_var_21:	; location of exit
	resq 1
free_var_22:	; location of integer->real
	resq 1
free_var_23:	; location of rational->real
	resq 1
free_var_24:	; location of char->integer
	resq 1
free_var_25:	; location of integer->char
	resq 1
free_var_26:	; location of trng
	resq 1
free_var_27:	; location of zero?
	resq 1
free_var_28:	; location of integer?
	resq 1
free_var_29:	; location of __bin-apply
	resq 1
free_var_30:	; location of __bin-add-rr
	resq 1
free_var_31:	; location of __bin-sub-rr
	resq 1
free_var_32:	; location of __bin-mul-rr
	resq 1
free_var_33:	; location of __bin-div-rr
	resq 1
free_var_34:	; location of __bin-add-qq
	resq 1
free_var_35:	; location of __bin-sub-qq
	resq 1
free_var_36:	; location of __bin-mul-qq
	resq 1
free_var_37:	; location of __bin-div-qq
	resq 1
free_var_38:	; location of error
	resq 1
free_var_39:	; location of __bin-less-than-rr
	resq 1
free_var_40:	; location of __bin-less-than-qq
	resq 1
free_var_41:	; location of __bin-equal-rr
	resq 1
free_var_42:	; location of __bin-equal-qq
	resq 1
free_var_43:	; location of quotient
	resq 1
free_var_44:	; location of remainder
	resq 1
free_var_45:	; location of set-car!
	resq 1
free_var_46:	; location of set-cdr!
	resq 1
free_var_47:	; location of string-ref
	resq 1
free_var_48:	; location of vector-ref
	resq 1
free_var_49:	; location of vector-set!
	resq 1
free_var_50:	; location of string-set!
	resq 1
free_var_51:	; location of make-vector
	resq 1
free_var_52:	; location of make-string
	resq 1
free_var_53:	; location of numerator
	resq 1
free_var_54:	; location of denominator
	resq 1
free_var_55:	; location of eq?
	resq 1
free_var_56:	; location of caar
	resq 1
free_var_57:	; location of cadr
	resq 1
free_var_58:	; location of cdar
	resq 1
free_var_59:	; location of cddr
	resq 1
free_var_60:	; location of caaar
	resq 1
free_var_61:	; location of caadr
	resq 1
free_var_62:	; location of cadar
	resq 1
free_var_63:	; location of caddr
	resq 1
free_var_64:	; location of cdaar
	resq 1
free_var_65:	; location of cdadr
	resq 1
free_var_66:	; location of cddar
	resq 1
free_var_67:	; location of cdddr
	resq 1
free_var_68:	; location of caaaar
	resq 1
free_var_69:	; location of caaadr
	resq 1
free_var_70:	; location of caadar
	resq 1
free_var_71:	; location of caaddr
	resq 1
free_var_72:	; location of cadaar
	resq 1
free_var_73:	; location of cadadr
	resq 1
free_var_74:	; location of caddar
	resq 1
free_var_75:	; location of cadddr
	resq 1
free_var_76:	; location of cdaaar
	resq 1
free_var_77:	; location of cdaadr
	resq 1
free_var_78:	; location of cdadar
	resq 1
free_var_79:	; location of cdaddr
	resq 1
free_var_80:	; location of cddaar
	resq 1
free_var_81:	; location of cddadr
	resq 1
free_var_82:	; location of cdddar
	resq 1
free_var_83:	; location of cddddr
	resq 1
free_var_84:	; location of list?
	resq 1
free_var_85:	; location of list
	resq 1
free_var_86:	; location of not
	resq 1
free_var_87:	; location of fraction?
	resq 1
free_var_88:	; location of list*
	resq 1
free_var_89:	; location of apply
	resq 1
free_var_90:	; location of ormap
	resq 1
free_var_91:	; location of map
	resq 1
free_var_92:	; location of andmap
	resq 1
free_var_93:	; location of reverse
	resq 1
free_var_94:	; location of append
	resq 1
free_var_95:	; location of fold-left
	resq 1
free_var_96:	; location of fold-right
	resq 1
free_var_97:	; location of +
	resq 1
free_var_98:	; location of -
	resq 1
free_var_99:	; location of *
	resq 1
free_var_100:	; location of /
	resq 1
free_var_101:	; location of fact
	resq 1
free_var_102:	; location of <
	resq 1
free_var_103:	; location of <=
	resq 1
free_var_104:	; location of >
	resq 1
free_var_105:	; location of >=
	resq 1
free_var_106:	; location of =
	resq 1
free_var_107:	; location of make-list
	resq 1
free_var_108:	; location of char<?
	resq 1
free_var_109:	; location of char<=?
	resq 1
free_var_110:	; location of char=?
	resq 1
free_var_111:	; location of char>?
	resq 1
free_var_112:	; location of char>=?
	resq 1
free_var_113:	; location of char-downcase
	resq 1
free_var_114:	; location of char-upcase
	resq 1
free_var_115:	; location of char-ci<?
	resq 1
free_var_116:	; location of char-ci<=?
	resq 1
free_var_117:	; location of char-ci=?
	resq 1
free_var_118:	; location of char-ci>?
	resq 1
free_var_119:	; location of char-ci>=?
	resq 1
free_var_120:	; location of string-downcase
	resq 1
free_var_121:	; location of string-upcase
	resq 1
free_var_122:	; location of list->string
	resq 1
free_var_123:	; location of string->list
	resq 1
free_var_124:	; location of string<?
	resq 1
free_var_125:	; location of string<=?
	resq 1
free_var_126:	; location of string=?
	resq 1
free_var_127:	; location of string>=?
	resq 1
free_var_128:	; location of string>?
	resq 1
free_var_129:	; location of string-ci<?
	resq 1
free_var_130:	; location of string-ci<=?
	resq 1
free_var_131:	; location of string-ci=?
	resq 1
free_var_132:	; location of string-ci>=?
	resq 1
free_var_133:	; location of string-ci>?
	resq 1
free_var_134:	; location of length
	resq 1
free_var_135:	; location of list->vector
	resq 1
free_var_136:	; location of vector
	resq 1
free_var_137:	; location of vector->list
	resq 1
free_var_138:	; location of random
	resq 1
free_var_139:	; location of positive?
	resq 1
free_var_140:	; location of negative?
	resq 1
free_var_141:	; location of even?
	resq 1
free_var_142:	; location of odd?
	resq 1
free_var_143:	; location of abs
	resq 1
free_var_144:	; location of equal?
	resq 1
free_var_145:	; location of assoc
	resq 1

extern printf, fprintf, stdout, stderr, fwrite, exit, putchar
global main
section .text
main:
        enter 0, 0
        
	; building closure for null?
	mov rdi, free_var_0
	mov rsi, L_code_ptr_is_null
	call bind_primitive

	; building closure for pair?
	mov rdi, free_var_1
	mov rsi, L_code_ptr_is_pair
	call bind_primitive

	; building closure for void?
	mov rdi, free_var_2
	mov rsi, L_code_ptr_is_void
	call bind_primitive

	; building closure for char?
	mov rdi, free_var_3
	mov rsi, L_code_ptr_is_char
	call bind_primitive

	; building closure for string?
	mov rdi, free_var_4
	mov rsi, L_code_ptr_is_string
	call bind_primitive

	; building closure for symbol?
	mov rdi, free_var_5
	mov rsi, L_code_ptr_is_symbol
	call bind_primitive

	; building closure for vector?
	mov rdi, free_var_6
	mov rsi, L_code_ptr_is_vector
	call bind_primitive

	; building closure for procedure?
	mov rdi, free_var_7
	mov rsi, L_code_ptr_is_closure
	call bind_primitive

	; building closure for real?
	mov rdi, free_var_8
	mov rsi, L_code_ptr_is_real
	call bind_primitive

	; building closure for rational?
	mov rdi, free_var_9
	mov rsi, L_code_ptr_is_rational
	call bind_primitive

	; building closure for boolean?
	mov rdi, free_var_10
	mov rsi, L_code_ptr_is_boolean
	call bind_primitive

	; building closure for number?
	mov rdi, free_var_11
	mov rsi, L_code_ptr_is_number
	call bind_primitive

	; building closure for collection?
	mov rdi, free_var_12
	mov rsi, L_code_ptr_is_collection
	call bind_primitive

	; building closure for cons
	mov rdi, free_var_13
	mov rsi, L_code_ptr_cons
	call bind_primitive

	; building closure for display-sexpr
	mov rdi, free_var_14
	mov rsi, L_code_ptr_display_sexpr
	call bind_primitive

	; building closure for write-char
	mov rdi, free_var_15
	mov rsi, L_code_ptr_write_char
	call bind_primitive

	; building closure for car
	mov rdi, free_var_16
	mov rsi, L_code_ptr_car
	call bind_primitive

	; building closure for cdr
	mov rdi, free_var_17
	mov rsi, L_code_ptr_cdr
	call bind_primitive

	; building closure for string-length
	mov rdi, free_var_18
	mov rsi, L_code_ptr_string_length
	call bind_primitive

	; building closure for vector-length
	mov rdi, free_var_19
	mov rsi, L_code_ptr_vector_length
	call bind_primitive

	; building closure for real->integer
	mov rdi, free_var_20
	mov rsi, L_code_ptr_real_to_integer
	call bind_primitive

	; building closure for exit
	mov rdi, free_var_21
	mov rsi, L_code_ptr_exit
	call bind_primitive

	; building closure for integer->real
	mov rdi, free_var_22
	mov rsi, L_code_ptr_integer_to_real
	call bind_primitive

	; building closure for rational->real
	mov rdi, free_var_23
	mov rsi, L_code_ptr_rational_to_real
	call bind_primitive

	; building closure for char->integer
	mov rdi, free_var_24
	mov rsi, L_code_ptr_char_to_integer
	call bind_primitive

	; building closure for integer->char
	mov rdi, free_var_25
	mov rsi, L_code_ptr_integer_to_char
	call bind_primitive

	; building closure for trng
	mov rdi, free_var_26
	mov rsi, L_code_ptr_trng
	call bind_primitive

	; building closure for zero?
	mov rdi, free_var_27
	mov rsi, L_code_ptr_is_zero
	call bind_primitive

	; building closure for integer?
	mov rdi, free_var_28
	mov rsi, L_code_ptr_is_integer
	call bind_primitive

	; building closure for __bin-apply
	mov rdi, free_var_29
	mov rsi, L_code_ptr_bin_apply
	call bind_primitive

	; building closure for __bin-add-rr
	mov rdi, free_var_30
	mov rsi, L_code_ptr_raw_bin_add_rr
	call bind_primitive

	; building closure for __bin-sub-rr
	mov rdi, free_var_31
	mov rsi, L_code_ptr_raw_bin_sub_rr
	call bind_primitive

	; building closure for __bin-mul-rr
	mov rdi, free_var_32
	mov rsi, L_code_ptr_raw_bin_mul_rr
	call bind_primitive

	; building closure for __bin-div-rr
	mov rdi, free_var_33
	mov rsi, L_code_ptr_raw_bin_div_rr
	call bind_primitive

	; building closure for __bin-add-qq
	mov rdi, free_var_34
	mov rsi, L_code_ptr_raw_bin_add_qq
	call bind_primitive

	; building closure for __bin-sub-qq
	mov rdi, free_var_35
	mov rsi, L_code_ptr_raw_bin_sub_qq
	call bind_primitive

	; building closure for __bin-mul-qq
	mov rdi, free_var_36
	mov rsi, L_code_ptr_raw_bin_mul_qq
	call bind_primitive

	; building closure for __bin-div-qq
	mov rdi, free_var_37
	mov rsi, L_code_ptr_raw_bin_div_qq
	call bind_primitive

	; building closure for error
	mov rdi, free_var_38
	mov rsi, L_code_ptr_error
	call bind_primitive

	; building closure for __bin-less-than-rr
	mov rdi, free_var_39
	mov rsi, L_code_ptr_raw_less_than_rr
	call bind_primitive

	; building closure for __bin-less-than-qq
	mov rdi, free_var_40
	mov rsi, L_code_ptr_raw_less_than_qq
	call bind_primitive

	; building closure for __bin-equal-rr
	mov rdi, free_var_41
	mov rsi, L_code_ptr_raw_equal_rr
	call bind_primitive

	; building closure for __bin-equal-qq
	mov rdi, free_var_42
	mov rsi, L_code_ptr_raw_equal_qq
	call bind_primitive

	; building closure for quotient
	mov rdi, free_var_43
	mov rsi, L_code_ptr_quotient
	call bind_primitive

	; building closure for remainder
	mov rdi, free_var_44
	mov rsi, L_code_ptr_remainder
	call bind_primitive

	; building closure for set-car!
	mov rdi, free_var_45
	mov rsi, L_code_ptr_set_car
	call bind_primitive

	; building closure for set-cdr!
	mov rdi, free_var_46
	mov rsi, L_code_ptr_set_cdr
	call bind_primitive

	; building closure for string-ref
	mov rdi, free_var_47
	mov rsi, L_code_ptr_string_ref
	call bind_primitive

	; building closure for vector-ref
	mov rdi, free_var_48
	mov rsi, L_code_ptr_vector_ref
	call bind_primitive

	; building closure for vector-set!
	mov rdi, free_var_49
	mov rsi, L_code_ptr_vector_set
	call bind_primitive

	; building closure for string-set!
	mov rdi, free_var_50
	mov rsi, L_code_ptr_string_set
	call bind_primitive

	; building closure for make-vector
	mov rdi, free_var_51
	mov rsi, L_code_ptr_make_vector
	call bind_primitive

	; building closure for make-string
	mov rdi, free_var_52
	mov rsi, L_code_ptr_make_string
	call bind_primitive

	; building closure for numerator
	mov rdi, free_var_53
	mov rsi, L_code_ptr_numerator
	call bind_primitive

	; building closure for denominator
	mov rdi, free_var_54
	mov rsi, L_code_ptr_denominator
	call bind_primitive

	; building closure for eq?
	mov rdi, free_var_55
	mov rsi, L_code_ptr_eq
	call bind_primitive

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_009d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_009d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_009d
.L_lambda_simple_env_end_009d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_009d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_009d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_009d
.L_lambda_simple_params_end_009d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_009d
	jmp .L_lambda_simple_end_009d
.L_lambda_simple_code_009d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_009d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_009d:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00b7:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00b7
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00b7
.L_tc_recycle_frame_done_00b7:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_009d:	; new closure is in rax
	mov qword [free_var_56], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_009e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_009e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_009e
.L_lambda_simple_env_end_009e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_009e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_009e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_009e
.L_lambda_simple_params_end_009e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_009e
	jmp .L_lambda_simple_end_009e
.L_lambda_simple_code_009e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_009e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_009e:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00b8:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00b8
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00b8
.L_tc_recycle_frame_done_00b8:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_009e:	; new closure is in rax
	mov qword [free_var_57], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_009f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_009f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_009f
.L_lambda_simple_env_end_009f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_009f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_009f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_009f
.L_lambda_simple_params_end_009f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_009f
	jmp .L_lambda_simple_end_009f
.L_lambda_simple_code_009f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_009f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_009f:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00b9:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00b9
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00b9
.L_tc_recycle_frame_done_00b9:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_009f:	; new closure is in rax
	mov qword [free_var_58], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00a0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00a0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00a0
.L_lambda_simple_env_end_00a0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00a0:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00a0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00a0
.L_lambda_simple_params_end_00a0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00a0
	jmp .L_lambda_simple_end_00a0
.L_lambda_simple_code_00a0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00a0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00a0:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00ba:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00ba
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00ba
.L_tc_recycle_frame_done_00ba:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00a0:	; new closure is in rax
	mov qword [free_var_59], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00a1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00a1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00a1
.L_lambda_simple_env_end_00a1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00a1:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00a1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00a1
.L_lambda_simple_params_end_00a1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00a1
	jmp .L_lambda_simple_end_00a1
.L_lambda_simple_code_00a1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00a1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00a1:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00bb:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00bb
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00bb
.L_tc_recycle_frame_done_00bb:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00a1:	; new closure is in rax
	mov qword [free_var_60], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00a2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00a2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00a2
.L_lambda_simple_env_end_00a2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00a2:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00a2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00a2
.L_lambda_simple_params_end_00a2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00a2
	jmp .L_lambda_simple_end_00a2
.L_lambda_simple_code_00a2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00a2
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00a2:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00bc:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00bc
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00bc
.L_tc_recycle_frame_done_00bc:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00a2:	; new closure is in rax
	mov qword [free_var_61], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00a3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00a3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00a3
.L_lambda_simple_env_end_00a3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00a3:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00a3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00a3
.L_lambda_simple_params_end_00a3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00a3
	jmp .L_lambda_simple_end_00a3
.L_lambda_simple_code_00a3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00a3
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00a3:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00bd:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00bd
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00bd
.L_tc_recycle_frame_done_00bd:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00a3:	; new closure is in rax
	mov qword [free_var_62], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00a4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00a4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00a4
.L_lambda_simple_env_end_00a4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00a4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00a4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00a4
.L_lambda_simple_params_end_00a4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00a4
	jmp .L_lambda_simple_end_00a4
.L_lambda_simple_code_00a4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00a4
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00a4:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00be:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00be
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00be
.L_tc_recycle_frame_done_00be:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00a4:	; new closure is in rax
	mov qword [free_var_63], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00a5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00a5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00a5
.L_lambda_simple_env_end_00a5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00a5:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00a5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00a5
.L_lambda_simple_params_end_00a5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00a5
	jmp .L_lambda_simple_end_00a5
.L_lambda_simple_code_00a5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00a5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00a5:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00bf:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00bf
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00bf
.L_tc_recycle_frame_done_00bf:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00a5:	; new closure is in rax
	mov qword [free_var_64], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00a6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00a6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00a6
.L_lambda_simple_env_end_00a6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00a6:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00a6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00a6
.L_lambda_simple_params_end_00a6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00a6
	jmp .L_lambda_simple_end_00a6
.L_lambda_simple_code_00a6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00a6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00a6:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00c0:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00c0
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00c0
.L_tc_recycle_frame_done_00c0:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00a6:	; new closure is in rax
	mov qword [free_var_65], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00a7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00a7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00a7
.L_lambda_simple_env_end_00a7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00a7:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00a7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00a7
.L_lambda_simple_params_end_00a7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00a7
	jmp .L_lambda_simple_end_00a7
.L_lambda_simple_code_00a7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00a7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00a7:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00c1:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00c1
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00c1
.L_tc_recycle_frame_done_00c1:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00a7:	; new closure is in rax
	mov qword [free_var_66], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00a8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00a8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00a8
.L_lambda_simple_env_end_00a8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00a8:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00a8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00a8
.L_lambda_simple_params_end_00a8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00a8
	jmp .L_lambda_simple_end_00a8
.L_lambda_simple_code_00a8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00a8
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00a8:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00c2:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00c2
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00c2
.L_tc_recycle_frame_done_00c2:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00a8:	; new closure is in rax
	mov qword [free_var_67], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00a9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00a9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00a9
.L_lambda_simple_env_end_00a9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00a9:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00a9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00a9
.L_lambda_simple_params_end_00a9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00a9
	jmp .L_lambda_simple_end_00a9
.L_lambda_simple_code_00a9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00a9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00a9:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00c3:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00c3
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00c3
.L_tc_recycle_frame_done_00c3:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00a9:	; new closure is in rax
	mov qword [free_var_68], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00aa:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00aa
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00aa
.L_lambda_simple_env_end_00aa:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00aa:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00aa
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00aa
.L_lambda_simple_params_end_00aa:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00aa
	jmp .L_lambda_simple_end_00aa
.L_lambda_simple_code_00aa:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00aa
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00aa:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00c4:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00c4
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00c4
.L_tc_recycle_frame_done_00c4:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00aa:	; new closure is in rax
	mov qword [free_var_69], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00ab:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00ab
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00ab
.L_lambda_simple_env_end_00ab:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00ab:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00ab
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00ab
.L_lambda_simple_params_end_00ab:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00ab
	jmp .L_lambda_simple_end_00ab
.L_lambda_simple_code_00ab:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00ab
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00ab:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00c5:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00c5
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00c5
.L_tc_recycle_frame_done_00c5:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00ab:	; new closure is in rax
	mov qword [free_var_70], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00ac:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00ac
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00ac
.L_lambda_simple_env_end_00ac:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00ac:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00ac
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00ac
.L_lambda_simple_params_end_00ac:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00ac
	jmp .L_lambda_simple_end_00ac
.L_lambda_simple_code_00ac:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00ac
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00ac:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00c6:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00c6
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00c6
.L_tc_recycle_frame_done_00c6:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00ac:	; new closure is in rax
	mov qword [free_var_71], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00ad:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00ad
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00ad
.L_lambda_simple_env_end_00ad:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00ad:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00ad
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00ad
.L_lambda_simple_params_end_00ad:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00ad
	jmp .L_lambda_simple_end_00ad
.L_lambda_simple_code_00ad:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00ad
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00ad:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00c7:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00c7
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00c7
.L_tc_recycle_frame_done_00c7:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00ad:	; new closure is in rax
	mov qword [free_var_72], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00ae:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00ae
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00ae
.L_lambda_simple_env_end_00ae:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00ae:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00ae
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00ae
.L_lambda_simple_params_end_00ae:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00ae
	jmp .L_lambda_simple_end_00ae
.L_lambda_simple_code_00ae:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00ae
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00ae:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00c8:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00c8
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00c8
.L_tc_recycle_frame_done_00c8:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00ae:	; new closure is in rax
	mov qword [free_var_73], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00af:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00af
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00af
.L_lambda_simple_env_end_00af:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00af:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00af
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00af
.L_lambda_simple_params_end_00af:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00af
	jmp .L_lambda_simple_end_00af
.L_lambda_simple_code_00af:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00af
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00af:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00c9:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00c9
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00c9
.L_tc_recycle_frame_done_00c9:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00af:	; new closure is in rax
	mov qword [free_var_74], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00b0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00b0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00b0
.L_lambda_simple_env_end_00b0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00b0:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00b0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00b0
.L_lambda_simple_params_end_00b0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00b0
	jmp .L_lambda_simple_end_00b0
.L_lambda_simple_code_00b0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00b0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00b0:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00ca:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00ca
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00ca
.L_tc_recycle_frame_done_00ca:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00b0:	; new closure is in rax
	mov qword [free_var_75], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00b1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00b1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00b1
.L_lambda_simple_env_end_00b1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00b1:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00b1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00b1
.L_lambda_simple_params_end_00b1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00b1
	jmp .L_lambda_simple_end_00b1
.L_lambda_simple_code_00b1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00b1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00b1:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00cb:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00cb
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00cb
.L_tc_recycle_frame_done_00cb:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00b1:	; new closure is in rax
	mov qword [free_var_76], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00b2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00b2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00b2
.L_lambda_simple_env_end_00b2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00b2:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00b2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00b2
.L_lambda_simple_params_end_00b2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00b2
	jmp .L_lambda_simple_end_00b2
.L_lambda_simple_code_00b2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00b2
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00b2:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00cc:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00cc
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00cc
.L_tc_recycle_frame_done_00cc:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00b2:	; new closure is in rax
	mov qword [free_var_77], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00b3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00b3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00b3
.L_lambda_simple_env_end_00b3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00b3:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00b3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00b3
.L_lambda_simple_params_end_00b3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00b3
	jmp .L_lambda_simple_end_00b3
.L_lambda_simple_code_00b3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00b3
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00b3:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00cd:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00cd
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00cd
.L_tc_recycle_frame_done_00cd:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00b3:	; new closure is in rax
	mov qword [free_var_78], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00b4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00b4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00b4
.L_lambda_simple_env_end_00b4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00b4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00b4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00b4
.L_lambda_simple_params_end_00b4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00b4
	jmp .L_lambda_simple_end_00b4
.L_lambda_simple_code_00b4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00b4
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00b4:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00ce:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00ce
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00ce
.L_tc_recycle_frame_done_00ce:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00b4:	; new closure is in rax
	mov qword [free_var_79], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00b5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00b5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00b5
.L_lambda_simple_env_end_00b5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00b5:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00b5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00b5
.L_lambda_simple_params_end_00b5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00b5
	jmp .L_lambda_simple_end_00b5
.L_lambda_simple_code_00b5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00b5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00b5:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00cf:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00cf
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00cf
.L_tc_recycle_frame_done_00cf:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00b5:	; new closure is in rax
	mov qword [free_var_80], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00b6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00b6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00b6
.L_lambda_simple_env_end_00b6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00b6:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00b6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00b6
.L_lambda_simple_params_end_00b6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00b6
	jmp .L_lambda_simple_end_00b6
.L_lambda_simple_code_00b6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00b6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00b6:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00d0:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00d0
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00d0
.L_tc_recycle_frame_done_00d0:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00b6:	; new closure is in rax
	mov qword [free_var_81], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00b7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00b7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00b7
.L_lambda_simple_env_end_00b7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00b7:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00b7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00b7
.L_lambda_simple_params_end_00b7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00b7
	jmp .L_lambda_simple_end_00b7
.L_lambda_simple_code_00b7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00b7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00b7:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00d1:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00d1
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00d1
.L_tc_recycle_frame_done_00d1:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00b7:	; new closure is in rax
	mov qword [free_var_82], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00b8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00b8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00b8
.L_lambda_simple_env_end_00b8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00b8:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00b8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00b8
.L_lambda_simple_params_end_00b8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00b8
	jmp .L_lambda_simple_end_00b8
.L_lambda_simple_code_00b8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00b8
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00b8:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00d2:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00d2
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00d2
.L_tc_recycle_frame_done_00d2:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00b8:	; new closure is in rax
	mov qword [free_var_83], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00b9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00b9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00b9
.L_lambda_simple_env_end_00b9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00b9:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00b9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00b9
.L_lambda_simple_params_end_00b9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00b9
	jmp .L_lambda_simple_end_00b9
.L_lambda_simple_code_00b9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00b9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00b9:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_000d
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_005f
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_84]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00d3:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00d3
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00d3
.L_tc_recycle_frame_done_00d3:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_005f
          .L_if_else_005f:
          	mov rax, L_constants + 2
.L_if_end_005f:
.L_or_end_000d:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00b9:	; new closure is in rax
	mov qword [free_var_84], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0018:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0018
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0018
.L_lambda_opt_env_end_0018:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0018:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0018
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0018
.L_lambda_opt_params_end_0018:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0018
	jmp .L_lambda_opt_end_0018
.L_lambda_opt_code_0018:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0018
	jg .L_lambda_opt_arity_check_more_0018
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0018:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0046:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0046
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0046
.L_lambda_opt_stack_shrink_loop_exit_0046:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0018
.L_lambda_opt_arity_check_more_0018:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0047:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0047
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0047
.L_lambda_opt_stack_shrink_loop_exit_0047:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_0048:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0048
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0048
.L_lambda_opt_stack_shrink_loop_exit_0048:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0018:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0018:	; new closure is in rax
	mov qword [free_var_85], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00ba:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00ba
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00ba
.L_lambda_simple_env_end_00ba:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00ba:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00ba
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00ba
.L_lambda_simple_params_end_00ba:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00ba
	jmp .L_lambda_simple_end_00ba
.L_lambda_simple_code_00ba:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00ba
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00ba:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	cmp rax, sob_boolean_false
          	je .L_if_else_0060
          	mov rax, L_constants + 2
	jmp .L_if_end_0060
          .L_if_else_0060:
          	mov rax, L_constants + 3
.L_if_end_0060:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00ba:	; new closure is in rax
	mov qword [free_var_86], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00bb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00bb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00bb
.L_lambda_simple_env_end_00bb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00bb:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00bb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00bb
.L_lambda_simple_params_end_00bb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00bb
	jmp .L_lambda_simple_end_00bb
.L_lambda_simple_code_00bb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00bb
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00bb:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0061
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_28]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_86]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00d4:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00d4
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00d4
.L_tc_recycle_frame_done_00d4:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0061
          .L_if_else_0061:
          	mov rax, L_constants + 2
.L_if_end_0061:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00bb:	; new closure is in rax
	mov qword [free_var_87], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00bc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00bc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00bc
.L_lambda_simple_env_end_00bc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00bc:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00bc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00bc
.L_lambda_simple_params_end_00bc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00bc
	jmp .L_lambda_simple_end_00bc
.L_lambda_simple_code_00bc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00bc
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00bc:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00bd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00bd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00bd
.L_lambda_simple_env_end_00bd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00bd:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00bd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00bd
.L_lambda_simple_params_end_00bd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00bd
	jmp .L_lambda_simple_end_00bd
.L_lambda_simple_code_00bd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00bd
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00bd:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0062
          	mov rax, qword [rbp + 8 * (4 + 0)]
	jmp .L_if_end_0062
          .L_if_else_0062:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00d5:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00d5
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00d5
.L_tc_recycle_frame_done_00d5:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0062:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00bd:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0019:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0019
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0019
.L_lambda_opt_env_end_0019:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0019:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0019
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0019
.L_lambda_opt_params_end_0019:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0019
	jmp .L_lambda_opt_end_0019
.L_lambda_opt_code_0019:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0019
	jg .L_lambda_opt_arity_check_more_0019
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0019:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0049:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0049
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0049
.L_lambda_opt_stack_shrink_loop_exit_0049:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0019
.L_lambda_opt_arity_check_more_0019:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_004a:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_004a
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_004a
.L_lambda_opt_stack_shrink_loop_exit_004a:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_004b:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_004b
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_004b
.L_lambda_opt_stack_shrink_loop_exit_004b:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0019:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00d6:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00d6
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00d6
.L_tc_recycle_frame_done_00d6:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0019:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00bc:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_88], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00be:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00be
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00be
.L_lambda_simple_env_end_00be:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00be:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00be
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00be
.L_lambda_simple_params_end_00be:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00be
	jmp .L_lambda_simple_end_00be
.L_lambda_simple_code_00be:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00be
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00be:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00bf:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00bf
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00bf
.L_lambda_simple_env_end_00bf:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00bf:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00bf
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00bf
.L_lambda_simple_params_end_00bf:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00bf
	jmp .L_lambda_simple_end_00bf
.L_lambda_simple_code_00bf:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00bf
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00bf:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0063
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00d7:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00d7
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00d7
.L_tc_recycle_frame_done_00d7:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0063
          .L_if_else_0063:
          	mov rax, qword [rbp + 8 * (4 + 0)]
.L_if_end_0063:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00bf:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_001a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_001a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_001a
.L_lambda_opt_env_end_001a:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_001a:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_001a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_001a
.L_lambda_opt_params_end_001a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_001a
	jmp .L_lambda_opt_end_001a
.L_lambda_opt_code_001a:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_001a
	jg .L_lambda_opt_arity_check_more_001a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_001a:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_004c:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_004c
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_004c
.L_lambda_opt_stack_shrink_loop_exit_004c:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_001a
.L_lambda_opt_arity_check_more_001a:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_004d:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_004d
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_004d
.L_lambda_opt_stack_shrink_loop_exit_004d:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_004e:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_004e
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_004e
.L_lambda_opt_stack_shrink_loop_exit_004e:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_001a:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_29]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00d8:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00d8
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00d8
.L_tc_recycle_frame_done_00d8:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_001a:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00be:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_89], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_001b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_001b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_001b
.L_lambda_opt_env_end_001b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_001b:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_001b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_001b
.L_lambda_opt_params_end_001b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_001b
	jmp .L_lambda_opt_end_001b
.L_lambda_opt_code_001b:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_001b
	jg .L_lambda_opt_arity_check_more_001b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_001b:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_004f:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_004f
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_004f
.L_lambda_opt_stack_shrink_loop_exit_004f:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_001b
.L_lambda_opt_arity_check_more_001b:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0050:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0050
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0050
.L_lambda_opt_stack_shrink_loop_exit_0050:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0051:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0051
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0051
.L_lambda_opt_stack_shrink_loop_exit_0051:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_001b:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00c0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00c0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00c0
.L_lambda_simple_env_end_00c0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00c0:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_00c0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00c0
.L_lambda_simple_params_end_00c0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00c0
	jmp .L_lambda_simple_end_00c0
.L_lambda_simple_code_00c0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00c0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00c0:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00c1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_00c1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00c1
.L_lambda_simple_env_end_00c1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00c1:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00c1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00c1
.L_lambda_simple_params_end_00c1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00c1
	jmp .L_lambda_simple_end_00c1
.L_lambda_simple_code_00c1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00c1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00c1:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0064
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_000e
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00da:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00da
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00da
.L_tc_recycle_frame_done_00da:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_or_end_000e:
	jmp .L_if_end_0064
          .L_if_else_0064:
          	mov rax, L_constants + 2
.L_if_end_0064:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00c1:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00db:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00db
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00db
.L_tc_recycle_frame_done_00db:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00c0:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00d9:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00d9
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00d9
.L_tc_recycle_frame_done_00d9:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_001b:	; new closure is in rax
	mov qword [free_var_90], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_001c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_001c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_001c
.L_lambda_opt_env_end_001c:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_001c:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_001c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_001c
.L_lambda_opt_params_end_001c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_001c
	jmp .L_lambda_opt_end_001c
.L_lambda_opt_code_001c:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_001c
	jg .L_lambda_opt_arity_check_more_001c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_001c:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0052:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0052
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0052
.L_lambda_opt_stack_shrink_loop_exit_0052:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_001c
.L_lambda_opt_arity_check_more_001c:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0053:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0053
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0053
.L_lambda_opt_stack_shrink_loop_exit_0053:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0054:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0054
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0054
.L_lambda_opt_stack_shrink_loop_exit_0054:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_001c:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00c2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00c2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00c2
.L_lambda_simple_env_end_00c2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00c2:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_00c2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00c2
.L_lambda_simple_params_end_00c2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00c2
	jmp .L_lambda_simple_end_00c2
.L_lambda_simple_code_00c2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00c2
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00c2:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00c3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_00c3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00c3
.L_lambda_simple_env_end_00c3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00c3:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00c3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00c3
.L_lambda_simple_params_end_00c3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00c3
	jmp .L_lambda_simple_end_00c3
.L_lambda_simple_code_00c3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00c3
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00c3:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_000f
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0065
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00dd:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00dd
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00dd
.L_tc_recycle_frame_done_00dd:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0065
          .L_if_else_0065:
          	mov rax, L_constants + 2
.L_if_end_0065:
.L_or_end_000f:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00c3:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00de:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00de
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00de
.L_tc_recycle_frame_done_00de:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00c2:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00dc:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00dc
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00dc
.L_tc_recycle_frame_done_00dc:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_001c:	; new closure is in rax
	mov qword [free_var_92], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	mov rax, L_constants + 23
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00c4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00c4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00c4
.L_lambda_simple_env_end_00c4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00c4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00c4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00c4
.L_lambda_simple_params_end_00c4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00c4
	jmp .L_lambda_simple_end_00c4
.L_lambda_simple_code_00c4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00c4
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00c4:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8 * (4 + 1)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 1)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00c5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00c5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00c5
.L_lambda_simple_env_end_00c5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00c5:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_00c5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00c5
.L_lambda_simple_params_end_00c5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00c5
	jmp .L_lambda_simple_end_00c5
.L_lambda_simple_code_00c5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00c5
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00c5:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0066
          	mov rax, L_constants + 1
	jmp .L_if_end_0066
          .L_if_else_0066:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00df:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00df
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00df
.L_tc_recycle_frame_done_00df:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0066:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00c5:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00c6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00c6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00c6
.L_lambda_simple_env_end_00c6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00c6:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_00c6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00c6
.L_lambda_simple_params_end_00c6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00c6
	jmp .L_lambda_simple_end_00c6
.L_lambda_simple_code_00c6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00c6
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00c6:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0067
          	mov rax, L_constants + 1
	jmp .L_if_end_0067
          .L_if_else_0067:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00e0:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00e0
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00e0
.L_tc_recycle_frame_done_00e0:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0067:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00c6:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_001d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_001d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_001d
.L_lambda_opt_env_end_001d:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_001d:	; copy params
	cmp rsi, 2
	je .L_lambda_opt_params_end_001d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_001d
.L_lambda_opt_params_end_001d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_001d
	jmp .L_lambda_opt_end_001d
.L_lambda_opt_code_001d:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_001d
	jg .L_lambda_opt_arity_check_more_001d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_001d:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0055:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0055
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0055
.L_lambda_opt_stack_shrink_loop_exit_0055:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_001d
.L_lambda_opt_arity_check_more_001d:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0056:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0056
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0056
.L_lambda_opt_stack_shrink_loop_exit_0056:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0057:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0057
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0057
.L_lambda_opt_stack_shrink_loop_exit_0057:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_001d:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0068
          	mov rax, L_constants + 1
	jmp .L_if_end_0068
          .L_if_else_0068:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00e1:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00e1
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00e1
.L_tc_recycle_frame_done_00e1:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0068:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_001d:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00c4:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_91], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00c7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00c7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00c7
.L_lambda_simple_env_end_00c7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00c7:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00c7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00c7
.L_lambda_simple_params_end_00c7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00c7
	jmp .L_lambda_simple_end_00c7
.L_lambda_simple_code_00c7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00c7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00c7:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00c8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00c8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00c8
.L_lambda_simple_env_end_00c8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00c8:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00c8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00c8
.L_lambda_simple_params_end_00c8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00c8
	jmp .L_lambda_simple_end_00c8
.L_lambda_simple_code_00c8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00c8
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00c8:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0069
          	mov rax, qword [rbp + 8 * (4 + 1)]
	jmp .L_if_end_0069
          .L_if_else_0069:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00e2:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00e2
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00e2
.L_tc_recycle_frame_done_00e2:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0069:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00c8:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00c9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00c9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00c9
.L_lambda_simple_env_end_00c9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00c9:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00c9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00c9
.L_lambda_simple_params_end_00c9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00c9
	jmp .L_lambda_simple_end_00c9
.L_lambda_simple_code_00c9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00c9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00c9:
	enter 0, 0
	mov rax, L_constants + 1
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00e3:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00e3
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00e3
.L_tc_recycle_frame_done_00e3:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00c9:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00c7:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_93], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	mov rax, L_constants + 23
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00ca:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00ca
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00ca
.L_lambda_simple_env_end_00ca:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00ca:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00ca
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00ca
.L_lambda_simple_params_end_00ca:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00ca
	jmp .L_lambda_simple_end_00ca
.L_lambda_simple_code_00ca:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00ca
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00ca:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8 * (4 + 1)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 1)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00cb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00cb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00cb
.L_lambda_simple_env_end_00cb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00cb:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_00cb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00cb
.L_lambda_simple_params_end_00cb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00cb
	jmp .L_lambda_simple_end_00cb
.L_lambda_simple_code_00cb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00cb
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00cb:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_006a
          	mov rax, qword [rbp + 8 * (4 + 0)]
	jmp .L_if_end_006a
          .L_if_else_006a:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00e4:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00e4
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00e4
.L_tc_recycle_frame_done_00e4:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_006a:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00cb:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00cc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00cc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00cc
.L_lambda_simple_env_end_00cc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00cc:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_00cc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00cc
.L_lambda_simple_params_end_00cc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00cc
	jmp .L_lambda_simple_end_00cc
.L_lambda_simple_code_00cc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00cc
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00cc:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_006b
          	mov rax, qword [rbp + 8 * (4 + 1)]
	jmp .L_if_end_006b
          .L_if_else_006b:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00e5:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00e5
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00e5
.L_tc_recycle_frame_done_00e5:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_006b:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00cc:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_001e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_001e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_001e
.L_lambda_opt_env_end_001e:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_001e:	; copy params
	cmp rsi, 2
	je .L_lambda_opt_params_end_001e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_001e
.L_lambda_opt_params_end_001e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_001e
	jmp .L_lambda_opt_end_001e
.L_lambda_opt_code_001e:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_001e
	jg .L_lambda_opt_arity_check_more_001e
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_001e:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0058:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0058
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0058
.L_lambda_opt_stack_shrink_loop_exit_0058:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_001e
.L_lambda_opt_arity_check_more_001e:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0059:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0059
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0059
.L_lambda_opt_stack_shrink_loop_exit_0059:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_005a:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_005a
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_005a
.L_lambda_opt_stack_shrink_loop_exit_005a:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_001e:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_006c
          	mov rax, L_constants + 1
	jmp .L_if_end_006c
          .L_if_else_006c:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00e6:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00e6
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00e6
.L_tc_recycle_frame_done_00e6:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_006c:
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_001e:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00ca:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_94], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00cd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00cd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00cd
.L_lambda_simple_env_end_00cd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00cd:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00cd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00cd
.L_lambda_simple_params_end_00cd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00cd
	jmp .L_lambda_simple_end_00cd
.L_lambda_simple_code_00cd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00cd
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00cd:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00ce:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00ce
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00ce
.L_lambda_simple_env_end_00ce:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00ce:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00ce
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00ce
.L_lambda_simple_params_end_00ce:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00ce
	jmp .L_lambda_simple_end_00ce
.L_lambda_simple_code_00ce:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_00ce
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00ce:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_0]
	push rax
	push 2
	mov rax, qword [free_var_90]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_006d
          	mov rax, qword [rbp + 8 * (4 + 1)]
	jmp .L_if_end_006d
          .L_if_else_006d:
          	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00e7:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00e7
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00e7
.L_tc_recycle_frame_done_00e7:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_006d:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_00ce:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_001f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_001f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_001f
.L_lambda_opt_env_end_001f:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_001f:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_001f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_001f
.L_lambda_opt_params_end_001f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_001f
	jmp .L_lambda_opt_end_001f
.L_lambda_opt_code_001f:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_opt_arity_check_exact_001f
	jg .L_lambda_opt_arity_check_more_001f
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_001f:
	mov qword [rsp + 8 * 2], 3
	mov rdx, 5
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_005b:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_005b
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_005b
.L_lambda_opt_stack_shrink_loop_exit_005b:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_001f
.L_lambda_opt_arity_check_more_001f:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 2
	mov qword [rsp + 8 * 2], 3
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 2 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_005c:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_005c
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_005c
.L_lambda_opt_stack_shrink_loop_exit_005c:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 32
	mov rsi, 5
.L_lambda_opt_stack_shrink_loop_005d:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_005d
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_005d
.L_lambda_opt_stack_shrink_loop_exit_005d:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_001f:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00e8:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00e8
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00e8
.L_tc_recycle_frame_done_00e8:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 3)
.L_lambda_opt_end_001f:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00cd:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_95], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00cf:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00cf
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00cf
.L_lambda_simple_env_end_00cf:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00cf:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00cf
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00cf
.L_lambda_simple_params_end_00cf:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00cf
	jmp .L_lambda_simple_end_00cf
.L_lambda_simple_code_00cf:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00cf
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00cf:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00d0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00d0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00d0
.L_lambda_simple_env_end_00d0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00d0:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00d0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00d0
.L_lambda_simple_params_end_00d0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00d0
	jmp .L_lambda_simple_end_00d0
.L_lambda_simple_code_00d0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_00d0
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00d0:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_0]
	push rax
	push 2
	mov rax, qword [free_var_90]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_006e
          	mov rax, qword [rbp + 8 * (4 + 1)]
	jmp .L_if_end_006e
          .L_if_else_006e:
          	mov rax, L_constants + 1
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_94]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00e9:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00e9
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00e9
.L_tc_recycle_frame_done_00e9:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_006e:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_00d0:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0020:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0020
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0020
.L_lambda_opt_env_end_0020:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0020:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0020
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0020
.L_lambda_opt_params_end_0020:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0020
	jmp .L_lambda_opt_end_0020
.L_lambda_opt_code_0020:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_opt_arity_check_exact_0020
	jg .L_lambda_opt_arity_check_more_0020
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0020:
	mov qword [rsp + 8 * 2], 3
	mov rdx, 5
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_005e:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_005e
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_005e
.L_lambda_opt_stack_shrink_loop_exit_005e:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0020
.L_lambda_opt_arity_check_more_0020:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 2
	mov qword [rsp + 8 * 2], 3
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 2 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_005f:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_005f
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_005f
.L_lambda_opt_stack_shrink_loop_exit_005f:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 32
	mov rsi, 5
.L_lambda_opt_stack_shrink_loop_0060:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0060
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0060
.L_lambda_opt_stack_shrink_loop_exit_0060:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0020:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00ea:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00ea
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00ea
.L_tc_recycle_frame_done_00ea:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 3)
.L_lambda_opt_end_0020:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00cf:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_96], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00d4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00d4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00d4
.L_lambda_simple_env_end_00d4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00d4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00d4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00d4
.L_lambda_simple_params_end_00d4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00d4
	jmp .L_lambda_simple_end_00d4
.L_lambda_simple_code_00d4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_00d4
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00d4:
	enter 0, 0
	mov rax, L_constants + 68
	push rax
	mov rax, L_constants + 59
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00f4:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00f4
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00f4
.L_tc_recycle_frame_done_00f4:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_00d4:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00d1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00d1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00d1
.L_lambda_simple_env_end_00d1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00d1:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00d1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00d1
.L_lambda_simple_params_end_00d1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00d1
	jmp .L_lambda_simple_end_00d1
.L_lambda_simple_code_00d1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00d1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00d1:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00d3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00d3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00d3
.L_lambda_simple_env_end_00d3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00d3:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00d3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00d3
.L_lambda_simple_params_end_00d3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00d3
	jmp .L_lambda_simple_end_00d3
.L_lambda_simple_code_00d3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00d3
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00d3:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0074
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0070
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_34]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00ed:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00ed
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00ed
.L_tc_recycle_frame_done_00ed:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0070
          .L_if_else_0070:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_006f
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_30]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00ee:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00ee
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00ee
.L_tc_recycle_frame_done_00ee:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_006f
          .L_if_else_006f:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00ef:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00ef
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00ef
.L_tc_recycle_frame_done_00ef:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_006f:
.L_if_end_0070:
	jmp .L_if_end_0074
          .L_if_else_0074:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0073
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0072
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_30]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00f0:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00f0
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00f0
.L_tc_recycle_frame_done_00f0:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0072
          .L_if_else_0072:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0071
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_30]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00f1:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00f1
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00f1
.L_tc_recycle_frame_done_00f1:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0071
          .L_if_else_0071:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00f2:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00f2
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00f2
.L_tc_recycle_frame_done_00f2:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0071:
.L_if_end_0072:
	jmp .L_if_end_0073
          .L_if_else_0073:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00f3:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00f3
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00f3
.L_tc_recycle_frame_done_00f3:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0073:
.L_if_end_0074:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00d3:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00d2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00d2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00d2
.L_lambda_simple_env_end_00d2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00d2:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00d2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00d2
.L_lambda_simple_params_end_00d2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00d2
	jmp .L_lambda_simple_end_00d2
.L_lambda_simple_code_00d2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00d2
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00d2:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0021:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0021
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0021
.L_lambda_opt_env_end_0021:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0021:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0021
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0021
.L_lambda_opt_params_end_0021:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0021
	jmp .L_lambda_opt_end_0021
.L_lambda_opt_code_0021:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0021
	jg .L_lambda_opt_arity_check_more_0021
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0021:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0061:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0061
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0061
.L_lambda_opt_stack_shrink_loop_exit_0061:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0021
.L_lambda_opt_arity_check_more_0021:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0062:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0062
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0062
.L_lambda_opt_stack_shrink_loop_exit_0062:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_0063:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0063
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0063
.L_lambda_opt_stack_shrink_loop_exit_0063:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0021:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 32
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 3
	mov rax, qword [free_var_95]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00ec:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00ec
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00ec
.L_tc_recycle_frame_done_00ec:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0021:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00d2:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00eb:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00eb
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00eb
.L_tc_recycle_frame_done_00eb:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00d1:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_97], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00d9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00d9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00d9
.L_lambda_simple_env_end_00d9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00d9:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00d9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00d9
.L_lambda_simple_params_end_00d9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00d9
	jmp .L_lambda_simple_end_00d9
.L_lambda_simple_code_00d9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_00d9
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00d9:
	enter 0, 0
	mov rax, L_constants + 68
	push rax
	mov rax, L_constants + 119
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0100:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0100
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0100
.L_tc_recycle_frame_done_0100:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_00d9:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00d5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00d5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00d5
.L_lambda_simple_env_end_00d5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00d5:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00d5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00d5
.L_lambda_simple_params_end_00d5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00d5
	jmp .L_lambda_simple_end_00d5
.L_lambda_simple_code_00d5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00d5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00d5:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00d8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00d8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00d8
.L_lambda_simple_env_end_00d8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00d8:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00d8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00d8
.L_lambda_simple_params_end_00d8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00d8
	jmp .L_lambda_simple_end_00d8
.L_lambda_simple_code_00d8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00d8
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00d8:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_007b
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0077
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_35]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00f9:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00f9
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00f9
.L_tc_recycle_frame_done_00f9:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0077
          .L_if_else_0077:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0076
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_31]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00fa:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00fa
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00fa
.L_tc_recycle_frame_done_00fa:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0076
          .L_if_else_0076:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00fb:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00fb
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00fb
.L_tc_recycle_frame_done_00fb:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0076:
.L_if_end_0077:
	jmp .L_if_end_007b
          .L_if_else_007b:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_007a
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0079
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_31]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00fc:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00fc
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00fc
.L_tc_recycle_frame_done_00fc:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0079
          .L_if_else_0079:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0078
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_31]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00fd:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00fd
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00fd
.L_tc_recycle_frame_done_00fd:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0078
          .L_if_else_0078:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00fe:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00fe
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00fe
.L_tc_recycle_frame_done_00fe:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0078:
.L_if_end_0079:
	jmp .L_if_end_007a
          .L_if_else_007a:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00ff:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00ff
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00ff
.L_tc_recycle_frame_done_00ff:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_007a:
.L_if_end_007b:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00d8:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00d6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00d6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00d6
.L_lambda_simple_env_end_00d6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00d6:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00d6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00d6
.L_lambda_simple_params_end_00d6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00d6
	jmp .L_lambda_simple_end_00d6
.L_lambda_simple_code_00d6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00d6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00d6:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0022:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0022
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0022
.L_lambda_opt_env_end_0022:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0022:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0022
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0022
.L_lambda_opt_params_end_0022:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0022
	jmp .L_lambda_opt_end_0022
.L_lambda_opt_code_0022:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0022
	jg .L_lambda_opt_arity_check_more_0022
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0022:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0064:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0064
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0064
.L_lambda_opt_stack_shrink_loop_exit_0064:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0022
.L_lambda_opt_arity_check_more_0022:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0065:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0065
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0065
.L_lambda_opt_stack_shrink_loop_exit_0065:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0066:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0066
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0066
.L_lambda_opt_stack_shrink_loop_exit_0066:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0022:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0075
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 32
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00f6:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00f6
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00f6
.L_tc_recycle_frame_done_00f6:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0075
          .L_if_else_0075:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, L_constants + 32
	push rax
	mov rax, qword [free_var_97]
	push rax
	push 3
	mov rax, qword [free_var_95]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00d7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_00d7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00d7
.L_lambda_simple_env_end_00d7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00d7:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_00d7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00d7
.L_lambda_simple_params_end_00d7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00d7
	jmp .L_lambda_simple_end_00d7
.L_lambda_simple_code_00d7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00d7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00d7:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00f8:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00f8
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00f8
.L_tc_recycle_frame_done_00f8:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00d7:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00f7:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00f7
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00f7
.L_tc_recycle_frame_done_00f7:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0075:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0022:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00d6:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00f5:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00f5
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00f5
.L_tc_recycle_frame_done_00f5:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00d5:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_98], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00dd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00dd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00dd
.L_lambda_simple_env_end_00dd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00dd:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00dd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00dd
.L_lambda_simple_params_end_00dd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00dd
	jmp .L_lambda_simple_end_00dd
.L_lambda_simple_code_00dd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_00dd
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00dd:
	enter 0, 0
	mov rax, L_constants + 68
	push rax
	mov rax, L_constants + 155
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_010a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_010a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_010a
.L_tc_recycle_frame_done_010a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_00dd:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00da:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00da
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00da
.L_lambda_simple_env_end_00da:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00da:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00da
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00da
.L_lambda_simple_params_end_00da:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00da
	jmp .L_lambda_simple_end_00da
.L_lambda_simple_code_00da:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00da
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00da:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00dc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00dc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00dc
.L_lambda_simple_env_end_00dc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00dc:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00dc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00dc
.L_lambda_simple_params_end_00dc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00dc
	jmp .L_lambda_simple_end_00dc
.L_lambda_simple_code_00dc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00dc
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00dc:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0081
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_007d
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_36]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0103:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0103
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0103
.L_tc_recycle_frame_done_0103:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_007d
          .L_if_else_007d:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_007c
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_32]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0104:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0104
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0104
.L_tc_recycle_frame_done_0104:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_007c
          .L_if_else_007c:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0105:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0105
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0105
.L_tc_recycle_frame_done_0105:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_007c:
.L_if_end_007d:
	jmp .L_if_end_0081
          .L_if_else_0081:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0080
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_007f
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_32]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0106:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0106
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0106
.L_tc_recycle_frame_done_0106:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_007f
          .L_if_else_007f:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_007e
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_32]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0107:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0107
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0107
.L_tc_recycle_frame_done_0107:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_007e
          .L_if_else_007e:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0108:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0108
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0108
.L_tc_recycle_frame_done_0108:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_007e:
.L_if_end_007f:
	jmp .L_if_end_0080
          .L_if_else_0080:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0109:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0109
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0109
.L_tc_recycle_frame_done_0109:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0080:
.L_if_end_0081:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00dc:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00db:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00db
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00db
.L_lambda_simple_env_end_00db:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00db:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00db
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00db
.L_lambda_simple_params_end_00db:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00db
	jmp .L_lambda_simple_end_00db
.L_lambda_simple_code_00db:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00db
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00db:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0023:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0023
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0023
.L_lambda_opt_env_end_0023:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0023:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0023
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0023
.L_lambda_opt_params_end_0023:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0023
	jmp .L_lambda_opt_end_0023
.L_lambda_opt_code_0023:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0023
	jg .L_lambda_opt_arity_check_more_0023
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0023:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0067:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0067
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0067
.L_lambda_opt_stack_shrink_loop_exit_0067:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0023
.L_lambda_opt_arity_check_more_0023:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0068:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0068
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0068
.L_lambda_opt_stack_shrink_loop_exit_0068:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_0069:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0069
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0069
.L_lambda_opt_stack_shrink_loop_exit_0069:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0023:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 3
	mov rax, qword [free_var_95]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0102:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0102
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0102
.L_tc_recycle_frame_done_0102:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0023:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00db:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0101:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0101
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0101
.L_tc_recycle_frame_done_0101:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00da:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_99], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00e2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00e2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00e2
.L_lambda_simple_env_end_00e2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00e2:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00e2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00e2
.L_lambda_simple_params_end_00e2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00e2
	jmp .L_lambda_simple_end_00e2
.L_lambda_simple_code_00e2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_00e2
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00e2:
	enter 0, 0
	mov rax, L_constants + 68
	push rax
	mov rax, L_constants + 174
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0116:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0116
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0116
.L_tc_recycle_frame_done_0116:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_00e2:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00de:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00de
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00de
.L_lambda_simple_env_end_00de:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00de:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00de
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00de
.L_lambda_simple_params_end_00de:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00de
	jmp .L_lambda_simple_end_00de
.L_lambda_simple_code_00de:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00de
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00de:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00e1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00e1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00e1
.L_lambda_simple_env_end_00e1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00e1:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00e1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00e1
.L_lambda_simple_params_end_00e1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00e1
	jmp .L_lambda_simple_end_00e1
.L_lambda_simple_code_00e1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00e1
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00e1:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0088
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0084
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_37]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_010f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_010f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_010f
.L_tc_recycle_frame_done_010f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0084
          .L_if_else_0084:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0083
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_33]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0110:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0110
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0110
.L_tc_recycle_frame_done_0110:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0083
          .L_if_else_0083:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0111:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0111
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0111
.L_tc_recycle_frame_done_0111:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0083:
.L_if_end_0084:
	jmp .L_if_end_0088
          .L_if_else_0088:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0087
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0086
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_33]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0112:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0112
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0112
.L_tc_recycle_frame_done_0112:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0086
          .L_if_else_0086:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0085
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_33]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0113:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0113
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0113
.L_tc_recycle_frame_done_0113:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0085
          .L_if_else_0085:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0114:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0114
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0114
.L_tc_recycle_frame_done_0114:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0085:
.L_if_end_0086:
	jmp .L_if_end_0087
          .L_if_else_0087:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0115:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0115
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0115
.L_tc_recycle_frame_done_0115:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0087:
.L_if_end_0088:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00e1:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00df:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00df
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00df
.L_lambda_simple_env_end_00df:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00df:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00df
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00df
.L_lambda_simple_params_end_00df:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00df
	jmp .L_lambda_simple_end_00df
.L_lambda_simple_code_00df:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00df
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00df:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0024:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0024
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0024
.L_lambda_opt_env_end_0024:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0024:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0024
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0024
.L_lambda_opt_params_end_0024:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0024
	jmp .L_lambda_opt_end_0024
.L_lambda_opt_code_0024:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0024
	jg .L_lambda_opt_arity_check_more_0024
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0024:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_006a:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_006a
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_006a
.L_lambda_opt_stack_shrink_loop_exit_006a:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0024
.L_lambda_opt_arity_check_more_0024:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_006b:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_006b
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_006b
.L_lambda_opt_stack_shrink_loop_exit_006b:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_006c:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_006c
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_006c
.L_lambda_opt_stack_shrink_loop_exit_006c:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0024:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0082
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 128
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_010c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_010c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_010c
.L_tc_recycle_frame_done_010c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0082
          .L_if_else_0082:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [free_var_99]
	push rax
	push 3
	mov rax, qword [free_var_95]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00e0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_00e0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00e0
.L_lambda_simple_env_end_00e0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00e0:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_00e0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00e0
.L_lambda_simple_params_end_00e0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00e0
	jmp .L_lambda_simple_end_00e0
.L_lambda_simple_code_00e0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00e0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00e0:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_010e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_010e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_010e
.L_tc_recycle_frame_done_010e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00e0:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_010d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_010d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_010d
.L_tc_recycle_frame_done_010d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0082:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0024:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00df:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_010b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_010b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_010b
.L_tc_recycle_frame_done_010b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00de:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_100], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00e3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00e3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00e3
.L_lambda_simple_env_end_00e3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00e3:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00e3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00e3
.L_lambda_simple_params_end_00e3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00e3
	jmp .L_lambda_simple_end_00e3
.L_lambda_simple_code_00e3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00e3
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00e3:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0089
          	mov rax, L_constants + 128
	jmp .L_if_end_0089
          .L_if_else_0089:
          	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_101]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_99]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0117:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0117
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0117
.L_tc_recycle_frame_done_0117:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0089:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00e3:	; new closure is in rax
	mov qword [free_var_101], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_102], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_103], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_104], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_105], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_106], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00f4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00f4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00f4
.L_lambda_simple_env_end_00f4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00f4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00f4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00f4
.L_lambda_simple_params_end_00f4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00f4
	jmp .L_lambda_simple_end_00f4
.L_lambda_simple_code_00f4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_00f4
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00f4:
	enter 0, 0
	mov rax, L_constants + 219
	push rax
	mov rax, L_constants + 210
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_012b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_012b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_012b
.L_tc_recycle_frame_done_012b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_00f4:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00e4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00e4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00e4
.L_lambda_simple_env_end_00e4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00e4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00e4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00e4
.L_lambda_simple_params_end_00e4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00e4
	jmp .L_lambda_simple_end_00e4
.L_lambda_simple_code_00e4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00e4
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00e4:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00f2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00f2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00f2
.L_lambda_simple_env_end_00f2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00f2:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00f2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00f2
.L_lambda_simple_params_end_00f2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00f2
	jmp .L_lambda_simple_end_00f2
.L_lambda_simple_code_00f2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00f2
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00f2:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00f3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_00f3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00f3
.L_lambda_simple_env_end_00f3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00f3:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_00f3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00f3
.L_lambda_simple_params_end_00f3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00f3
	jmp .L_lambda_simple_end_00f3
.L_lambda_simple_code_00f3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00f3
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00f3:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0090
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_008c
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0125:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0125
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0125
.L_tc_recycle_frame_done_0125:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_008c
          .L_if_else_008c:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_008b
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0126:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0126
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0126
.L_tc_recycle_frame_done_0126:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_008b
          .L_if_else_008b:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0127:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0127
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0127
.L_tc_recycle_frame_done_0127:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_008b:
.L_if_end_008c:
	jmp .L_if_end_0090
          .L_if_else_0090:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_008f
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_008e
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0128:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0128
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0128
.L_tc_recycle_frame_done_0128:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_008e
          .L_if_else_008e:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_008d
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0129:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0129
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0129
.L_tc_recycle_frame_done_0129:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_008d
          .L_if_else_008d:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_012a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_012a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_012a
.L_tc_recycle_frame_done_012a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_008d:
.L_if_end_008e:
	jmp .L_if_end_008f
          .L_if_else_008f:
          	mov rax, L_constants + 0
.L_if_end_008f:
.L_if_end_0090:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00f3:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00f2:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00e5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00e5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00e5
.L_lambda_simple_env_end_00e5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00e5:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00e5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00e5
.L_lambda_simple_params_end_00e5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00e5
	jmp .L_lambda_simple_end_00e5
.L_lambda_simple_code_00e5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00e5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00e5:
	enter 0, 0
	mov rax, qword [free_var_39]
	push rax
	mov rax, qword [free_var_40]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00e6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_00e6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00e6
.L_lambda_simple_env_end_00e6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00e6:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00e6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00e6
.L_lambda_simple_params_end_00e6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00e6
	jmp .L_lambda_simple_end_00e6
.L_lambda_simple_code_00e6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00e6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00e6:
	enter 0, 0
	mov rax, qword [free_var_41]
	push rax
	mov rax, qword [free_var_42]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00e7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_00e7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00e7
.L_lambda_simple_env_end_00e7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00e7:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00e7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00e7
.L_lambda_simple_params_end_00e7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00e7
	jmp .L_lambda_simple_end_00e7
.L_lambda_simple_code_00e7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00e7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00e7:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00f1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_00f1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00f1
.L_lambda_simple_env_end_00f1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00f1:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00f1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00f1
.L_lambda_simple_params_end_00f1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00f1
	jmp .L_lambda_simple_end_00f1
.L_lambda_simple_code_00f1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00f1
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00f1:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_86]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0124:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0124
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0124
.L_tc_recycle_frame_done_0124:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00f1:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00e8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_00e8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00e8
.L_lambda_simple_env_end_00e8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00e8:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00e8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00e8
.L_lambda_simple_params_end_00e8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00e8
	jmp .L_lambda_simple_end_00e8
.L_lambda_simple_code_00e8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00e8
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00e8:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 6	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00f0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 5
	je .L_lambda_simple_env_end_00f0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00f0
.L_lambda_simple_env_end_00f0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00f0:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00f0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00f0
.L_lambda_simple_params_end_00f0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00f0
	jmp .L_lambda_simple_end_00f0
.L_lambda_simple_code_00f0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00f0
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00f0:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0123:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0123
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0123
.L_tc_recycle_frame_done_0123:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00f0:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 6	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00e9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 5
	je .L_lambda_simple_env_end_00e9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00e9
.L_lambda_simple_env_end_00e9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00e9:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00e9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00e9
.L_lambda_simple_params_end_00e9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00e9
	jmp .L_lambda_simple_end_00e9
.L_lambda_simple_code_00e9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00e9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00e9:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 7	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00ef:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 6
	je .L_lambda_simple_env_end_00ef
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00ef
.L_lambda_simple_env_end_00ef:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00ef:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00ef
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00ef
.L_lambda_simple_params_end_00ef:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00ef
	jmp .L_lambda_simple_end_00ef
.L_lambda_simple_code_00ef:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00ef
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00ef:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_86]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0122:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0122
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0122
.L_tc_recycle_frame_done_0122:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00ef:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 7	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00ea:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 6
	je .L_lambda_simple_env_end_00ea
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00ea
.L_lambda_simple_env_end_00ea:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00ea:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00ea
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00ea
.L_lambda_simple_params_end_00ea:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00ea
	jmp .L_lambda_simple_end_00ea
.L_lambda_simple_code_00ea:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00ea
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00ea:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 8	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00ec:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 7
	je .L_lambda_simple_env_end_00ec
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00ec
.L_lambda_simple_env_end_00ec:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00ec:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00ec
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00ec
.L_lambda_simple_params_end_00ec:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00ec
	jmp .L_lambda_simple_end_00ec
.L_lambda_simple_code_00ec:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00ec
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00ec:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 9	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00ed:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 8
	je .L_lambda_simple_env_end_00ed
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00ed
.L_lambda_simple_env_end_00ed:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00ed:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00ed
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00ed
.L_lambda_simple_params_end_00ed:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00ed
	jmp .L_lambda_simple_end_00ed
.L_lambda_simple_code_00ed:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00ed
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00ed:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 10	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00ee:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 9
	je .L_lambda_simple_env_end_00ee
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00ee
.L_lambda_simple_env_end_00ee:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00ee:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00ee
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00ee
.L_lambda_simple_params_end_00ee:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00ee
	jmp .L_lambda_simple_end_00ee
.L_lambda_simple_code_00ee:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00ee
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00ee:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0010
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_008a
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0120:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0120
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0120
.L_tc_recycle_frame_done_0120:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_008a
          .L_if_else_008a:
          	mov rax, L_constants + 2
.L_if_end_008a:
.L_or_end_0010:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00ee:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 10	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0025:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 9
	je .L_lambda_opt_env_end_0025
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0025
.L_lambda_opt_env_end_0025:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0025:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0025
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0025
.L_lambda_opt_params_end_0025:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0025
	jmp .L_lambda_opt_end_0025
.L_lambda_opt_code_0025:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0025
	jg .L_lambda_opt_arity_check_more_0025
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0025:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_006d:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_006d
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_006d
.L_lambda_opt_stack_shrink_loop_exit_006d:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0025
.L_lambda_opt_arity_check_more_0025:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_006e:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_006e
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_006e
.L_lambda_opt_stack_shrink_loop_exit_006e:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_006f:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_006f
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_006f
.L_lambda_opt_stack_shrink_loop_exit_006f:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0025:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0121:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0121
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0121
.L_tc_recycle_frame_done_0121:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0025:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00ed:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_011f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_011f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_011f
.L_tc_recycle_frame_done_011f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00ec:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 8	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00eb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 7
	je .L_lambda_simple_env_end_00eb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00eb
.L_lambda_simple_env_end_00eb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00eb:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00eb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00eb
.L_lambda_simple_params_end_00eb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00eb
	jmp .L_lambda_simple_end_00eb
.L_lambda_simple_code_00eb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00eb
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00eb:
	enter 0, 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 4]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_102], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_103], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_104], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_105], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 3]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_106], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00eb:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_011e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_011e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_011e
.L_tc_recycle_frame_done_011e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00ea:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_011d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_011d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_011d
.L_tc_recycle_frame_done_011d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00e9:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_011c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_011c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_011c
.L_tc_recycle_frame_done_011c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00e8:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_011b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_011b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_011b
.L_tc_recycle_frame_done_011b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00e7:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_011a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_011a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_011a
.L_tc_recycle_frame_done_011a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00e6:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0119:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0119
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0119
.L_tc_recycle_frame_done_0119:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00e5:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0118:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0118
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0118
.L_tc_recycle_frame_done_0118:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00e4:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00f5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00f5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00f5
.L_lambda_simple_env_end_00f5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00f5:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00f5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00f5
.L_lambda_simple_params_end_00f5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00f5
	jmp .L_lambda_simple_end_00f5
.L_lambda_simple_code_00f5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00f5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00f5:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00f6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00f6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00f6
.L_lambda_simple_env_end_00f6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00f6:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00f6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00f6
.L_lambda_simple_params_end_00f6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00f6
	jmp .L_lambda_simple_end_00f6
.L_lambda_simple_code_00f6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_00f6
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00f6:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0091
          	mov rax, L_constants + 1
	jmp .L_if_end_0091
          .L_if_else_0091:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_012c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_012c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_012c
.L_tc_recycle_frame_done_012c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0091:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_00f6:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0026:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0026
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0026
.L_lambda_opt_env_end_0026:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0026:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0026
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0026
.L_lambda_opt_params_end_0026:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0026
	jmp .L_lambda_opt_end_0026
.L_lambda_opt_code_0026:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0026
	jg .L_lambda_opt_arity_check_more_0026
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0026:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0070:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0070
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0070
.L_lambda_opt_stack_shrink_loop_exit_0070:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0026
.L_lambda_opt_arity_check_more_0026:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0071:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0071
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0071
.L_lambda_opt_stack_shrink_loop_exit_0071:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0072:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0072
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0072
.L_lambda_opt_stack_shrink_loop_exit_0072:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0026:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0095
          	mov rax, L_constants + 4
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_012d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_012d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_012d
.L_tc_recycle_frame_done_012d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0095
          .L_if_else_0095:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0093
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0092
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_3]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0092
          .L_if_else_0092:
          	mov rax, L_constants + 2
.L_if_end_0092:
	jmp .L_if_end_0093
          .L_if_else_0093:
          	mov rax, L_constants + 2
.L_if_end_0093:
	cmp rax, sob_boolean_false
          	je .L_if_else_0094
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_012e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_012e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_012e
.L_tc_recycle_frame_done_012e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0094
          .L_if_else_0094:
          	mov rax, L_constants + 288
	push rax
	mov rax, L_constants + 279
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_012f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_012f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_012f
.L_tc_recycle_frame_done_012f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0094:
.L_if_end_0095:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0026:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00f5:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_107], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_108], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_109], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_110], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_111], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_112], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00f8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00f8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00f8
.L_lambda_simple_env_end_00f8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00f8:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00f8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00f8
.L_lambda_simple_params_end_00f8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00f8
	jmp .L_lambda_simple_end_00f8
.L_lambda_simple_code_00f8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00f8
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00f8:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0027:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0027
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0027
.L_lambda_opt_env_end_0027:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0027:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0027
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0027
.L_lambda_opt_params_end_0027:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0027
	jmp .L_lambda_opt_end_0027
.L_lambda_opt_code_0027:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0027
	jg .L_lambda_opt_arity_check_more_0027
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0027:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0073:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0073
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0073
.L_lambda_opt_stack_shrink_loop_exit_0073:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0027
.L_lambda_opt_arity_check_more_0027:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0074:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0074
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0074
.L_lambda_opt_stack_shrink_loop_exit_0074:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_0075:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0075
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0075
.L_lambda_opt_stack_shrink_loop_exit_0075:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0027:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_24]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0130:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0130
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0130
.L_tc_recycle_frame_done_0130:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0027:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00f8:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00f7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00f7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00f7
.L_lambda_simple_env_end_00f7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00f7:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00f7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00f7
.L_lambda_simple_params_end_00f7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00f7
	jmp .L_lambda_simple_end_00f7
.L_lambda_simple_code_00f7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00f7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00f7:
	enter 0, 0
	mov rax, qword [free_var_102]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_108], rax
	mov rax, sob_void

	mov rax, qword [free_var_103]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_109], rax
	mov rax, sob_void

	mov rax, qword [free_var_106]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_110], rax
	mov rax, sob_void

	mov rax, qword [free_var_104]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_111], rax
	mov rax, sob_void

	mov rax, qword [free_var_105]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_112], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00f7:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_113], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_114], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 342
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, L_constants + 346
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00f9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00f9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00f9
.L_lambda_simple_env_end_00f9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00f9:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00f9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00f9
.L_lambda_simple_params_end_00f9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00f9
	jmp .L_lambda_simple_end_00f9
.L_lambda_simple_code_00f9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00f9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00f9:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00fa:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00fa
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00fa
.L_lambda_simple_env_end_00fa:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00fa:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00fa
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00fa
.L_lambda_simple_params_end_00fa:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00fa
	jmp .L_lambda_simple_end_00fa
.L_lambda_simple_code_00fa:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00fa
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00fa:
	enter 0, 0
	mov rax, L_constants + 344
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 342
	push rax
	push 3
	mov rax, qword [free_var_109]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0096
          	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_25]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0131:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0131
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0131
.L_tc_recycle_frame_done_0131:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0096
          .L_if_else_0096:
          	mov rax, qword [rbp + 8 * (4 + 0)]
.L_if_end_0096:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00fa:	; new closure is in rax
	mov qword [free_var_113], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00fb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_00fb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00fb
.L_lambda_simple_env_end_00fb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00fb:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00fb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00fb
.L_lambda_simple_params_end_00fb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00fb
	jmp .L_lambda_simple_end_00fb
.L_lambda_simple_code_00fb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00fb
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00fb:
	enter 0, 0
	mov rax, L_constants + 348
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 346
	push rax
	push 3
	mov rax, qword [free_var_109]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0097
          	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_25]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0132:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0132
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0132
.L_tc_recycle_frame_done_0132:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0097
          .L_if_else_0097:
          	mov rax, qword [rbp + 8 * (4 + 0)]
.L_if_end_0097:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00fb:	; new closure is in rax
	mov qword [free_var_114], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00f9:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_115], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_116], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_117], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_118], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_119], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00fd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00fd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00fd
.L_lambda_simple_env_end_00fd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00fd:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00fd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00fd
.L_lambda_simple_params_end_00fd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00fd
	jmp .L_lambda_simple_end_00fd
.L_lambda_simple_code_00fd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00fd
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00fd:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0028:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0028
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0028
.L_lambda_opt_env_end_0028:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0028:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0028
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0028
.L_lambda_opt_params_end_0028:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0028
	jmp .L_lambda_opt_end_0028
.L_lambda_opt_code_0028:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0028
	jg .L_lambda_opt_arity_check_more_0028
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0028:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0076:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0076
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0076
.L_lambda_opt_stack_shrink_loop_exit_0076:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0028
.L_lambda_opt_arity_check_more_0028:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0077:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0077
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0077
.L_lambda_opt_stack_shrink_loop_exit_0077:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_0078:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0078
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0078
.L_lambda_opt_stack_shrink_loop_exit_0078:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0028:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00fe:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_00fe
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00fe
.L_lambda_simple_env_end_00fe:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00fe:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_00fe
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00fe
.L_lambda_simple_params_end_00fe:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00fe
	jmp .L_lambda_simple_end_00fe
.L_lambda_simple_code_00fe:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00fe
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00fe:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_113]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0134:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0134
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0134
.L_tc_recycle_frame_done_0134:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00fe:	; new closure is in rax
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0133:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0133
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0133
.L_tc_recycle_frame_done_0133:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0028:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00fd:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00fc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00fc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00fc
.L_lambda_simple_env_end_00fc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00fc:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00fc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00fc
.L_lambda_simple_params_end_00fc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00fc
	jmp .L_lambda_simple_end_00fc
.L_lambda_simple_code_00fc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00fc
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00fc:
	enter 0, 0
	mov rax, qword [free_var_102]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_115], rax
	mov rax, sob_void

	mov rax, qword [free_var_103]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_116], rax
	mov rax, sob_void

	mov rax, qword [free_var_106]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_117], rax
	mov rax, sob_void

	mov rax, qword [free_var_104]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_118], rax
	mov rax, sob_void

	mov rax, qword [free_var_105]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_119], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00fc:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_120], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_121], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0100:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0100
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0100
.L_lambda_simple_env_end_0100:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0100:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0100
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0100
.L_lambda_simple_params_end_0100:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0100
	jmp .L_lambda_simple_end_0100
.L_lambda_simple_code_0100:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0100
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0100:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0101:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0101
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0101
.L_lambda_simple_env_end_0101:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0101:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0101
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0101
.L_lambda_simple_params_end_0101:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0101
	jmp .L_lambda_simple_end_0101
.L_lambda_simple_code_0101:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0101
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0101:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_123]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_122]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0135:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0135
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0135
.L_tc_recycle_frame_done_0135:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0101:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0100:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_00ff:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_00ff
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_00ff
.L_lambda_simple_env_end_00ff:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_00ff:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_00ff
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_00ff
.L_lambda_simple_params_end_00ff:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_00ff
	jmp .L_lambda_simple_end_00ff
.L_lambda_simple_code_00ff:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_00ff
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_00ff:
	enter 0, 0
	mov rax, qword [free_var_113]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_120], rax
	mov rax, sob_void

	mov rax, qword [free_var_114]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_121], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_00ff:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_124], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_125], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_126], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_127], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_128], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_129], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_130], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_131], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_132], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_133], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0103:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0103
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0103
.L_lambda_simple_env_end_0103:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0103:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0103
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0103
.L_lambda_simple_params_end_0103:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0103
	jmp .L_lambda_simple_end_0103
.L_lambda_simple_code_0103:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0103
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0103:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0104:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0104
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0104
.L_lambda_simple_env_end_0104:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0104:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0104
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0104
.L_lambda_simple_params_end_0104:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0104
	jmp .L_lambda_simple_end_0104
.L_lambda_simple_code_0104:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0104
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0104:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0105:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0105
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0105
.L_lambda_simple_env_end_0105:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0105:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0105
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0105
.L_lambda_simple_params_end_0105:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0105
	jmp .L_lambda_simple_end_0105
.L_lambda_simple_code_0105:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 5
	je .L_lambda_simple_arity_check_ok_0105
	push qword [rsp + 8 * 2]
	push 5
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0105:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0098
          	mov rax, qword [rbp + 8 * (4 + 4)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0098
          .L_if_else_0098:
          	mov rax, L_constants + 2
.L_if_end_0098:
	cmp rax, sob_boolean_false
	jne .L_or_end_0011
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_009a
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0012
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0099
          	mov rax, qword [rbp + 8 * (4 + 4)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 5 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0137:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0137
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0137
.L_tc_recycle_frame_done_0137:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0099
          .L_if_else_0099:
          	mov rax, L_constants + 2
.L_if_end_0099:
.L_or_end_0012:
	jmp .L_if_end_009a
          .L_if_else_009a:
          	mov rax, L_constants + 2
.L_if_end_009a:
.L_or_end_0011:
	leave
	ret 8 * (2 + 5)
.L_lambda_simple_end_0105:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0109:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0109
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0109
.L_lambda_simple_env_end_0109:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0109:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0109
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0109
.L_lambda_simple_params_end_0109:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0109
	jmp .L_lambda_simple_end_0109
.L_lambda_simple_code_0109:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0109
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0109:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_010a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_010a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_010a
.L_lambda_simple_env_end_010a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_010a:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_010a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_010a
.L_lambda_simple_params_end_010a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_010a
	jmp .L_lambda_simple_end_010a
.L_lambda_simple_code_010a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_010a
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_010a:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_103]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_009c
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, L_constants + 32
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 5 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_013d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_013d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_013d
.L_tc_recycle_frame_done_013d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_009c
          .L_if_else_009c:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, L_constants + 32
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 5 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_013e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_013e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_013e
.L_tc_recycle_frame_done_013e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_009c:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_010a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_013c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_013c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_013c
.L_tc_recycle_frame_done_013c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0109:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0106:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0106
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0106
.L_lambda_simple_env_end_0106:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0106:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0106
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0106
.L_lambda_simple_params_end_0106:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0106
	jmp .L_lambda_simple_end_0106
.L_lambda_simple_code_0106:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0106
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0106:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0107:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_0107
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0107
.L_lambda_simple_env_end_0107:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0107:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0107
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0107
.L_lambda_simple_params_end_0107:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0107
	jmp .L_lambda_simple_end_0107
.L_lambda_simple_code_0107:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0107
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0107:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0108:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_0108
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0108
.L_lambda_simple_env_end_0108:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0108:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0108
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0108
.L_lambda_simple_params_end_0108:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0108
	jmp .L_lambda_simple_end_0108
.L_lambda_simple_code_0108:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0108
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0108:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0013
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_009b
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_013a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_013a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_013a
.L_tc_recycle_frame_done_013a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_009b
          .L_if_else_009b:
          	mov rax, L_constants + 2
.L_if_end_009b:
.L_or_end_0013:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0108:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0029:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_0029
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0029
.L_lambda_opt_env_end_0029:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0029:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0029
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0029
.L_lambda_opt_params_end_0029:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0029
	jmp .L_lambda_opt_end_0029
.L_lambda_opt_code_0029:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0029
	jg .L_lambda_opt_arity_check_more_0029
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0029:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0079:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0079
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0079
.L_lambda_opt_stack_shrink_loop_exit_0079:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0029
.L_lambda_opt_arity_check_more_0029:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_007a:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_007a
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_007a
.L_lambda_opt_stack_shrink_loop_exit_007a:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_007b:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_007b
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_007b
.L_lambda_opt_stack_shrink_loop_exit_007b:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0029:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_013b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_013b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_013b
.L_tc_recycle_frame_done_013b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0029:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0107:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0139:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0139
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0139
.L_tc_recycle_frame_done_0139:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0106:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0138:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0138
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0138
.L_tc_recycle_frame_done_0138:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0104:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0136:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0136
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0136
.L_tc_recycle_frame_done_0136:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0103:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0102:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0102
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0102
.L_lambda_simple_env_end_0102:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0102:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0102
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0102
.L_lambda_simple_params_end_0102:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0102
	jmp .L_lambda_simple_end_0102
.L_lambda_simple_code_0102:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0102
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0102:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_124], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_115]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_129], rax
	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_111]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_128], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_118]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_133], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0102:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_010c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_010c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_010c
.L_lambda_simple_env_end_010c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_010c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_010c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_010c
.L_lambda_simple_params_end_010c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_010c
	jmp .L_lambda_simple_end_010c
.L_lambda_simple_code_010c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_010c
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_010c:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_010d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_010d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_010d
.L_lambda_simple_env_end_010d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_010d:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_010d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_010d
.L_lambda_simple_params_end_010d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_010d
	jmp .L_lambda_simple_end_010d
.L_lambda_simple_code_010d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_010d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_010d:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_010e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_010e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_010e
.L_lambda_simple_env_end_010e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_010e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_010e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_010e
.L_lambda_simple_params_end_010e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_010e
	jmp .L_lambda_simple_end_010e
.L_lambda_simple_code_010e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 5
	je .L_lambda_simple_arity_check_ok_010e
	push qword [rsp + 8 * 2]
	push 5
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_010e:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0014
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0014
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_009e
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_009d
          	mov rax, qword [rbp + 8 * (4 + 4)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 5 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0140:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0140
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0140
.L_tc_recycle_frame_done_0140:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_009d
          .L_if_else_009d:
          	mov rax, L_constants + 2
.L_if_end_009d:
	jmp .L_if_end_009e
          .L_if_else_009e:
          	mov rax, L_constants + 2
.L_if_end_009e:
.L_or_end_0014:
	leave
	ret 8 * (2 + 5)
.L_lambda_simple_end_010e:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0112:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0112
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0112
.L_lambda_simple_env_end_0112:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0112:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0112
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0112
.L_lambda_simple_params_end_0112:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0112
	jmp .L_lambda_simple_end_0112
.L_lambda_simple_code_0112:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0112
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0112:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0113:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_0113
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0113
.L_lambda_simple_env_end_0113:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0113:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0113
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0113
.L_lambda_simple_params_end_0113:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0113
	jmp .L_lambda_simple_end_0113
.L_lambda_simple_code_0113:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0113
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0113:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_103]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00a0
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, L_constants + 32
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 5 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0146:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0146
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0146
.L_tc_recycle_frame_done_0146:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00a0
          .L_if_else_00a0:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, L_constants + 32
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 5 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0147:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0147
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0147
.L_tc_recycle_frame_done_0147:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_00a0:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0113:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0145:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0145
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0145
.L_tc_recycle_frame_done_0145:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0112:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_010f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_010f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_010f
.L_lambda_simple_env_end_010f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_010f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_010f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_010f
.L_lambda_simple_params_end_010f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_010f
	jmp .L_lambda_simple_end_010f
.L_lambda_simple_code_010f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_010f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_010f:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0110:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_0110
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0110
.L_lambda_simple_env_end_0110:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0110:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0110
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0110
.L_lambda_simple_params_end_0110:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0110
	jmp .L_lambda_simple_end_0110
.L_lambda_simple_code_0110:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0110
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0110:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0111:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_0111
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0111
.L_lambda_simple_env_end_0111:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0111:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0111
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0111
.L_lambda_simple_params_end_0111:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0111
	jmp .L_lambda_simple_end_0111
.L_lambda_simple_code_0111:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0111
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0111:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0015
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_009f
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0143:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0143
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0143
.L_tc_recycle_frame_done_0143:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_009f
          .L_if_else_009f:
          	mov rax, L_constants + 2
.L_if_end_009f:
.L_or_end_0015:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0111:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_002a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_002a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_002a
.L_lambda_opt_env_end_002a:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_002a:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_002a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_002a
.L_lambda_opt_params_end_002a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_002a
	jmp .L_lambda_opt_end_002a
.L_lambda_opt_code_002a:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_002a
	jg .L_lambda_opt_arity_check_more_002a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_002a:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_007c:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_007c
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_007c
.L_lambda_opt_stack_shrink_loop_exit_007c:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_002a
.L_lambda_opt_arity_check_more_002a:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_007d:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_007d
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_007d
.L_lambda_opt_stack_shrink_loop_exit_007d:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_007e:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_007e
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_007e
.L_lambda_opt_stack_shrink_loop_exit_007e:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_002a:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0144:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0144
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0144
.L_tc_recycle_frame_done_0144:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_002a:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0110:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0142:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0142
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0142
.L_tc_recycle_frame_done_0142:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_010f:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0141:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0141
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0141
.L_tc_recycle_frame_done_0141:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_010d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_013f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_013f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_013f
.L_tc_recycle_frame_done_013f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_010c:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_010b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_010b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_010b
.L_lambda_simple_env_end_010b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_010b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_010b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_010b
.L_lambda_simple_params_end_010b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_010b
	jmp .L_lambda_simple_end_010b
.L_lambda_simple_code_010b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_010b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_010b:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_125], rax
	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_130], rax
	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_111]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_127], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_118]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_132], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_010b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0115:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0115
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0115
.L_lambda_simple_env_end_0115:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0115:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0115
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0115
.L_lambda_simple_params_end_0115:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0115
	jmp .L_lambda_simple_end_0115
.L_lambda_simple_code_0115:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0115
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0115:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0116:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0116
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0116
.L_lambda_simple_env_end_0116:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0116:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0116
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0116
.L_lambda_simple_params_end_0116:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0116
	jmp .L_lambda_simple_end_0116
.L_lambda_simple_code_0116:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0116
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0116:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0117:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0117
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0117
.L_lambda_simple_env_end_0117:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0117:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0117
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0117
.L_lambda_simple_params_end_0117:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0117
	jmp .L_lambda_simple_end_0117
.L_lambda_simple_code_0117:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 4
	je .L_lambda_simple_arity_check_ok_0117
	push qword [rsp + 8 * 2]
	push 4
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0117:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0016
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00a2
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00a1
          	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 4
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 4 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0149:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0149
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0149
.L_tc_recycle_frame_done_0149:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00a1
          .L_if_else_00a1:
          	mov rax, L_constants + 2
.L_if_end_00a1:
	jmp .L_if_end_00a2
          .L_if_else_00a2:
          	mov rax, L_constants + 2
.L_if_end_00a2:
.L_or_end_0016:
	leave
	ret 8 * (2 + 4)
.L_lambda_simple_end_0117:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_011b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_011b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_011b
.L_lambda_simple_env_end_011b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_011b:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_011b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_011b
.L_lambda_simple_params_end_011b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_011b
	jmp .L_lambda_simple_end_011b
.L_lambda_simple_code_011b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_011b
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_011b:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_011c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_011c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_011c
.L_lambda_simple_env_end_011c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_011c:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_011c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_011c
.L_lambda_simple_params_end_011c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_011c
	jmp .L_lambda_simple_end_011c
.L_lambda_simple_code_011c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_011c
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_011c:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00a4
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, L_constants + 32
	push rax
	push 4
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 4 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_014f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_014f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_014f
.L_tc_recycle_frame_done_014f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00a4
          .L_if_else_00a4:
          	mov rax, L_constants + 2
.L_if_end_00a4:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_011c:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_014e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_014e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_014e
.L_tc_recycle_frame_done_014e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_011b:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0118:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0118
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0118
.L_lambda_simple_env_end_0118:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0118:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0118
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0118
.L_lambda_simple_params_end_0118:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0118
	jmp .L_lambda_simple_end_0118
.L_lambda_simple_code_0118:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0118
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0118:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0119:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_0119
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0119
.L_lambda_simple_env_end_0119:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0119:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0119
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0119
.L_lambda_simple_params_end_0119:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0119
	jmp .L_lambda_simple_end_0119
.L_lambda_simple_code_0119:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0119
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0119:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_011a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_011a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_011a
.L_lambda_simple_env_end_011a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_011a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_011a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_011a
.L_lambda_simple_params_end_011a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_011a
	jmp .L_lambda_simple_end_011a
.L_lambda_simple_code_011a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_011a
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_011a:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0017
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00a3
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_014c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_014c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_014c
.L_tc_recycle_frame_done_014c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00a3
          .L_if_else_00a3:
          	mov rax, L_constants + 2
.L_if_end_00a3:
.L_or_end_0017:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_011a:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_002b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_002b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_002b
.L_lambda_opt_env_end_002b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_002b:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_002b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_002b
.L_lambda_opt_params_end_002b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_002b
	jmp .L_lambda_opt_end_002b
.L_lambda_opt_code_002b:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_002b
	jg .L_lambda_opt_arity_check_more_002b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_002b:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_007f:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_007f
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_007f
.L_lambda_opt_stack_shrink_loop_exit_007f:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_002b
.L_lambda_opt_arity_check_more_002b:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0080:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0080
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0080
.L_lambda_opt_stack_shrink_loop_exit_0080:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0081:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0081
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0081
.L_lambda_opt_stack_shrink_loop_exit_0081:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_002b:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_014d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_014d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_014d
.L_tc_recycle_frame_done_014d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_002b:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0119:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_014b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_014b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_014b
.L_tc_recycle_frame_done_014b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0118:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_014a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_014a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_014a
.L_tc_recycle_frame_done_014a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0116:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0148:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0148
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0148
.L_tc_recycle_frame_done_0148:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0115:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0114:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0114
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0114
.L_lambda_simple_env_end_0114:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0114:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0114
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0114
.L_lambda_simple_params_end_0114:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0114
	jmp .L_lambda_simple_end_0114
.L_lambda_simple_code_0114:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0114
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0114:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_126], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_131], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0114:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_011d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_011d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_011d
.L_lambda_simple_env_end_011d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_011d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_011d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_011d
.L_lambda_simple_params_end_011d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_011d
	jmp .L_lambda_simple_end_011d
.L_lambda_simple_code_011d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_011d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_011d:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00a5
          	mov rax, L_constants + 32
	jmp .L_if_end_00a5
          .L_if_else_00a5:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_134]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, L_constants + 128
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0150:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0150
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0150
.L_tc_recycle_frame_done_0150:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_00a5:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_011d:	; new closure is in rax
	mov qword [free_var_134], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_011e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_011e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_011e
.L_lambda_simple_env_end_011e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_011e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_011e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_011e
.L_lambda_simple_params_end_011e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_011e
	jmp .L_lambda_simple_end_011e
.L_lambda_simple_code_011e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_011e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_011e:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0018
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00a6
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_84]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0151:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0151
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0151
.L_tc_recycle_frame_done_0151:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00a6
          .L_if_else_00a6:
          	mov rax, L_constants + 2
.L_if_end_00a6:
.L_or_end_0018:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_011e:	; new closure is in rax
	mov qword [free_var_84], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword [free_var_51]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_011f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_011f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_011f
.L_lambda_simple_env_end_011f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_011f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_011f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_011f
.L_lambda_simple_params_end_011f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_011f
	jmp .L_lambda_simple_end_011f
.L_lambda_simple_code_011f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_011f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_011f:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_002c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_002c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_002c
.L_lambda_opt_env_end_002c:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_002c:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_002c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_002c
.L_lambda_opt_params_end_002c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_002c
	jmp .L_lambda_opt_end_002c
.L_lambda_opt_code_002c:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_002c
	jg .L_lambda_opt_arity_check_more_002c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_002c:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0082:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0082
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0082
.L_lambda_opt_stack_shrink_loop_exit_0082:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_002c
.L_lambda_opt_arity_check_more_002c:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0083:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0083
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0083
.L_lambda_opt_stack_shrink_loop_exit_0083:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0084:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0084
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0084
.L_lambda_opt_stack_shrink_loop_exit_0084:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_002c:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00a9
          	mov rax, L_constants + 0
	jmp .L_if_end_00a9
          .L_if_else_00a9:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00a7
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00a7
          .L_if_else_00a7:
          	mov rax, L_constants + 2
.L_if_end_00a7:
	cmp rax, sob_boolean_false
          	je .L_if_else_00a8
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00a8
          .L_if_else_00a8:
          	mov rax, L_constants + 379
	push rax
	mov rax, L_constants + 370
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
.L_if_end_00a8:
.L_if_end_00a9:
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0120:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0120
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0120
.L_lambda_simple_env_end_0120:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0120:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0120
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0120
.L_lambda_simple_params_end_0120:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0120
	jmp .L_lambda_simple_end_0120
.L_lambda_simple_code_0120:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0120
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0120:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0153:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0153
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0153
.L_tc_recycle_frame_done_0153:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0120:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0152:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0152
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0152
.L_tc_recycle_frame_done_0152:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_002c:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_011f:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_51], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword [free_var_52]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0121:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0121
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0121
.L_lambda_simple_env_end_0121:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0121:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0121
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0121
.L_lambda_simple_params_end_0121:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0121
	jmp .L_lambda_simple_end_0121
.L_lambda_simple_code_0121:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0121
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0121:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_002d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_002d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_002d
.L_lambda_opt_env_end_002d:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_002d:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_002d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_002d
.L_lambda_opt_params_end_002d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_002d
	jmp .L_lambda_opt_end_002d
.L_lambda_opt_code_002d:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_002d
	jg .L_lambda_opt_arity_check_more_002d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_002d:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0085:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0085
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0085
.L_lambda_opt_stack_shrink_loop_exit_0085:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_002d
.L_lambda_opt_arity_check_more_002d:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0086:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0086
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0086
.L_lambda_opt_stack_shrink_loop_exit_0086:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0087:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0087
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0087
.L_lambda_opt_stack_shrink_loop_exit_0087:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_002d:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00ac
          	mov rax, L_constants + 4
	jmp .L_if_end_00ac
          .L_if_else_00ac:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00aa
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00aa
          .L_if_else_00aa:
          	mov rax, L_constants + 2
.L_if_end_00aa:
	cmp rax, sob_boolean_false
          	je .L_if_else_00ab
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00ab
          .L_if_else_00ab:
          	mov rax, L_constants + 460
	push rax
	mov rax, L_constants + 451
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
.L_if_end_00ab:
.L_if_end_00ac:
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0122:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0122
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0122
.L_lambda_simple_env_end_0122:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0122:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0122
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0122
.L_lambda_simple_params_end_0122:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0122
	jmp .L_lambda_simple_end_0122
.L_lambda_simple_code_0122:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0122
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0122:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0155:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0155
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0155
.L_tc_recycle_frame_done_0155:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0122:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0154:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0154
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0154
.L_tc_recycle_frame_done_0154:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_002d:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0121:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_52], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0123:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0123
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0123
.L_lambda_simple_env_end_0123:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0123:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0123
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0123
.L_lambda_simple_params_end_0123:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0123
	jmp .L_lambda_simple_end_0123
.L_lambda_simple_code_0123:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0123
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0123:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0124:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0124
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0124
.L_lambda_simple_env_end_0124:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0124:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0124
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0124
.L_lambda_simple_params_end_0124:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0124
	jmp .L_lambda_simple_end_0124
.L_lambda_simple_code_0124:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0124
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0124:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00ad
          	mov rax, L_constants + 0
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_51]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0156:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0156
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0156
.L_tc_recycle_frame_done_0156:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00ad
          .L_if_else_00ad:
          	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0125:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0125
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0125
.L_lambda_simple_env_end_0125:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0125:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0125
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0125
.L_lambda_simple_params_end_0125:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0125
	jmp .L_lambda_simple_end_0125
.L_lambda_simple_code_0125:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0125
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0125:
	enter 0, 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [free_var_49]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rax, qword [rbp + 8 * (4 + 0)]
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0125:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0157:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0157
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0157
.L_tc_recycle_frame_done_0157:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_00ad:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0124:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0126:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0126
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0126
.L_lambda_simple_env_end_0126:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0126:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0126
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0126
.L_lambda_simple_params_end_0126:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0126
	jmp .L_lambda_simple_end_0126
.L_lambda_simple_code_0126:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0126
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0126:
	enter 0, 0
	mov rax, L_constants + 32
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0158:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0158
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0158
.L_tc_recycle_frame_done_0158:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0126:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0123:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_135], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0127:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0127
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0127
.L_lambda_simple_env_end_0127:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0127:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0127
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0127
.L_lambda_simple_params_end_0127:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0127
	jmp .L_lambda_simple_end_0127
.L_lambda_simple_code_0127:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0127
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0127:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0128:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0128
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0128
.L_lambda_simple_env_end_0128:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0128:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0128
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0128
.L_lambda_simple_params_end_0128:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0128
	jmp .L_lambda_simple_end_0128
.L_lambda_simple_code_0128:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0128
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0128:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00ae
          	mov rax, L_constants + 4
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_52]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0159:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0159
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0159
.L_tc_recycle_frame_done_0159:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00ae
          .L_if_else_00ae:
          	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0129:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0129
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0129
.L_lambda_simple_env_end_0129:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0129:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0129
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0129
.L_lambda_simple_params_end_0129:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0129
	jmp .L_lambda_simple_end_0129
.L_lambda_simple_code_0129:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0129
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0129:
	enter 0, 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [free_var_50]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rax, qword [rbp + 8 * (4 + 0)]
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0129:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_015a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_015a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_015a
.L_tc_recycle_frame_done_015a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_00ae:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0128:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_012a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_012a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_012a
.L_lambda_simple_env_end_012a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_012a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_012a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_012a
.L_lambda_simple_params_end_012a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_012a
	jmp .L_lambda_simple_end_012a
.L_lambda_simple_code_012a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_012a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_012a:
	enter 0, 0
	mov rax, L_constants + 32
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_015b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_015b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_015b
.L_tc_recycle_frame_done_015b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_012a:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0127:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_122], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_002e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_002e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_002e
.L_lambda_opt_env_end_002e:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_002e:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_002e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_002e
.L_lambda_opt_params_end_002e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_002e
	jmp .L_lambda_opt_end_002e
.L_lambda_opt_code_002e:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_002e
	jg .L_lambda_opt_arity_check_more_002e
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_002e:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0088:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0088
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0088
.L_lambda_opt_stack_shrink_loop_exit_0088:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_002e
.L_lambda_opt_arity_check_more_002e:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0089:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0089
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0089
.L_lambda_opt_stack_shrink_loop_exit_0089:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_008a:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_008a
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_008a
.L_lambda_opt_stack_shrink_loop_exit_008a:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_002e:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_135]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_015c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_015c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_015c
.L_tc_recycle_frame_done_015c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_002e:	; new closure is in rax
	mov qword [free_var_136], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_012b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_012b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_012b
.L_lambda_simple_env_end_012b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_012b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_012b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_012b
.L_lambda_simple_params_end_012b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_012b
	jmp .L_lambda_simple_end_012b
.L_lambda_simple_code_012b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_012b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_012b:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_012c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_012c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_012c
.L_lambda_simple_env_end_012c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_012c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_012c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_012c
.L_lambda_simple_params_end_012c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_012c
	jmp .L_lambda_simple_end_012c
.L_lambda_simple_code_012c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_012c
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_012c:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00af
          	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_015d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_015d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_015d
.L_tc_recycle_frame_done_015d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00af
          .L_if_else_00af:
          	mov rax, L_constants + 1
.L_if_end_00af:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_012c:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_012d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_012d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_012d
.L_lambda_simple_env_end_012d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_012d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_012d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_012d
.L_lambda_simple_params_end_012d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_012d
	jmp .L_lambda_simple_end_012d
.L_lambda_simple_code_012d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_012d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_012d:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, L_constants + 32
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_015e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_015e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_015e
.L_tc_recycle_frame_done_015e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_012d:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_012b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_123], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_012e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_012e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_012e
.L_lambda_simple_env_end_012e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_012e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_012e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_012e
.L_lambda_simple_params_end_012e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_012e
	jmp .L_lambda_simple_end_012e
.L_lambda_simple_code_012e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_012e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_012e:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_012f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_012f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_012f
.L_lambda_simple_env_end_012f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_012f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_012f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_012f
.L_lambda_simple_params_end_012f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_012f
	jmp .L_lambda_simple_end_012f
.L_lambda_simple_code_012f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_012f
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_012f:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00b0
          	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_48]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_015f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_015f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_015f
.L_tc_recycle_frame_done_015f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00b0
          .L_if_else_00b0:
          	mov rax, L_constants + 1
.L_if_end_00b0:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_012f:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0130:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0130
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0130
.L_lambda_simple_env_end_0130:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0130:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0130
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0130
.L_lambda_simple_params_end_0130:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0130
	jmp .L_lambda_simple_end_0130
.L_lambda_simple_code_0130:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0130
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0130:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_19]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, L_constants + 32
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0160:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0160
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0160
.L_tc_recycle_frame_done_0160:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0130:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_012e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_137], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0131:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0131
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0131
.L_lambda_simple_env_end_0131:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0131:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0131
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0131
.L_lambda_simple_params_end_0131:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0131
	jmp .L_lambda_simple_end_0131
.L_lambda_simple_code_0131:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0131
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0131:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 0
	mov rax, qword [free_var_26]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_44]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0161:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0161
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0161
.L_tc_recycle_frame_done_0161:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0131:	; new closure is in rax
	mov qword [free_var_138], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0132:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0132
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0132
.L_lambda_simple_env_end_0132:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0132:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0132
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0132
.L_lambda_simple_params_end_0132:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0132
	jmp .L_lambda_simple_end_0132
.L_lambda_simple_code_0132:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0132
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0132:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 32
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0162:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0162
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0162
.L_tc_recycle_frame_done_0162:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0132:	; new closure is in rax
	mov qword [free_var_139], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0133:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0133
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0133
.L_lambda_simple_env_end_0133:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0133:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0133
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0133
.L_lambda_simple_params_end_0133:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0133
	jmp .L_lambda_simple_end_0133
.L_lambda_simple_code_0133:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0133
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0133:
	enter 0, 0
	mov rax, L_constants + 32
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0163:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0163
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0163
.L_tc_recycle_frame_done_0163:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0133:	; new closure is in rax
	mov qword [free_var_140], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0134:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0134
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0134
.L_lambda_simple_env_end_0134:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0134:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0134
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0134
.L_lambda_simple_params_end_0134:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0134
	jmp .L_lambda_simple_end_0134
.L_lambda_simple_code_0134:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0134
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0134:
	enter 0, 0
	mov rax, L_constants + 512
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_44]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0164:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0164
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0164
.L_tc_recycle_frame_done_0164:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0134:	; new closure is in rax
	mov qword [free_var_141], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0135:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0135
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0135
.L_lambda_simple_env_end_0135:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0135:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0135
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0135
.L_lambda_simple_params_end_0135:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0135
	jmp .L_lambda_simple_end_0135
.L_lambda_simple_code_0135:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0135
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0135:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_141]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_86]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0165:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0165
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0165
.L_tc_recycle_frame_done_0165:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0135:	; new closure is in rax
	mov qword [free_var_142], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0136:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0136
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0136
.L_lambda_simple_env_end_0136:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0136:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0136
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0136
.L_lambda_simple_params_end_0136:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0136
	jmp .L_lambda_simple_end_0136
.L_lambda_simple_code_0136:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0136
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0136:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_140]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00b1
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0166:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0166
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0166
.L_tc_recycle_frame_done_0166:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00b1
          .L_if_else_00b1:
          	mov rax, qword [rbp + 8 * (4 + 0)]
.L_if_end_00b1:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0136:	; new closure is in rax
	mov qword [free_var_143], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0137:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0137
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0137
.L_lambda_simple_env_end_0137:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0137:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0137
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0137
.L_lambda_simple_params_end_0137:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0137
	jmp .L_lambda_simple_end_0137
.L_lambda_simple_code_0137:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0137
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0137:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00b2
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00b2
          .L_if_else_00b2:
          	mov rax, L_constants + 2
.L_if_end_00b2:
	cmp rax, sob_boolean_false
          	je .L_if_else_00ba
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_144]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00b3
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_144]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0167:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0167
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0167
.L_tc_recycle_frame_done_0167:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00b3
          .L_if_else_00b3:
          	mov rax, L_constants + 2
.L_if_end_00b3:
	jmp .L_if_end_00ba
          .L_if_else_00ba:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_6]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00b5
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_6]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00b4
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_19]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_19]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00b4
          .L_if_else_00b4:
          	mov rax, L_constants + 2
.L_if_end_00b4:
	jmp .L_if_end_00b5
          .L_if_else_00b5:
          	mov rax, L_constants + 2
.L_if_end_00b5:
	cmp rax, sob_boolean_false
          	je .L_if_else_00b9
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_137]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_137]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_144]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0168:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0168
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0168
.L_tc_recycle_frame_done_0168:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00b9
          .L_if_else_00b9:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_4]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00b7
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_4]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00b6
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00b6
          .L_if_else_00b6:
          	mov rax, L_constants + 2
.L_if_end_00b6:
	jmp .L_if_end_00b7
          .L_if_else_00b7:
          	mov rax, L_constants + 2
.L_if_end_00b7:
	cmp rax, sob_boolean_false
          	je .L_if_else_00b8
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_126]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0169:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0169
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0169
.L_tc_recycle_frame_done_0169:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00b8
          .L_if_else_00b8:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_55]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_016a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_016a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_016a
.L_tc_recycle_frame_done_016a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_00b8:
.L_if_end_00b9:
.L_if_end_00ba:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0137:	; new closure is in rax
	mov qword [free_var_144], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0138:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0138
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0138
.L_lambda_simple_env_end_0138:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0138:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0138
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0138
.L_lambda_simple_params_end_0138:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0138
	jmp .L_lambda_simple_end_0138
.L_lambda_simple_code_0138:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0138
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0138:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00bc
          	mov rax, L_constants + 2
	jmp .L_if_end_00bc
          .L_if_else_00bc:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_55]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_00bb
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_016b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_016b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_016b
.L_tc_recycle_frame_done_016b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_00bb
          .L_if_else_00bb:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_145]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, [rbp]
	mov rdi, rbp
.L_tc_recycle_frame_loop_016c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_016c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_016c
.L_tc_recycle_frame_done_016c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_00bb:
.L_if_end_00bc:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0138:	; new closure is in rax
	mov qword [free_var_145], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 512
	push rax
	mov rax, L_constants + 128
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

        mov rdi, fmt_memory_usage
        mov rsi, qword [top_of_memory]
        sub rsi, memory
        mov rax, 0
	ENTER
        call printf
	LEAVE
	leave
	ret

L_error_non_closure:
        mov rdi, qword [stderr]
        mov rsi, fmt_non_closure
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -2
        call exit

L_error_improper_list:
	mov rdi, qword [stderr]
	mov rsi, fmt_error_improper_list
	mov rax, 0
	ENTER
	call fprintf
	LEAVE
	mov rax, -7
	call exit

L_error_incorrect_arity_simple:
        mov rdi, qword [stderr]
        mov rsi, fmt_incorrect_arity_simple
        jmp L_error_incorrect_arity_common
L_error_incorrect_arity_opt:
        mov rdi, qword [stderr]
        mov rsi, fmt_incorrect_arity_opt
L_error_incorrect_arity_common:
        pop rdx
        pop rcx
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -6
        call exit

section .data
fmt_incorrect_arity_simple:
        db `!!! Expected %ld arguments, but given %ld\n\0`
fmt_incorrect_arity_opt:
        db `!!! Expected at least %ld arguments, but given %ld\n\0`
fmt_memory_usage:
        db `\n\n!!! Used %ld bytes of dynamically-allocated memory\n\n\0`
fmt_non_closure:
        db `!!! Attempting to apply a non-closure!\n\0`
fmt_error_improper_list:
	db `!!! The argument is not a proper list!\n\0`

section .bss
memory:
	resb gbytes(1)

section .data
top_of_memory:
        dq memory

section .text
malloc:
        mov rax, qword [top_of_memory]
        add qword [top_of_memory], rdi
        ret
        
print_sexpr_if_not_void:
	cmp rdi, sob_void
	jne print_sexpr
	ret

section .data
fmt_void:
	db `#<void>\0`
fmt_nil:
	db `()\0`
fmt_boolean_false:
	db `#f\0`
fmt_boolean_true:
	db `#t\0`
fmt_char_backslash:
	db `#\\\\\0`
fmt_char_dquote:
	db `#\\"\0`
fmt_char_simple:
	db `#\\%c\0`
fmt_char_null:
	db `#\\nul\0`
fmt_char_bell:
	db `#\\bell\0`
fmt_char_backspace:
	db `#\\backspace\0`
fmt_char_tab:
	db `#\\tab\0`
fmt_char_newline:
	db `#\\newline\0`
fmt_char_formfeed:
	db `#\\page\0`
fmt_char_return:
	db `#\\return\0`
fmt_char_escape:
	db `#\\esc\0`
fmt_char_space:
	db `#\\space\0`
fmt_char_hex:
	db `#\\x%02X\0`
fmt_closure:
	db `#<closure at 0x%08X env=0x%08X code=0x%08X>\0`
fmt_lparen:
	db `(\0`
fmt_dotted_pair:
	db ` . \0`
fmt_rparen:
	db `)\0`
fmt_space:
	db ` \0`
fmt_empty_vector:
	db `#()\0`
fmt_vector:
	db `#(\0`
fmt_real:
	db `%f\0`
fmt_fraction:
	db `%ld/%ld\0`
fmt_zero:
	db `0\0`
fmt_int:
	db `%ld\0`
fmt_unknown_sexpr_error:
	db `\n\n!!! Error: Unknown type of sexpr (0x%02X) `
	db `at address 0x%08X\n\n\0`
fmt_dquote:
	db `\"\0`
fmt_string_char:
        db `%c\0`
fmt_string_char_7:
        db `\\a\0`
fmt_string_char_8:
        db `\\b\0`
fmt_string_char_9:
        db `\\t\0`
fmt_string_char_10:
        db `\\n\0`
fmt_string_char_11:
        db `\\v\0`
fmt_string_char_12:
        db `\\f\0`
fmt_string_char_13:
        db `\\r\0`
fmt_string_char_34:
        db `\\"\0`
fmt_string_char_92:
        db `\\\\\0`
fmt_string_char_hex:
        db `\\x%X;\0`

section .text

print_sexpr:
	ENTER
	mov al, byte [rdi]
	cmp al, T_void
	je .Lvoid
	cmp al, T_nil
	je .Lnil
	cmp al, T_boolean_false
	je .Lboolean_false
	cmp al, T_boolean_true
	je .Lboolean_true
	cmp al, T_char
	je .Lchar
	cmp al, T_symbol
	je .Lsymbol
	cmp al, T_pair
	je .Lpair
	cmp al, T_vector
	je .Lvector
	cmp al, T_closure
	je .Lclosure
	cmp al, T_real
	je .Lreal
	cmp al, T_rational
	je .Lrational
	cmp al, T_string
	je .Lstring

	jmp .Lunknown_sexpr_type

.Lvoid:
	mov rdi, fmt_void
	jmp .Lemit

.Lnil:
	mov rdi, fmt_nil
	jmp .Lemit

.Lboolean_false:
	mov rdi, fmt_boolean_false
	jmp .Lemit

.Lboolean_true:
	mov rdi, fmt_boolean_true
	jmp .Lemit

.Lchar:
	mov al, byte [rdi + 1]
	cmp al, ' '
	jle .Lchar_whitespace
	cmp al, 92 		; backslash
	je .Lchar_backslash
	cmp al, '"'
	je .Lchar_dquote
	and rax, 255
	mov rdi, fmt_char_simple
	mov rsi, rax
	jmp .Lemit

.Lchar_whitespace:
	cmp al, 0
	je .Lchar_null
	cmp al, 7
	je .Lchar_bell
	cmp al, 8
	je .Lchar_backspace
	cmp al, 9
	je .Lchar_tab
	cmp al, 10
	je .Lchar_newline
	cmp al, 12
	je .Lchar_formfeed
	cmp al, 13
	je .Lchar_return
	cmp al, 27
	je .Lchar_escape
	and rax, 255
	cmp al, ' '
	je .Lchar_space
	mov rdi, fmt_char_hex
	mov rsi, rax
	jmp .Lemit	

.Lchar_backslash:
	mov rdi, fmt_char_backslash
	jmp .Lemit

.Lchar_dquote:
	mov rdi, fmt_char_dquote
	jmp .Lemit

.Lchar_null:
	mov rdi, fmt_char_null
	jmp .Lemit

.Lchar_bell:
	mov rdi, fmt_char_bell
	jmp .Lemit

.Lchar_backspace:
	mov rdi, fmt_char_backspace
	jmp .Lemit

.Lchar_tab:
	mov rdi, fmt_char_tab
	jmp .Lemit

.Lchar_newline:
	mov rdi, fmt_char_newline
	jmp .Lemit

.Lchar_formfeed:
	mov rdi, fmt_char_formfeed
	jmp .Lemit

.Lchar_return:
	mov rdi, fmt_char_return
	jmp .Lemit

.Lchar_escape:
	mov rdi, fmt_char_escape
	jmp .Lemit

.Lchar_space:
	mov rdi, fmt_char_space
	jmp .Lemit

.Lclosure:
	mov rsi, qword rdi
	mov rdi, fmt_closure
	mov rdx, SOB_CLOSURE_ENV(rsi)
	mov rcx, SOB_CLOSURE_CODE(rsi)
	jmp .Lemit

.Lsymbol:
	mov rdi, qword [rdi + 1] ; sob_string
	mov rsi, 1		 ; size = 1 byte
	mov rdx, qword [rdi + 1] ; length
	lea rdi, [rdi + 1 + 8]	 ; actual characters
	mov rcx, qword [stdout]	 ; FILE *
	call fwrite
	jmp .Lend
	
.Lpair:
	push rdi
	mov rdi, fmt_lparen
	mov rax, 0
        ENTER
	call printf
        LEAVE
	mov rdi, qword [rsp] 	; pair
	mov rdi, SOB_PAIR_CAR(rdi)
	call print_sexpr
	pop rdi 		; pair
	mov rdi, SOB_PAIR_CDR(rdi)
.Lcdr:
	mov al, byte [rdi]
	cmp al, T_nil
	je .Lcdr_nil
	cmp al, T_pair
	je .Lcdr_pair
	push rdi
	mov rdi, fmt_dotted_pair
	mov rax, 0
	ENTER
	call printf
	LEAVE
	pop rdi
	call print_sexpr
	mov rdi, fmt_rparen
	mov rax, 0
	ENTER
	call printf
	LEAVE
	LEAVE
	ret

.Lcdr_nil:
	mov rdi, fmt_rparen
	mov rax, 0
	ENTER
	call printf
	LEAVE
	LEAVE
	ret

.Lcdr_pair:
	push rdi
	mov rdi, fmt_space
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rdi, qword [rsp]
	mov rdi, SOB_PAIR_CAR(rdi)
	call print_sexpr
	pop rdi
	mov rdi, SOB_PAIR_CDR(rdi)
	jmp .Lcdr

.Lvector:
	mov rax, qword [rdi + 1] ; length
	cmp rax, 0
	je .Lvector_empty
	push rdi
	mov rdi, fmt_vector
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rdi, qword [rsp]
	push qword [rdi + 1]
	push 1
	mov rdi, qword [rdi + 1 + 8] ; v[0]
	call print_sexpr
.Lvector_loop:
	; [rsp] index
	; [rsp + 8*1] limit
	; [rsp + 8*2] vector
	mov rax, qword [rsp]
	cmp rax, qword [rsp + 8*1]
	je .Lvector_end
	mov rdi, fmt_space
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rax, qword [rsp]
	mov rbx, qword [rsp + 8*2]
	mov rdi, qword [rbx + 1 + 8 + 8 * rax] ; v[i]
	call print_sexpr
	inc qword [rsp]
	jmp .Lvector_loop

.Lvector_end:
	add rsp, 8*3
	mov rdi, fmt_rparen
	jmp .Lemit	

.Lvector_empty:
	mov rdi, fmt_empty_vector
	jmp .Lemit

.Lreal:
	push qword [rdi + 1]
	movsd xmm0, qword [rsp]
	add rsp, 8*1
	mov rdi, fmt_real
	mov rax, 1
	ENTER
	call printf
	LEAVE
	jmp .Lend

.Lrational:
	mov rsi, qword [rdi + 1]
	mov rdx, qword [rdi + 1 + 8]
	cmp rsi, 0
	je .Lrat_zero
	cmp rdx, 1
	je .Lrat_int
	mov rdi, fmt_fraction
	jmp .Lemit

.Lrat_zero:
	mov rdi, fmt_zero
	jmp .Lemit

.Lrat_int:
	mov rdi, fmt_int
	jmp .Lemit

.Lstring:
	lea rax, [rdi + 1 + 8]
	push rax
	push qword [rdi + 1]
	mov rdi, fmt_dquote
	mov rax, 0
	ENTER
	call printf
	LEAVE
.Lstring_loop:
	; qword [rsp]: limit
	; qword [rsp + 8*1]: char *
	cmp qword [rsp], 0
	je .Lstring_end
	mov rax, qword [rsp + 8*1]
	mov al, byte [rax]
	and rax, 255
	cmp al, 7
        je .Lstring_char_7
        cmp al, 8
        je .Lstring_char_8
        cmp al, 9
        je .Lstring_char_9
        cmp al, 10
        je .Lstring_char_10
        cmp al, 11
        je .Lstring_char_11
        cmp al, 12
        je .Lstring_char_12
        cmp al, 13
        je .Lstring_char_13
        cmp al, 34
        je .Lstring_char_34
        cmp al, 92              ; \
        je .Lstring_char_92
        cmp al, ' '
        jl .Lstring_char_hex
        mov rdi, fmt_string_char
        mov rsi, rax
.Lstring_char_emit:
        mov rax, 0
        ENTER
        call printf
        LEAVE
        dec qword [rsp]
        inc qword [rsp + 8*1]
        jmp .Lstring_loop

.Lstring_char_7:
        mov rdi, fmt_string_char_7
        jmp .Lstring_char_emit

.Lstring_char_8:
        mov rdi, fmt_string_char_8
        jmp .Lstring_char_emit
        
.Lstring_char_9:
        mov rdi, fmt_string_char_9
        jmp .Lstring_char_emit

.Lstring_char_10:
        mov rdi, fmt_string_char_10
        jmp .Lstring_char_emit

.Lstring_char_11:
        mov rdi, fmt_string_char_11
        jmp .Lstring_char_emit

.Lstring_char_12:
        mov rdi, fmt_string_char_12
        jmp .Lstring_char_emit

.Lstring_char_13:
        mov rdi, fmt_string_char_13
        jmp .Lstring_char_emit

.Lstring_char_34:
        mov rdi, fmt_string_char_34
        jmp .Lstring_char_emit

.Lstring_char_92:
        mov rdi, fmt_string_char_92
        jmp .Lstring_char_emit

.Lstring_char_hex:
        mov rdi, fmt_string_char_hex
        mov rsi, rax
        jmp .Lstring_char_emit        

.Lstring_end:
	add rsp, 8 * 2
	mov rdi, fmt_dquote
	jmp .Lemit

.Lunknown_sexpr_type:
	mov rsi, fmt_unknown_sexpr_error
	and rax, 255
	mov rdx, rax
	mov rcx, rdi
	mov rdi, qword [stderr]
	mov rax, 0
	ENTER
	call fprintf
	LEAVE
	mov rax, -1
	call exit

.Lemit:
	mov rax, 0
	ENTER
	call printf
	LEAVE
	jmp .Lend

.Lend:
	LEAVE
	ret

;;; rdi: address of free variable
;;; rsi: address of code-pointer
bind_primitive:
        ENTER
        push rdi
        mov rdi, (1 + 8 + 8)
        call malloc
        pop rdi
        mov byte [rax], T_closure
        mov SOB_CLOSURE_ENV(rax), 0 ; dummy, lexical environment
        mov SOB_CLOSURE_CODE(rax), rsi ; code pointer
        mov qword [rdi], rax
        LEAVE
        ret

;;; PLEASE IMPLEMENT THIS PROCEDURE
L_code_ptr_bin_apply:
	enter 0, 0 ; mov rbp, rsp  push rbp
	cmp COUNT, 2 ;check if number of arguments are 2 - closure and list
	jne L_error_arg_count_2
	mov rax, PARAM(0) ;first argument - closure
        cmp byte [rax], T_closure
        jne L_error_non_closure
        mov rax, PARAM(1) ;second argument - list
        cmp byte [rax], T_pair
        je .L_apply_second_arg_is_pair
        cmp rax, sob_nil
        je .L_apply_second_arg_is_null
        jmp L_error_improper_list
.L_apply_second_arg_is_pair:
	mov rdx, 0 ; initialize rdx to 0
	mov rsi, PARAM(1) ; rsi will be used to iterate through the list 
.L_start_loop_length_pair:
	 cmp rsi, sob_nil ; check if the current element is the end of the list 
	 je .L_apply_end_count_list ; if it is, jump to done 
	 mov rsi, SOB_PAIR_CDR(rsi)  ; move to the next element in the list 
	 inc rdx ; increment the counter in rdx 
	 sub rsp, 8
	 jmp .L_start_loop_length_pair ; jump back to the beginning of the loop 
.L_apply_end_count_list: 
	mov rbx, rsp
	mov rsi, PARAM(1)
.L_apply_push_elements: 
	cmp rsi, sob_nil
	je .L_apply_push_elements_end
	mov rcx, SOB_PAIR_CAR(rsi)
	mov qword[rbx], rcx
	mov rsi, SOB_PAIR_CDR(rsi) 
	add rbx, 8
	jmp .L_apply_push_elements
.L_apply_push_elements_end:
	push rdx
	jmp .L_apply_end
.L_apply_second_arg_is_null:
	push 0
.L_apply_end:
	mov rax, PARAM(0)
	push SOB_CLOSURE_ENV(rax) ;closure in rax
        push qword [rbp + 8 * 1] ; old ret addr
        push qword [rbp] ; same the old rbp
        add rdx, 3
        mov rcx, [rbp] 
        mov rdi, rbp
.L_startLoop_recycle:
        cmp rdx, 0
        je .L_endLoop_recycle
       	sub rcx, 8
        sub rdi, 8
        mov rsi, [rdi]
        mov qword [rcx], rsi
        dec rdx
        jmp .L_startLoop_recycle
.L_endLoop_recycle:
        pop rbp ; restore the old rbp
        mov rsp, rcx
        jmp SOB_CLOSURE_CODE(rax)
		

	
L_code_ptr_is_null:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_nil
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_pair:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_pair
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_void:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_void
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_char
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_string:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_string
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_symbol:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_symbol
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_vector:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_vector
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_closure:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_closure
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_real
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_rational:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_boolean:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_boolean
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_number:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_number
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_collection:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_collection
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_cons:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_pair
        mov rbx, PARAM(0)
        mov SOB_PAIR_CAR(rax), rbx
        mov rbx, PARAM(1)
        mov SOB_PAIR_CDR(rax), rbx
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_display_sexpr:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rdi, PARAM(0)
        call print_sexpr
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_write_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_char(rax)
        mov al, SOB_CHAR_VALUE(rax)
        and rax, 255
        mov rdi, fmt_char
        mov rsi, rax
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_car:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rax, SOB_PAIR_CAR(rax)
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_cdr:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rax, SOB_PAIR_CDR(rax)
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_string_length:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_string(rax)
        mov rdi, SOB_STRING_LENGTH(rax)
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_vector_length:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_vector(rax)
        mov rdi, SOB_VECTOR_LENGTH(rax)
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_real_to_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rbx, PARAM(0)
        assert_real(rbx)
        movsd xmm0, qword [rbx + 1]
        cvttsd2si rdi, xmm0
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_exit:
        ENTER
        cmp COUNT, 0
        jne L_error_arg_count_0
        mov rax, 0
        call exit

L_code_ptr_integer_to_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_integer(rax)
        push qword [rax + 1]
        cvtsi2sd xmm0, qword [rsp]
        call make_real
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_rational_to_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        push qword [rax + 1]
        cvtsi2sd xmm0, qword [rsp]
        push qword [rax + 1 + 8]
        cvtsi2sd xmm1, qword [rsp]
        divsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_char_to_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_char(rax)
        mov al, byte [rax + 1]
        and rax, 255
        mov rdi, rax
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_integer_to_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_integer(rax)
        mov rbx, qword [rax + 1]
        cmp rbx, 0
        jle L_error_integer_range
        cmp rbx, 256
        jge L_error_integer_range
        mov rdi, (1 + 1)
        call malloc
        mov byte [rax], T_char
        mov byte [rax + 1], bl
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_trng:
        ENTER
        cmp COUNT, 0
        jne L_error_arg_count_0
        rdrand rdi
        shr rdi, 1
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(0)

L_code_ptr_is_zero:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        je .L_rational
        cmp byte [rax], T_real
        je .L_real
        jmp L_error_incorrect_type
.L_rational:
        cmp qword [rax + 1], 0
        je .L_zero
        jmp .L_not_zero
.L_real:
        pxor xmm0, xmm0
        push qword [rax + 1]
        movsd xmm1, qword [rsp]
        ucomisd xmm0, xmm1
        je .L_zero
.L_not_zero:
        mov rax, sob_boolean_false
        jmp .L_end
.L_zero:
        mov rax, sob_boolean_true
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        jne .L_false
        cmp qword [rax + 1 + 8], 1
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_raw_bin_add_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        addsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_sub_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        subsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_mul_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        mulsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_div_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        pxor xmm2, xmm2
        ucomisd xmm1, xmm2
        je L_error_division_by_zero
        divsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_add_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1]     ; num2
        cqo
        imul rbx
        add rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_sub_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1]     ; num2
        cqo
        imul rbx
        sub rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_mul_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1] ; num2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_bin_div_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        cmp qword [r9 + 1], 0
        je L_error_division_by_zero
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1] ; num2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)
        
normalize_rational:
        push rsi
        push rdi
        call gcd
        mov rbx, rax
        pop rax
        cqo
        idiv rbx
        mov r8, rax
        pop rax
        cqo
        idiv rbx
        mov r9, rax
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_rational
        mov qword [rax + 1], r9
        mov qword [rax + 1 + 8], r8
        ret

iabs:
        mov rax, rdi
        cmp rax, 0
        jl .Lneg
        ret
.Lneg:
        neg rax
        ret

gcd:
        call iabs
        mov rbx, rax
        mov rdi, rsi
        call iabs
        cmp rax, 0
        jne .L0
        xchg rax, rbx
.L0:
        cmp rbx, 0
        je .L1
        cqo
        div rbx
        mov rax, rdx
        xchg rax, rbx
        jmp .L0
.L1:
        ret

L_code_ptr_error:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_symbol(rsi)
        mov rsi, PARAM(1)
        assert_string(rsi)
        mov rdi, fmt_scheme_error_part_1
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rdi, PARAM(0)
        call print_sexpr
        mov rdi, fmt_scheme_error_part_2
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, PARAM(1)       ; sob_string
        mov rsi, 1              ; size = 1 byte
        mov rdx, qword [rax + 1] ; length
        lea rdi, [rax + 1 + 8]   ; actual characters
        mov rcx, qword [stdout]  ; FILE*
        call fwrite
        mov rdi, fmt_scheme_error_part_3
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, -9
        call exit

L_code_ptr_raw_less_than_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_real(rsi)
        mov rdi, PARAM(1)
        assert_real(rdi)
        movsd xmm0, qword [rsi + 1]
        movsd xmm1, qword [rdi + 1]
        comisd xmm0, xmm1
        jae .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_less_than_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_rational(rsi)
        mov rdi, PARAM(1)
        assert_rational(rdi)
        mov rax, qword [rsi + 1] ; num1
        cqo
        imul qword [rdi + 1 + 8] ; den2
        mov rcx, rax
        mov rax, qword [rsi + 1 + 8] ; den1
        cqo
        imul qword [rdi + 1]          ; num2
        sub rcx, rax
        jge .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_equal_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_real(rsi)
        mov rdi, PARAM(1)
        assert_real(rdi)
        movsd xmm0, qword [rsi + 1]
        movsd xmm1, qword [rdi + 1]
        comisd xmm0, xmm1
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_equal_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_rational(rsi)
        mov rdi, PARAM(1)
        assert_rational(rdi)
        mov rax, qword [rsi + 1] ; num1
        cqo
        imul qword [rdi + 1 + 8] ; den2
        mov rcx, rax
        mov rax, qword [rdi + 1 + 8] ; den1
        cqo
        imul qword [rdi + 1]          ; num2
        sub rcx, rax
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_quotient:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_integer(rsi)
        mov rdi, PARAM(1)
        assert_integer(rdi)
        mov rax, qword [rsi + 1]
        mov rbx, qword [rdi + 1]
        cmp rbx, 0
        je L_error_division_by_zero
        cqo
        idiv rbx
        mov rdi, rax
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_remainder:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_integer(rsi)
        mov rdi, PARAM(1)
        assert_integer(rdi)
        mov rax, qword [rsi + 1]
        mov rbx, qword [rdi + 1]
        cmp rbx, 0
        je L_error_division_by_zero
        cqo
        idiv rbx
        mov rdi, rdx
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_set_car:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rbx, PARAM(1)
        mov SOB_PAIR_CAR(rax), rbx
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_set_cdr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rbx, PARAM(1)
        mov SOB_PAIR_CDR(rax), rbx
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_string_ref:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, PARAM(0)
        assert_string(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov bl, byte [rdi + 1 + 8 + 1 * rcx]
        mov rdi, 2
        call malloc
        mov byte [rax], T_char
        mov byte [rax + 1], bl
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_vector_ref:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, PARAM(0)
        assert_vector(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, [rdi + 1 + 8 + 8 * rcx]
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_vector_set:
        ENTER
        cmp COUNT, 3
        jne L_error_arg_count_3
        mov rdi, PARAM(0)
        assert_vector(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, PARAM(2)
        mov qword [rdi + 1 + 8 + 8 * rcx], rax
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(3)

L_code_ptr_string_set:
        ENTER
        cmp COUNT, 3
        jne L_error_arg_count_3
        mov rdi, PARAM(0)
        assert_string(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, PARAM(2)
        assert_char(rax)
        mov al, byte [rax + 1]
        mov byte [rdi + 1 + 8 + 1 * rcx], al
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(3)

L_code_ptr_make_vector:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rcx, PARAM(0)
        assert_integer(rcx)
        mov rcx, qword [rcx + 1]
        cmp rcx, 0
        jl L_error_integer_range
        mov rdx, PARAM(1)
        lea rdi, [1 + 8 + 8 * rcx]
        call malloc
        mov byte [rax], T_vector
        mov qword [rax + 1], rcx
        mov r8, 0
.L0:
        cmp r8, rcx
        je .L1
        mov qword [rax + 1 + 8 + 8 * r8], rdx
        inc r8
        jmp .L0
.L1:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_make_string:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rcx, PARAM(0)
        assert_integer(rcx)
        mov rcx, qword [rcx + 1]
        cmp rcx, 0
        jl L_error_integer_range
        mov rdx, PARAM(1)
        assert_char(rdx)
        mov dl, byte [rdx + 1]
        lea rdi, [1 + 8 + 1 * rcx]
        call malloc
        mov byte [rax], T_string
        mov qword [rax + 1], rcx
        mov r8, 0
.L0:
        cmp r8, rcx
        je .L1
        mov byte [rax + 1 + 8 + 1 * r8], dl
        inc r8
        jmp .L0
.L1:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_numerator:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        mov rdi, qword [rax + 1]
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_denominator:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        mov rdi, qword [rax + 1 + 8]
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_eq:
	ENTER
	cmp COUNT, 2
	jne L_error_arg_count_2
	mov rdi, PARAM(0)
	mov rsi, PARAM(1)
	cmp rdi, rsi
	je .L_eq_true
	mov dl, byte [rdi]
	cmp dl, byte [rsi]
	jne .L_eq_false
	cmp dl, T_char
	je .L_char
	cmp dl, T_symbol
	je .L_symbol
	cmp dl, T_real
	je .L_real
	cmp dl, T_rational
	je .L_rational
	jmp .L_eq_false
.L_rational:
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
	jne .L_eq_false
	mov rax, qword [rsi + 1 + 8]
	cmp rax, qword [rdi + 1 + 8]
	jne .L_eq_false
	jmp .L_eq_true
.L_real:
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
.L_symbol:
	; never reached, because symbols are static!
	; but I'm keeping it in case, I'll ever change
	; the implementation
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
.L_char:
	mov bl, byte [rsi + 1]
	cmp bl, byte [rdi + 1]
	jne .L_eq_false
.L_eq_true:
	mov rax, sob_boolean_true
	jmp .L_eq_exit
.L_eq_false:
	mov rax, sob_boolean_false
.L_eq_exit:
	LEAVE
	ret AND_KILL_FRAME(2)

make_real:
        ENTER
        mov rdi, (1 + 8)
        call malloc
        mov byte [rax], T_real
        movsd qword [rax + 1], xmm0
        LEAVE
        ret
        
make_integer:
        ENTER
        mov rsi, rdi
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_rational
        mov qword [rax + 1], rsi
        mov qword [rax + 1 + 8], 1
        LEAVE
        ret
        
L_error_integer_range:
        mov rdi, qword [stderr]
        mov rsi, fmt_integer_range
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -5
        call exit

L_error_arg_count_0:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_0
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_1:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_1
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_2:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_2
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_12:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_12
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_3:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_3
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit
        
L_error_incorrect_type:
        mov rdi, qword [stderr]
        mov rsi, fmt_type
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -4
        call exit

L_error_division_by_zero:
        mov rdi, qword [stderr]
        mov rsi, fmt_division_by_zero
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -8
        call exit

section .data
fmt_char:
        db `%c\0`
fmt_arg_count_0:
        db `!!! Expecting zero arguments. Found %d\n\0`
fmt_arg_count_1:
        db `!!! Expecting one argument. Found %d\n\0`
fmt_arg_count_12:
        db `!!! Expecting one required and one optional argument. Found %d\n\0`
fmt_arg_count_2:
        db `!!! Expecting two arguments. Found %d\n\0`
fmt_arg_count_3:
        db `!!! Expecting three arguments. Found %d\n\0`
fmt_type:
        db `!!! Function passed incorrect type\n\0`
fmt_integer_range:
        db `!!! Incorrect integer range\n\0`
fmt_division_by_zero:
        db `!!! Division by zero\n\0`
fmt_scheme_error_part_1:
        db `\n!!! The procedure \0`
fmt_scheme_error_part_2:
        db ` asked to terminate the program\n`
        db `    with the following message:\n\n\0`
fmt_scheme_error_part_3:
        db `\n\nGoodbye!\n\n\0`

