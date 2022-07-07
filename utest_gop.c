#include <string.h>
#include <math.h>
#include <time.h>
#include <sys/timeb.h>
#include <stdlib.h>

#ifdef _WIN32
#include <IO.H>
#endif

#include <assert.h>
#include <fcntl.h>
#include <stdio.h>

#include "uAVS3lib/uAVS3lib_gop.h"

#define SPEED_TEST 0

#if SPEED_TEST

typedef struct listt
{
    unsigned char* list[2];
    int width;
    int height;
}listt;

#ifdef _WIN32
#include <IO.H>
#include "./uAVS3lib/tools/win32thread.h"
#include "./uAVS3lib/tools/win32thread.c"
#include "./uAVS3lib/tools/threadpool.h"
#include "./uAVS3lib/tools/threadpool.c"
#else
#include "./uAVS3lib/tools/threadpool.h"
#include "./uAVS3lib/tools/threadpool.c"
#endif
#endif

#define SKIP_FRAMES 0

#define S_IREAD        0000400         /* read  permission, owner */
#define S_IWRITE       0000200         /* write permission, owner */
#define MAX_ITEMS_TO_PARSE  10000

#define max(a, b)      (((a) > (b)) ? (a) : (b))  //!< Macro returning max value
#define min(a, b)      (((a) < (b)) ? (a) : (b))

#ifndef _WIN32
#if defined(__APPLE__)
#define _lseeki64 lseek
#else
#define _lseeki64 lseek64
#endif
#define _read read
#define _write write
#define _open open
#define _close close

#define O_BINARY 0x0
#endif

#if SKIP_FRAMES
int skip_frame = 0;
#endif

int (*ReadOneFrame)(image_t *img, int fd, cfg_param_t *input, long long FrameNoInFile);

#if SPEED_TEST
int(*ReadOneth)(avs3_threadpool_t *mem, image_t *img, unsigned char *fd, cfg_param_t *input, long long FrameNoInFile);
#endif

cfg_param_t input;
int fd_bitstream = 0;

int shift_bits;

double all_psnr_y = 0;
double all_psnr_u = 0;
double all_psnr_v = 0;

long long total_frms = 0;
long long total_bits = 0;
long long total_time = 0;

static void PatchInp(cfg_param_t *input)
{
    int b_error = 0;

    if (input->InterlaceCodingOption) {
        input->img_height = input->img_height / 2;
        input->no_frames = input->no_frames * 2;
        input->intra_period = input->intra_period * 2;
    }

    if (input->profile_id == 0x12 && input->intra_period != 1) {
        printf("Baseline picture file only supports intra picture coding!");
        b_error = 1;
    }
    if (input->baseQP > MAX_QP || input->baseQP < 0) {
        printf("Error input parameter quant_0,check configuration file");
        b_error = 1;
    }

    if (0 >((input->img_height / 8) * (input->img_width / 8))) {
        printf("\nNumber of LCUs in slice cannot exceed total LCU in picture!");
        b_error = 1;
    }
    if (input->alpha_c_offset > 8 || input->alpha_c_offset < -8) {
        printf("Error input parameter LFAlphaC0Offset, check configuration file");
        b_error = 1;
    }
    if (input->beta_offset > 8 || input->beta_offset < -8) {
        printf("Error input parameter LFBetaOffset, check configuration file");
        b_error = 1;
    }

    if (b_error) {
        exit(1);
    }
}

int ParseRefContent(cfg_param_t *input, signed char **buf)
{
    ref_man *tmp;
    int i = 1;
    int j = 0;
	signed char *token;
	signed char **p = buf;
	signed char *tmp_str = ":";
	signed char str[64];
	signed char headstr[10] = { 'F', 'r', 'a', 'm', 'e', '\0', '\0', '\0', '\0', '\0' };

    // Fix by Sunil for RD5.0 test in Linux (2013.11.06)
    sprintf(str, "%d", i);

    strcat(headstr, str);
    strcat(headstr, tmp_str);

    memset(input->seq_ref_cfg, -1, sizeof(struct reference_management)*MAXGOP);

    while (0 == strcmp(headstr, *p++)) {
        tmp = input->seq_ref_cfg + i - 1;
        token = *p++;
        tmp->layer = atoi(token);
        token = *p++;
        tmp->poc = atoi(token);
        token = *p++;
        tmp->qp_offset = atoi(token);
        token = *p++;
        tmp->num_of_ref = atoi(token);
        token = *p++;
        tmp->referd_by_others = atoi(token);
        for (j = 0; j < tmp->num_of_ref; j++) {
            token = *p++;
            tmp->ref_pic[j] = atoi(token);
        }
        token = *p++;
        tmp->num_to_remove = atoi(token);
        for (j = 0; j < tmp->num_to_remove; j++) {
            token = *p++;
            tmp->remove_pic[j] = atoi(token);
        }

        i++;
        headstr[5] = headstr[6] = headstr[7] = headstr[8] = headstr[9] = '\0';

        sprintf(str, "%d", i);

        strcat(headstr, str);
        strcat(headstr, tmp_str);
    }

    return (int)(p - buf - 1);
}

