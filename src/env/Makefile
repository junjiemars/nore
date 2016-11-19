
env: $(bin_path)env$(bin_ext)

env_cflags += $(CFLAGS) $(INC) -I$(src_path)


$(tmp_path)env$(obj_ext): $(src_path)env.c
	$(CC) -c $(env_cflags) $^ $(obj_out)$@


$(bin_path)env$(bin_ext): $(tmp_path)env$(obj_ext)
	$(LINK) $(LFLAGS) $^ $(bin_out)$@ 
