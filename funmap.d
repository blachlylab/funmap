import std.algorithm;	// map
import std.stdio;
import std.file;
import std.format;
import std.string;
import std.range;	// walkLength
import std.getopt;

static import htslib.bgzf;
import htslib.hts;
import htslib.sam;

int main() {
	auto fn = std.string.toStringz("test.bam");
	auto mode=std.string.toStringz("r");
	htslib.bgzf.BGZF *fp = htslib.bgzf.bgzf_open(fn, mode);
	
	return htslib.bgzf.bgzf_close(fp);
}