int ParseHdrContent(cfg_param_t *input, signed char **buf)
{
    hdr_ext_data_t *tmp = &input->hdr_ext;
    signed char **p = buf + 1;

    tmp->enable = atoi(*p++);
    tmp->display_primaries_x[0] = atoi(*p++);
    tmp->display_primaries_x[1] = atoi(*p++);
    tmp->display_primaries_x[2] = atoi(*p++);
    tmp->display_primaries_y[0] = atoi(*p++);
    tmp->display_primaries_y[1] = atoi(*p++);
    tmp->display_primaries_y[2] = atoi(*p++);
    tmp->white_point_x = atoi(*p++);
    tmp->white_point_y = atoi(*p++);
    tmp->max_display_mastering_luminance = atoi(*p++);
    tmp->min_display_mastering_luminance = atoi(*p++);
    tmp->max_content_light_level         = atoi(*p++);
    tmp->max_picture_average_light_level = atoi(*p++);

    return (int)(p - buf);
}

int ParseNodeContent(cfg_param_t* input, signed char** buf, int j, int k)
{
    signed char** p = buf + 1;

    input->node[j][k]= atoi(*p++);

    return (int)(p - buf - 1);
}

static int ParameterNameToMapIndex(const Mapping *map_tab, signed char *s)
{
    int i = 0;

    while (map_tab[i].TokenName != NULL) {
        if (0 == strcmp(map_tab[i].TokenName, s)) {
            return i;
        }
        else {
            i++;
        }
    }

    return -1;
};

#pragma warning(disable: 4204) // nonstandard extension used : non-constant aggregate initializer

void ParseContent(cfg_param_t *input, signed char *buf, int bufsize)
{
	signed char *items[MAX_ITEMS_TO_PARSE];
    int MapIdx;
    int item = 0;
    int InString = 0;
    int InItem = 0;
	signed char *p = buf;
	signed char *bufend = &buf[bufsize];
    int IntContent;
    int i;

    // Stage one: Generate an argc/argv-type list in items[], without comments and whitespace.
    // This is context insensitive and could be done most easily with lex(1).

    while (p < bufend) {
        switch (*p) {
        case 13:
            p++;
            break;
        case '#':                 // Found comment
            *p = '\0';              // Replace '#' with '\0' in case of comment immediately following integer or string

            while (*p != '\n' && p < bufend) { // Skip till EOL or EOF, whichever comes first
                p++;
            }

            InString = 0;
            InItem = 0;
            break;
        case '\n':
            InItem = 0;
            InString = 0;
            *p++ = '\0';
            break;
        case ' ':
        case '\t':              // Skip whitespace, leave state unchanged

            if (InString) {
                p++;
            }
            else {
                // Terminate non-strings once whitespace is found
                *p++ = '\0';
                InItem = 0;
            }

            break;
        case '"':               // Begin/End of String
            *p++ = '\0';

            if (!InString) {
                items[item++] = p;
                InItem = ~InItem;
            }
            else {
                InItem = 0;
            }

            InString = ~InString; // Toggle
            break;
        default:

            if (!InItem) {
                items[item++] = p;
                InItem = ~InItem;
            }

            p++;
        }
    }

    item--;

    for (i = 0; i < item; i += 3) {
        if (0 == strcmp(items[i], refheadstr)) {
            i += ParseRefContent(input, &items[i]);
        }
        if (0 == strcmp(items[i], hdrheadstr)) {
            i += ParseHdrContent(input, &items[i]);
        }

        int j = 0, k = 0;
        if(0 == strcmp(items[i], nodelist)) {
            while (!((0 == strcmp(items[i], ";")) || (0 == strcmp(items[i], ";\r"))))
            {
                i += ParseNodeContent(input, &items[i], j, k);
                k++;
                if ((0 == strcmp(items[i], ",")) || (0 == strcmp(items[i], ",\r")))
                {
                    input->core_in_node[j] = k - 1;
                    j++;
                    input->node_num = j;
                    k = 0;
                }
            }
            input->core_in_node[j] = k - 1;
            j++;
            input->node_num = j;
            i++;
        }
        
        if (0 >(MapIdx = ParameterNameToMapIndex(tab_cfg_map, items[i]))) {
            printf(" Parsing error in config file: Parameter Name '%s' not recognized.", items[i]);
        }

        if (strcmp("=", items[i + 1]) && strcmp(":", items[i + 1])) {
            printf(" Parsing error in config file: '=' expected as the second token in each line.");
        }

        // Now interprete the Value, context sensitive...
        switch (tab_cfg_map[MapIdx].Type) {
        case 0:           // Numerical

            if (1 != sscanf(items[i + 2], "%d", &IntContent)) {
                printf(" Parsing error: Expected numerical value for Parameter of %s, found '%s'.", items[i], items[i + 2]);
            }

            *(int *)((char*)input + tab_cfg_map[MapIdx].offset) = IntContent;
            printf(".");
            break;
        case 1:
			strcpy((signed char *)input + tab_cfg_map[MapIdx].offset, items[i + 2]);
            printf(".");
            break;
        default:
            assert("Unknown value type in the map definition of configfile.h");
        }
    }
}

