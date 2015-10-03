default: all

EMFLAGS = -s "EXPORT_NAME='TestModule'" \
-s EXPORTED_FUNCTIONS="['_malloc','_sum']" \
--pre-js pre.js

CFLAGS += -O0

all: module

module: emscripten_test.js

emscripten_test.js: pre.js
	$(CC) $(CFLAGS) emscripten_test.c $(EMFLAGS) -o $@

clean:
	$(RM) emscripten_test.js

