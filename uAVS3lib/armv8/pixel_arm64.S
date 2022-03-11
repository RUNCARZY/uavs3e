#include "def_arm64.S"
#if defined(__arm64__)

#if !COMPILE_10BIT
//void avg_pel_4_arm64(pel_t *dst, int i_dst, pel_t *src1, int i_src1, pel_t *src2, int i_src2, int width, int height);
// dst->x0, i_dst->x1, src1->x2, i_src1->x3, src2->x4, i_src2->x5, width->x6, height->x7
function avg_pel_4_arm64

avg_pel_w4_y:
    ld1 {v0.s}[0], [x2], x3
    ld1 {v0.s}[1], [x2], x3
    ld1 {v0.s}[2], [x2], x3
    ld1 {v0.s}[3], [x2], x3
    ld1 {v1.s}[0], [x4], x5
    ld1 {v1.s}[1], [x4], x5
    ld1 {v1.s}[2], [x4], x5
    ld1 {v1.s}[3], [x4], x5

    urhadd v0.16b, v0.16b, v1.16b

    st1  {v0.s}[0], [x0], x1
    st1  {v0.s}[1], [x0], x1
    st1  {v0.s}[2], [x0], x1
    st1  {v0.s}[3], [x0], x1

    subs w7, w7, #4
    bgt avg_pel_w4_y

    ret

//void avg_pel_8_arm64(pel_t *dst, int i_dst, pel_t *src1, int i_src1, pel_t *src2, int i_src2, int width, int height);
// dst->x0, i_dst->x1, src1->x2, i_src1->x3, src2->x4, i_src2->x5, width->x6, height->x7
function avg_pel_8_arm64

avg_pel_w8_y:
    ld1 {v0.d}[0], [x2], x3
    ld1 {v0.d}[1], [x2], x3
    ld1 {v1.d}[0], [x2], x3
    ld1 {v1.d}[1], [x2], x3
    ld1 {v2.d}[0], [x4], x5
    ld1 {v2.d}[1], [x4], x5
    ld1 {v3.d}[0], [x4], x5
    ld1 {v3.d}[1], [x4], x5

    urhadd v0.16b, v0.16b, v2.16b
    urhadd v1.16b, v1.16b, v3.16b

    subs w7, w7, #4
    st1  {v0.d}[0], [x0], x1
    st1  {v0.d}[1], [x0], x1
    st1  {v1.d}[0], [x0], x1
    st1  {v1.d}[1], [x0], x1

    bgt avg_pel_w8_y

    ret

//void avg_pel_16_arm64(pel_t *dst, int i_dst, pel_t *src1, int i_src1, pel_t *src2, int i_src2, int width, int height);
// dst->x0, i_dst->x1, src1->x2, i_src1->x3, src2->x4, i_src2->x5, width->x6, height->x7
function avg_pel_16_arm64

avg_pel_w16_y:
    ld1 {v0.16b}, [x2], x3
    ld1 {v1.16b}, [x2], x3
    ld1 {v2.16b}, [x2], x3
    ld1 {v3.16b}, [x2], x3

    ld1 {v4.16b}, [x4], x5
    ld1 {v5.16b}, [x4], x5
    ld1 {v6.16b}, [x4], x5
    ld1 {v7.16b}, [x4], x5

    urhadd v0.16b, v0.16b, v4.16b
    urhadd v1.16b, v1.16b, v5.16b
    urhadd v2.16b, v2.16b, v6.16b
    urhadd v3.16b, v3.16b, v7.16b

    subs w7, w7, #4
    st1  {v0.16b}, [x0], x1
    st1  {v1.16b}, [x0], x1
    st1  {v2.16b}, [x0], x1
    st1  {v3.16b}, [x0], x1

    bgt avg_pel_w16_y

    ret

//void avg_pel_32_arm64(pel_t *dst, int i_dst, pel_t *src1, int i_src1, pel_t *src2, int i_src2, int width, int height);
// dst->x0, i_dst->x1, src1->x2, i_src1->x3, src2->x4, i_src2->x5, width->x6, height->x7
function avg_pel_32_arm64

avg_pel_w32_y:
    ld1 {v0.16b, v1.16b}, [x2], x3
    ld1 {v2.16b, v3.16b}, [x2], x3

    ld1 {v4.16b, v5.16b}, [x4], x5
    ld1 {v6.16b, v7.16b}, [x4], x5

    urhadd v0.16b, v0.16b, v4.16b
    urhadd v1.16b, v1.16b, v5.16b
    urhadd v2.16b, v2.16b, v6.16b
    urhadd v3.16b, v3.16b, v7.16b

    subs w7, w7, #2
    st1  {v0.16b, v1.16b}, [x0], x1
    st1  {v2.16b, v3.16b}, [x0], x1
    bgt avg_pel_w32_y

    ret

//void com_mem_cpy4_arm64(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5
function com_mem_cpy4_arm64

if_cpy_w4_loop_y:
    ld1 {v0.s}[0], [x0], x1
    ld1 {v0.s}[1], [x0], x1
    ld1 {v0.s}[2], [x0], x1
    ld1 {v0.s}[3], [x0], x1
    st1 {v0.s}[0], [x2], x3
    st1 {v0.s}[1], [x2], x3
    subs w5, w5, #4
    st1 {v0.s}[2], [x2], x3
    st1 {v0.s}[3], [x2], x3
    bgt if_cpy_w4_loop_y

    ret