signed char *GetConfigFileContent(signed char *Filename)
{
    size_t FileSize;
    FILE *f;
	signed char *buf;

    if (NULL == (f = fopen(Filename, "r"))) {
        printf("Cannot open configuration file %s.\n", Filename);
    }

    if (0 != fseek(f, 0, SEEK_END)) {
        printf("Cannot fseek in configuration file %s.\n", Filename);
    }

    FileSize = ftell(f);

    if (FileSize > 60000) {
        printf("Unreasonable Filesize %zd reported by ftell for configuration file %s.\n", FileSize, Filename);
    }

    if (0 != fseek(f, 0, SEEK_SET)) {
        printf("Cannot fseek in configuration file %s.\n", Filename);
    }

    if ((buf = malloc(FileSize + 1)) == NULL) {
        printf("Could not allocate memory: GetConfigFileContent: buft");
    }

    // Note that ftell() gives us the file size as the file system sees it.  The actual file size,
    // as reported by fread() below will be often smaller due to CR/LF to CR conversion and/or
    // control characters after the dos EOF marker in the file.

    FileSize = fread(buf, 1, FileSize, f);
    buf[FileSize] = '\0';

    fclose(f);

    return buf;
}


void Configure(cfg_param_t *input, int ac, signed char *av[])
{
	signed char *content;
    int CLcount, NumberParams;
    size_t ContentLen;

    CLcount = 1;

    while (CLcount < ac) {
        if (0 == strncmp(av[CLcount], "-f", 2)) {    // A file parameter?
            content = GetConfigFileContent(av[CLcount + 1]);
            printf("Parsing Configfile %s", av[CLcount + 1]);
            ParseContent(input, content, (int)strlen(content));
            printf("\n");
            free(content);
            CLcount += 2;
        }
        else {
            if (0 == strncmp(av[CLcount], "-p", 2)) {    // A config change?
                // Collect all data until next parameter (starting with -<x> (x is any character)),
                // put it into content, and parse content.
                CLcount++;
                ContentLen = 0;
                NumberParams = CLcount;

                // determine the necessary size for content
                while (NumberParams < ac && av[NumberParams][0] != '-') {
                    ContentLen += strlen(av[NumberParams++]);     // Space for all the strings
                }

                ContentLen += 1000;                     // Additional 1000 bytes for spaces and \0s

                if ((content = malloc(ContentLen)) == NULL) {
                    printf("Could not allocate memory: Configure: content");
                }

                content[0] = '\0';

                // concatenate all parameters itendified before
                while (CLcount < NumberParams) {
					signed char *source = &av[CLcount][0];
					signed char *destin = &content[strlen(content)];

                    while (*source != '\0') {
                        if (*source == '=') { // The Parser expects whitespace before and after '='
                            *destin++ = ' ';
                            *destin++ = '=';
                            *destin++ = ' '; // Hence make sure we add it
                        }
                        else {
                            *destin++ = *source;
                        }

                        source++;
                    }

                    *destin++ = ' ';      // add a space to support multiple config items
                    *destin = '\0';
                    CLcount++;
                }

                printf("Parsing command line string '%s'", content);
                ParseContent(input, content, (int)strlen(content));
                free(content);
                printf("\n");
            }
            else {
                int i;
                printf("\nError in command line, command %d, command string '%s'\n", CLcount, av[CLcount]);
                printf("input[-f] is mandatory! \n");
                printf("Configuration error\n");
                printf("<Optional parameter > \n");
                printf("   -f */bin/encoder_ra.cfg\n     : mandatory, including default parameter configuration\n");
                for (i = 0; i < 36; i++)
                {
                    printf("   -p %s = \n     : %s \n", tab_cfg_map[i].TokenName, tab_cfg_map[i].ToKenLog);
                }
                printf("\n");
                return;
            }
        }
    }

    PatchInp(input);
    printf("\n");
}

