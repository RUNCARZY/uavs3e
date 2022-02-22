#include "arm64.h"
#if defined(__arm64__)
#include "sao_kernel_arm64.h"

ALIGNED_32(pel_t uavs3e_sao_mask[16 * 16]) = {
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0
};

#if 0
void sao_getStatblk_eo_0_c(pel_t* rec, pel_t* org, int i_rec, int i_org, i16s_t* pdiff, i16u_t* pedgetype, int start_x, int end_x, int end_y)
{
    int diff;
    char_t leftsign, rightsign;
    int edgetype;
    int width = end_x - start_x;
    
    for (int y = 0; y < end_y; y++) {
        diff = rec[start_x] - rec[start_x - 1];
        leftsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        for (int x = start_x; x < end_x; x++) {
            diff = rec[x] - rec[x + 1];
            rightsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            edgetype = leftsign + rightsign;
            leftsign = -rightsign;
            pdiff[x + width * y] = (org[x] - rec[x]);
            pedgetype[x + width * y] = edgetype + 2;
        }
        org += i_org;
        rec += i_rec;
    }
}

void sao_getStatblk_eo_90_c(pel_t* rec_base, pel_t* org_base, int i_rec, int i_org, i16s_t* pdiff, i16u_t* pedgetype, int end_x, int start_y, int end_y)
{
    pel_t* org;
    pel_t* rec;
    int diff;
    char_t upsign, downsign;
    int edgetype;
    for (int x = 0; x < end_x; x++) {
        diff = rec[0] - rec[-i_rec];

        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        for (int y = start_y; y < end_y; y++) {
            diff = rec[0] - rec[i_rec];
            downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            edgetype = downsign + upsign;
            upsign = -downsign;
            pdiff[x + end_x * y] = (org[0] - rec[0]);
            pedgetype[x + end_x * y] = edgetype + 2;
            org += i_org;
            rec += i_rec;
        }
    }
}

