
math_objout := $(tmp_path)math$(obj_ext)
math_binout := $(bin_path)math$(bin_ext)

math: geo $(bin_path)math$(bin_ext)

math_cflags = $(CFLAGS) $(INC)
ifeq ($(CC_NAME), gcc)
	math_cflags += -std=c99 -Wno-error=strict-aliasing
endif

math_lflags += $(LFLAGS) $(LDLIBS)

$(math_objout): $(src_path)math1.c
	$(CC) $(math_cflags) -c $^ $(obj_out)$@


$(math_binout): $(math_objout)
	$(LINK) $(math_lflags) $^ -lgeo $(bin_out)$@

math_test: math
	LD_LIBRARY_PATH=$(lib_path) $(math_binout)
