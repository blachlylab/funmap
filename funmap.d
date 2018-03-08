import std.algorithm;	// map
import std.stdio;
import std.file;
import std.format;
import std.string;
import std.range;	// walkLength
import std.getopt;

import core.stdc.stdlib : alloca;

static import htslib.bgzf;
static import htslib.hts;
static import htslib.sam;

immutable int max_readlen = 10000;

struct Read {
    char[max_readlen] seq;
    int seqlen;
}

pure int get_read(const bam1_t *rec, Read *r)
{
   int len = (*rec).core.l_qseq + 1;
    char *seq = cast(char *)bam_get_seq(rec) 
}
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
	auto fn = std.string.toStringz("wgEncodeUwRepliSeqBg02esG1bAlnRep1.bam");
	auto mode=std.string.toStringz("r");
	htslib.hts.htsFile *fp = htslib.hts.hts_open(fn, mode);

	htslib.sam.bam_hdr_t *header = null;
	header = htslib.sam.sam_hdr_read(fp);
	// Verify BAM header was read:
	writeln("n_targets: ", header.n_targets);

	// bam1_t is a BAM alignment record
	// Allocate one on the stack
	htslib.sam.bam1_t b;
	auto bptr = &b;

	auto ret = htslib.sam.sam_read1(fp, header, bptr);
	writeln("sam_read1: ", ret);

	auto qname = htslib.sam.bam_get_qname(bptr);
	writeln("Query name: ", fromStringz(qname) );

	Read r;

	htslib.sam.bam_hdr_destroy(header);
	return htslib.hts.hts_close(fp);
}