void report(cfg_param_t *input, int running_time)
{
    double bitrate;
    double frame_rate = input->frame_rate_num * 1.0 / input->frame_rate_den;
    FILE* fp;

    printf("\n");
    printf("uAVS3 [user]:\tduration:   %f\n", total_frms / frame_rate);
    printf("uAVS3 [user]:\t ==========  Frame Info Log End ========== \n\n" );

    fprintf(stdout, "-----------------------------------------------------------------------------\n");
    fprintf(stdout, " Freq. for encoded bitstream       : %1.0f\n", (double)(frame_rate * (input->succ_bfrms + 1)) / (double)(input->succ_bfrms + 1));
    fprintf(stdout, " Image format                      : %dx%d\n", input->img_width, input->img_height);
    if (input->InterlaceCodingOption) {
        fprintf(stdout, " Image format for original image   : %dx%d\n", input->img_width, input->img_height * 2);
    }
    fprintf(stdout, " Total encoding time for the seq.  : %.3f sec (%5.2f fps) \n", total_time * 0.001, total_frms * 1000.0 / total_time);
    fprintf(stdout, "------------------ Average data all frames  ---------------------------------\n");
    fprintf(stdout, " SNR Y(dB)                         : %.5f\n", all_psnr_y / total_frms);
    fprintf(stdout, " SNR U(dB)                         : %.5f\n", all_psnr_u / total_frms);
    fprintf(stdout, " SNR V(dB)                         : %.5f\n", all_psnr_v / total_frms);
    fprintf(stdout, " Total bits                        : %lld\n", total_bits);

    if (input->InterlaceCodingOption) {
        bitrate = 2 * ((double)total_bits * frame_rate) / total_frms;
    } else {
        bitrate = ((double)total_bits * frame_rate) / total_frms;
    }

    fprintf(stdout, " Bit rate (kbit/s)  @ %2.2f Hz     : %5.2f\n", frame_rate, bitrate / 1000);
    fprintf(stdout, "-----------------------------------------------------------------------------\n");
    fprintf(stdout, "\n");

    if ((fp = fopen(input->TraceFile, "a+")) != NULL) {
        fprintf(fp, "bitrate: %9.2f kbps  psnr: %.5f %.5f %.5f  speed: %5.4f fps( %5.4f fps )  @ stream:%s\n", bitrate / 1000, all_psnr_y / total_frms, all_psnr_u / total_frms, all_psnr_v / total_frms, total_frms * 1000.0 / total_time, total_frms * 1000.0 / running_time, input->outfile);
        fclose(fp);
    }
}

