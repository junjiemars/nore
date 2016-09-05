
env: $(bin_path)env

env_cflags := -std=c99

$(tmp_path)env$(nm_objext): $(src_path)env.c
	$(CC) -c $(CFLAGS) $(env_cflags) \
        $(nm_objout)$(tmp_path)env$(nm_objext) $(src_path)env.c 

$(bin_path)env$(nm_binext): $(tmp_path)env$(nm_objext)
	$(LINK) $^ $(nm_binout)$@ 
