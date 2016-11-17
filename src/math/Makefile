
math_objout := $(tmp_path)math$(obj_ext)
math_binout := $(bin_path)math$(bin_ext)

math: geo $(bin_path)math$(bin_ext)

math_cflags = $(CFLAGS) $(NM_INCS) -std=c99
math_lflags += $(LFLAGS) $(NM_LDS)

ifeq ($(NM_SYSTEM),Darwin)
	math_cflags += -O3
endif

$(math_objout): $(src_path)math1.c
	$(CC) $(math_cflags) -c $^ $(obj_out)$@


$(math_binout): $(math_objout)
	$(LINK) $(math_lflags) $^ -lgeo $(bin_out)$@
