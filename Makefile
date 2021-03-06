HTSLIB=/home/blac96@OSUMC.EDU/source/github.com/samtools/htslib-1.7/libhts.a -L-lcurl -L-lbz2 -L-llzma
HTSLIB_MAC=/Users/james/Documents/Development/github.com/samtools/htslib-1.7/libhts.a -L-lcurl -L-lbz2 -L-llzma
# -i must be included (only works with newer DMD)
# otherwise the inline functions in the htslib .d files are missing symbols at link time
# (they were #define macros in the original htslib .h sources)
# Other option is to explicitly include their names on the command line for compilation
funmap: funmap.d
	dmd -release -O -inline -I=../dhtslib/source/ -i $(HTSLIB_MAC) funmap.d

funmap_minimal: funmap_minimal.d
	ldc2 -O -release -I=../dhtslib/source/ -i -L-lhts funmap_minimal.d

funmap_c: funmap_c.c
	gcc -O3 funmap_c.c -lhts -I../../github.com/samtools/htslib-1.7/htslib -o funmap_c

debug: funmap.d
	dmd -debug -I=../dhtslib/source/ -i $(HTSLIB_MAC) funmap.d

ldc: funmap.d
	ldc2 -release -O -I=../dhtslib/source/ -i /Users/james/Documents/Development/github.com/samtools/htslib-1.7/libhts.a -L-lcurl -L-lbz2 -L-llzma funmap.d
ldc_shorter: funmap.d
	ldc2 -O -release -I=../dhtslib/source/ -i -L-lhts funmap.d

clean:
	rm funmap funmap_minimal funmap_c
