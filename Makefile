BASEDIR=${HOME}
BINDIR=${BASEDIR}/bin
LIBDIR=${BASEDIR}/lib/longpass

install:
	mkdir -p ${BINDIR} ${LIBDIR}
	cp -p longpass ${BINDIR}
	rm -f ${LIBDIR}/*
	cp -p lib/longpass/* ${LIBDIR}/
	@echo "For presets:"
	@echo "    cp dot-longpass.txt ~/.longpass"