//void com_mem_cpy8_arm64(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5
function com_mem_cpy8_arm64

if_cpy_w8_loop_y:
    ld1 {v0.8b}, [x0], x1
    ld1 {v1.8b}, [x0], x1
    ld1 {v2.8b}, [x0], x1
    ld1 {v3.8b}, [x0], x1

    subs w5, w5, #4
    st1 {v0.8b}, [x2], x3
    st1 {v1.8b}, [x2], x3
    st1 {v2.8b}, [x2], x3
    st1 {v3.8b}, [x2], x3
    bgt if_cpy_w8_loop_y

    ret

//void com_mem_cpy16_arm64(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5
function com_mem_cpy16_arm64

if_cpy_w16_loop_y:
    ld1 {v0.16b}, [x0], x1
    ld1 {v1.16b}, [x0], x1
    ld1 {v2.16b}, [x0], x1
    ld1 {v3.16b}, [x0], x1

    subs w5, w5, #4
    st1 {v0.16b}, [x2], x3
    st1 {v1.16b}, [x2], x3
    st1 {v2.16b}, [x2], x3
    st1 {v3.16b}, [x2], x3
    bgt if_cpy_w16_loop_y

    ret

//void com_mem_cpy32_arm64(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5
function com_mem_cpy32_arm64

if_cpy_w32_loop_y:
    ld1 {v0.2d, v1.2d}, [x0], x1
    ld1 {v2.2d, v3.2d}, [x0], x1
    ld1 {v4.2d, v5.2d}, [x0], x1
    ld1 {v6.2d, v7.2d}, [x0], x1

    subs w5, w5, #4
    st1 {v0.2d, v1.2d}, [x2], x3
    st1 {v2.2d, v3.2d}, [x2], x3
    st1 {v4.2d, v5.2d}, [x2], x3
    st1 {v6.2d, v7.2d}, [x2], x3
    bne if_cpy_w32_loop_y

    ret

/******************************************************************************************************
*  void pix_sub_4_arm64(resi_t *dst, pel_t *org, int i_org, pel_t *pred, int i_pred)
*  dst->x0, org->x1, i_org->x2, pred->x3, i_pred->x4
******************************************************************************************************/
function pix_sub_4_arm64
    //load *org
    ld1 {v0.s}[0], [x1], x2
    ld1 {v0.s}[1], [x1], x2
    ld1 {v0.s}[2], [x1], x2
    ld1 {v0.s}[3], [x1], x2

    //load *pred
    ld1 {v1.s}[0], [x3], x4
    ld1 {v1.s}[1], [x3], x4
    ld1 {v1.s}[2], [x3], x4
    ld1 {v1.s}[3], [x3], x4

    //sub
    usubl v2.8h, v0.8b, v1.8b
    usubl2 v3.8h, v0.16b, v1.16b
    st1 {v2.8h, v3.8h}, [x0]

    ret

/******************************************************************************************************
*  void pix_sub_8_arm64(resi_t *dst, pel_t *org, int i_org, pel_t *pred, int i_pred)
*  dst->x0, org->x1, i_org->x2, pred->x3, i_pred->x4
******************************************************************************************************/
function pix_sub_8_arm64

diff_w8_loopx:
    //load *org
    ld1 {v0.d}[0], [x1], x2
    ld1 {v0.d}[1], [x1], x2
    ld1 {v1.d}[0], [x1], x2
    ld1 {v1.d}[1], [x1], x2
    ld1 {v2.d}[0], [x1], x2
    ld1 {v2.d}[1], [x1], x2
    ld1 {v3.d}[0], [x1], x2
    ld1 {v3.d}[1], [x1], x2

    //load *pred
    ld1 {v4.d}[0], [x3], x4
    ld1 {v4.d}[1], [x3], x4
    ld1 {v5.d}[0], [x3], x4
    ld1 {v5.d}[1], [x3], x4
    ld1 {v6.d}[0], [x3], x4
    ld1 {v6.d}[1], [x3], x4
    ld1 {v7.d}[0], [x3], x4
    ld1 {v7.d}[1], [x3], x4

    //sub
    usubl v16.8h, v0.8b, v4.8b
    usubl2 v17.8h, v0.16b, v4.16b
    usubl v18.8h, v1.8b, v5.8b
    usubl2 v19.8h, v1.16b, v5.16b
    usubl v20.8h, v2.8b, v6.8b
    usubl2 v21.8h, v2.16b, v6.16b
    usubl v22.8h, v3.8b, v7.8b
    usubl2 v23.8h, v3.16b, v7.16b

    st1 {v16.8h - v19.8h}, [x0], #64
    st1 {v20.8h - v23.8h}, [x0]

    ret

/******************************************************************************************************
*  void pix_sub_16_arm64(resi_t *dst, pel_t *org, int i_org, pel_t *pred, int i_pred)
*  dst->x0, org->x1, i_org->x2, pred->x3, i_pred->x4
******************************************************************************************************/
function pix_sub_16_arm64
    mov x5, #4

