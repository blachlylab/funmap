import std.algorithm;	// map
import std.stdio;
import std.file;
import std.format;
import std.string;
import std.range;	// walkLength
import std.getopt;
import std.stdint;

import core.stdc.stdlib : calloc, free;
import core.stdc.stdio: printf;
import core.stdc.string: strlen;

import dhtslib.sam;
import dhtslib.htslib.hts;
import dhtslib.htslib.sam;

immutable(int8_t)[16] seq_comp_table = [ 0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15 ];

/*
 * Reverse a string in place.
 * From http://stackoverflow.com/questions/8534274/is-the-strrev-function-not-available-in-linux.
 * Author Sumit-naik: http://stackoverflow.com/users/4590926/sumit-naik
 */
char *reverse(char *str) 
{
    auto i = strlen(str)-1,j=0;
    char ch;
    while (i>j) {
        ch = str[i];
        str[i]= str[j];
        str[j] = ch;
        i--;
        j++;
    }
    return str;
}

/* return the read, reverse complemented if necessary */
char *get_read(bam1_t *rec) 
{
    int len = (*rec).core.l_qseq + 1;
    char *read = cast(char*) calloc(1, len);
    //char *seq = cast(char *)bam_get_seq(rec);
    auto seq = bam_get_seq(rec);    // should be ubyte *
    int n;

    if (!read) return null;

    for (n=0; n < (*rec).core.l_qseq; n++) {
        if ((*rec).core.flag & BAM_FREVERSE) read[n] = seq_nt16_str[seq_comp_table[bam_seqi(seq,n)]];
        else                                           read[n] = seq_nt16_str[bam_seqi(seq,n)];
    }
    if (rec.core.flag & BAM_FREVERSE) reverse(read);
    return read;
}

/*
 * get and decode the quality from a BAM record
 */
int get_quality(bam1_t *rec, char **qual_out) 
{
    char *quality = cast(char *)calloc(1, rec.core.l_qseq + 1);
    char *q = cast(char *)bam_get_qual(rec);
    int n;

    if (!quality) return -1;

    if (*q == '\xff') {
        free(quality);
        *qual_out = null;
        return 0;
    }

    for (n=0; n < rec.core.l_qseq; n++) {
        quality[n] = cast(char) (q[n] + 33);
    }
    if (rec.core.flag & BAM_FREVERSE) reverse(quality);
    *qual_out = quality;
    return 0;
}

int main(string[] args) {

    ulong nrecords = 0;

    auto fn = std.string.toStringz( args[1] );
	auto mode=std.string.toStringz("r");

	htsFile *fp = hts_open(fn, mode);

	bam_hdr_t *header = null;
	header = sam_hdr_read(fp);
	// Verify BAM header was read:
	writeln("n_targets: ", header.n_targets);

    bam1_t *b = bam_init1();

    while( sam_read1(fp, header, b) >= 0) {
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
        auto qn = bam_get_qname(b);
        auto s = get_read(b);
        char * q;
        auto qret = get_quality(b, &q);
        nrecords++;

        printf("%s\n%s\n+\n%s\n", qn, s, q);

        free(s);
        free(q);
    }

    writeln("sam_read1 >= 0: ", sam_read1(fp, header, b) );
    writeln("nrecords: ", nrecords);

	bam_hdr_destroy(header);
	return hts_close(fp);
}
