#include "arm64.h"
#if defined(__arm64__)
#ifndef __SAO_ARM64_H__
#define __SAO_ARM64_H__


void sao_eo_0_arm64(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_x, int end_x, int mb_height, pel_t* mask, int bit_depth);
void sao_eo_90_arm64(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_y, int end_y, int mb_width, int bit_depth);
void sao_eo_135_arm64(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, pel_t* mask, int mb_height, int bit_depth, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn);
void sao_eo_45_arm64(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, pel_t* mask, int mb_height, int bit_depth, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn);

void sao_getStatblk_eo_0_arm64(pel_t* rec, pel_t* org, int i_rec, int i_org, i32s_t* pdiff, i32s_t* pedgetype, int start_x, int end_x, int end_y, pel_t* mask);
void sao_getStatblk_eo_90_arm64(pel_t* rec_base, pel_t* org_base, int i_rec, int i_org, i32s_t* pdiff, i32s_t* pedgetype, int end_x, int start_y, int end_y);
void sao_getStatblk_eo_135_arm64(pel_t* rec, pel_t* org, int i_rec, int i_org, i32s_t* pdiff, i32s_t* pedgetype, int lcu_pix_height, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn, pel_t* mask);
void sao_getStatblk_eo_45_arm64(pel_t* rec, pel_t* org, int i_rec, int i_org, i32s_t* pdiff, i32s_t* pedgetype, int lcu_pix_height, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn, pel_t* mask);

#endif
#endif