diff_w16_loopy:
    ld1 {v0.16b}, [x1], x2
    ld1 {v1.16b}, [x1], x2
    ld1 {v2.16b}, [x1], x2
    ld1 {v3.16b}, [x1], x2

    //load *pred
    ld1 {v4.16b}, [x3], x4
    ld1 {v5.16b}, [x3], x4
    ld1 {v6.16b}, [x3], x4
    ld1 {v7.16b}, [x3], x4

    //sub
    usubl v16.8h, v0.8b, v4.8b
    usubl2 v17.8h, v0.16b, v4.16b
    usubl v18.8h, v1.8b, v5.8b
    usubl2 v19.8h, v1.16b, v5.16b
    usubl v20.8h, v2.8b, v6.8b
    usubl2 v21.8h, v2.16b, v6.16b
    usubl v22.8h, v3.8b, v7.8b
    usubl2 v23.8h, v3.16b, v7.16b

    st1 {v16.8h - v19.8h}, [x0], #64
    st1 {v20.8h - v23.8h}, [x0], #64
    subs w5, w5, #1
    bgt diff_w16_loopy

    ret

/******************************************************************************************************
*  void pix_sub_32_arm64(resi_t *dst, pel_t *org, int i_org, pel_t *pred, int i_pred)
*  dst->x0, org->x1, i_org->x2, pred->x3, i_pred->x4
******************************************************************************************************/
function pix_sub_32_arm64
    mov x5, #16

diff_w32_loopy:
    ld1 {v0.16b, v1.16b}, [x1], x2
    ld1 {v2.16b, v3.16b}, [x1], x2

    //load *pred
    ld1 {v4.16b, v5.16b}, [x3], x4
    ld1 {v6.16b, v7.16b}, [x3], x4

    //sub
    usubl v16.8h, v0.8b, v4.8b
    usubl2 v17.8h, v0.16b, v4.16b
    usubl v18.8h, v1.8b, v5.8b
    usubl2 v19.8h, v1.16b, v5.16b
    usubl v20.8h, v2.8b, v6.8b
    usubl2 v21.8h, v2.16b, v6.16b
    usubl v22.8h, v3.8b, v7.8b
    usubl2 v23.8h, v3.16b, v7.16b
    
    st1 {v16.8h - v19.8h}, [x0], #64
    st1 {v20.8h - v23.8h}, [x0], #64

    subs w5, w5, #1
    bgt diff_w32_loopy

    ret
/******************************************************************************************************
*  void pix_add_4_arm64(pel_t *dst, int i_dst, pel_t *pred, int i_pred, resi_t *resi, int bit_depth);
*  dst->x0, i_dst->x1, pred->x2, i_pred->x3, resi->x4, bit_depth->x5
******************************************************************************************************/
function pix_add_4_arm64
    //load resi
    ld1 {v0.8h, v1.8h}, [x4]
    
    //load pred
    ld1 {v2.s}[0], [x2], x3
    ld1 {v2.s}[1], [x2], x3
    ld1 {v3.s}[0], [x2], x3
    ld1 {v3.s}[1], [x2], x3
    
    uxtl v2.8h, v2.8b
    uxtl v3.8h, v3.8b
    
    add v0.8h, v0.8h, v2.8h
    add v1.8h, v1.8h, v3.8h
    
    sqxtun v0.8b, v0.8h
    sqxtun v1.8b, v1.8h
    
    st1 {v0.s}[0], [x0], x1
    st1 {v0.s}[1], [x0], x1
    st1 {v1.s}[0], [x0], x1
    st1 {v1.s}[1], [x0], x1
    ret
/******************************************************************************************************
*  void pix_add_8_arm64(pel_t *dst, int i_dst, pel_t *pred, int i_pred, resi_t *resi, int bit_depth);
*  dst->x0, i_dst->x1, pred->x2, i_pred->x3, resi->x4, bit_depth->x5
******************************************************************************************************/
function pix_add_8_arm64

    //load resi
    ld1 {v0.8h - v3.8h}, [x4], #64
    ld1 {v4.8h - v7.8h}, [x4]
    
    //load pred
    ld1 {v16.8b}, [x2], x3
    ld1 {v17.8b}, [x2], x3
    ld1 {v18.8b}, [x2], x3
    ld1 {v19.8b}, [x2], x3
    ld1 {v20.8b}, [x2], x3
    ld1 {v21.8b}, [x2], x3
    ld1 {v22.8b}, [x2], x3
    ld1 {v23.8b}, [x2], x3

    uxtl v16.8h, v16.8b
    uxtl v17.8h, v17.8b
    uxtl v18.8h, v18.8b
    uxtl v19.8h, v19.8b
    uxtl v20.8h, v20.8b
    uxtl v21.8h, v21.8b
    uxtl v22.8h, v22.8b
    uxtl v23.8h, v23.8b

    add v0.8h, v0.8h, v16.8h
    add v1.8h, v1.8h, v17.8h
    add v2.8h, v2.8h, v18.8h
    add v3.8h, v3.8h, v19.8h
    add v4.8h, v4.8h, v20.8h
    add v5.8h, v5.8h, v21.8h
    add v6.8h, v6.8h, v22.8h
    add v7.8h, v7.8h, v23.8h

    sqxtun v0.8b, v0.8h
    sqxtun v1.8b, v1.8h
    sqxtun v2.8b, v2.8h
    sqxtun v3.8b, v3.8h
    sqxtun v4.8b, v4.8h
    sqxtun v5.8b, v5.8h
    sqxtun v6.8b, v6.8h
    sqxtun v7.8b, v7.8h
    
    st1 {v0.8b}, [x0], x1
    st1 {v1.8b}, [x0], x1
    st1 {v2.8b}, [x0], x1
    st1 {v3.8b}, [x0], x1
    st1 {v4.8b}, [x0], x1
    st1 {v5.8b}, [x0], x1
    st1 {v6.8b}, [x0], x1
    st1 {v7.8b}, [x0], x1
    
    ret