int ReadOneFrame_8bit(image_t *img, int fd, cfg_param_t *input, long long FrameNoInFile)
{
    int i, j;
    int width  = input->img_width  - input->auto_crop_right;
    int height = input->img_height - input->auto_crop_bottom;
    unsigned char *buf;
    int read_size = 0;

    img->pts = FrameNoInFile * 40; // only for test

#if SKIP_FRAMES
    FrameNoInFile += skip_frame;
#endif

    long long offset;

    if (input->InterlaceCodingOption) {
        offset = (FrameNoInFile / 2) * ((width * height * 2) * 3 / 2) + (FrameNoInFile % 2 ? width : 0);
    } else {
        offset = FrameNoInFile * width * height * 3 / 2;
    }
    _lseeki64(fd, offset, SEEK_SET);

    buf = (unsigned char *)img->plane[0];
	read_size += _read(fd, buf, width * height);

   if (input->InterlaceCodingOption) {
	   _lseeki64(fd, width, SEEK_CUR);
   }

    if (input->InterlaceCodingOption && FrameNoInFile % 2) {
		_lseeki64(fd, -width, SEEK_CUR);
    }

    buf = (unsigned char *)img->plane[1];
    read_size += _read(fd, buf, width * height / 4);

    if (input->InterlaceCodingOption) {
		_lseeki64(fd, width / 2, SEEK_CUR);
    }


    if (input->InterlaceCodingOption && FrameNoInFile % 2) {
        _lseeki64(fd, -width / 2, SEEK_CUR);
    }

    buf = (unsigned char *)img->plane[2];
    read_size += _read(fd, buf, width * height / 4);

    if (input->InterlaceCodingOption) {
		_lseeki64(fd, width / 2, SEEK_CUR);
    }

    if (read_size != (size_t)(width * height * 3 / 2)) {
        return 0;
    }

    if (input->auto_crop_right) {
        buf = (unsigned char *)img->plane[0];
        for (i = 0; i < height; i++) {
            for (j = width; j < input->img_width; j++) {
                buf[j] = buf[width - 1];
            }
            buf += img->i_stride[0];
        }
        buf = (unsigned char *)img->plane[1];
        for (i = 0; i < height / 2; i++) {
            for (j = width / 2; j < input->img_width / 2; j++) {
                buf[j] = buf[width / 2 - 1];
            }
            buf += img->i_stride[1];
        }
        buf = (unsigned char *)img->plane[2];
        for (i = 0; i < height / 2; i++) {
            for (j = width / 2; j < input->img_width / 2; j++) {
                buf[j] = buf[width / 2 - 1];
            }
            buf += img->i_stride[2];
        }
    }
    if (input->auto_crop_bottom) {
        unsigned char *src;
        
        src = (unsigned char *)img->plane[0] + (height - 1) * img->i_stride[0];
        buf = src + img->i_stride[0];

        for (i = 0; i < input->auto_crop_bottom; i++) {
            memcpy(buf, src, img->i_stride[0]);
            buf += img->i_stride[0];
        }

        src = (unsigned char *)img->plane[1] + (height / 2 - 1) * img->i_stride[1];
        buf = src + img->i_stride[1];

        for (i = 0; i < input->auto_crop_bottom / 2; i++) {
            memcpy(buf, src, img->i_stride[1]);
            buf += img->i_stride[1];
        }

        src = (unsigned char *)img->plane[2] + (height / 2 - 1) * img->i_stride[2];
        buf = src + img->i_stride[2];

        for (i = 0; i < input->auto_crop_bottom / 2; i++) {
            memcpy(buf, src, img->i_stride[2]);
            buf += img->i_stride[2];
        }
    }

#if COMPILE_10BIT
    {
        int plane_size;

        plane_size = img->i_stride[0] * input->img_height;
        buf = (unsigned char *)img->plane[0];

        for (i = plane_size - 1; i >= 0; i--) {
            img->plane[0][i] = buf[i] << shift_bits;
        }

        plane_size = img->i_stride[1] * input->img_height / 2;
        buf = (unsigned char *)img->plane[1];

        for (i = plane_size - 1; i >= 0; i--) {
            img->plane[1][i] = buf[i] << shift_bits;
        }

        plane_size = img->i_stride[2] * input->img_height / 2;
        buf = (unsigned char *)img->plane[2];

        for (i = plane_size - 1; i >= 0; i--) {
            img->plane[2][i] = buf[i] << shift_bits;
        }
    }
#endif

    return 1;
}

