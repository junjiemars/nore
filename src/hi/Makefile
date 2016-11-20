

hi_binout := $(bin_path)hi$(bin_ext)

hi: $(hi_binout)

$(hi_binout): $(src_path)hi.c
	$(LINK) $(LFLAGS) $^ $(bin_out)$@

hi_test: hi
	$(hi_binout)

