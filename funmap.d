import std.algorithm;	// map
import std.stdio;
import std.file;
import std.format;
import std.string;
import std.range;	// walkLength
import std.getopt;
import std.parallelism: totalCPUs;

import core.stdc.stdlib : alloca, free;
import core.stdc.stdio: printf;

/+
static import htslib.bgzf;
static import htslib.hts;
static import htslib.sam;
+/
import dhtslib.sam;
import dhtslib.htslib.hts;
import dhtslib.htslib.sam;

immutable int max_readlen = 10000;
/+
struct Read {
    char[max_readlen] seq;
    int seqlen;
}

pure int get_read(const bam1_t *rec, Read *r)
{
   int len = (*rec).core.l_qseq + 1;
    char *seq = cast(char *)bam_get_seq(rec); 
}+/
/*
// return the read, reverse complemented if necessary
pure char *get_read(const bam1_t *rec)
{
    int len = (*rec).core.l_qseq + 1;
    //char *read = calloc(1, len);
    char *read = alloca(len);
    char *seq = cast(char *)bam_get_seq(rec);
    int n;

    if (!read) return null;

    for (n=0; n < (*rec).core.l_qseq; n++) {
        if ((*rec).core.flag & htslib.sam.BAM_FREVERSE) read[n] = seq_nt16_str[seq_comp_table[bam_seqi(seq,n)]];
        else                                            read[n] = seq_nt16_str[bam_seqi(seq,n)];
    }
    if (rec->core.flag & BAM_FREVERSE) reverse(read);
    return read;
}
*/

int main(string[] args) {
    Record r = new Record;

    ulong nrecords = 0;

    auto fn = std.string.toStringz( args[1] );
	auto mode=std.string.toStringz("r");
	htsFile *fp = hts_open(fn, mode);

    if (totalCPUs > 1) {
        stderr.writefln("%d CPU cores detected; enabling multithreading.", totalCPUs);
        // hts_set_threads adds N _EXTRA_ threads, so totalCPUs - 1 seemed reasonable,
        // but overcomitting by 1 thread (i.e., passing totalCPUs) buys an extra 3% on my 2-core 2013 Mac
        hts_set_threads(fp, totalCPUs );
    }

	bam_hdr_t *header = null;
	header = sam_hdr_read(fp);
	// Verify BAM header was read:
	writeln("n_targets: ", header.n_targets);

    while( sam_read1(fp, header, r.b) >= 0) {
/+
        writeln( '@', r.queryName );
        writeln( r.sequence );
        writeln('+');
        writeln( r.qscores );
        /+
        auto s = r.sequence;
        auto q = r.qscores;

        free(s);
        free(q);
        +/
+/
//        auto qn = r.queryName;
        auto qn = bam_get_qname(r.b);
        auto s = r.sequence;
        auto q = r.qscores;
        nrecords++;

        printf("%s\n%s\n+\n%s\n", qn, s, q);

        free(s);
        free(q);
    }

    writeln("sam_read1 >= 0: ", sam_read1(fp, header, r.b) );
    writeln("nrecords: ", nrecords);

	bam_hdr_destroy(header);
	return hts_close(fp);
}