void sao_getStatblk_eo_135_c(pel_t* rec, pel_t* org, int i_rec, int i_org, i16s_t* pdiff, i16u_t* pedgetype, int lcu_pix_height, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
{
    int diff;
    int x=0, y=0;
    char_t upsign, downsign;
    char_t signupline[69];
    int edgetype;
    int reg=0;
    //init the line buffer
    for (int x = start_x_r + 1; x < end_x_r + 1; x++) {
        diff = rec[x + i_rec] - rec[x - 1];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        signupline[x] = upsign;
    }
    //first row
    for (int x = start_x_r0; x < end_x_r0; x++) {
        diff = rec[x] - rec[x - 1 - i_rec];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        edgetype = upsign - signupline[x + 1];
        pdiff[x] = (org[x] - rec[x]);
        pedgetype[x] = edgetype + 2;
    }

    //middle rows
    org += i_org;
    rec += i_rec;

    for (y = 1; y < lcu_pix_height - 1; y++) {
        for (x = start_x_r; x < end_x_r; x++) {
            if (x == start_x_r) {
                diff = rec[x] - rec[x - 1 - i_rec];
                upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
                signupline[x] = upsign;
            }
            diff = rec[x] - rec[x + 1 + i_rec];
            downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            edgetype = downsign + signupline[x];
            pdiff[x + y * 36] = (org[x] - rec[x]);
            pedgetype[x + y * 36] = edgetype + 2;
            signupline[x] = (char_t)reg;
            reg = -downsign;
        }
        org += i_org;
        rec += i_rec;
    }
    //last row
    if (lcu_pix_height == 0) {
        org -= i_org * 2;
        rec -= i_rec * 2;
    }

    for (x = start_x_rn; x < end_x_rn; x++) {
        if (x == start_x_r) {
            diff = rec[x] - rec[x - 1 - i_rec];
            upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            signupline[x] = upsign;
        }
        diff = rec[x] - rec[x + 1 + i_rec];
        downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        edgetype = downsign + signupline[x];
        pdiff[x + (lcu_pix_height - 1) *  36] = (org[x] - rec[x]);
        pedgetype[x + (lcu_pix_height - 1) *  36] = edgetype + 2;
    }
}

void sao_getStatblk_eo_45_c(pel_t* rec, pel_t* org, int i_rec, int i_org, i16s_t* pdiff, i16u_t* pedgetype, int lcu_pix_height, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
{
    int diff;
    int x=0, y=0;
    char_t upsign, downsign;
    char_t signupline[69];
    int edgetype;
    char_t *signupline1;
    signupline1 = signupline + 1;
    for (x = start_x_r - 1; x < max(end_x_r - 1, end_x_r0 - 1); x++) {
        diff = rec[x + i_rec] - rec[x + 1];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        signupline1[x] = upsign;
    }
    //first row
    for (x = start_x_r0; x < end_x_r0; x++) {
        diff = rec[x] - rec[x - i_rec + 1];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        edgetype = upsign - signupline1[x - 1];
        pdiff[x] = (org[x] - rec[x]);
        pedgetype[x] = edgetype + 2;
    }
    
    //middle rows
    org += i_org;
    rec += i_rec;
    
    for (y = 1; y < lcu_pix_height - 1; y++) {
        for (x = start_x_r; x < end_x_r; x++) {
            if (x == end_x_r - 1) {
                diff = rec[x] - rec[x + 1 - i_rec];
                upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
                signupline1[x] = upsign;
            }
            diff = rec[x] - rec[x - 1 + i_rec];
            downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            edgetype = downsign + signupline1[x];
            pdiff[x + y * 36] = (org[x] - rec[x]);
            pedgetype[x + y * 36] = edgetype + 2;
            signupline1[x - 1] = -downsign;
        }
        org += i_org;
        rec += i_rec;
    }
    if (lcu_pix_height == 0) {
        org -= i_org * 2;
        rec -= i_rec * 2;
    }
    for (x = start_x_rn; x < end_x_rn; x++) {
        if (x == end_x_r - 1) {
            diff = rec[x] - rec[x + 1 - i_rec];
            upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            signupline1[x] = upsign;
        }
        diff = rec[x] - rec[x - 1 + i_rec];
        downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        edgetype = downsign + signupline1[x];
        pdiff[x + (lcu_pix_height - 1) * 36] = (org[x] - rec[x]);
        pedgetype[x + (lcu_pix_height - 1) * 36] = edgetype + 2;
    }
    
}

void sao_getStatblk_arm64(void *handle, void *sao_data, int compIdx, const int pix_y, const int pix_x, int lcu_pix_height, int lcu_pix_width, int smb_available_left, int smb_available_right, int smb_available_up, int smb_available_down)
{
    avs3_enc_t *h = (avs3_enc_t*)handle;
    SAOStatData *saostatsData = (SAOStatData*)sao_data;
    int type;
    int start_x, end_x, start_y, end_y;
    int start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn;
    int x, y;
    SAOStatData *statsDate;
    pel_t *org_base, *rec_base;
    pel_t *rec, *org;
    int i_rec, i_org;
    int bit_depth = h->input->bit_depth;
    int smb_available_upleft = (smb_available_up && smb_available_left);
    int smb_available_upright = (smb_available_up && smb_available_right);
    int smb_available_leftdown = (smb_available_down && smb_available_left);
    int smb_available_rightdwon = (smb_available_down && smb_available_right);
    ALIGNED_16(i16s_t pdiff[36 * 36 + 32]);
    ALIGNED_16(i16u_t pedgetype[36 * 36 + 32]);
    int etype;
    int width;
    
    i_rec = h->img_rec->i_stride[compIdx];
    i_org = h->img_org->i_stride[compIdx];

    for (type = 0; type < NUM_SAO_NEW_TYPES; type++) {
        rec = h->img_rec->plane[compIdx] + pix_y * i_rec + pix_x;
        org = h->img_org->plane[compIdx] + pix_y * i_org + pix_x;

        statsDate = &(saostatsData[type]);
        switch (type) {
        case SAO_TYPE_EO_0:
            end_y = lcu_pix_height;
            start_x = smb_available_left ? 0 : 1;
            end_x = smb_available_right ? lcu_pix_width : (lcu_pix_width - 1);
            width = end_x-start_x;
            sao_getStatblk_eo_0_arm64(rec, org, i_rec, i_org, pdiff, pedgetype, start_x, end_x, end_y);
            //sao_getStatblk_eo_0_c(rec, org, i_rec, i_org, pdiff, pedgetype, start_x, end_x, end_y);
            for(y=0; y < end_y; y++){
                for(x = start_x; x < end_x; x++){
                    etype = pedgetype[x + width * y];
                    statsDate->diff[etype] += pdiff[x + width * y];
                    statsDate->count[etype]++;
                }
            }
            break;
        case SAO_TYPE_EO_90:
            end_x = lcu_pix_width;
            start_y = smb_available_up ? 0 : 1;
            end_y = smb_available_down ? lcu_pix_height : (lcu_pix_height - 1);

            org_base = org + start_y * i_org;
            rec_base = rec + start_y * i_rec;
            sao_getStatblk_eo_90_arm64(rec_base, org_base, i_rec, i_org, pdiff, pedgetype, end_x, start_y, end_y);
            //sao_getStatblk_eo_90_c(rec_base, org_base, i_rec, i_org, pdiff, pedgetype, end_x, start_y, end_y);
            for(x=0; x < end_x; x++){
                for(y = 0; y < (end_y - start_y); y++){
                    etype = pedgetype[x + end_x * y];
                    statsDate->diff[etype] += pdiff[x + end_x * y];
                    statsDate->count[etype]++;
                }
            }
            break;
        case SAO_TYPE_EO_135:
            start_x_r0 = smb_available_upleft ? 0 : 1;
            end_x_r0 = smb_available_up ? (smb_available_right ? lcu_pix_width : (lcu_pix_width - 1)) : 1;
            start_x_r = smb_available_left ? 0 : 1;
            end_x_r = smb_available_right ? lcu_pix_width : (lcu_pix_width - 1);
            start_x_rn = smb_available_down ? (smb_available_left ? 0 : 1) : (lcu_pix_width - 1);
            end_x_rn = smb_available_rightdwon ? lcu_pix_width : (lcu_pix_width - 1);
            sao_getStatblk_eo_135_arm64(rec, org, i_rec, i_org, pdiff, pedgetype, lcu_pix_height, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            //sao_getStatblk_eo_135_c(rec, org, i_rec, i_org, pdiff, pedgetype, lcu_pix_height, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            for(int x = start_x_r0; x < end_x_r0; x++){
                etype = pedgetype[x];
                statsDate->diff[etype] += pdiff[x];
                statsDate->count[etype]++;
            }
            for(int y = 1; y < lcu_pix_height - 1; y++){
                for(x = start_x_r; x < end_x_r; x++){
                    etype = pedgetype[x + y * 36];
                    statsDate->diff[etype] += pdiff[x + y * 36];
                    statsDate->count[etype]++;
                }
            }
            for(x = start_x_rn; x < end_x_rn; x++) {
                etype = pedgetype[x + (lcu_pix_height - 1) *  36];
                statsDate->diff[etype] += pdiff[x + (lcu_pix_height - 1) *  36];
                statsDate->count[etype]++;
            }
            break;
        case SAO_TYPE_EO_45:
            start_x_r0 = smb_available_up ? (smb_available_left ? 0 : 1) : (lcu_pix_width - 1);
            end_x_r0 = smb_available_upright ? lcu_pix_width : (lcu_pix_width - 1);
            start_x_r = smb_available_left ? 0 : 1;
            end_x_r = smb_available_right ? lcu_pix_width : (lcu_pix_width - 1);
            start_x_rn = smb_available_leftdown ? 0 : 1;
            end_x_rn = smb_available_down ? (smb_available_right ? lcu_pix_width : (lcu_pix_width - 1)) : 1;
            sao_getStatblk_eo_45_arm64(rec, org, i_rec, i_org, pdiff, pedgetype, lcu_pix_height, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            //sao_getStatblk_eo_45_c(rec, org, i_rec, i_org, pdiff, pedgetype, lcu_pix_height, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
                
            for(int x = start_x_r0; x < end_x_r0; x++){
                etype = pedgetype[x];
                statsDate->diff[etype] += pdiff[x];
                statsDate->count[etype]++;
            }
            for(int y = 1; y < lcu_pix_height - 1; y++){
                for(x = start_x_r; x < end_x_r; x++){
                    etype = pedgetype[x + y * 36];
                    statsDate->diff[etype] += pdiff[x + y * 36];
                    statsDate->count[etype]++;
                }
            }
            for(x = start_x_rn; x < end_x_rn; x++) {
                etype = pedgetype[x + (lcu_pix_height - 1) *  36];
                statsDate->diff[etype] += pdiff[x + (lcu_pix_height - 1) *  36];
                statsDate->count[etype]++;
            }
            break;
        default:
            printf("Not a supported SAO types\n");
            assert(0);
            exit(-1);

        }
    }
}

#endif

void sao_on_lcu_arm64(void *handle, void *sao_data, int compIdx, int pix_y, int pix_x, int height, int width, int available_left, int available_right, int available_up, int available_down)
{
    avs3_enc_t *h = (avs3_enc_t *)handle;
    SAOBlkParam *saoBlkParam = (SAOBlkParam *)sao_data;
    pel_t *src, *dst;
    int i_src, i_dst;
    i_src = h->img_sao.i_stride[compIdx];
    i_dst = h->img_rec->i_stride[compIdx];
    src = h->img_sao.plane[compIdx] + pix_y * i_src + pix_x;
    dst = h->img_rec->plane[compIdx] + pix_y * i_dst + pix_x;
    int type;
    int start_x, end_x, start_y, end_y;
    int start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn;
    int bit_depth = h->input->bit_depth;

    type = saoBlkParam->typeIdc;

    switch (type) {
        case SAO_TYPE_EO_0: {
            start_x = available_left ? 0 : 1;
            end_x = available_right ? width : (width - 1);
            sao_eo_0_arm64(src, dst, i_src, i_dst, saoBlkParam->offset, start_x, end_x, height, uavs3e_sao_mask, bit_depth);
            //SAO_EO_0_c(src, dst, i_src, i_dst, sao_params->offset, start_x, end_x, smb_pix_height, uavs3e_sao_mask, bit_depth);
            break;
        }
        case SAO_TYPE_EO_90: {
            start_y = available_up ? 0 : 1;
            end_y = available_down ? height : (height - 1);
            sao_eo_90_arm64(src, dst, i_src, i_dst, saoBlkParam->offset, start_y, end_y, width, bit_depth);
            //SAO_EO_90_c(src, dst, i_src, i_dst, sao_params->offset, start_y, end_y, smb_pix_width, bit_depth);
            break;
        }
        case SAO_TYPE_EO_135: {
            start_x_r0 = (available_up && available_left) ? 0 : 1;
            end_x_r0 = available_up ? (available_right ? width : (width - 1)) : 1;
            start_x_r = available_left ? 0 : 1;
            end_x_r = available_right ? width : (width - 1);
            start_x_rn = available_down ? (available_left ? 0 : 1) : (width - 1);
            end_x_rn = (available_right && available_down) ? width : (width - 1);

            sao_eo_135_arm64(src, dst, i_src, i_dst, saoBlkParam->offset, uavs3e_sao_mask, height, bit_depth, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            //SAO_EO_135_c(src, dst, i_src, i_dst, sao_params->offset, uavs3e_sao_mask, smb_pix_height, bit_depth, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            break;
        }
        case SAO_TYPE_EO_45: {
            start_x_r0 = available_up ? (available_left ? 0 : 1) : (width - 1);
            end_x_r0 = (available_up && available_right) ? width : (width - 1);
            start_x_r = available_left ? 0 : 1;
            end_x_r = available_right ? width : (width - 1);
            start_x_rn = (available_left && available_down) ? 0 : 1;
            end_x_rn = available_down ? (available_right ? width : (width - 1)) : 1;
            sao_eo_45_arm64(src, dst, i_src, i_dst, saoBlkParam->offset, uavs3e_sao_mask, height, bit_depth, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            //SAO_EO_45_c(src, dst, i_src, i_dst, sao_params->offset, uavs3e_sao_mask, smb_pix_height, bit_depth, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            break;
        }
        default:{
            fprintf(stderr, "Not a supported SAO types\n");
            assert(0);
            exit(-1);
        }
    }
}

#endif