int ReadOneFrame_10bit(image_t *img, int fd, cfg_param_t *input, long long FrameNoInFile)
{
    int i, j;
    int width  = input->img_width  - input->auto_crop_right;
    int height = input->img_height - input->auto_crop_bottom;
    pel_t *buf;
    int read_size = 0;

    img->pts = FrameNoInFile * 40; // only for test

#if SKIP_FRAMES
    FrameNoInFile += skip_frame;
#endif

    long long offset;

    if (input->InterlaceCodingOption) {
        offset = (FrameNoInFile / 2) * ((width * height * 2) * 3 / 2) + (FrameNoInFile % 2 ? width : 0);
    }
    else {
        offset = FrameNoInFile * width * height * 3 / 2;
    }
    _lseeki64(fd, offset * 2, SEEK_SET);

    buf = img->plane[0];
    read_size += _read(fd, buf, width * height * 2);

    if (input->InterlaceCodingOption) {
        _lseeki64(fd, width * 2, SEEK_CUR);
    }

    if (input->InterlaceCodingOption && FrameNoInFile % 2) {
        _lseeki64(fd, -width * 2, SEEK_CUR);
    }

    buf = img->plane[1];
    read_size += _read(fd, buf, width * height / 2);

        if (input->InterlaceCodingOption) {
            _lseeki64(fd, width / 2 * 2, SEEK_CUR);
        }

    if (input->InterlaceCodingOption && FrameNoInFile % 2) {
        _lseeki64(fd, -width / 2 * 2, SEEK_CUR);
    }

    buf = img->plane[2];
    read_size += _read(fd, buf, width * height / 2);

        if (input->InterlaceCodingOption) {
            _lseeki64(fd, width / 2 * 2, SEEK_CUR);
        }


    if (read_size != (size_t)(width * height * 3 / 2 * 2)) {
        return 0;
    }

    if (input->auto_crop_right) {
        buf = img->plane[0];
        for (i = 0; i < height; i++) {
            for (j = width; j < input->img_width; j++) {
                buf[j] = buf[width - 1];
            }
            buf += img->i_stride[0];
        }
        buf = img->plane[1];
        for (i = 0; i < height / 2; i++) {
            for (j = width / 2; j < input->img_width / 2; j++) {
                buf[j] = buf[width / 2 - 1];
            }
            buf += img->i_stride[1];
        }
        buf = img->plane[2];
        for (i = 0; i < height / 2; i++) {
            for (j = width / 2; j < input->img_width / 2; j++) {
                buf[j] = buf[width / 2 - 1];
            }
            buf += img->i_stride[2];
        }
    }
    if (input->auto_crop_bottom) {
        pel_t *src;

        src = img->plane[0] + (height - 1) * img->i_stride[0];
        buf = src + img->i_stride[0];

        for (i = 0; i < input->auto_crop_bottom; i++) {
            memcpy(buf, src, img->i_stride[0] * 2);
            buf += img->i_stride[0];
        }

        src = img->plane[1] + (height / 2 - 1) * img->i_stride[1];
        buf = src + img->i_stride[1];

        for (i = 0; i < input->auto_crop_bottom / 2; i++) {
            memcpy(buf, src, img->i_stride[1] * 2);
            buf += img->i_stride[1];
        }

        src = img->plane[2] + (height / 2 - 1) * img->i_stride[2];
        buf = src + img->i_stride[2];

        for (i = 0; i < input->auto_crop_bottom / 2; i++) {
            memcpy(buf, src, img->i_stride[2] * 2);
            buf += img->i_stride[2];
        }
    }

    return 1;
}

#if SPEED_TEST
void *mem_copy(void* list)
{
    listt *tt = (listt *)list;
    memcpy(tt->list[1], tt->list[0], tt->height * tt->width / 2);
    return NULL;
}

int ReadOneth_10bit(avs3_threadpool_t *mem, image_t *img, unsigned char *fd, cfg_param_t *input, int i)
{
    listt *listx[6];
    int width = input->img_width - input->auto_crop_right;
    int height = input->img_height - input->auto_crop_bottom;

    if (i > 49)
    {
        return 0;
    }

    for (i = 0; i < 6; i++)
    {
        listx[i] = malloc(sizeof(listt));
        listx[i]->list[0] = fd + width * height / 2 * i;
        switch (i)
        {
        case 0:
            listx[i]->list[1] = (unsigned char *)img->plane[0];
            break;
        case 1:
            listx[i]->list[1] = (unsigned char *)img->plane[0] + width * height / 2;
            break;
        case 2:
            listx[i]->list[1] = (unsigned char *)img->plane[0] + width * height;
            break;
        case 3:
            listx[i]->list[1] = (unsigned char *)img->plane[0] + width * height * 3 / 2;
            break;
        case 4:
            listx[i]->list[1] = (unsigned char *)img->plane[1];
            break;
        case 5:
            listx[i]->list[1] = (unsigned char *)img->plane[2];
            break;
        }
        listx[i]->width = width;
        listx[i]->height = height;
        avs3_threadpool_run(mem, mem_copy, listx[i], 1);
    }
    for (i = 0; i < 6; i++)
    {
        avs3_threadpool_wait(mem, listx[i]);
    }

    return 1;
}
#endif

