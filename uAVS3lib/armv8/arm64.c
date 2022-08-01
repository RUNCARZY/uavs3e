#include "arm64.h"

#if defined(__arm64__)
void com_funs_init_arm64()
{
#if(COMPILE_10BIT==0)
    g_funs_handle.cost_sad[2] = xGetSAD8_arm64;
    g_funs_handle.cost_sad[4] = xGetSAD16_arm64;
    g_funs_handle.cost_sad[8] = xGetSAD32_arm64;
    
    g_funs_handle.cost_sad_x4[2] = xGetSAD8_x4_arm64;
    g_funs_handle.cost_sad_x4[4] = xGetSAD16_x4_arm64;
    g_funs_handle.cost_sad_x4[8] = xGetSAD32_x4_arm64;
    
    g_funs_handle.cost_avg_sad[2] = xGetAVGSAD8_arm64;
    g_funs_handle.cost_avg_sad[4] = xGetAVGSAD16_arm64;
    g_funs_handle.cost_avg_sad[8] = xGetAVGSAD32_arm64;
    
    g_funs_handle.cost_ssd[1] = xGetSSE8_arm64;
    g_funs_handle.cost_ssd[2] = xGetSSE16_arm64;
    g_funs_handle.cost_ssd[3] = xGetSSE32_arm64;
    
    g_funs_handle.cost_blk_satd[1] = xCalcHAD8x8_arm64;
    
    g_funs_handle.avg_pel[2] = avg_pel_4_arm64;
    g_funs_handle.avg_pel[4] = avg_pel_8_arm64;
    g_funs_handle.avg_pel[8] = avg_pel_16_arm64;
    g_funs_handle.avg_pel[16] = avg_pel_32_arm64;
    
    g_funs_handle.cpy_pel[2] = com_mem_cpy4_arm64;
    g_funs_handle.cpy_pel[4] = com_mem_cpy8_arm64;
    g_funs_handle.cpy_pel[8] = com_mem_cpy16_arm64;
    g_funs_handle.cpy_pel[16] = com_mem_cpy32_arm64;
    
    g_funs_handle.ip_flt_y_hor = com_if_filter_hor_8_arm64;
    g_funs_handle.ip_flt_y_ver = com_if_filter_ver_8_arm64;
    g_funs_handle.ip_flt_y_ver_ext = com_if_filter_ver_8_ext_arm64;
    g_funs_handle.ip_flt_c[IP_FLT_C_H][1] = com_if_filter_hor_4_w4_arm64;
    g_funs_handle.ip_flt_c[IP_FLT_C_H][3] = com_if_filter_hor_4_w8_arm64;
    g_funs_handle.ip_flt_c[IP_FLT_C_H][7] = com_if_filter_hor_4_w16_arm64;

    g_funs_handle.ip_flt_c[IP_FLT_C_V][1] = com_if_filter_ver_4_w4_arm64;
    g_funs_handle.ip_flt_c[IP_FLT_C_V][3] = com_if_filter_ver_4_w8_arm64;
    g_funs_handle.ip_flt_c[IP_FLT_C_V][7] = com_if_filter_ver_4_w16_arm64;
   
    g_funs_handle.ip_flt_c_ext[3] = com_if_filter_hor_ver_4_w8_arm64;
    g_funs_handle.ip_flt_c_ext[7] = com_if_filter_hor_Ver_4_w16_arm64;
    
    g_funs_handle.add_inv_trans[1] = add_inv_trans_4x4_arm64;
    g_funs_handle.add_inv_trans[2] = add_inv_trans_8x8_arm64;
    g_funs_handle.add_inv_trans[3] = add_inv_trans_16x16_arm64;
    g_funs_handle.add_inv_trans[4] = add_inv_trans_32x32_arm64;
    
    g_funs_handle.sub_trans[1] = sub_trans_4x4_arm64;
    g_funs_handle.sub_trans[2] = sub_trans_8x8_arm64_8bit;
    //g_funs_handle.sub_trans[3] = sub_trans_16x16_arm64;
    g_funs_handle.sub_trans[4] = sub_trans_32x32_arm64;
    
    g_funs_handle.pix_sub[0] = pix_sub_4_arm64;
    g_funs_handle.pix_add[0] = pix_add_4_arm64;
    g_funs_handle.pix_sub[1] = pix_sub_8_arm64;
    g_funs_handle.pix_add[1] = pix_add_8_arm64;
    g_funs_handle.pix_sub[2] = pix_sub_16_arm64;
    g_funs_handle.pix_add[2] = pix_add_16_arm64;
    g_funs_handle.pix_sub[3] = pix_sub_32_arm64;
    g_funs_handle.pix_add[3] = pix_add_32_arm64;
    
    g_funs_handle.intra_pred_plane = xPredIntraPlaneAdi_arm64;
    g_funs_handle.intra_pred_hor   = xPredIntraHorAdi_arm64;
    g_funs_handle.intra_pred_ver   = xPredIntraVertAdi_arm64;
    g_funs_handle.intra_pred_dc    = xPredIntraDCAdi_arm64;
    g_funs_handle.intra_pred_bi    = xPredIntraBiAdi_arm64;
    
    //g_funs_handle.sao_flt[0] = sao_getStatblk_arm64;
    g_funs_handle.sao_flt[1] = sao_on_lcu_arm64;
    
    g_funs_handle.deblk_luma[0] = deblock_ver_luma_arm64;
    g_funs_handle.deblk_luma[1] = deblock_hor_luma_arm64;
    g_funs_handle.deblk_chroma[0] = deblock_ver_chroma_arm64;
    g_funs_handle.deblk_chroma[1] = deblock_hor_chroma_arm64;
    
    g_funs_handle.quant         = quant_normal_arm64;
    g_funs_handle.inv_quant     = inv_quant_normal_arm64;

#else
    g_funs_handle.cost_sad[2] = xGetSAD8_arm64;
    g_funs_handle.cost_sad[4] = xGetSAD16_arm64;
    g_funs_handle.cost_sad[8] = xGetSAD32_arm64;
    g_funs_handle.cost_sad[16] = xGetSAD64_arm64;
    
    g_funs_handle.cost_sad_x4[2] = xGetSAD8_x4_arm64;
    g_funs_handle.cost_sad_x4[4] = xGetSAD16_x4_arm64;
    g_funs_handle.cost_sad_x4[8] = xGetSAD32_x4_arm64;

    g_funs_handle.cost_avg_sad[2] = xGetAVGSAD8_arm64;
    g_funs_handle.cost_avg_sad[4] = xGetAVGSAD16_arm64;
    g_funs_handle.cost_avg_sad[8] = xGetAVGSAD32_arm64;
    
    g_funs_handle.cost_ssd[1] = xGetSSE8_arm64;
    g_funs_handle.cost_ssd[2] = xGetSSE16_arm64;
    g_funs_handle.cost_ssd[3] = xGetSSE32_arm64;
    
    g_funs_handle.cost_ssd_psnr = xGetSSE_Psnr_arm64;

    g_funs_handle.cost_blk_satd[1] = xCalcHAD8x8_arm64;
    
    g_funs_handle.avg_pel[2] = avg_pel_4_arm64;
    g_funs_handle.avg_pel[4] = avg_pel_8_arm64;
    g_funs_handle.avg_pel[8] = avg_pel_16_arm64;
    g_funs_handle.avg_pel[16] = avg_pel_32_arm64;
    
    g_funs_handle.cpy_pel[2] = com_mem_cpy4_arm64;
    g_funs_handle.cpy_pel[4] = com_mem_cpy8_arm64;
    g_funs_handle.cpy_pel[8] = com_mem_cpy16_arm64;
    g_funs_handle.cpy_pel[16] = com_mem_cpy32_arm64;
    
    g_funs_handle.ip_flt_y_hor = com_if_filter_hor_8_arm64;
    g_funs_handle.ip_flt_y_ver = com_if_filter_ver_8_arm64;
    g_funs_handle.ip_flt_y_ver_ext = com_if_filter_ver_8_ext_arm64;
    g_funs_handle.ip_flt_c[IP_FLT_C_H][1] = com_if_filter_hor_4_w4_arm64;
    g_funs_handle.ip_flt_c[IP_FLT_C_H][3] = com_if_filter_hor_4_w8_arm64;
    g_funs_handle.ip_flt_c[IP_FLT_C_H][7] = com_if_filter_hor_4_w16_arm64;

    g_funs_handle.ip_flt_c[IP_FLT_C_V][1] = com_if_filter_ver_4_w4_arm64;
    g_funs_handle.ip_flt_c[IP_FLT_C_V][3] = com_if_filter_ver_4_w8_arm64;
    g_funs_handle.ip_flt_c[IP_FLT_C_V][7] = com_if_filter_ver_4_w16_arm64;
   
    g_funs_handle.ip_flt_c_ext[3] = com_if_filter_hor_ver_4_w8_arm64;
    g_funs_handle.ip_flt_c_ext[7] = com_if_filter_hor_Ver_4_w16_arm64;
    
    g_funs_handle.add_inv_trans[1] = add_inv_trans_4x4_arm64;
    g_funs_handle.add_inv_trans[2] = add_inv_trans_8x8_arm64;
    g_funs_handle.add_inv_trans[3] = add_inv_trans_16x16_arm64;
    g_funs_handle.add_inv_trans[4] = add_inv_trans_32x32_arm64;
    
    g_funs_handle.sub_trans[1] = sub_trans_4x4_arm64;
    g_funs_handle.sub_trans[2] = sub_trans_8x8_arm64;
    g_funs_handle.sub_trans[3] = sub_trans_16x16_arm64;
    g_funs_handle.sub_trans[4] = sub_trans_32x32_arm64;
    
    g_funs_handle.add_inv_trans_ext[4] = add_inv_trans_32x32_arm64;
    g_funs_handle.sub_trans_ext[4] = sub_trans_32x32_arm64;
    
    g_funs_handle.get_nz_num = get_nz_num_arm64;
    
    g_funs_handle.pix_sub[0] = pix_sub_4_arm64;
    g_funs_handle.pix_sub[1] = pix_sub_8_arm64;
    g_funs_handle.pix_add[1] = pix_add_8_arm64;
    g_funs_handle.pix_sub[2] = pix_sub_16_arm64;
    g_funs_handle.pix_add[2] = pix_add_16_arm64;
    g_funs_handle.pix_sub[3] = pix_sub_32_arm64;
    g_funs_handle.pix_add[3] = pix_add_32_arm64;
    
    //g_funs_handle.intra_pred_plane = xPredIntraPlaneAdi_arm64;
    g_funs_handle.intra_pred_hor   = xPredIntraHorAdi_arm64;
    g_funs_handle.intra_pred_ver   = xPredIntraVertAdi_arm64;
    g_funs_handle.intra_pred_dc    = xPredIntraDCAdi_arm64;
    //g_funs_handle.intra_pred_bi    = xPredIntraBiAdi_arm64;
    
    //g_funs_handle.sao_flt[0] = sao_getStatblk_arm64;
    g_funs_handle.sao_flt[1] = sao_on_lcu_arm64;
    
    g_funs_handle.deblk_luma[0] = deblock_ver_luma_arm64;
    g_funs_handle.deblk_luma[1] = deblock_hor_luma_arm64;
    g_funs_handle.deblk_chroma[0] = deblock_ver_chroma_arm64;
    g_funs_handle.deblk_chroma[1] = deblock_hor_chroma_arm64;
    
    g_funs_handle.quant         = quant_normal_arm64;
    g_funs_handle.inv_quant     = inv_quant_normal_arm64;
#endif

}
#endif
