default: all

LIBDIR = ../lib
include $(LIBDIR)/complex.inc

EMFLAGS = -s "EXPORT_NAME='TestModule'" \
-s EXPORTED_FUNCTIONS="['_malloc',\
$(EXP_COMPLEX),\
'_sum']" \
--pre-js pre.js --post-js $(LIBDIR)/post.js

CFLAGS += -O0

all: module

module: emscripten_test.js

emscripten_test.js: pre.js $(LIBDIR)/post.js $(LIBDIR)/complex.c
	$(CC) $(CFLAGS) emscripten_test.c $(LIBDIR)/complex.c $(EMFLAGS) -o $@

clean:
	$(RM) emscripten_test.js