/******************************************************************************************************
*  void pix_add_16_arm64(pel_t *dst, int i_dst, pel_t *pred, int i_pred, resi_t *resi, int bit_depth);
*  dst->x0, i_dst->x1, pred->x2, i_pred->x3, resi->x4, bit_depth->x5
******************************************************************************************************/
function pix_add_16_arm64
    mov x7, #16

pix_add_16_loop_y:
    //load resi
    ld1 {v0.8h - v3.8h}, [x4], #64
    ld1 {v4.8h - v7.8h}, [x4], #64
    
    //load pred
    ld1 {v16.8b, v17.8b}, [x2], x3
    ld1 {v18.8b, v19.8b}, [x2], x3
    ld1 {v20.8b, v21.8b}, [x2], x3
    ld1 {v22.8b, v23.8b}, [x2], x3

    uxtl v16.8h, v16.8b
    uxtl v17.8h, v17.8b
    uxtl v18.8h, v18.8b
    uxtl v19.8h, v19.8b
    uxtl v20.8h, v20.8b
    uxtl v21.8h, v21.8b
    uxtl v22.8h, v22.8b
    uxtl v23.8h, v23.8b

    add v0.8h, v0.8h, v16.8h
    add v1.8h, v1.8h, v17.8h
    add v2.8h, v2.8h, v18.8h
    add v3.8h, v3.8h, v19.8h
    add v4.8h, v4.8h, v20.8h
    add v5.8h, v5.8h, v21.8h
    add v6.8h, v6.8h, v22.8h
    add v7.8h, v7.8h, v23.8h

    sqxtun v0.8b, v0.8h
    sqxtun v1.8b, v1.8h
    sqxtun v2.8b, v2.8h
    sqxtun v3.8b, v3.8h
    sqxtun v4.8b, v4.8h
    sqxtun v5.8b, v5.8h
    sqxtun v6.8b, v6.8h
    sqxtun v7.8b, v7.8h
 
    st1 {v0.8b, v1.8b}, [x0], x1
    st1 {v2.8b, v3.8b}, [x0], x1
    st1 {v4.8b, v5.8b}, [x0], x1
    st1 {v6.8b, v7.8b}, [x0], x1
    subs w7, w7, #4
    bgt pix_add_16_loop_y
    
    ret

/******************************************************************************************************
*  void pix_add_32_arm64(pel_t *dst, int i_dst, pel_t *pred, int i_pred, resi_t *resi, int bit_depth);
*  dst->x0, i_dst->x1, pred->x2, i_pred->x3, resi->x4, bit_depth->x5
******************************************************************************************************/
function pix_add_32_arm64
    mov x7, #32
pix_add_32_loop_y:
    //load resi
    ld1 {v0.8h - v3.8h}, [x4], #64
    ld1 {v4.8h - v7.8h}, [x4], #64
    
    //load pred
    ld1 {v16.8b - v19.8b}, [x2], x3
    ld1 {v20.8b - v23.8b}, [x2], x3

    uxtl v16.8h, v16.8b
    uxtl v17.8h, v17.8b
    uxtl v18.8h, v18.8b
    uxtl v19.8h, v19.8b
    uxtl v20.8h, v20.8b
    uxtl v21.8h, v21.8b
    uxtl v22.8h, v22.8b
    uxtl v23.8h, v23.8b

    add v0.8h, v0.8h, v16.8h
    add v1.8h, v1.8h, v17.8h
    add v2.8h, v2.8h, v18.8h
    add v3.8h, v3.8h, v19.8h
    add v4.8h, v4.8h, v20.8h
    add v5.8h, v5.8h, v21.8h
    add v6.8h, v6.8h, v22.8h
    add v7.8h, v7.8h, v23.8h
    
    sqxtun v0.8b, v0.8h
    sqxtun v1.8b, v1.8h
    sqxtun v2.8b, v2.8h
    sqxtun v3.8b, v3.8h
    sqxtun v4.8b, v4.8h
    sqxtun v5.8b, v5.8h
    sqxtun v6.8b, v6.8h
    sqxtun v7.8b, v7.8h
    
    st1 {v0.8b - v3.8b}, [x0], x1
    st1 {v4.8b - v7.8b}, [x0], x1
    subs w7, w7, #2
    bgt pix_add_32_loop_y
    
    ret

#else

//void avg_pel_4_arm64(pel_t *dst, int i_dst, pel_t *src1, int i_src1, pel_t *src2, int i_src2, int width, int height);
// dst->x0, i_dst->x1, src1->x2, i_src1->x3, src2->x4, i_src2->x5, width->x6, height->x7
function avg_pel_4_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    lsl x5, x5, #1

