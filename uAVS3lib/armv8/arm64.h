#if defined(__aarch64__) && !defined(__arm64__)
#define __arm64__ 1
#endif

#if defined(__arm64__)
#ifndef __ARM64_H__
#define __ARM64_H__

#include "../common.h"
i32u_t xGetSAD8_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height, int skip_lines);
i32u_t xGetSAD16_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height, int skip_lines);
i32u_t xGetSAD32_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height, int skip_lines);
i32u_t xGetSAD64_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height, int skip_lines);

void xGetSAD8_x4_arm64(pel_t *p_org, int i_org, pel_t *pred0, pel_t *pred1, pel_t *pred2, pel_t *pred3, int i_pred, i32u_t sad[4], int height, int skip_lines);
void xGetSAD16_x4_arm64(pel_t *p_org, int i_org, pel_t *pred0, pel_t *pred1, pel_t *pred2, pel_t *pred3, int i_pred, i32u_t sad[4], int height, int skip_lines);
void xGetSAD32_x4_arm64(pel_t *p_org, int i_org, pel_t *pred0, pel_t *pred1, pel_t *pred2, pel_t *pred3, int i_pred, i32u_t sad[4], int height, int skip_lines);

i32u_t xGetAVGSAD8_arm64(pel_t *p_org, int i_org, pel_t *pred1, int i_pred1, pel_t *p_pred2, int i_pred2, int height, int skip_lines);
i32u_t xGetAVGSAD16_arm64(pel_t *p_org, int i_org, pel_t *pred1, int i_pred1, pel_t *p_pred2, int i_pred2, int height, int skip_lines);
i32u_t xGetAVGSAD32_arm64(pel_t *p_org, int i_org, pel_t *pred1, int i_pred1, pel_t *p_pred2, int i_pred2, int height, int skip_lines);

i32u_t xGetSSE8_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height);
i32u_t xGetSSE16_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height);
i32u_t xGetSSE32_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height);

i64u_t xGetSSE_Psnr_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int iWidth, int iHeight);

i32u_t xCalcHAD8x8_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred);

void avg_pel_4_arm64(pel_t *dst, int i_dst, pel_t *src1, int i_src1, pel_t *src2, int i_src2, int width, int height);
void avg_pel_8_arm64(pel_t *dst, int i_dst, pel_t *src1, int i_src1, pel_t *src2, int i_src2, int width, int height);
void avg_pel_16_arm64(pel_t *dst, int i_dst, pel_t *src1, int i_src1, pel_t *src2, int i_src2, int width, int height);
void avg_pel_32_arm64(pel_t *dst, int i_dst, pel_t *src1, int i_src1, pel_t *src2, int i_src2, int width, int height);
void avg_pel_64_arm64(pel_t *dst, int i_dst, pel_t *src1, int i_src1, pel_t *src2, int i_src2, int width, int height);

void com_mem_cpy4_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height);
void com_mem_cpy8_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height);
void com_mem_cpy16_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height);
void com_mem_cpy32_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height);
void com_mem_cpy64_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height);

void com_if_filter_hor_8_arm64(const pel_t *src, int i_src, pel_t *dst[3], int i_dst, i16s_t *dst_tmp[3], int i_dst_tmp, int width, int height, tab_char_t (*coeff)[8], int bit_depth);
void com_if_filter_ver_8_arm64(const pel_t *src, int i_src, pel_t *dst[3], int i_dst, int width, int height, tab_char_t (*coeff)[8], int bit_depth);
void com_if_filter_ver_8_ext_arm64(const i16s_t *src, int i_src, pel_t *dst[3], int i_dst, int width, int height, tab_char_t (*coeff)[8], int bit_depth);

void com_if_filter_hor_4_w4_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
void com_if_filter_hor_4_w8_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
void com_if_filter_hor_4_w16_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);

void com_if_filter_ver_4_w4_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
void com_if_filter_ver_4_w8_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
void com_if_filter_ver_4_w16_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);

void com_if_filter_hor_ver_4_w4_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, const char_t *coeff_h, const char_t *coeff_v, int bit_depth);
void com_if_filter_hor_ver_4_w8_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, const char_t *coeff_h, const char_t *coeff_v, int bit_depth);
void com_if_filter_hor_Ver_4_w16_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, const char_t *coeff_h, const char_t *coeff_v, int bit_depth);

void sub_trans_4x4_arm64(pel_t *org, int i_org, pel_t *pred, int i_pred, coef_t *dst, int shift);
void sub_trans_8x8_arm64(pel_t *org, int i_org, pel_t *pred, int i_pred, coef_t *dst, int shift);

void sub_trans_8x8_arm64_8bit(pel_t *org, int i_org, pel_t *pred, int i_pred, coef_t *dst, int shift);
void sub_trans_16x16_arm64(pel_t *org, int i_org, pel_t *pred, int i_pred, coef_t *dst, int shift);
void sub_trans_32x32_arm64(pel_t *org, int i_org, pel_t *pred, int i_pred, coef_t *dst, int shift);

