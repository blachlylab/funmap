import std.algorithm;	// map
import std.stdio;
import std.file;
import std.format;
import std.string;
import std.range;	// walkLength
import std.getopt;

import core.stdc.stdlib : alloca;

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

int main() {
    Record r;

	auto fn = std.string.toStringz("wgEncodeUwRepliSeqBg02esG1bAlnRep1.bam");
	auto mode=std.string.toStringz("r");
	htsFile *fp = hts_open(fn, mode);

	bam_hdr_t *header = null;
	header = sam_hdr_read(fp);
	// Verify BAM header was read:
	writeln("n_targets: ", header.n_targets);

    r.b = bam_init1();
	auto ret = sam_read1(fp, header, r.b);
	writeln("sam_read1: ", ret);

	auto qname = bam_get_qname(r.b);
	writeln("Query name: ", fromStringz(qname) );

	//Read r;

	bam_hdr_destroy(header);
	return hts_close(fp);
}