avg_pel_w4_y:
    ld1 {v0.d}[0], [x2], x3
    ld1 {v0.d}[1], [x2], x3
    ld1 {v1.d}[0], [x2], x3
    ld1 {v1.d}[1], [x2], x3
    ld1 {v2.d}[0], [x4], x5
    ld1 {v2.d}[1], [x4], x5
    ld1 {v3.d}[0], [x4], x5
    ld1 {v3.d}[1], [x4], x5

    urhadd v0.8h, v0.8h, v2.8h
    urhadd v1.8h, v1.8h, v3.8h

    st1  {v0.d}[0], [x0], x1
    st1  {v0.d}[1], [x0], x1
    st1  {v1.d}[0], [x0], x1
    st1  {v1.d}[1], [x0], x1

    subs w7, w7, #4
    bgt avg_pel_w4_y

    ret

//void avg_pel_8_arm64(pel_t *dst, int i_dst, pel_t *src1, int i_src1, pel_t *src2, int i_src2, int width, int height);
// dst->x0, i_dst->x1, src1->x2, i_src1->x3, src2->x4, i_src2->x5, width->x6, height->x7
function avg_pel_8_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    lsl x5, x5, #1

avg_pel_w8_y:
    ld1 {v0.8h}, [x2], x3
    ld1 {v1.8h}, [x2], x3
    ld1 {v2.8h}, [x2], x3
    ld1 {v3.8h}, [x2], x3
    ld1 {v4.8h}, [x4], x5
    ld1 {v5.8h}, [x4], x5
    ld1 {v6.8h}, [x4], x5
    ld1 {v7.8h}, [x4], x5

    urhadd v0.8h, v0.8h, v4.8h
    urhadd v1.8h, v1.8h, v5.8h
    urhadd v2.8h, v2.8h, v6.8h
    urhadd v3.8h, v3.8h, v7.8h

    subs w7, w7, #4
    st1  {v0.8h}, [x0], x1
    st1  {v1.8h}, [x0], x1
    st1  {v2.8h}, [x0], x1
    st1  {v3.8h}, [x0], x1

    bgt avg_pel_w8_y

    ret

//void avg_pel_16_arm64(pel_t *dst, int i_dst, pel_t *src1, int i_src1, pel_t *src2, int i_src2, int width, int height);
// dst->x0, i_dst->x1, src1->x2, i_src1->x3, src2->x4, i_src2->x5, width->x6, height->x7
function avg_pel_16_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    lsl x5, x5, #1

avg_pel_w16_y:
    ld1 {v0.8h, v1.8h}, [x2], x3
    ld1 {v2.8h, v3.8h}, [x2], x3
    ld1 {v4.8h, v5.8h}, [x2], x3
    ld1 {v6.8h, v7.8h}, [x2], x3

    ld1 {v20.8h, v21.8h}, [x4], x5
    ld1 {v22.8h, v23.8h}, [x4], x5
    ld1 {v24.8h, v25.8h}, [x4], x5
    ld1 {v26.8h, v27.8h}, [x4], x5

    urhadd v0.8h, v0.8h, v20.8h
    urhadd v1.8h, v1.8h, v21.8h
    urhadd v2.8h, v2.8h, v22.8h
    urhadd v3.8h, v3.8h, v23.8h
    urhadd v4.8h, v4.8h, v24.8h
    urhadd v5.8h, v5.8h, v25.8h
    urhadd v6.8h, v6.8h, v26.8h
    urhadd v7.8h, v7.8h, v27.8h

    subs w7, w7, #4
    st1  {v0.8h, v1.8h}, [x0], x1
    st1  {v2.8h, v3.8h}, [x0], x1
    st1  {v4.8h, v5.8h}, [x0], x1
    st1  {v6.8h, v7.8h}, [x0], x1

    bgt avg_pel_w16_y

    ret

//void avg_pel_32_arm64(pel_t *dst, int i_dst, pel_t *src1, int i_src1, pel_t *src2, int i_src2, int width, int height);
// dst->x0, i_dst->x1, src1->x2, i_src1->x3, src2->x4, i_src2->x5, width->x6, height->x7
function avg_pel_32_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    lsl x5, x5, #1

avg_pel_w32_y:
    ld1 {v0.8h - v3.8h}, [x2], x3
    ld1 {v4.8h - v7.8h}, [x2], x3

    ld1 {v20.8h - v23.8h}, [x4], x5
    ld1 {v24.8h - v27.8h}, [x4], x5

    urhadd v0.8h, v0.8h, v20.8h
    urhadd v1.8h, v1.8h, v21.8h
    urhadd v2.8h, v2.8h, v22.8h
    urhadd v3.8h, v3.8h, v23.8h
    urhadd v4.8h, v4.8h, v24.8h
    urhadd v5.8h, v5.8h, v25.8h
    urhadd v6.8h, v6.8h, v26.8h
    urhadd v7.8h, v7.8h, v27.8h

    subs w7, w7, #2
    st1  {v0.8h - v3.8h}, [x0], x1
    st1  {v4.8h - v7.8h}, [x0], x1
    bgt avg_pel_w32_y

    ret

//void com_mem_cpy4_arm64(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5
function com_mem_cpy4_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
if_cpy_w4_loop_y:
    ld1 {v0.4h}, [x0], x1
    ld1 {v1.4h}, [x0], x1
    ld1 {v2.4h}, [x0], x1
    ld1 {v3.4h}, [x0], x1
    st1 {v0.4h}, [x2], x3
    st1 {v1.4h}, [x2], x3
    subs w5, w5, #4
    st1 {v2.4h}, [x2], x3
    st1 {v3.4h}, [x2], x3
    bgt if_cpy_w4_loop_y

    ret

