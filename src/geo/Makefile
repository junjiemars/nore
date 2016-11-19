
geo_objout := $(tmp_path)geo$(obj_ext)
geo_libout := $(lib_path)libgeo$(mod_ext)

geo: $(geo_libout)

geo_cflags := $(CFLAGS) $(NM_PIC_OPT) $(INC) -I$(src_path)
geo_ldflags := $(LDFLAGS) 


$(geo_objout): $(src_path)geo.c 
	$(CC) $(geo_cflags) -c $^ $(obj_out)$@
	cp $(src_path)geo.h $(inc_path)

$(geo_libout): $(geo_objout)
	$(CC) $(LFLAGS) $(geo_ldflags) $^ $(bin_out)$@