void add_inv_trans_4x4_arm64(coef_t *src, pel_t *pred, int i_pred, pel_t *dst, int i_dst, int bit_depth);
void add_inv_trans_8x8_arm64(coef_t *src, pel_t *pred, int i_pred, pel_t *dst, int i_dst, int bit_depth);
void add_inv_trans_16x16_arm64(coef_t *src, pel_t *pred, int i_pred, pel_t *dst, int i_dst, int bit_depth);
void add_inv_trans_32x32_arm64(coef_t *src, pel_t *pred, int i_pred, pel_t *dst, int i_dst, int bit_depth);

void pix_sub_4_arm64(resi_t *dst, pel_t *org, int i_org, pel_t *pred, int i_pred);
void pix_sub_8_arm64(resi_t *dst, pel_t *org, int i_org, pel_t *pred, int i_pred);
void pix_sub_16_arm64(resi_t *dst, pel_t *org, int i_org, pel_t *pred, int i_pred);
void pix_sub_32_arm64(resi_t *dst, pel_t *org, int i_org, pel_t *pred, int i_pred);

void pix_add_4_arm64(pel_t *dst, int i_dst, pel_t *pred, int i_pred, resi_t *resi, int bit_depth);
void pix_add_8_arm64(pel_t *dst, int i_dst, pel_t *pred, int i_pred, resi_t *resi, int bit_depth);
void pix_add_16_arm64(pel_t *dst, int i_dst, pel_t *pred, int i_pred, resi_t *resi, int bit_depth);
void pix_add_32_arm64(pel_t *dst, int i_dst, pel_t *pred, int i_pred, resi_t *resi, int bit_depth);

void partialButterfly4x4_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift);
void partialButterfly8x8_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift);
void partialButterfly16x16_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift);
void partialButterfly16x16_arm64_f(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift);
void partialButterfly16x16_arm64_s(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift);
void partialButterfly32x32_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift);
void partialButterfly32x32_arm64_s(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift);


void add_inv_trans_4x4_arm64(coef_t *src, pel_t *pred, int i_pred, pel_t *dst, int i_dst, int bit_depth);
void add_inv_trans_8x8_arm64(coef_t *src, pel_t *pred, int i_pred, pel_t *dst, int i_dst, int bit_depth);
void add_inv_trans_16x16_arm64(coef_t *src, pel_t *pred, int i_pred, pel_t *dst, int i_dst, int bit_depth);
void add_inv_trans_32x32_arm64(coef_t *src, pel_t *pred, int i_pred, pel_t *dst, int i_dst, int bit_depth);

void partialButterflyInverse4x4_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift, int bit_depth);
void partialButterflyInverse8x8_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift, int bit_depth);
void partialButterflyInverse16x16_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift, int bit_depth);
void partialButterflyInverse32x32_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift, int bit_depth);

int get_nz_num_arm64(coef_t *p_coef, int num_coeff);

void xPredIntraVertAdi_arm64(pel_t *pSrc, pel_t *dst, int i_dst, int iWidth, int iHeight);
void xPredIntraHorAdi_arm64(pel_t *pSrc, pel_t *dst, int i_dst, int iWidth, int iHeight);
void xPredIntraDCAdi_arm64(pel_t *pSrc, pel_t *dst, int i_dst, int iWidth, int iHeight, int bAboveAvail, int bLeftAvail, int bit_depth);
void xPredIntraPlaneAdi_arm64(pel_t *pSrc, pel_t *dst, int i_dst, int iWidth, int iHeight, int bit_depth);
void xPredIntraBiAdi_arm64(pel_t *pSrc, pel_t *dst, int i_dst, int iWidth, int iHeight, int bit_depth);

void sao_getStatblk_arm64(void *handle, void *sao_data, int compIdx, const int pix_y, const int pix_x, int lcu_pix_height, int lcu_pix_width, int smb_available_left, int smb_available_right, int smb_available_up, int smb_available_down);
void sao_on_lcu_arm64(void *handle, void *sao_data, int compIdx, int pix_y, int pix_x, int height, int width, int available_left, int available_right, int available_up, int available_down);

void deblock_ver_luma_arm64(pel_t *src, int stride, int alpha, int beta);
void deblock_hor_luma_arm64(pel_t *src, int stride, int alpha, int beta);
void deblock_ver_chroma_arm64(pel_t *srcu, pel_t *srcv, int stride, int alpha_u, int beta_u, int alpha_v, int beta_v);
void deblock_hor_chroma_arm64(pel_t *srcu, pel_t *srcv, int stride, int alpha_u, int beta_u, int alpha_v, int beta_v);

int quant_normal_arm64(coef_t *curr_blk, int coef_num, int Q, int qp_const, int shift);
void inv_quant_normal_arm64(coef_t *src, coef_t *dst, int coef_num, int QPI, int shift);


#endif
#endif