//void com_mem_cpy8_arm64(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5
function com_mem_cpy8_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
if_cpy_w8_loop_y:
    ld1 {v0.8h}, [x0], x1
    ld1 {v1.8h}, [x0], x1
    ld1 {v2.8h}, [x0], x1
    ld1 {v3.8h}, [x0], x1

    subs w5, w5, #4
    st1 {v0.8h}, [x2], x3
    st1 {v1.8h}, [x2], x3
    st1 {v2.8h}, [x2], x3
    st1 {v3.8h}, [x2], x3
    bgt if_cpy_w8_loop_y

    ret

//void com_mem_cpy16_arm64(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5
function com_mem_cpy16_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
if_cpy_w16_loop_y:
    ld1 {v0.2d, v1.2d}, [x0], x1
    ld1 {v2.2d, v3.2d}, [x0], x1
    ld1 {v4.2d, v5.2d}, [x0], x1
    ld1 {v6.2d, v7.2d}, [x0], x1

    subs w5, w5, #4
    st1 {v0.2d, v1.2d}, [x2], x3
    st1 {v2.2d, v3.2d}, [x2], x3
    st1 {v4.2d, v5.2d}, [x2], x3
    st1 {v6.2d, v7.2d}, [x2], x3
    bgt if_cpy_w16_loop_y

    ret

//void com_mem_cpy32_arm64(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5
function com_mem_cpy32_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
if_cpy_w32_loop_y:
    ld1 {v0.2d, v1.2d, v2.2d, v3.2d}, [x0], x1
    ld1 {v4.2d, v5.2d, v6.2d, v7.2d}, [x0], x1
    ld1 {v18.2d, v19.2d, v20.2d, v21.2d}, [x0], x1
    ld1 {v22.2d, v23.2d, v24.2d, v25.2d}, [x0], x1

    subs w5, w5, #4
    st1 {v0.2d, v1.2d, v2.2d, v3.2d}, [x2], x3
    st1 {v4.2d, v5.2d, v6.2d, v7.2d}, [x2], x3
    st1 {v18.2d, v19.2d, v20.2d, v21.2d}, [x2], x3
    st1 {v22.2d, v23.2d, v24.2d, v25.2d}, [x2], x3
    bne if_cpy_w32_loop_y

    ret

/******************************************************************************************************
*  void pix_sub_4_arm64(resi_t *dst, pel_t *org, int i_org, pel_t *pred, int i_pred)
*  dst->x0, org->x1, i_org->x2, pred->x3, i_pred->x4
******************************************************************************************************/
function pix_sub_4_arm64

    lsl x2, x2, #1
    lsl x4, x4, #1

    //load *org
    ld1 {v0.d}[0], [x1], x2
    ld1 {v0.d}[1], [x1], x2
    ld1 {v1.d}[0], [x1], x2
    ld1 {v1.d}[1], [x1], x2

    //load *pred
    ld1 {v2.d}[0], [x3], x4
    ld1 {v2.d}[1], [x3], x4
    ld1 {v3.d}[0], [x3], x4
    ld1 {v3.d}[1], [x3], x4

    //sub
    sub v0.8h, v0.8h, v2.8h
    sub v1.8h, v1.8h, v3.8h

    st1 {v0.8h, v1.8h}, [x0]

    ret

/******************************************************************************************************
*  void pix_sub_8_arm64(resi_t *dst, pel_t *org, int i_org, pel_t *pred, int i_pred)
*  dst->x0, org->x1, i_org->x2, pred->x3, i_pred->x4
******************************************************************************************************/
function pix_sub_8_arm64
    lsl x2, x2, #1
    lsl x4, x4, #1

    //load *org
    ld1 {v0.8h}, [x1], x2
    ld1 {v1.8h}, [x1], x2
    ld1 {v2.8h}, [x1], x2
    ld1 {v3.8h}, [x1], x2
    ld1 {v4.8h}, [x1], x2
    ld1 {v5.8h}, [x1], x2
    ld1 {v6.8h}, [x1], x2
    ld1 {v7.8h}, [x1], x2

    //load *pred
    ld1 {v16.8h}, [x3], x4
    ld1 {v17.8h}, [x3], x4
    ld1 {v18.8h}, [x3], x4
    ld1 {v19.8h}, [x3], x4
    ld1 {v20.8h}, [x3], x4
    ld1 {v21.8h}, [x3], x4
    ld1 {v22.8h}, [x3], x4
    ld1 {v23.8h}, [x3], x4

    //sub
    sub v0.8h, v0.8h, v16.8h
    sub v1.8h, v1.8h, v17.8h
    sub v2.8h, v2.8h, v18.8h
    sub v3.8h, v3.8h, v19.8h
    sub v4.8h, v4.8h, v20.8h
    sub v5.8h, v5.8h, v21.8h
    sub v6.8h, v6.8h, v22.8h
    sub v7.8h, v7.8h, v23.8h

    st1 {v0.8h - v3.8h}, [x0], #64
    st1 {v4.8h - v7.8h}, [x0]

    ret