void information_init(cfg_param_t *input)
{
    if (input->img_width % 32 != 0) {
        input->auto_crop_right = 32 - input->img_width % 32;
    }
    else {
        input->auto_crop_right = 0;
    }
    if (input->img_height % 32 != 0) {
        input->auto_crop_bottom = 32 - input->img_height % 32;
    }
    else {
        input->auto_crop_bottom = 0;
    }
    input->img_width += input->auto_crop_right;
    input->img_height += input->auto_crop_bottom;
    printf("-----------------------------------------------------------------------------\n");
    printf(" Input YUV file                    : %s \n", input->infile);
    printf(" Output AVS bitstream              : %s \n", input->outfile);
    printf(" Output YUV file                   : %s \n", input->ReconFile);
    printf("\n\n");
    printf("==========  Frame Info Log Start ========== \n");
    printf("   Num  POC T    QP      Bits       PSNR(y,u,v)       Time \n\n");
}

static long long frm_num = 0;

void Report_frame(int frm_type, long long idx, int bits, double qp, double snr_y, double snr_u, double snr_v, int tmp_time, signed char* ext_info)
{
#if !TEST_SPEED
	signed char *type;

	static signed char frm_type_name[][8] = { " I", " P", " B", " F", " S", " G", "GB", "ER" };

    switch (frm_type) {
    case I_FRM:
        type = frm_type_name[0]; break;
    case P_FRM:
        type = frm_type_name[1]; break;
    case B_FRM:
        type = frm_type_name[2]; break;
    case F_FRM:
        type = frm_type_name[3]; break;
    case S_FRM:
        type = frm_type_name[4]; break;
    case G_FRM:
        type = frm_type_name[5]; break;
    case GB_FRM:
        type = frm_type_name[6]; break;
    default:
        type = frm_type_name[7]; break;
    }

    printf("%5lld %4lld %s %5.2f %8d %7.4f %7.4f %7.4f %4d Ext:%s\n",frm_num, idx, type, qp, bits, snr_y, snr_u, snr_v, tmp_time, ext_info);

#endif
    frm_num++;
}


#if defined(_MSC_VER) && TEST_SPEED
#pragma warning(disable: 4100)  // unreferenced formal parameter
#endif

void callback_output_rec(void *priv_data, image_t *rec, image_t *org, image_t *trace, int frm_type, long long idx, int bits, double qp, int time, signed char* ext_info)
{
    double psnr_y, psnr_u, psnr_v;

    avs3_find_psnr(&input, org, rec, &psnr_y, &psnr_u, &psnr_v);
    Report_frame(frm_type, idx, bits, qp, psnr_y, psnr_u, psnr_v, time, ext_info);

    all_psnr_y += psnr_y;
    all_psnr_u += psnr_u;
    all_psnr_v += psnr_v;

    total_time += time;
}

void callback_output_bitstream(void* priv_data, unsigned char *buf, int len, long long pts, long long dts, int type)
{
    total_bits += len * 8;

    if (type == PIC_HDR && INSERT_MD5) {
        total_bits -= 23 * 8;
    }

    if (fd_bitstream > 0) {
        _write(fd_bitstream, buf, len);
    }
}


static void uavs3e_set_default_param(cfg_param_t *cfg)
{
    int i;
    int num = sizeof(tab_cfg_map) / sizeof(Mapping);

    memset(cfg, 0, sizeof(cfg_param_t));

    for (i = 0; i < num; i++) {
        *(int *)((char*)cfg + tab_cfg_map[i].offset) = tab_cfg_map[i].Value;
    }

    memcpy(&cfg->seq_ref_cfg, &RA_RPS, sizeof(RA_RPS));
}

