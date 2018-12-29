#import <stdlib.h>
#import <stdio.h>
#import <string.h>

#import "hts.h"
#import "sam.h"

int8_t seq_comp_table[16] = { 0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15 };

/*
 * Reverse a string in place.
 * From http://stackoverflow.com/questions/8534274/is-the-strrev-function-not-available-in-linux.
 * Author Sumit-naik: http://stackoverflow.com/users/4590926/sumit-naik
 */
char *reverse(char *str) 
{
    int i = strlen(str)-1,j=0;
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
    char *read = (char*) calloc(1, len);
    char *seq = (char *)bam_get_seq(rec);
    int n;

    if (!read) return NULL;

    for (n=0; n < (*rec).core.l_qseq; n++) {
        if ((*rec).core.flag & BAM_FREVERSE) read[n] = seq_nt16_str[seq_comp_table[bam_seqi(seq,n)]];
        else                                           read[n] = seq_nt16_str[bam_seqi(seq,n)];
    }
    if (rec->core.flag & BAM_FREVERSE) reverse(read);
    return read;
}

/*
 * get and decode the quality from a BAM record
 */
int get_quality(bam1_t *rec, char **qual_out) 
{
    char *quality = (char *)calloc(1, rec->core.l_qseq + 1);
    char *q = (char *)bam_get_qual(rec);
    int n;

    if (!quality) return -1;

    if (*q == '\xff') {
        free(quality);
        *qual_out = NULL;
        return 0;
    }

    for (n=0; n < rec->core.l_qseq; n++) {
        quality[n] = (char) (q[n] + 33);
    }
    if (rec->core.flag & BAM_FREVERSE) reverse(quality);
    *qual_out = quality;
    return 0;
}

int main(int argc, char *argv[]) {

    int nrecords = 0;

    htsFile *fp = hts_open(argv[1], "r");

    bam_hdr_t *header = NULL;
    header = sam_hdr_read(fp);
    // Verify BAM header was read:
    printf("n_targets: %d", header->n_targets);

    bam1_t *b = bam_init1();

    while( sam_read1(fp, header, b) >= 0) {
        char* qn = bam_get_qname(b);
        char* s = get_read(b);
        char * q;
        int qret = get_quality(b, &q);
        nrecords++;

        printf("%s\n%s\n+\n%s\n", qn, s, q);

        free(s);
        free(q);
    }

    printf("sam_read1 >= 0: %d", sam_read1(fp, header, b) );
    printf("nrecords: %d", nrecords);

	bam_hdr_destroy(header);
	return hts_close(fp);
}