/******************************************************************************************************
*  void pix_sub_16_arm64(resi_t *dst, pel_t *org, int i_org, pel_t *pred, int i_pred)
*  dst->x0, org->x1, i_org->x2, pred->x3, i_pred->x4
******************************************************************************************************/
function pix_sub_16_arm64
    lsl x2, x2, #1
    lsl x4, x4, #1
    mov x5, #4

diff_w16_loopy:
    ld1 {v0.8h, v1.8h}, [x1], x2
    ld1 {v2.8h, v3.8h}, [x1], x2
    ld1 {v4.8h, v5.8h}, [x1], x2
    ld1 {v6.8h, v7.8h}, [x1], x2

    //load *pred
    ld1 {v16.8h, v17.8h}, [x3], x4
    ld1 {v18.8h, v19.8h}, [x3], x4
    ld1 {v20.8h, v21.8h}, [x3], x4
    ld1 {v22.8h, v23.8h}, [x3], x4

    //sub
    sub v0.8h, v0.8h, v16.8h
    sub v1.8h, v1.8h, v17.8h
    sub v2.8h, v2.8h, v18.8h
    sub v3.8h, v3.8h, v19.8h
    sub v4.8h, v4.8h, v20.8h
    sub v5.8h, v5.8h, v21.8h
    sub v6.8h, v6.8h, v22.8h
    sub v7.8h, v7.8h, v23.8h

    st1 {v0.8h - v3.8h}, [x0], #64
    st1 {v4.8h - v7.8h}, [x0], #64
    subs w5, w5, #1
    bgt diff_w16_loopy

    ret

/******************************************************************************************************
*  void pix_sub_32_arm64(resi_t *dst, pel_t *org, int i_org, pel_t *pred, int i_pred)
*  dst->x0, org->x1, i_org->x2, pred->x3, i_pred->x4
******************************************************************************************************/
function pix_sub_32_arm64
    lsl x2, x2, #1
    lsl x4, x4, #1
    mov x5, #16

diff_w32_loopy:
    ld1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    ld1 {v4.8h, v5.8h, v6.8h, v7.8h}, [x1], x2

    //load *pred
    ld1 {v16.8h, v17.8h, v18.8h, v19.8h}, [x3], x4
    ld1 {v20.8h, v21.8h, v22.8h, v23.8h}, [x3], x4

    //sub
    sub v0.8h, v0.8h, v16.8h
    sub v1.8h, v1.8h, v17.8h
    sub v2.8h, v2.8h, v18.8h
    sub v3.8h, v3.8h, v19.8h
    sub v4.8h, v4.8h, v20.8h
    sub v5.8h, v5.8h, v21.8h
    sub v6.8h, v6.8h, v22.8h
    sub v7.8h, v7.8h, v23.8h

    st1 {v0.8h - v3.8h}, [x0], #64
    st1 {v4.8h - v7.8h}, [x0], #64

    subs w5, w5, #1
    bgt diff_w32_loopy

    ret

/******************************************************************************************************
*  void pix_add_8_arm64(pel_t *dst, int i_dst, pel_t *pred, int i_pred, resi_t *resi, int bit_depth);
*  dst->x0, i_dst->x1, pred->x2, i_pred->x3, resi->x4, bit_depth->x5
******************************************************************************************************/
function pix_add_8_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    mov x6, #1
    lsl x6, x6, x5
    sub x6, x6, #1      //max_pixel
    dup v31.8h, w6
    mov w6, #0
    dup v30.8h, w6

    //load resi
    ld1 {v0.8h - v3.8h}, [x4], #64
    ld1 {v4.8h - v7.8h}, [x4]
    
    //load pred
    ld1 {v16.8h}, [x2], x3
    ld1 {v17.8h}, [x2], x3
    ld1 {v18.8h}, [x2], x3
    ld1 {v19.8h}, [x2], x3
    ld1 {v20.8h}, [x2], x3
    ld1 {v21.8h}, [x2], x3
    ld1 {v22.8h}, [x2], x3
    ld1 {v23.8h}, [x2], x3

    add v0.8h, v0.8h, v16.8h
    add v1.8h, v1.8h, v17.8h
    add v2.8h, v2.8h, v18.8h
    add v3.8h, v3.8h, v19.8h
    add v4.8h, v4.8h, v20.8h
    add v5.8h, v5.8h, v21.8h
    add v6.8h, v6.8h, v22.8h
    add v7.8h, v7.8h, v23.8h
    
    smin v0.8h, v0.8h, v31.8h
    smin v1.8h, v1.8h, v31.8h
    smin v2.8h, v2.8h, v31.8h
    smin v3.8h, v3.8h, v31.8h
    smin v4.8h, v4.8h, v31.8h
    smin v5.8h, v5.8h, v31.8h
    smin v6.8h, v6.8h, v31.8h
    smin v7.8h, v7.8h, v31.8h
    smax v0.8h, v0.8h, v30.8h
    smax v1.8h, v1.8h, v30.8h
    smax v2.8h, v2.8h, v30.8h
    smax v3.8h, v3.8h, v30.8h
    smax v4.8h, v4.8h, v30.8h
    smax v5.8h, v5.8h, v30.8h
    smax v6.8h, v6.8h, v30.8h
    smax v7.8h, v7.8h, v30.8h
    
    st1 {v0.8h}, [x0], x1
    st1 {v1.8h}, [x0], x1
    st1 {v2.8h}, [x0], x1
    st1 {v3.8h}, [x0], x1
    st1 {v4.8h}, [x0], x1
    st1 {v5.8h}, [x0], x1
    st1 {v6.8h}, [x0], x1
    st1 {v7.8h}, [x0], x1
    
    ret

