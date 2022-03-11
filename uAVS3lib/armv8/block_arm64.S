#include "def_arm64.S"

#if defined(__arm64__)

#if !COMPILE_10BIT
//int quant_normal_arm64(coef_t *curr_blk, int coef_num, int Q, int qp_const, int shift)
//x0->curr_blk, x1->coef_num, x2->Q, x3->qp_const, x4->shift
function quant_normal_arm64
    dup v16.8h, w2
    dup v17.4s, w3
    neg w4, w4
    dup v18.4s, w4
    movi v19.8h, #0
    movi v20.8h, #0

    mov x5, x0
quant_normal_loop:
    ld1 {v0.8h, v1.8h}, [x0], #32

    abs v2.8h, v0.8h
    abs v3.8h, v1.8h
    smull v4.4s, v2.4h, v16.4h
    smull2 v5.4s, v2.8h, v16.8h
    smull v6.4s, v3.4h, v16.4h
    smull2 v7.4s, v3.8h, v16.8h
    add v4.4s, v4.4s, v17.4s
    add v5.4s, v5.4s, v17.4s
    add v6.4s, v6.4s, v17.4s
    add v7.4s, v7.4s, v17.4s
    sshl v4.4s, v4.4s, v18.4s
    sshl v5.4s, v5.4s, v18.4s
    sshl v6.4s, v6.4s, v18.4s
    sshl v7.4s, v7.4s, v18.4s             //abs(val) * q + qp_const >> shift

    sqxtn v4.4h, v4.4s
    sqxtn2 v4.8h, v5.4s
    sqxtn v5.4h, v6.4s
    sqxtn2 v5.8h, v7.4s

    add v21.8h, v4.8h, v5.8h
    add v20.8h, v20.8h, v21.8h               //nz += temp

    cmlt v6.8h, v0.8h, #0
    cmlt v7.8h, v1.8h, #0
    sub v0.8h, v19.8h, v4.8h
    sub v1.8h, v19.8h, v5.8h
    bit v4.16b, v0.16b, v6.16b
    bit v5.16b, v1.16b, v7.16b
    st1 {v4.8h, v5.8h}, [x5], #32
    
    subs x1, x1, #16
    bgt quant_normal_loop

    addp v20.8h, v20.8h, v20.8h
    addp v20.8h, v20.8h, v20.8h
    addp v20.8h, v20.8h, v20.8h

    smov w0, v20.h[0]
            
ret

//void inv_quant_normal_arm64(coef_t *src, coef_t *dst, int coef_num, int QPI, int shift);
//x0->src, x1->dst, x2->coef_num, x3->QPI, x4->shift
function inv_quant_normal_arm64
    dup v31.4s, w3
    dup v30.4s, w4
    neg v30.4s, v30.4s

inv_quant_normal_loop:
    ld1 {v0.8h, v1.8h}, [x0], #32
    sxtl v2.4s, v0.4h
    sxtl2 v3.4s, v0.8h
    sxtl v4.4s, v1.4h
    sxtl2 v5.4s, v1.8h
    mul v2.4s, v2.4s, v31.4s
    mul v3.4s, v3.4s, v31.4s
    mul v4.4s, v4.4s, v31.4s
    mul v5.4s, v5.4s, v31.4s
    srshl v2.4s, v2.4s, v30.4s
    srshl v3.4s, v3.4s, v30.4s
    srshl v4.4s, v4.4s, v30.4s
    srshl v5.4s, v5.4s, v30.4s
    sqxtn v2.4h, v2.4s
    sqxtn2 v2.8h, v3.4s
    sqxtn v3.4h, v4.4s
    sqxtn2 v3.8h, v5.4s
    st1 {v2.8h, v3.8h}, [x1], #32
    subs w2, w2, #16
    bgt inv_quant_normal_loop

ret

#else
//int quant_normal_arm64(coef_t *curr_blk, int coef_num, int Q, int qp_const, int shift)
//x0->curr_blk, x1->coef_num, x2->Q, x3->qp_const, x4->shift
function quant_normal_arm64
    dup v16.8h, w2
    dup v17.4s, w3
    neg w4, w4
    dup v18.4s, w4
    movi v19.8h, #0
    movi v20.8h, #0

    mov x5, x0
quant_normal_loop:
    ld1 {v0.8h, v1.8h}, [x0], #32

    abs v2.8h, v0.8h
    abs v3.8h, v1.8h
    smull v4.4s, v2.4h, v16.4h
    smull2 v5.4s, v2.8h, v16.8h
    smull v6.4s, v3.4h, v16.4h
    smull2 v7.4s, v3.8h, v16.8h
    add v4.4s, v4.4s, v17.4s
    add v5.4s, v5.4s, v17.4s
    add v6.4s, v6.4s, v17.4s
    add v7.4s, v7.4s, v17.4s
    sshl v4.4s, v4.4s, v18.4s
    sshl v5.4s, v5.4s, v18.4s
    sshl v6.4s, v6.4s, v18.4s
    sshl v7.4s, v7.4s, v18.4s             //abs(val) * q + qp_const >> shift

    sqxtn v4.4h, v4.4s
    sqxtn2 v4.8h, v5.4s
    sqxtn v5.4h, v6.4s
    sqxtn2 v5.8h, v7.4s

    add v21.8h, v4.8h, v5.8h
    add v20.8h, v20.8h, v21.8h               //nz += temp

    cmlt v6.8h, v0.8h, #0
    cmlt v7.8h, v1.8h, #0
    sub v0.8h, v19.8h, v4.8h
    sub v1.8h, v19.8h, v5.8h
    bit v4.16b, v0.16b, v6.16b
    bit v5.16b, v1.16b, v7.16b
    st1 {v4.8h, v5.8h}, [x5], #32
    
    subs x1, x1, #16
    bgt quant_normal_loop

    addp v20.8h, v20.8h, v20.8h
    addp v20.8h, v20.8h, v20.8h
    addp v20.8h, v20.8h, v20.8h

    smov w0, v20.h[0]
            
ret

//void inv_quant_normal_arm64(coef_t *src, coef_t *dst, int coef_num, int QPI, int shift);
//x0->src, x1->dst, x2->coef_num, x3->QPI, x4->shift
function inv_quant_normal_arm64
    dup v31.4s, w3
    dup v30.4s, w4
    neg v30.4s, v30.4s

inv_quant_normal_loop:
    ld1 {v0.8h, v1.8h}, [x0], #32
    sxtl v2.4s, v0.4h
    sxtl2 v3.4s, v0.8h
    sxtl v4.4s, v1.4h
    sxtl2 v5.4s, v1.8h
    mul v2.4s, v2.4s, v31.4s
    mul v3.4s, v3.4s, v31.4s
    mul v4.4s, v4.4s, v31.4s
    mul v5.4s, v5.4s, v31.4s
    srshl v2.4s, v2.4s, v30.4s
    srshl v3.4s, v3.4s, v30.4s
    srshl v4.4s, v4.4s, v30.4s
    srshl v5.4s, v5.4s, v30.4s
    sqxtn v2.4h, v2.4s
    sqxtn2 v2.8h, v3.4s
    sqxtn v3.4h, v4.4s
    sqxtn2 v3.8h, v5.4s
    st1 {v2.8h, v3.8h}, [x1], #32
    subs w2, w2, #16
    bgt inv_quant_normal_loop

ret

#endif
#endif

