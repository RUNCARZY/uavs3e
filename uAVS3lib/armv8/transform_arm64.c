#include "arm64.h"
#if defined(__arm64__)
void sub_trans_4x4_arm64(pel_t *org, int i_org, pel_t *pred, int i_pred, coef_t *dst, int shift)
{
    ALIGNED_32(coef_t tmp[LCU_SIZE * LCU_SIZE]);
    ALIGNED_32(resi_t resi[LCU_SIZE * LCU_SIZE]);
    g_funs_handle.pix_sub[0](resi, org, i_org, pred, i_pred);
    partialButterfly4x4_arm64(resi, 4, tmp, 4, shift);
    partialButterfly4x4_arm64(tmp, 4, dst, 4, 7);
}

void sub_trans_8x8_arm64_8bit(pel_t *org, int i_org, pel_t *pred, int i_pred, coef_t *dst, int shift)
{
    ALIGNED_32(coef_t tmp[LCU_SIZE * LCU_SIZE]);
    ALIGNED_32(resi_t resi[LCU_SIZE * LCU_SIZE]);
    g_funs_handle.pix_sub[1](resi, org, i_org, pred, i_pred);
    partialButterfly8x8_arm64(resi, 8, tmp, 8, shift);
    partialButterfly8x8_arm64(tmp, 8, dst, 8, 8);
}

void sub_trans_16x16_arm64(pel_t *org, int i_org, pel_t *pred, int i_pred, coef_t *dst, int shift)
{
    ALIGNED_32(coef_t tmp[LCU_SIZE * LCU_SIZE]);
    ALIGNED_32(resi_t resi[LCU_SIZE * LCU_SIZE]);
    g_funs_handle.pix_sub[2](resi, org, i_org, pred, i_pred);
    partialButterfly16x16_arm64_f(resi, 16, tmp, 16, shift);
    partialButterfly16x16_arm64_s(tmp, 16, dst, 16, 9);
}

void sub_trans_32x32_arm64(pel_t *org, int i_org, pel_t *pred, int i_pred, coef_t *dst, int shift)
{
    ALIGNED_32(coef_t tmp[LCU_SIZE * LCU_SIZE]);
    ALIGNED_32(resi_t resi[LCU_SIZE * LCU_SIZE]);
    g_funs_handle.pix_sub[3](resi, org, i_org, pred, i_pred);
    partialButterfly32x32_arm64_s(resi, 32, tmp, 32, shift);
    partialButterfly32x32_arm64_s(tmp, 32, dst, 32, 10);
}

void add_inv_trans_4x4_arm64(coef_t *src, pel_t *pred, int i_pred, pel_t *dst, int i_dst, int bit_depth)
{
    ALIGNED_32(coef_t tmp[LCU_SIZE * LCU_SIZE]);
    ALIGNED_32(resi_t resi[LCU_SIZE * LCU_SIZE]);
    partialButterflyInverse4x4_arm64(src, 4, tmp, 4, 5, 15);
    partialButterflyInverse4x4_arm64(tmp, 4, resi, 4, 20 - bit_depth, bit_depth);
    g_funs_handle.pix_add[0](dst, i_dst, pred, i_pred, resi, bit_depth);
}

void add_inv_trans_8x8_arm64(coef_t *src, pel_t *pred, int i_pred, pel_t *dst, int i_dst, int bit_depth)
{
    ALIGNED_32(coef_t tmp[LCU_SIZE * LCU_SIZE]);
    ALIGNED_32(resi_t resi[LCU_SIZE * LCU_SIZE]);
    partialButterflyInverse8x8_arm64(src, 8, tmp, 8, 5, 15);
    partialButterflyInverse8x8_arm64(tmp, 8, resi, 8, 20 - bit_depth, bit_depth);
    g_funs_handle.pix_add[1](dst, i_dst, pred, i_pred, resi, bit_depth);
}

void add_inv_trans_16x16_arm64(coef_t *src, pel_t *pred, int i_pred, pel_t *dst, int i_dst, int bit_depth)
{
    ALIGNED_32(coef_t tmp[LCU_SIZE * LCU_SIZE]);
    ALIGNED_32(resi_t resi[LCU_SIZE * LCU_SIZE]);
    partialButterflyInverse16x16_arm64(src, 16, tmp, 16, 5, 15);
    partialButterflyInverse16x16_arm64(tmp, 16, resi, 16, 20 - bit_depth, bit_depth);
    g_funs_handle.pix_add[2](dst, i_dst, pred, i_pred, resi, bit_depth);
}

void add_inv_trans_32x32_arm64(coef_t *src, pel_t *pred, int i_pred, pel_t *dst, int i_dst, int bit_depth)
{
    ALIGNED_32(coef_t tmp[LCU_SIZE * LCU_SIZE]);
    ALIGNED_32(resi_t resi[LCU_SIZE * LCU_SIZE]);
    partialButterflyInverse32x32_arm64(src, 32, tmp, 32, 5, 15);
    partialButterflyInverse32x32_arm64(tmp, 32, resi, 32, 20 - bit_depth, bit_depth);
    g_funs_handle.pix_add[3](dst, i_dst, pred, i_pred, resi, bit_depth);
}

#endif