/******************************************************************************************************
*  void pix_add_16_arm64(pel_t *dst, int i_dst, pel_t *pred, int i_pred, resi_t *resi, int bit_depth);
*  dst->x0, i_dst->x1, pred->x2, i_pred->x3, resi->x4, bit_depth->x5
******************************************************************************************************/
function pix_add_16_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    mov x6, #1
    lsl x6, x6, x5
    sub x6, x6, #1      //max_pixel
    dup v31.8h, w6
    mov w6, #0
    dup v30.8h, w6
    mov x7, #16

pix_add_16_loop_y:
    //load resi
    ld1 {v0.8h - v3.8h}, [x4], #64
    ld1 {v4.8h - v7.8h}, [x4], #64
    
    //load pred
    ld1 {v16.8h, v17.8h}, [x2], x3
    ld1 {v18.8h, v19.8h}, [x2], x3
    ld1 {v20.8h, v21.8h}, [x2], x3
    ld1 {v22.8h, v23.8h}, [x2], x3

    add v0.8h, v0.8h, v16.8h
    add v1.8h, v1.8h, v17.8h
    add v2.8h, v2.8h, v18.8h
    add v3.8h, v3.8h, v19.8h
    add v4.8h, v4.8h, v20.8h
    add v5.8h, v5.8h, v21.8h
    add v6.8h, v6.8h, v22.8h
    add v7.8h, v7.8h, v23.8h
    
    smin v0.8h, v0.8h, v31.8h
    smin v1.8h, v1.8h, v31.8h
    smin v2.8h, v2.8h, v31.8h
    smin v3.8h, v3.8h, v31.8h
    smin v4.8h, v4.8h, v31.8h
    smin v5.8h, v5.8h, v31.8h
    smin v6.8h, v6.8h, v31.8h
    smin v7.8h, v7.8h, v31.8h
    smax v0.8h, v0.8h, v30.8h
    smax v1.8h, v1.8h, v30.8h
    smax v2.8h, v2.8h, v30.8h
    smax v3.8h, v3.8h, v30.8h
    smax v4.8h, v4.8h, v30.8h
    smax v5.8h, v5.8h, v30.8h
    smax v6.8h, v6.8h, v30.8h
    smax v7.8h, v7.8h, v30.8h
    
    st1 {v0.8h, v1.8h}, [x0], x1
    st1 {v2.8h, v3.8h}, [x0], x1
    st1 {v4.8h, v5.8h}, [x0], x1
    st1 {v6.8h, v7.8h}, [x0], x1
    subs w7, w7, #4
    bgt pix_add_16_loop_y
    
    ret

/******************************************************************************************************
*  void pix_add_32_arm64(pel_t *dst, int i_dst, pel_t *pred, int i_pred, resi_t *resi, int bit_depth);
*  dst->x0, i_dst->x1, pred->x2, i_pred->x3, resi->x4, bit_depth->x5
******************************************************************************************************/
function pix_add_32_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    mov x6, #1
    lsl x6, x6, x5
    sub x6, x6, #1      //max_pixel
    dup v31.8h, w6
    mov w6, #0
    dup v30.8h, w6
    mov x7, #32

pix_add_32_loop_y:
    //load resi
    ld1 {v0.8h - v3.8h}, [x4], #64
    ld1 {v4.8h - v7.8h}, [x4], #64
    
    //load pred
    ld1 {v16.8h - v19.8h}, [x2], x3
    ld1 {v20.8h - v23.8h}, [x2], x3

    add v0.8h, v0.8h, v16.8h
    add v1.8h, v1.8h, v17.8h
    add v2.8h, v2.8h, v18.8h
    add v3.8h, v3.8h, v19.8h
    add v4.8h, v4.8h, v20.8h
    add v5.8h, v5.8h, v21.8h
    add v6.8h, v6.8h, v22.8h
    add v7.8h, v7.8h, v23.8h
    
    smin v0.8h, v0.8h, v31.8h
    smin v1.8h, v1.8h, v31.8h
    smin v2.8h, v2.8h, v31.8h
    smin v3.8h, v3.8h, v31.8h
    smin v4.8h, v4.8h, v31.8h
    smin v5.8h, v5.8h, v31.8h
    smin v6.8h, v6.8h, v31.8h
    smin v7.8h, v7.8h, v31.8h
    smax v0.8h, v0.8h, v30.8h
    smax v1.8h, v1.8h, v30.8h
    smax v2.8h, v2.8h, v30.8h
    smax v3.8h, v3.8h, v30.8h
    smax v4.8h, v4.8h, v30.8h
    smax v5.8h, v5.8h, v30.8h
    smax v6.8h, v6.8h, v30.8h
    smax v7.8h, v7.8h, v30.8h
    
    st1 {v0.8h - v3.8h}, [x0], x1
    st1 {v4.8h - v7.8h}, [x0], x1
    subs w7, w7, #2
    bgt pix_add_32_loop_y
    
    ret

#endif

#endif
