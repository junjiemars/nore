
math: geo $(bin_path)math



math_cflags := $(CFLAGS) -std=c99 $(NM_INCS)
math_ldflags := $(NM_LDS)


$(tmp_path)math$(nm_objsext): $(src_path)math1.c
	$(CC) $(math_cflags) -c $^ $(nm_objout)$@


$(bin_path)math$(nm_binext): $(tmp_path)math$(nm_objext)
	$(LINK) $(math_ldflags) $^ -lgeo $(nm_binout)$@