int main(int argc, char **argv)
{
    int fd_in = 0;
    long long check_time=0;
    int i;
    void *handle;
    
    srand((int)time(0));
    uavs3e_set_default_param(&input);

#if SKIP_FRAMES
    skip_frame = atoi(argv[1]);
    Configure(&input, argc - 1, argv+1);
#else
    Configure(&input, argc, argv);
#endif

#if defined(__GNUC__)
    int j, k;
    cpu_set_t mask1, mask2, mask3, mask4, mask5, mask6, mask7, mask8, mask9, mask10, mask11, mask12, mask13, mask14, mask15, mask16;
    void *mask_list[16] = { &mask1, &mask2, &mask3, &mask4, &mask5, &mask6, &mask7, &mask8, &mask9, &mask10, &mask11, &mask12, &mask13, &mask14, &mask15, &mask16 };

    CPU_ZERO(&mask1);
    CPU_ZERO(&mask2);
    CPU_ZERO(&mask3);
    CPU_ZERO(&mask4);
    CPU_ZERO(&mask5);
    CPU_ZERO(&mask6);
    CPU_ZERO(&mask7);
    CPU_ZERO(&mask8);
    CPU_ZERO(&mask9);
    CPU_ZERO(&mask10);
    CPU_ZERO(&mask11);
    CPU_ZERO(&mask12);
    CPU_ZERO(&mask13);
    CPU_ZERO(&mask14);
    CPU_ZERO(&mask15);
    CPU_ZERO(&mask16);

    for (i = 0; i < ((input.threads_gop - 1) / input.node_num) + 1; i++)
    {
        for (j = 0; j < input.node_num; j++)
        {
            for (k = 0; k < input.core_in_node[j]; k++)
            {
                CPU_SET(input.node[j][k], (cpu_set_t*)mask_list[j + (i * input.node_num)]);
            }
        }
    }

    handle = avs3gop_lib_create(&input, callback_output_bitstream, callback_output_rec, NULL, input.threads_gop, mask_list);
#else
    handle = avs3gop_lib_create(&input, callback_output_bitstream, callback_output_rec, NULL, 2, NULL);
#endif

    shift_bits = input.bit_depth - 8;

    fd_bitstream = _open(input.outfile, O_WRONLY | O_CREAT | O_BINARY | O_TRUNC, S_IREAD | S_IWRITE);

    if (strlen(input.infile) > 0 && (fd_in = _open(input.infile, O_RDONLY | O_BINARY)) <= 0) {
        printf("Input file %s does not exist", input.infile);
        return 0;
    }

    information_init(&input);

    check_time = get_mdate();
#if SPEED_TEST
    ReadOneth = ReadOneth_10bit;
#else
    if (input.sample_bit_depth == 8) {
        ReadOneFrame = ReadOneFrame_8bit;
    } else {
        ReadOneFrame = ReadOneFrame_10bit;
    }
#endif

    avs3gop_lib_speed_adjust(handle, 1);

#if SPEED_TEST
    avs3_threadpool_t *mem_threadpool;
    mem_threadpool = avs3_threadpool_init(6, 6, NULL, NULL);

    int repeat = 100;
    long long read_size;

    unsigned char* buffer[5];

    for (i = 0; i < 5; i++)
    {
        buffer[i] = malloc(2 * input.img_width * input.img_height * 15);
        read_size = _read(fd_in, buffer[i], 2 * input.img_width*input.img_height * 15);
    }

    for (i = 0; i < input.no_frames; i++) {
        if (!ReadOneth(mem_threadpool, avs3gop_lib_imgbuf(handle), buffer[i/10] + i%10 * 3 * input.img_width*input.img_height, &input, i)) {
            if (repeat--) {
                i= 0;
                ReadOneth(mem_threadpool, avs3gop_lib_imgbuf(handle), buffer[i/10] + i%10 * 3 * input.img_width*input.img_height, &input, i);
            } else {
                break;
            }
        }
        
        avs3gop_lib_encode(handle, 0, 0);
        total_frms++;
    }

#else
    int repeat = 0;

    for (i = 0; i < input.no_frames; i++) {
        if (!ReadOneFrame(avs3gop_lib_imgbuf(handle), fd_in, &input, i)) {
            if (repeat--) {
                i = 0;
                ReadOneFrame(avs3gop_lib_imgbuf(handle), fd_in, &input, i);
            }
            else {
                break;
            }
        }

        avs3gop_lib_encode(handle, 0, 0);
        total_frms++;       
    }
#endif

    /* flush left frames */
    avs3gop_lib_encode(handle, 1, 1);
    avs3gop_lib_free(handle);

    check_time = (get_mdate() - check_time) / 1000;

    report(&input, (int)check_time);

    printf("total time: %.2f (%.2f fps)\n\n", check_time * 0.001, total_frms * 1000.0 / check_time);


    _close(fd_in);

    if (fd_bitstream > 0) {
        _close(fd_bitstream);
    }

    return 0;
}
