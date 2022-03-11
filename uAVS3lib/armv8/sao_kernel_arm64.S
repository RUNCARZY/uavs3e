#include "def_arm64.S"

#if defined(__arm64__)

#if !COMPILE_10BIT
/***********************************************************************************************************************************
*  void sao_eo_0_arm64(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_x, int end_x, int mb_height, char_t* mask)
*  src->x0, dst->x1, src_stride->x2, dst_stride->x3, offset->x4, start_x->x5, end_x->x6, mb_height->x7, mask->x8
************************************************************************************************************************************/
function sao_eo_0_arm64
    ldr x8, [sp]                // mask

    // ------- load mask -------
    sub x10, x6, x5
    and x9, x10, #15
    add x12, x8, x9, lsl #4
    ld1 {v31.4s}, [x12]         // mask + (((end_x - start_x) & 0x0f) - 1)*16

    sub w10, w6, w9             // end_x_16 = end_x - ((end_x - start_x) & 0x0f)

    // ------- set offset table -------
    ld1  {v20.4s}, [x4]         // offset[0-3]
    ldr  w9, [x4, #16]          // offset[4]
    mov  x8, #0
    movi v2.4s, #0
    mov  v2.s[0], w9
    xtn  v0.4h, v20.4s
    xtn2 v0.8h, v2.4s
    xtn  v0.8b, v0.8h           // v0.8b: offset[0-4]

    movi v1.16b, #2

loop_y_eo_0:

    mov x9, x5                  // x = start_x
loop_x_eo_0:

    add  x12, x0, x9
    sub  x13, x12, #1
    add  x14, x12, #1
    
    ld1  {v21.16b}, [x12]       // src[x]
    ld1  {v20.16b}, [x13]       // src[x-1]
    ld1  {v22.16b}, [x14]       // src[x+1]

    // leftsign & rightsign
    umin v23.16b, v20.16b, v21.16b
    umin v24.16b, v21.16b, v22.16b

    cmeq v25.16b, v23.16b, v20.16b
    cmeq v26.16b, v23.16b, v21.16b
    cmeq v27.16b, v24.16b, v21.16b
    cmeq v28.16b, v24.16b, v22.16b

    sub  v20.16b, v26.16b, v25.16b      // leftsign
    sub  v22.16b, v27.16b, v28.16b      // rightsign

    // get edgetype
    add v20.16b, v22.16b, v20.16b       // edgetype

    uxtl  v23.8h, v21.8b
    uxtl2 v24.8h, v21.16b               // src[x]

    add v20.16b, v20.16b, v1.16b        // edgetype+2
    tbl v22.16b, {v0.16b}, v20.16b      // offset

    saddw  v23.8h, v23.8h, v22.8b       // offset+src[x] low 8 samples
    saddw2 v24.8h, v24.8h, v22.16b      // offset+src[x] high 8 samples

    sqxtun  v20.8b, v23.8h
    sqxtun2 v20.16b, v24.8h

    add x12, x1, x9
    cmp x9, x10
    beq maskmove_eo_0
    add x9, x9, #16
    st1 {v20.16b}, [x12]
    cmp x9, x6
    blt loop_x_eo_0
    b   loop_x_eo_0_end

maskmove_eo_0:
    // maskmove
    ld1 {v22.16b}, [x12]                // load 16 pixels from dst+x
    bif v20.16b, v22.16b, v31.16b
    st1 {v20.16b}, [x12]

loop_x_eo_0_end:
    subs w7, w7, #1
    add x0, x0, x2
    add x1, x1, x3
    bne loop_y_eo_0

    ret

/***********************************************************************************************************************************
 *  void sao_eo_90_arm64(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_y, int end_y, int mb_width);
 *  src->x0, dst->x1, src_stride->x2, dst_stride->x3, offset->x4, start_y->x5, end_y->x6, mb_width->x7
 ************************************************************************************************************************************/
function sao_eo_90_arm64

    mul x8, x2, x5
    mul x9, x3, x5
    add x0, x0, x8
    add x1, x1, x9              // update x0 and x2

    sub x10, x7, #15            // end_x_16 = mb_width - 15

    // ------- set offset table -------
    ld1  {v20.4s}, [x4]         // offset[0-3]
    ldr  w9, [x4, #16]          // offset[4]
    mov  x8, #0
    movi v2.4s, #0
    mov  v2.s[0], w9
    xtn  v0.4h, v20.4s
    xtn2 v0.8h, v2.4s
    xtn  v0.8b, v0.8h           // offset[0-4]

    movi v1.16b, #2

    sub  w8, w6, w5             // loop_y = end_y - start_y

    mov  w12, #0
    mov  w9, #-1
    cmp  w7, #4
    beq  set_mask_width_4
    movi v30.2d, #-1
    mov  v30.s[3], w12          //  mask="-1 repeat 12, 0, 0, 0, 0"
    b    loop_y_eo_90

set_mask_width_4:

    movi v30.4s, #0
    mov  v30.s[0], w9           // mask="-1, -1, -1, -1, 0 repeat 12"

loop_y_eo_90:

    mov  x9, #0                 // x = 0

loop_x_eo_90:
    add  x12, x0, x9            // x12
    sub  x13, x12, x2
    add  x14, x12, x2
    ld1  {v21.16b}, [x12]       // src[x]
    ld1  {v20.16b}, [x13]       // src[x-src_stride]
    ld1  {v22.16b}, [x14]       // src[x+src_stride]

    // get leftsign & rightsign
    umin  v23.16b, v20.16b, v21.16b
    umin  v26.16b, v21.16b, v22.16b
    cmeq  v24.16b, v23.16b, v20.16b
    cmeq  v25.16b, v23.16b, v21.16b
    cmeq  v27.16b, v26.16b, v21.16b
    cmeq  v28.16b, v26.16b, v22.16b
    sub   v20.16b, v25.16b, v24.16b     //-- leftsign
    sub   v22.16b, v27.16b, v28.16b     //-- rightsign

    add     v20.16b, v22.16b, v20.16b   // edgetype

    uxtl    v23.8h, v21.8b
    uxtl2   v24.8h, v21.16b             // src[x]

    add     v20.16b, v20.16b, v1.16b    // edgetype+2
    tbl     v22.16b, {v0.16b}, v20.16b  // offset

    saddw   v23.8h, v23.8h, v22.8b      // offset+src[x] low 8 samples
    saddw2  v24.8h, v24.8h, v22.16b     // offset+src[x] high 8 samples

    sqxtun  v20.8b, v23.8h
    sqxtun2 v20.16b, v24.8h             // $v20.16b the result = offset+src[x]

    add x12, x1, x9
    cmp x9, x10
    bge maskmove_eo_90
    st1 {v20.16b}, [x12]
    add x9, x9, #16
    cmp x9, x7
    blt loop_x_eo_90
    b   loop_x_eo_90_end

maskmove_eo_90:
    // maskmove
    ld1 {v22.16b}, [x12]                // load 16 pixels from dst+x
    bif v20.16b, v22.16b, v30.16b
    st1 {v20.16b}, [x12]

loop_x_eo_90_end:
    subs w8, w8, #1                     // loop_y--
    add x0, x0, x2
    add x1, x1, x3
    bgt loop_y_eo_90

    ret

/***********************************************************************************************************************************
 *  void sao_eo_135_arm64(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, char_t* mask, int mb_height, int bit_depth, int start_x_r0,
 *  int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
 *  src->x0, dst->x1, src_stride->x2, dst_stride->x3, offset->x4, mask->x5, mb_height->x6, start_x_r0->x7,
 *  end_x_r0->x8, start_x_r->x9, end_x_r->x10, start_x_rn->x11, end_x_rn->x12
 ************************************************************************************************************************************/
function sao_eo_135_arm64
    // get start_x_r0 and end_x_r0
#if defined(__APPLE__)
    ldp w8, w9, [sp]
#else
    ldp x8, x9, [sp]
#endif
    sxtw x8, w8                         // start_x_r0
    sxtw x9, w9                         // end_x_r0

    // get end_x_r0_16
    sub x11, x9, x8
    and x11, x11, #15
    sub x10, x9, x11                    // end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f

    // ------- set offset table -------
    ld1  {v20.4s}, [x4]                 // offset[0-3]
    ldr  w11, [x4, #16]                 // offset[4]
    movi v2.4s, #0
    mov  v2.s[0], w11
    xtn  v0.4h, v20.4s
    xtn2 v0.8h, v2.4s
    xtn  v0.8b, v0.8h                   // offset[0-4]

    movi v1.16b, #2

    // ------- first row -------
    mov  x11, x8                        // x = start_x_r0

test_loop_x_eo_135_r0:

    cmp x11, x9
    bge test_loop_x_eo_135_end_r0

    add x12, x0, x11
    sub x13, x12, x2
    add x14, x12, x2
    sub x13, x13, #1
    add x14, x14, #1
    ld1 {v21.16b}, [x12]                // src[x]
    ld1 {v20.16b}, [x13]                // src[x-src_stride-1]
    ld1 {v22.16b}, [x14]                // src[x+src_stride+1]

    // get leftsign & rightsign
    umin  v23.16b, v20.16b, v21.16b
    umin  v26.16b, v21.16b, v22.16b
    cmeq  v24.16b, v23.16b, v20.16b
    cmeq  v25.16b, v23.16b, v21.16b
    cmeq  v27.16b, v26.16b, v21.16b
    cmeq  v28.16b, v26.16b, v22.16b
    sub   v20.16b, v25.16b, v24.16b     //-- leftsign
    sub   v22.16b, v27.16b, v28.16b     //-- rightsign

    add     v20.16b, v22.16b, v20.16b   // edgetype

    uxtl    v23.8h, v21.8b
    uxtl2   v24.8h, v21.16b             // src[x]

    add     v20.16b, v20.16b, v1.16b    // edgetype+2
    tbl     v22.16b, {v0.16b}, v20.16b  // offset

    saddw   v23.8h, v23.8h, v22.8b      // offset+src[x] low 8 samples
    saddw2  v24.8h, v24.8h, v22.16b     // offset+src[x] high 8 samples

    sqxtun  v20.8b, v23.8h
    sqxtun2 v20.16b, v24.8h             //-- results

    add x12, x1, x11
    cmp x11, x10
    bge test_maskmove_eo_135_r0
    st1 {v20.16b}, [x12]
    add x11, x11, #16
    b   test_loop_x_eo_135_r0

test_maskmove_eo_135_r0:
    sub x7, x9, x10
    add x7, x5, x7, lsl #4              // offset = 16*rownum
    ld1 {v30.4s}, [x7]                  // load mask_r0
    ld1 {v22.16b}, [x12]                // load 16 pixels from dst+x
    bif v20.16b, v22.16b, v30.16b
    st1 {v20.16b}, [x12]

test_loop_x_eo_135_end_r0:
    add x0, x0, x2                      // src+=src_stride
    add x1, x1, x3                      // dst+=dst_stride

    // ------- middle rows -------
    // get param
#if defined(__APPLE__)
    ldp w7, w8, [sp, #8]
#else
    ldp x7, x8, [sp, #16]
#endif
    sxtw x7, w7                         // start_x_r
    sxtw x8, w8                         // end_x_r

    sub x9, x8, x7
    and x9, x9, #15
    add x12, x5, x9, lsl #4
    ld1 {v30.4s}, [x12]                 // mask_r

    sub x10, x8, x9                     // end_x_r_16

    sub x11, x6, #2                     // y = mb_height - 2

test_loop_y_eo_135_r:

    mov x9, x7                          // x = start_x_r

test_loop_x_eo_135_r:
    add x12, x0, x9
    sub x13, x12, x2
    add x14, x12, x2
    sub x13, x13, #1
    add x14, x14, #1
    ld1 {v21.16b}, [x12]                // src[x]
    ld1 {v20.16b}, [x13]                // src[x-src_stride-1]
    ld1 {v22.16b}, [x14]                // src[x+src_stride+1]

    // get leftsign & rightsign
    umin  v23.16b, v20.16b, v21.16b
    umin  v26.16b, v21.16b, v22.16b
    cmeq  v24.16b, v23.16b, v20.16b
    cmeq  v25.16b, v23.16b, v21.16b
    cmeq  v27.16b, v26.16b, v21.16b
    cmeq  v28.16b, v26.16b, v22.16b
    sub   v20.16b, v25.16b, v24.16b     //-- leftsign
    sub   v22.16b, v27.16b, v28.16b     //-- rightsign

    add     v20.16b, v22.16b, v20.16b   // edgetype

    uxtl    v23.8h, v21.8b
    uxtl2   v24.8h, v21.16b             // src[x]

    add     v20.16b, v20.16b, v1.16b    // edgetype+2
    tbl     v22.16b, {v0.16b}, v20.16b  // offset

    saddw   v23.8h, v23.8h, v22.8b      // offset+src[x] low 8 samples
    saddw2  v24.8h, v24.8h, v22.16b     // offset+src[x] high 8 samples

    sqxtun  v20.8b, v23.8h
    sqxtun2 v20.16b, v24.8h             //-- results

    add x12, x1, x9
    cmp x9, x10
    bge test_maskmove_eo_135_r
    add x9, x9, #16
    st1 {v20.16b}, [x12]
    cmp x9, x8
    blt test_loop_x_eo_135_r
    b   test_loop_x_eo_135_end_r

test_maskmove_eo_135_r:
    ld1 {v22.16b}, [x12]                // load 16 pixels from dst+x
    bif v20.16b, v22.16b, v30.16b
    st1 {v20.16b}, [x12]

test_loop_x_eo_135_end_r:
    subs x11, x11, #1                   // y--
    add x0, x0, x2                      // src += src_stride
    add x1, x1, x3                      // dst += dst_stride
    bgt test_loop_y_eo_135_r

// ------- last row -------
#if defined(__APPLE__)
    ldp w6, w7, [sp, #16]
#else
    ldp x6, x7, [sp, #32]
#endif
    sxtw x6, w6                         // start_x_rn
    sxtw x7, w7                         // end_x_rn

    sub x8, x7, x6
    and x8, x8, #15
    sub x10, x7, x8                     // end_x_rn_16

    mov x9, x6                          // x = start_x_rn

test_loop_x_eo_135_rn:
    cmp x9, x7
    bge test_loop_x_eo_135_end_rn

    add x12, x0, x9
    sub x13, x12, x2
    add x14, x12, x2
    sub x13, x13, #1
    add x14, x14, #1
    ld1 {v21.16b}, [x12]                // src[x]
    ld1 {v20.16b}, [x13]                // src[x-src_stride-1]
    ld1 {v22.16b}, [x14]                // src[x+src_stride+1]

    // get leftsign & rightsign
    umin  v23.16b, v20.16b, v21.16b
    umin  v26.16b, v21.16b, v22.16b
    cmeq  v24.16b, v23.16b, v20.16b
    cmeq  v25.16b, v23.16b, v21.16b
    cmeq  v27.16b, v26.16b, v21.16b
    cmeq  v28.16b, v26.16b, v22.16b
    sub   v20.16b, v25.16b, v24.16b     //-- leftsign
    sub   v22.16b, v27.16b, v28.16b     //-- rightsign

    add     v20.16b, v22.16b, v20.16b   // edgetype

    uxtl    v23.8h, v21.8b
    uxtl2   v24.8h, v21.16b             // src[x]

    add     v20.16b, v20.16b, v1.16b    // edgetype+2
    tbl     v22.16b, {v0.16b}, v20.16b  // offset

    saddw   v23.8h, v23.8h, v22.8b      // offset+src[x] low 8 samples
    saddw2  v24.8h, v24.8h, v22.16b     // offset+src[x] high 8 samples

    sqxtun  v20.8b, v23.8h
    sqxtun2 v20.16b, v24.8h             //-- results

    add x12, x1, x9
    cmp x9, x10
    bge test_maskmove_eo_135_rn
    st1 {v20.16b}, [x12]
    add x9, x9, #16
    b   test_loop_x_eo_135_rn

test_maskmove_eo_135_rn:
    sub x6, x7, x10
    add x6, x5, x6, lsl #4              // offset = 16*rownum
    ld1 {v30.4s}, [x6]                  // load mask_r0
    ld1 {v22.16b}, [x12]                // load 16 pixels from dst+x
    bif v20.16b, v22.16b, v30.16b
    st1 {v20.16b}, [x12]

test_loop_x_eo_135_end_rn:

    ret

/***********************************************************************************************************************************
 *  void sao_eo_45_arm64(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, char_t* mask, int mb_height, int start_x_r0,
 *  int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
 *  src->x0, dst->x1, src_stride->x2, dst_stride->x3, offset->x4, mask->x5, mb_height->x6, start_x_r0->x7,
 *  end_x_r0->x8, start_x_r->x9, end_x_r->x10, start_x_rn->x11, end_x_rn->x12
 ************************************************************************************************************************************/
function sao_eo_45_arm64
#if defined(__APPLE__)
    ldp w8, w9, [sp]
#else
    ldp x8, x9, [sp]
#endif
    sxtw x8, w8                         // start_x_r0
    sxtw x9, w9                         // end_x_r0

    // get end_x_r0_16
    sub x11, x9, x8
    and x11, x11, #15
    sub x10, x9, x11                    // end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f

    // ------- set offset table -------
    ld1  {v20.4s}, [x4]                 // offset[0-3]
    ldr  w11, [x4, #16]                 // offset[4]
    movi v2.4s, #0
    mov  v2.s[0], w11
    xtn  v0.4h, v20.4s
    xtn2 v0.8h, v2.4s
    xtn  v0.8b, v0.8h                   // offset[0-4]

    movi v1.16b, #2

    // ------- first row -------
    mov  x11, x8                         // x = start_x_r0

test_loop_x_eo_45_r0:

    cmp x11, x9
    bge test_loop_x_eo_45_end_r0
    add x12, x0, x11
    sub x13, x12, x2
    add x14, x12, x2
    add x13, x13, #1
    sub x14, x14, #1
    ld1 {v21.16b}, [x12]                // src[x]
    ld1 {v20.16b}, [x13]                // src[x-src_stride+1]
    ld1 {v22.16b}, [x14]                // src[x+src_stride-1]

    // get leftsign & rightsign
    umin  v23.16b, v20.16b, v21.16b
    umin  v26.16b, v21.16b, v22.16b
    cmeq  v24.16b, v23.16b, v20.16b
    cmeq  v25.16b, v23.16b, v21.16b
    cmeq  v27.16b, v26.16b, v21.16b
    cmeq  v28.16b, v26.16b, v22.16b
    sub   v20.16b, v25.16b, v24.16b     //-- leftsign
    sub   v22.16b, v27.16b, v28.16b     //-- rightsign

    add     v20.16b, v22.16b, v20.16b   // edgetype

    uxtl    v23.8h, v21.8b
    uxtl2   v24.8h, v21.16b             // src[x]

    add     v20.16b, v20.16b, v1.16b    // edgetype+2
    tbl     v22.16b, {v0.16b}, v20.16b  // offset

    saddw   v23.8h, v23.8h, v22.8b      // offset+src[x] low 8 samples
    saddw2  v24.8h, v24.8h, v22.16b     // offset+src[x] high 8 samples

    sqxtun  v20.8b, v23.8h
    sqxtun2 v20.16b, v24.8h             //-- results

    add x12, x1, x11
    cmp x11, x10
    bge test_maskmove_eo_45_r0
    st1 {v20.16b}, [x12]
    add x11, x11, #16
    b   test_loop_x_eo_45_r0

test_maskmove_eo_45_r0:
    sub x7, x9, x10
    add x7, x5, x7, lsl #4              // offset = 16*rownum
    ld1 {v30.4s}, [x7]                  // load mask_r0
    ld1 {v22.16b}, [x12]                // load 16 pixels from dst+x
    bif v20.16b, v22.16b, v30.16b
    st1 {v20.16b}, [x12]

test_loop_x_eo_45_end_r0:
    add x0, x0, x2                      // src+=src_stride
    add x1, x1, x3                      // dst+=dst_stride

    // ------- middle rows -------
    // get param
#if defined(__APPLE__)
    ldp w7, w8, [sp, #8]                // x7 start_x_r; x8 end_x_r
#else
    ldp x7, x8, [sp, #16]               // x7 start_x_r; x8 end_x_r
#endif
    sxtw x7, w7
    sxtw x8, w8

    sub x9, x8, x7
    and x9, x9, #15
    add x12, x5, x9, lsl #4
    ld1 {v30.4s}, [x12]                 // mask_r

    sub x10, x8, x9                     // end_x_r_16

    sub x11, x6, #2                     // y = mb_height - 2

test_loop_y_eo_45_r:

    mov x9, x7                          // x = start_x_r

test_loop_x_eo_45_r:

    add x12, x0, x9
    sub x13, x12, x2
    add x14, x12, x2
    add x13, x13, #1
    sub x14, x14, #1
    ld1 {v21.16b}, [x12]                // src[x]
    ld1 {v20.16b}, [x13]                // src[x-src_stride+1]
    ld1 {v22.16b}, [x14]                // src[x+src_stride-1]

    // get leftsign & rightsign
    umin  v23.16b, v20.16b, v21.16b
    umin  v26.16b, v21.16b, v22.16b
    cmeq  v24.16b, v23.16b, v20.16b
    cmeq  v25.16b, v23.16b, v21.16b
    cmeq  v27.16b, v26.16b, v21.16b
    cmeq  v28.16b, v26.16b, v22.16b
    sub   v20.16b, v25.16b, v24.16b     //-- leftsign
    sub   v22.16b, v27.16b, v28.16b     //-- rightsign

    add     v20.16b, v22.16b, v20.16b   // edgetype

    uxtl    v23.8h, v21.8b
    uxtl2   v24.8h, v21.16b             // src[x]

    add     v20.16b, v20.16b, v1.16b    // edgetype+2
    tbl     v22.16b, {v0.16b}, v20.16b  // offset

    saddw   v23.8h, v23.8h, v22.8b      // offset+src[x] low 8 samples
    saddw2  v24.8h, v24.8h, v22.16b     // offset+src[x] high 8 samples

    sqxtun  v20.8b, v23.8h
    sqxtun2 v20.16b, v24.8h             //-- results

    add x12, x1, x9
    cmp x9, x10
    bge test_maskmove_eo_45_r
    add x9, x9, #16
    st1 {v20.16b}, [x12]
    cmp x9, x8
    blt test_loop_x_eo_45_r
    b   test_loop_x_eo_45_end_r

test_maskmove_eo_45_r:
    ld1 {v22.16b}, [x12]                // load 16 pixels from dst+x
    bif v20.16b, v22.16b, v30.16b
    st1 {v20.16b}, [x12]

test_loop_x_eo_45_end_r:
    subs x11, x11, #1
    add x0, x0, x2                      // src+=src_stride
    add x1, x1, x3                      // dst+=dst_stride
    bgt test_loop_y_eo_45_r

    // ------- last row -------
#if defined(__APPLE__)
    ldp w6, w7, [sp, #16]               // $x6 start_x_rn; $x7 end_x_rn
#else
    ldp x6, x7, [sp, #32]               // $x6 start_x_rn; $x7 end_x_rn
#endif
    sxtw x6, w6
    sxtw x7, w7

    sub x8, x7, x6
    and x8, x8, #15
    sub x10, x7, x8                     // end_x_rn_16

    mov x9, x6                          // x = start_x_rn

test_loop_x_eo_45_rn:
    cmp x9, x7
    bge test_loop_x_eo_45_end_rn
    add x12, x0, x9
    sub x13, x12, x2
    add x14, x12, x2
    add x13, x13, #1
    sub x14, x14, #1
    ld1 {v21.16b}, [x12]                // src[x]
    ld1 {v20.16b}, [x13]                // src[x-src_stride+1]
    ld1 {v22.16b}, [x14]                // src[x+src_stride-1]

    // get leftsign & rightsign
    umin  v23.16b, v20.16b, v21.16b
    umin  v26.16b, v21.16b, v22.16b
    cmeq  v24.16b, v23.16b, v20.16b
    cmeq  v25.16b, v23.16b, v21.16b
    cmeq  v27.16b, v26.16b, v21.16b
    cmeq  v28.16b, v26.16b, v22.16b
    sub   v20.16b, v25.16b, v24.16b     //-- leftsign
    sub   v22.16b, v27.16b, v28.16b     //-- rightsign

    add     v20.16b, v22.16b, v20.16b   // edgetype

    uxtl    v23.8h, v21.8b
    uxtl2   v24.8h, v21.16b             // src[x]

    add     v20.16b, v20.16b, v1.16b    // edgetype+2
    tbl     v22.16b, {v0.16b}, v20.16b  // offset

    saddw   v23.8h, v23.8h, v22.8b      // offset+src[x] low 8 samples
    saddw2  v24.8h, v24.8h, v22.16b     // offset+src[x] high 8 samples

    sqxtun  v20.8b, v23.8h
    sqxtun2 v20.16b, v24.8h             //-- results

    add x12, x1, x9
    cmp x9, x10
    bge test_maskmove_eo_45_rn
    st1 {v20.16b}, [x12]
    add x9, x9, #16
    b   test_loop_x_eo_45_rn

test_maskmove_eo_45_rn:
    sub x6, x7, x10
    add x6, x5, x6, lsl #4              // offset = 16*rownum
    ld1 {v30.4s}, [x6]                  // load mask_r0
    ld1 {v22.16b}, [x12]                // load 16 pixels from dst+x
    bif v20.16b, v22.16b, v30.16b
    st1 {v20.16b}, [x12]

test_loop_x_eo_45_end_rn:

ret

/***********************************************************************************************************************************
*   void sao_getStatblk_eo_0_arm64(pel_t* rec, pel_t* org, int i_rec, int i_org, i32s_t* pdiff, i32s_t* pedgetype, int start_x, int end_x, int end_y, pel_t* mask);
*  src->x0, org->x1, i_rec->x2, i_org->x3, pdiff->x4, pdegetype->x5, start_x->x6, end_x->x7, end_y->w8, mask->x9
************************************************************************************************************************************/
function sao_getStatblk_eo_0_arm64
    mov x10, sp
    ldr x8, [x10], #8
    ldr x9, [x10]

    sub sp, sp, #64
    st1 {v8.8h - v11.8h}, [sp]
    sub sp, sp, #64
    st1 {v12.8h - v15.8h}, [sp]

    sub x10, x7, x6                 // width = end_x - start_x

    // ------- load mask -------
    and x11, x10, #15
    add x12, x9, x11, lsl #4
    ld1 {v31.16b}, [x12]     // mask + ((end_x - start_x) & 0x0f) * 16 * sizeof(pel)

    sub x10, x7, x11                // end_x_16 = end_x - ((end_x - start_x) & 0x0f)

    movi v1.16b, #0
    movi v2.16b, #1
    movi v3.16b, #2
    movi v4.16b, #3
    movi v5.16b, #4
    movi v6.16b, #5

    movi v7.8h, #0
    movi v8.8h, #0
    movi v9.8h, #0
    movi v10.8h, #0
    movi v11.8h, #0
    movi v12.8h, #0
    movi v13.8h, #0
    movi v14.8h, #0
    movi v15.8h, #0
    movi v25.8h, #0

getStat_loop_y_eo_0:

    mov x15, x6                  // x = start_x
getStat_loop_x_eo_0:

    add x12, x0, x15             //rec
    sub x13, x12, #1
    add x14, x12, #1
    add x11, x1, x15             //org

    ld1 {v16.16b}, [x13]        // rec[x-1]
    ld1 {v17.16b}, [x12]        // rec[x]
    ld1 {v18.16b}, [x14]        // rec[x+1]

    ld1 {v0.16b}, [x11]
    
    sub v0.16b, v0.16b, v17.16b  //diff
    
    // leftsign & rightsign
    umin v19.16b, v16.16b, v17.16b
    umin v20.16b, v17.16b, v18.16b
    
    cmeq v21.16b, v19.16b, v16.16b
    cmeq v22.16b, v19.16b, v17.16b
    cmeq v23.16b, v20.16b, v17.16b
    cmeq v24.16b, v20.16b, v18.16b
    
    sub  v20.16b, v22.16b, v21.16b      // leftsign
    sub  v22.16b, v23.16b, v24.16b      // rightsign
    
    // get edgetype
    add v20.16b, v22.16b, v20.16b       // edgetype
    add v20.16b, v20.16b, v3.16b
    
    cmp x15, x10
    bne getStat_nomask_eo_0
    and v31.16b, v6.16b, v31.16b
    add v20.16b, v20.16b, v31.16b

getStat_nomask_eo_0:
    //edgetype[0] diff[0]
    cmeq v21.16b, v20.16b, v1.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v25.8h, v25.8h, v21.8h
    add v7.8h, v7.8h, v22.8h
    
    //edgetype[1] diff[1]
    cmeq v21.16b, v20.16b, v2.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v22.8h
    
    //edgetype[2] diff[2]
    cmeq v21.16b, v20.16b, v3.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v22.8h
    
    //edgetype[3] diff[3]
    cmeq v21.16b, v20.16b, v4.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v22.8h
    
    //edgetype[4] diff[4]
    cmeq v21.16b, v20.16b, v5.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v22.8h

    add x15, x15, #16
    cmp x15, x7
    blt getStat_loop_x_eo_0

    subs w8, w8, #1
    add x0, x0, x2
    add x1, x1, x3
    bgt getStat_loop_y_eo_0

    addp v25.8h, v25.8h, v8.8h
    addp v10.8h, v10.8h, v12.8h
    addp v25.8h, v25.8h, v10.8h
    saddlp v25.4s, v25.8h
    neg v25.4s, v25.4s

    addp v7.8h, v7.8h, v9.8h
    addp v11.8h, v11.8h, v13.8h
    addp v7.8h, v7.8h, v11.8h
    saddlp v7.4s, v7.8h

    addp v14.8h, v14.8h, v14.8h
    addp v14.8h, v14.8h, v14.8h
    saddlp v14.4s, v14.8h
    neg v14.4s, v14.4s
    
    addp v15.8h, v15.8h, v15.8h
    addp v15.8h, v15.8h, v15.8h
    saddlp v15.4s, v15.8h

    st1 {v7.4s}, [x4], #16
    st1 {v15.s}[0], [x4]

    st1 {v25.4s}, [x5], #16
    st1 {v14.s}[0], [x5]

    ld1 {v12.8h, v13.8h, v14.8h, v15.8h}, [sp], #64
    ld1 {v8.8h, v9.8h, v10.8h, v11.8h}, [sp], #64

    ret

/***********************************************************************************************************************************
 *  void sao_getStatblk_eo_90_arm64(pel_t* rec_base, pel_t* org_base, int i_rec, int i_org, i16s_t* pdiff, i16u_t* pedgetype, int end_x, int start_y, int end_y);
 *  rec->x0, org->x1, i_rec->x2, i_org->x3, pdiff->x4, pedgetype->x5, end_x->x6, start_y->x7, end_y->w8
 ************************************************************************************************************************************/
function sao_getStatblk_eo_90_arm64
    ldr w8, [sp]

    sub sp, sp, #64
    st1 {v8.8h - v11.8h}, [sp]
    sub sp, sp, #64
    st1 {v12.8h - v15.8h}, [sp]

    and x15, x6, #15

    sub x10, x6, #15            // end_x_16 = (mb_width - 15) * sizeof(pel)

    sub  w8, w8, w7             // y = end_y - start_y

    movi v1.16b, #0
    movi v2.16b, #1
    movi v3.16b, #2
    movi v4.16b, #3
    movi v5.16b, #4

    movi v6.8h, #0
    movi v7.8h, #0
    movi v8.8h, #0
    movi v9.8h, #0
    movi v10.8h, #0
    movi v11.8h, #0
    movi v12.8h, #0
    movi v13.8h, #0
    movi v14.8h, #0
    movi v15.8h, #0

    mov w9, #-1
    cmp x15, #4
    beq getStat_set_mask_width_4
    cmp x15, #0
    beq getStat_loop_y_eo_90
    movi v31.16b, #0
    mov v31.s[3], w9          // v31.16b: "0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1"
    b getStat_loop_y_eo_90
    
getStat_set_mask_width_4:
    movi v31.16b, #255        // v31.8h: "0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1"
    mov w9, #0
    mov v31.s[0], w9

getStat_loop_y_eo_90:

    mov  x9, #0                 // x = 0

getStat_loop_x_eo_90:
    add  x12, x0, x9            // src
    sub  x13, x12, x2
    add  x14, x12, x2
    add x11, x1, x9             // org

    ld1  {v17.16b}, [x12]        // rec[x]
    ld1  {v16.16b}, [x13]        // rec[x-src_stride]
    ld1  {v18.16b}, [x14]        // rec[x+src_stride]
    
    ld1 {v0.16b}, [x11]
    sub v0.16b, v0.16b, v17.16b            //pdiff
    
    // leftsign & rightsign
    umin v19.16b, v16.16b, v17.16b
    umin v20.16b, v17.16b, v18.16b
    
    cmeq v21.16b, v19.16b, v16.16b
    cmeq v22.16b, v19.16b, v17.16b
    cmeq v23.16b, v20.16b, v17.16b
    cmeq v24.16b, v20.16b, v18.16b
    
    sub  v20.16b, v22.16b, v21.16b      // leftsign
    sub  v22.16b, v23.16b, v24.16b      // rightsign
    
    // get edgetype
    add v20.16b, v22.16b, v20.16b       // edgetype
    add v20.16b, v20.16b, v3.16b
    
    cmp x9, x10
    blt getStat_nomask_eo_90
    
    movi v25.16b, #5
    and v31.16b, v25.16b, v31.16b
    add v20.8h, v20.8h, v31.8h

getStat_nomask_eo_90:
    //edgetype[0] diff[0]
    cmeq v21.16b, v20.16b, v1.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v22.8h
    
    //edgetype[1] diff[1]
    cmeq v21.16b, v20.16b, v2.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v22.8h
    
    //edgetype[2] diff[2]
    cmeq v21.16b, v20.16b, v3.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v22.8h
    
    //edgetype[3] diff[3]
    cmeq v21.16b, v20.16b, v4.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v22.8h
    
    //edgetype[4] diff[4]
    cmeq v21.16b, v20.16b, v5.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v22.8h

    add x9, x9, #16
    cmp x9, x6
    blt getStat_loop_x_eo_90

    subs w8, w8, #1
    add x0, x0, x2
    add x1, x1, x3
    bgt getStat_loop_y_eo_90

    addp v6.8h, v6.8h, v8.8h
    addp v10.8h, v10.8h, v12.8h
    addp v6.8h, v6.8h, v10.8h
    saddlp v6.4s, v6.8h
    neg v6.4s, v6.4s
    
    addp v7.8h, v7.8h, v9.8h
    addp v11.8h, v11.8h, v13.8h
    addp v7.8h, v7.8h, v11.8h
    saddlp v7.4s, v7.8h
    
    addp v14.8h, v14.8h, v14.8h
    addp v14.8h, v14.8h, v14.8h
    saddlp v14.4s, v14.8h
    neg v14.4s, v14.4s
    
    addp v15.8h, v15.8h, v15.8h
    addp v15.8h, v15.8h, v15.8h
    saddlp v15.4s, v15.8h

    st1 {v7.4s}, [x4], #16
    st1 {v15.s}[0], [x4]
    
    st1 {v6.4s}, [x5], #16
    st1 {v14.s}[0], [x5]

    ld1 {v12.8h, v13.8h, v14.8h, v15.8h}, [sp], #64
    ld1 {v8.8h, v9.8h, v10.8h, v11.8h}, [sp], #64

    ret

/***********************************************************************************************************************************
 *  void sao_getStatblk_eo_135_arm64(pel_t* rec, pel_t* org, int i_rec, int i_org, i16s_t* pdiff, i16u_t* pedgetype, int lcu_pix_height, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn, pel_t* uavs3e_sao_mask);
 *  rec->x0, org->x1, i_rec->x2, i_org->x3, pdiff->x4, pedgetype->x5, lcu_pix_height->x6, start_x_r0->x7, end_x_r0->w8, start_x_r->w9, end_x_r->w10, start_x_rn->w11, end_x_rn->w12, mask->x13
 ************************************************************************************************************************************/
function sao_getStatblk_eo_135_arm64
#if defined(__APPLE__)
    ldp w8, w9, [sp]
    ldr w10, [sp, #8]
    ldr w11, [sp, #12]
    ldr w12, [sp, #16]
    ldr x13, [sp, #24]

#else   //未测试
    ldp x8, x9, [sp]                // start_x_r0 and end_x_r0
    ldr x10, [sp, #16]              //
    ldr x11, [sp, #24]
    ldr x12, [sp, #32]
    ldr x13, [sp, #40]
#endif

    sxtw x8, w8                     // end_x_r0
    sxtw x9, w9                     // start_x_r
    sxtw x10, w10
    sxtw x11, w11
    sxtw x12, w12

    sub sp, sp, #16
    stp x19, x20, [sp]
    sub sp, sp, #16
    stp x21, x22, [sp]
    sub sp, sp, #16
    stp x23, x24, [sp]
    sub sp, sp, #64
    st1 {v8.8h - v11.8h}, [sp]
    sub sp, sp, #64
    st1 {v12.8h - v15.8h}, [sp]
    movi v1.16b, #0
    movi v2.16b, #1
    movi v3.16b, #2
    movi v4.16b, #3
    movi v5.16b, #4

    movi v6.8h, #0
    movi v7.8h, #0
    movi v8.8h, #0
    movi v9.8h, #0
    movi v10.8h, #0
    movi v11.8h, #0
    movi v12.8h, #0
    movi v13.8h, #0
    movi v14.8h, #0
    movi v15.8h, #0

    // ------- first row -------
    sub x21, x8, x7
    and x21, x21, #15
    sub x22, x8, x21                 // end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f

    mov  x23, x7                     // x = start_x_r0

getStat_loop_x_eo_135_r0:
    cmp x23, x8
    bge getStat_loop_x_eo_135_end_r0
    add x14, x0, x23                // rec[x]
    add x20, x1, x23                // org[x]
    sub x15, x14, x2                // rec[x - i_rec]
    add x19, x14, x2                // rec[x + i_rec]
    sub x15, x15, #1                // rec[x - i_rec - 2]
    add x19, x19, #1                // rec[x + i_rec + 2]
    
    ld1 {v16.16b}, [x15]        // rec[x - i_rec - 2]
    ld1 {v17.16b}, [x14]        // rec[x]
    ld1 {v18.16b}, [x19]        // rec[x + i_rec + 2]
    ld1 {v0.16b}, [x20]          // org[x]
    
    sub v0.16b, v0.16b, v17.16b           //pdiff
    
    // leftsign & rightsign
    umin v19.16b, v16.16b, v17.16b
    umin v20.16b, v17.16b, v18.16b
    
    cmeq v21.16b, v19.16b, v16.16b
    cmeq v22.16b, v19.16b, v17.16b
    cmeq v23.16b, v20.16b, v17.16b
    cmeq v24.16b, v20.16b, v18.16b
    
    sub  v20.16b, v22.16b, v21.16b      // leftsign
    sub  v22.16b, v23.16b, v24.16b      // rightsign
    
    // get edgetype
    add v20.16b, v22.16b, v20.16b       // edgetype
    add v20.16b, v20.16b, v3.16b

    cmp x23, x22
    bne getStat_nomask_eo_135_r0
    add x24, x13, x21, lsl #4
    ld1 {v31.16b}, [x24]
    movi v25.16b, #5
    and v31.16b, v25.16b, v31.16b
    add v20.16b, v20.16b, v31.16b
    
getStat_nomask_eo_135_r0:
    //edgetype[0] diff[0]
    cmeq v21.16b, v20.16b, v1.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v22.8h
    
    //edgetype[1] diff[1]
    cmeq v21.16b, v20.16b, v2.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v22.8h
    
    //edgetype[2] diff[2]
    cmeq v21.16b, v20.16b, v3.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v22.8h
    
    //edgetype[3] diff[3]
    cmeq v21.16b, v20.16b, v4.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v22.8h
    
    //edgetype[4] diff[4]
    cmeq v21.16b, v20.16b, v5.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v22.8h
    add x23, x23, #16
    
    b getStat_loop_x_eo_135_r0

getStat_loop_x_eo_135_end_r0:
    add x0, x0, x2                      // rec += i_rec
    add x1, x1, x3                      // org += i_org

    // ------- middle rows -------

    sub x8, x6, #2                     // y = mb_height - 2

    sub x21, x10, x9
    and x21, x21, #15
    sub x22, x10, x21                 // end_x_r_16 = end_x_r - ((end_x_r - start_x_r) & 0x0f

getStat_loop_y_eo_135_r:
    mov x23, x9                          // x = start_x_r

getStat_loop_x_eo_135_r:
    add x14, x0, x23                // rec[x]
    add x20, x1, x23                // org[x]
    sub x15, x14, x2                // rec[x - i_rec]
    add x19, x14, x2                // rec[x + i_rec]
    sub x15, x15, #1                // rec[x - i_rec - 2]
    add x19, x19, #1                // rec[x + i_rec + 2]

    ld1 {v16.16b}, [x15]        // rec[x - i_rec - 2]
    ld1 {v17.16b}, [x14]        // rec[x]
    ld1 {v18.16b}, [x19]        // rec[x + i_rec + 2]
    ld1 {v0.16b}, [x20]          // org[x]
    
    sub v0.16b, v0.16b, v17.16b           //pdiff
    
    // leftsign & rightsign
    umin v19.16b, v16.16b, v17.16b
    umin v20.16b, v17.16b, v18.16b
    
    cmeq v21.16b, v19.16b, v16.16b
    cmeq v22.16b, v19.16b, v17.16b
    cmeq v23.16b, v20.16b, v17.16b
    cmeq v24.16b, v20.16b, v18.16b
    
    sub  v20.16b, v22.16b, v21.16b      // leftsign
    sub  v22.16b, v23.16b, v24.16b      // rightsign
    
    // get edgetype
    add v20.16b, v22.16b, v20.16b       // edgetype
    add v20.16b, v20.16b, v3.16b

    cmp x23, x22
    bne getStat_nomask_eo_135_r
    add x24, x13, x21, lsl #4
    ld1 {v31.16b}, [x24]
    movi v25.16b, #5
    and v31.16b, v25.16b, v31.16b
    add v20.16b, v20.16b, v31.16b
    
getStat_nomask_eo_135_r:
    //edgetype[0] diff[0]
    cmeq v21.16b, v20.16b, v1.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v22.8h
    
    //edgetype[1] diff[1]
    cmeq v21.16b, v20.16b, v2.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v22.8h
    
    //edgetype[2] diff[2]
    cmeq v21.16b, v20.16b, v3.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v22.8h
    
    //edgetype[3] diff[3]
    cmeq v21.16b, v20.16b, v4.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v22.8h
    
    //edgetype[4] diff[4]
    cmeq v21.16b, v20.16b, v5.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v22.8h
    
    add x23, x23, #16
    cmp x23, x10
    blt getStat_loop_x_eo_135_r

    subs x8, x8, #1
    add x0, x0, x2                      // rec += i_rec
    add x1, x1, x3                      // org += i_org

    bgt getStat_loop_y_eo_135_r

    // ------- last row -------
    sub x21, x12, x11
    and x21, x21, #15
    sub x22, x12, x21                 // end_x_r_16 = end_x_r - ((end_x_r - start_x_r) & 0x0f

    mov x23, x11                          // x = start_x_rn

getStat_loop_x_eo_135_rn:
    cmp x23, x12
    bge getStat_loop_x_eo_135_end_rn
    add x14, x0, x23                // rec[x]
    add x20, x1, x23                // org[x]
    sub x15, x14, x2                // rec[x - i_rec]
    add x19, x14, x2                // rec[x + i_rec]
    sub x15, x15, #1                // rec[x - i_rec - 2]
    add x19, x19, #1                // rec[x + i_rec + 2]

    ld1 {v16.16b}, [x15]        // rec[x - i_rec - 2]
    ld1 {v17.16b}, [x14]        // rec[x]
    ld1 {v18.16b}, [x19]        // rec[x + i_rec + 2]
    ld1 {v0.16b}, [x20]          // org[x]

    sub v0.16b, v0.16b, v17.16b           //pdiff
    
    // leftsign & rightsign
    umin v19.16b, v16.16b, v17.16b
    umin v20.16b, v17.16b, v18.16b
    
    cmeq v21.16b, v19.16b, v16.16b
    cmeq v22.16b, v19.16b, v17.16b
    cmeq v23.16b, v20.16b, v17.16b
    cmeq v24.16b, v20.16b, v18.16b
    
    sub  v20.16b, v22.16b, v21.16b      // leftsign
    sub  v22.16b, v23.16b, v24.16b      // rightsign
    
    // get edgetype
    add v20.16b, v22.16b, v20.16b       // edgetype
    add v20.16b, v20.16b, v3.16b
        
    cmp x23, x22
    bne getStat_nomask_eo_135_rn
    add x24, x13, x21, lsl #4
    ld1 {v31.16b}, [x24]
    movi v25.16b, #5
    and v31.16b, v25.16b, v31.16b
    add v20.16b, v20.16b, v31.16b
    
    getStat_nomask_eo_135_rn:
    //edgetype[0] diff[0]
    cmeq v21.16b, v20.16b, v1.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v22.8h
    
    //edgetype[1] diff[1]
    cmeq v21.16b, v20.16b, v2.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v22.8h
    
    //edgetype[2] diff[2]
    cmeq v21.16b, v20.16b, v3.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v22.8h
    
    //edgetype[3] diff[3]
    cmeq v21.16b, v20.16b, v4.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v22.8h
    
    //edgetype[4] diff[4]
    cmeq v21.16b, v20.16b, v5.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v22.8h

    add x23, x23, #16
    b   getStat_loop_x_eo_135_rn

getStat_loop_x_eo_135_end_rn:

    addp v6.8h, v6.8h, v8.8h
    addp v10.8h, v10.8h, v12.8h
    addp v6.8h, v6.8h, v10.8h
    saddlp v6.4s, v6.8h
    neg v6.4s, v6.4s
    
    addp v7.8h, v7.8h, v9.8h
    addp v11.8h, v11.8h, v13.8h
    addp v7.8h, v7.8h, v11.8h
    saddlp v7.4s, v7.8h
    
    addp v14.8h, v14.8h, v14.8h
    addp v14.8h, v14.8h, v14.8h
    saddlp v14.4s, v14.8h
    neg v14.4s, v14.4s
    
    addp v15.8h, v15.8h, v15.8h
    addp v15.8h, v15.8h, v15.8h
    saddlp v15.4s, v15.8h
    
    st1 {v7.4s}, [x4], #16
    st1 {v15.s}[0], [x4]
    
    st1 {v6.4s}, [x5], #16
    st1 {v14.s}[0], [x5]
    
    ld1 {v12.8h, v13.8h, v14.8h, v15.8h}, [sp], #64
    ld1 {v8.8h, v9.8h, v10.8h, v11.8h}, [sp], #64
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16

    ret

/***********************************************************************************************************************************
 *  void sao_getStatblk_eo_45_arm64(pel_t* rec, pel_t* org, int i_rec, int i_org, i16s_t* pdiff, i16u_t* pedgetype, int lcu_pix_height, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn, pel_t* uavs3e_sao_mask);
 *  rec->x0, org->x1, i_rec->x2, i_org->x3, pdiff->x4, pedgetype->x5, lcu_pix_height->x6, start_x_r0->x7, end_x_r0->w8, start_x_r->w9, end_x_r->w10, start_x_rn->w11, end_x_rn->w12
 ************************************************************************************************************************************/
function sao_getStatblk_eo_45_arm64
#if defined(__APPLE__)
    ldp w8, w9, [sp]
    ldr w10, [sp, #8]
    ldr w11, [sp, #12]
    ldr w12, [sp, #16]
    ldr x13, [sp, #24]

#else   //未测试
    ldp x8, x9, [sp]                // start_x_r0 and end_x_r0
    ldr x10, [sp, #16]              //
    ldr x11, [sp, #24]
    ldr x12, [sp, #32]
    ldr x13, [sp, #40]
#endif

    sxtw x8, w8                     // end_x_r0
    sxtw x9, w9                     // start_x_r
    sxtw x10, w10
    sxtw x11, w11
    sxtw x12, w12

    sub sp, sp, #16
    stp x19, x20, [sp]
    sub sp, sp, #16
    stp x21, x22, [sp]
    sub sp, sp, #16
    stp x23, x24, [sp]
    sub sp, sp, #64
    st1 {v8.8h - v11.8h}, [sp]
    sub sp, sp, #64
    st1 {v12.8h - v15.8h}, [sp]

    movi v1.16b, #0
    movi v2.16b, #1
    movi v3.16b, #2
    movi v4.16b, #3
    movi v5.16b, #4

    movi v6.8h, #0
    movi v7.8h, #0
    movi v8.8h, #0
    movi v9.8h, #0
    movi v10.8h, #0
    movi v11.8h, #0
    movi v12.8h, #0
    movi v13.8h, #0
    movi v14.8h, #0
    movi v15.8h, #0
    
    // ------- first row -------
    sub x21, x8, x7
    and x21, x21, #15
    sub x22, x8, x21                 // end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f
    
    mov  x23, x7                     // x = start_x_r0

getStat_loop_x_eo_45_r0:
    cmp x23, x8
    bge getStat_loop_x_eo_45_end_r0
    add x14, x0, x23                // rec[x]
    add x20, x1, x23                // org[x]
    sub x15, x14, x2                // rec[x - i_rec]
    add x19, x14, x2                // rec[x + i_rec]
    add x15, x15, #1                // rec[x - i_rec + 2]
    sub x19, x19, #1                // rec[x + i_rec - 2]
    
    ld1 {v16.16b}, [x15]        // rec[x - i_rec - 2]
    ld1 {v17.16b}, [x14]        // rec[x]
    ld1 {v18.16b}, [x19]        // rec[x + i_rec + 2]
    ld1 {v0.16b}, [x20]          // org[x]
    
    sub v0.16b, v0.16b, v17.16b           //pdiff
    
    // leftsign & rightsign
    umin v19.16b, v16.16b, v17.16b
    umin v20.16b, v17.16b, v18.16b
    
    cmeq v21.16b, v19.16b, v16.16b
    cmeq v22.16b, v19.16b, v17.16b
    cmeq v23.16b, v20.16b, v17.16b
    cmeq v24.16b, v20.16b, v18.16b
    
    sub  v20.16b, v22.16b, v21.16b      // leftsign
    sub  v22.16b, v23.16b, v24.16b      // rightsign
    
    // get edgetype
    add v20.16b, v22.16b, v20.16b       // edgetype
    add v20.16b, v20.16b, v3.16b

    cmp x23, x22
    bne getStat_nomask_eo_45_r0
    add x24, x13, x21, lsl #4
    ld1 {v31.16b}, [x24]
    movi v25.16b, #5
    and v31.16b, v25.16b, v31.16b
    add v20.16b, v20.16b, v31.16b
    
getStat_nomask_eo_45_r0:
    //edgetype[0] diff[0]
    cmeq v21.16b, v20.16b, v1.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v22.8h
    
    //edgetype[1] diff[1]
    cmeq v21.16b, v20.16b, v2.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v22.8h
    
    //edgetype[2] diff[2]
    cmeq v21.16b, v20.16b, v3.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v22.8h
    
    //edgetype[3] diff[3]
    cmeq v21.16b, v20.16b, v4.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v22.8h
    
    //edgetype[4] diff[4]
    cmeq v21.16b, v20.16b, v5.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v22.8h
    add x23, x23, #16
    
    b getStat_loop_x_eo_45_r0

getStat_loop_x_eo_45_end_r0:
    add x0, x0, x2                      // rec += i_rec
    add x1, x1, x3                      // org += i_org

    // ------- middle rows -------

    sub x8, x6, #2                     // y = mb_height - 2
    sub x21, x10, x9
    and x21, x21, #15
    sub x22, x10, x21                 // end_x_r_16 = end_x_r - ((end_x_r - start_x_r) & 0x0f

getStat_loop_y_eo_45_r:
    mov x23, x9                          // x = start_x_r

getStat_loop_x_eo_45_r:
    add x14, x0, x23                // rec[x]
    add x20, x1, x23                // org[x]
    sub x15, x14, x2                // rec[x - i_rec]
    add x19, x14, x2                // rec[x + i_rec]
    add x15, x15, #1                // rec[x - i_rec + 2]
    sub x19, x19, #1                // rec[x + i_rec - 2]

    ld1 {v16.16b}, [x15]        // rec[x - i_rec - 2]
    ld1 {v17.16b}, [x14]        // rec[x]
    ld1 {v18.16b}, [x19]        // rec[x + i_rec + 2]
    ld1 {v0.16b}, [x20]          // org[x]
    
    sub v0.16b, v0.16b, v17.16b           //pdiff
    
    // leftsign & rightsign
    umin v19.16b, v16.16b, v17.16b
    umin v20.16b, v17.16b, v18.16b
    
    cmeq v21.16b, v19.16b, v16.16b
    cmeq v22.16b, v19.16b, v17.16b
    cmeq v23.16b, v20.16b, v17.16b
    cmeq v24.16b, v20.16b, v18.16b
    
    sub  v20.16b, v22.16b, v21.16b      // leftsign
    sub  v22.16b, v23.16b, v24.16b      // rightsign
    
    // get edgetype
    add v20.16b, v22.16b, v20.16b       // edgetype
    add v20.16b, v20.16b, v3.16b

    cmp x23, x22
    bne getStat_nomask_eo_45_r
    add x24, x13, x21, lsl #4
    ld1 {v31.16b}, [x24]
    movi v25.16b, #5
    and v31.16b, v25.16b, v31.16b
    add v20.16b, v20.16b, v31.16b
        
getStat_nomask_eo_45_r:
    //edgetype[0] diff[0]
    cmeq v21.16b, v20.16b, v1.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v22.8h
    
    //edgetype[1] diff[1]
    cmeq v21.16b, v20.16b, v2.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v22.8h
    
    //edgetype[2] diff[2]
    cmeq v21.16b, v20.16b, v3.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v22.8h
    
    //edgetype[3] diff[3]
    cmeq v21.16b, v20.16b, v4.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v22.8h
    
    //edgetype[4] diff[4]
    cmeq v21.16b, v20.16b, v5.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v22.8h
    add x23, x23, #16
    cmp x23, x10
    blt getStat_loop_x_eo_45_r

    subs x8, x8, #1
    add x0, x0, x2                      // rec += i_rec
    add x1, x1, x3                      // org += i_org
    bgt getStat_loop_y_eo_45_r

    // ------- last row -------
    sub x21, x12, x11

    and x21, x21, #15
    sub x22, x12, x21                 // end_x_r_16 = end_x_r - ((end_x_r - start_x_r) & 0x0f
    mov x23, x11                          // x = start_x_rn

getStat_loop_x_eo_45_rn:
    cmp x23, x12
    bge getStat_loop_x_eo_45_end_rn
    add x14, x0, x23                // rec[x]
    add x20, x1, x23                // org[x]
    sub x15, x14, x2                // rec[x - i_rec]
    add x19, x14, x2                // rec[x + i_rec]
    add x15, x15, #1                // rec[x - i_rec + 2]
    sub x19, x19, #1                // rec[x + i_rec - 2]

    ld1 {v16.16b}, [x15]        // rec[x - i_rec - 2]
    ld1 {v17.16b}, [x14]        // rec[x]
    ld1 {v18.16b}, [x19]        // rec[x + i_rec + 2]
    ld1 {v0.16b}, [x20]          // org[x]
    
    sub v0.16b, v0.16b, v17.16b           //pdiff
    
    // leftsign & rightsign
    umin v19.16b, v16.16b, v17.16b
    umin v20.16b, v17.16b, v18.16b
    
    cmeq v21.16b, v19.16b, v16.16b
    cmeq v22.16b, v19.16b, v17.16b
    cmeq v23.16b, v20.16b, v17.16b
    cmeq v24.16b, v20.16b, v18.16b
    
    sub  v20.16b, v22.16b, v21.16b      // leftsign
    sub  v22.16b, v23.16b, v24.16b      // rightsign
    
    // get edgetype
    add v20.16b, v22.16b, v20.16b       // edgetype
    add v20.16b, v20.16b, v3.16b

    cmp x23, x22
    bne getStat_nomask_eo_45_rn
    add x24, x13, x21, lsl #4
    ld1 {v31.16b}, [x24]
    movi v25.16b, #5
    and v31.16b, v25.16b, v31.16b
    add v20.16b, v20.16b, v31.16b
    
getStat_nomask_eo_45_rn:
    //edgetype[0] diff[0]
    cmeq v21.16b, v20.16b, v1.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v22.8h
    
    //edgetype[1] diff[1]
    cmeq v21.16b, v20.16b, v2.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v22.8h
    
    //edgetype[2] diff[2]
    cmeq v21.16b, v20.16b, v3.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v22.8h
    
    //edgetype[3] diff[3]
    cmeq v21.16b, v20.16b, v4.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v22.8h
    
    //edgetype[4] diff[4]
    cmeq v21.16b, v20.16b, v5.16b
    and v22.16b, v21.16b, v0.16b
    saddlp v21.8h, v21.16b
    saddlp v22.8h, v22.16b
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v22.8h
    
    add x23, x23, #16
    b   getStat_loop_x_eo_45_rn

getStat_loop_x_eo_45_end_rn:

    addp v6.8h, v6.8h, v8.8h
    addp v10.8h, v10.8h, v12.8h
    addp v6.8h, v6.8h, v10.8h
    saddlp v6.4s, v6.8h
    neg v6.4s, v6.4s
    
    addp v7.8h, v7.8h, v9.8h
    addp v11.8h, v11.8h, v13.8h
    addp v7.8h, v7.8h, v11.8h
    saddlp v7.4s, v7.8h
    
    addp v14.8h, v14.8h, v14.8h
    addp v14.8h, v14.8h, v14.8h
    saddlp v14.4s, v14.8h
    neg v14.4s, v14.4s
    
    addp v15.8h, v15.8h, v15.8h
    addp v15.8h, v15.8h, v15.8h
    saddlp v15.4s, v15.8h
    
    st1 {v7.4s}, [x4], #16
    st1 {v15.s}[0], [x4]
    
    st1 {v6.4s}, [x5], #16
    st1 {v14.s}[0], [x5]
    
    ld1 {v12.8h, v13.8h, v14.8h, v15.8h}, [sp], #64
    ld1 {v8.8h, v9.8h, v10.8h, v11.8h}, [sp], #64
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16

    ret


#else // COMPILE_10BIT == 1

/***********************************************************************************************************************************
*  void sao_eo_0_arm64(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_x, int end_x, int mb_height, pel* mask, int bit_depth)
*  src->x0, dst->x1, src_stride->x2, dst_stride->x3, offset->x4, start_x->x5, end_x->x6, mb_height->x7, mask->x8, bit_depth->w9
************************************************************************************************************************************/
function sao_eo_0_arm64
    ldr x8, [sp]                // mask
    ldr w9, [sp, #8]            // bit_depth

    // ------- load mask -------
    sub x10, x6, x5
    and x11, x10, #15
    add x12, x8, x11, lsl #5
    ld1 {v30.8h, v31.8h}, [x12] // mask + ((end_x - start_x) & 0x0f)*16*sizeof(pel)

    sub w10, w6, w11            // end_x_16 = end_x - ((end_x - start_x) & 0x0f)

    // ------- set offset table -------
    ld1  {v20.4s}, [x4]         // offset[0-3]
    ldr  w11, [x4, #16]         // offset[4]
    mov  x8, #0
    movi v2.4s, #0
    mov  v2.s[0], w11
    xtn  v0.4h, v20.4s
    xtn2 v0.8h, v2.4s
    xtn  v0.8b, v0.8h           // v0.8b: offset[0-4]

    mov w11, #1
    movi v1.16b, #2
    lsl w11, w11, w9

    lsl x2, x2, #1
    lsl x3, x3, #1
    lsl x5, x5, #1
    lsl x6, x6, #1
    lsl x10, x10, #1

    sub w11, w11, #1            // max_pel

    movi v6.8h, #0              // min_pel
    dup  v7.8h, w11             // max_pel

loop_y_eo_0:

    mov x9, x5                  // x = start_x
loop_x_eo_0:

    add  x12, x0, x9
    sub  x13, x12, #2
    add  x14, x12, #2

    ld1  {v16.8h, v17.8h}, [x13]        // src[x-1]
    ld1  {v18.8h, v19.8h}, [x12]        // src[x]
    ld1  {v20.8h, v21.8h}, [x14]        // src[x+1]

    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h

    xtn  v16.8b, v16.8h
    xtn2 v16.16b, v17.8h

    add v16.16b, v16.16b, v1.16b        // edgetype+2

    tbl v22.16b, {v0.16b}, v16.16b      // offset

    saddw  v23.8h, v18.8h, v22.8b       // offset+src[x] low 8 samples
    saddw2 v24.8h, v19.8h, v22.16b      // offset+src[x] high 8 samples

    smax v23.8h, v23.8h, v6.8h
    smax v24.8h, v24.8h, v6.8h
    smin v23.8h, v23.8h, v7.8h
    smin v24.8h, v24.8h, v7.8h

    add x12, x1, x9
    cmp x9, x10
    beq maskmove_eo_0
    add x9, x9, #32
    st1 {v23.8h, v24.8h}, [x12]
    cmp x9, x6
    blt loop_x_eo_0
    b   loop_x_eo_0_end

maskmove_eo_0:
    // maskmove
    ld1 {v21.8h, v22.8h}, [x12]         // load 16 pixels from dst+x
    bif v23.16b, v21.16b, v30.16b
    bif v24.16b, v22.16b, v31.16b
    st1 {v23.8h, v24.8h}, [x12]

loop_x_eo_0_end:
    subs w7, w7, #1
    add x0, x0, x2
    add x1, x1, x3
    bgt loop_y_eo_0

    ret

/***********************************************************************************************************************************
 *  void sao_eo_90_arm64(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_y, int end_y, int mb_width, int bit_depth);
 *  src->x0, dst->x1, src_stride->x2, dst_stride->x3, offset->x4, start_y->x5, end_y->x6, mb_width->x7, bit_depth->w8
 ************************************************************************************************************************************/
function sao_eo_90_arm64
    ldr w8, [sp]

    mov x9, #1

    lsl x2, x2, #1
    lsl x3, x3, #1
    lsl x7, x7, #1
    lsl w9, w9, w8

    mul x10, x2, x5
    mul x11, x3, x5
    add x0, x0, x10
    add x1, x1, x11             // dst += start_y * dst_stride

    sub x10, x7, #30            // end_x_16 = (mb_width - 15)*sizeof(pel)
    sub w11, w9, #1

    // ------- set offset table -------
    ld1  {v20.4s}, [x4]         // offset[0-3]
    ldr  w9, [x4, #16]          // offset[4]
    mov  x8, #0
    movi v2.4s, #0
    mov  v2.s[0], w9
    xtn  v0.4h, v20.4s
    xtn2 v0.8h, v2.4s
    xtn  v0.8b, v0.8h           // offset[0-4]

    movi v1.16b, #2
    movi v6.8h, #0
    dup  v7.8h, w11

    sub  w8, w6, w5             // y = end_y - start_y

    mov  x9, #-1
    cmp  w7, #8
    beq  set_mask_width_4
    movi v30.16b, #255
    movi v31.4s, #0
    mov  v31.d[0], x9           // v31.8h: "-1, -1, -1, -1, 0, 0, 0, 0"
    b    loop_y_eo_90

set_mask_width_4:
    movi v30.4s, #0
    mov  v30.d[0], x9           // v30.8h: "-1, -1, -1, -1, 0, 0, 0, 0"
    movi v31.4s, #0
loop_y_eo_90:

    mov  x9, #0                 // x = 0

loop_x_eo_90:
    add  x12, x0, x9            // x12
    sub  x13, x12, x2
    add  x14, x12, x2
    ld1  {v16.8h, v17.8h}, [x13]        // src[x-src_stride]
    ld1  {v18.8h, v19.8h}, [x12]        // src[x]
    ld1  {v20.8h, v21.8h}, [x14]        // src[x+src_stride]

    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h

    xtn  v16.8b, v16.8h
    xtn2 v16.16b, v17.8h

    add v16.16b, v16.16b, v1.16b        // edgetype+2

    tbl v25.16b, {v0.16b}, v16.16b      // offset

    saddw  v23.8h, v18.8h, v25.8b       // offset+src[x] low 8 samples
    saddw2 v24.8h, v19.8h, v25.16b      // offset+src[x] high 8 samples

    smax v23.8h, v23.8h, v6.8h
    smax v24.8h, v24.8h, v6.8h
    smin v23.8h, v23.8h, v7.8h
    smin v24.8h, v24.8h, v7.8h

    add x12, x1, x9
    cmp x9, x10
    bge maskmove_eo_90
    st1 {v23.8h, v24.8h}, [x12]
    add x9, x9, #32
    cmp x9, x7
    blt loop_x_eo_90
    b   loop_x_eo_90_end

maskmove_eo_90:
    // maskmove
    ld1 {v21.8h, v22.8h}, [x12]         // load 16 pixels from dst+x
    bif v23.16b, v21.16b, v30.16b
    bif v24.16b, v22.16b, v31.16b
    st1 {v23.8h, v24.8h}, [x12]

loop_x_eo_90_end:
    subs w8, w8, #1
    add x0, x0, x2
    add x1, x1, x3
    bgt loop_y_eo_90

ret

/***********************************************************************************************************************************
 *  void sao_eo_135_arm64(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, char_t* mask, int mb_height, int bit_depth, int start_x_r0,
 *  int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
 *  src->x0, dst->x1, src_stride->x2, dst_stride->x3, offset->x4, mask->x5, mb_height->x6, bit_depth->x7
 ************************************************************************************************************************************/
function sao_eo_135_arm64
#if defined(__APPLE__)
    ldp w8, w9, [sp]
#else
    ldp x8, x9, [sp]                // start_x_r0 and end_x_r0
#endif

    sxtw x8, w8                     // start_x_r0
    sxtw x9, w9                     // end_x_r0

    // get end_x_r0_16
    sub x11, x9, x8
    and x11, x11, #15
    sub x10, x9, x11                // end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f

    mov x12, #1

    lsl x2, x2, #1
    lsl x3, x3, #1
    lsl x8, x8, #1
    lsl x9, x9, #1
    lsl x10, x10, #1
    lsl w12, w12, w7

    // ------- set offset table -------
    ld1  {v20.4s}, [x4]             // offset[0-3]
    ldr  w11, [x4, #16]             // offset[4]
    movi v2.4s, #0
    mov  v2.s[0], w11
    xtn  v0.4h, v20.4s
    xtn2 v0.8h, v2.4s
    xtn  v0.8b, v0.8h               // offset[0-4]

    sub w12, w12, #1
    movi v1.16b, #2
    movi v6.8h, #0                  // min_pel
    dup  v7.8h, w12                 // max_pel

    // ------- first row -------
    mov x11, x8                     // x = start_x_r0

test_loop_x_eo_135_r0:

    cmp x11, x9
    bge test_loop_x_eo_135_end_r0

    add x12, x0, x11
    sub x13, x12, x2
    add x14, x12, x2
    sub x13, x13, #2
    add x14, x14, #2
    ld1  {v16.8h, v17.8h}, [x13]        // src[x-src_stride-1]
    ld1  {v18.8h, v19.8h}, [x12]        // src[x]
    ld1  {v20.8h, v21.8h}, [x14]        // src[x+src_stride+1]

    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h

    xtn  v16.8b, v16.8h
    xtn2 v16.16b, v17.8h

    add v16.16b, v16.16b, v1.16b        // edgetype+2

    tbl v25.16b, {v0.16b}, v16.16b      // offset

    saddw  v23.8h, v18.8h, v25.8b       // offset+src[x] low 8 samples
    saddw2 v24.8h, v19.8h, v25.16b      // offset+src[x] high 8 samples

    smax v23.8h, v23.8h, v6.8h
    smax v24.8h, v24.8h, v6.8h
    smin v23.8h, v23.8h, v7.8h
    smin v24.8h, v24.8h, v7.8h

    add x12, x1, x11
    cmp x11, x10
    bge test_maskmove_eo_135_r0
    st1 {v23.8h, v24.8h}, [x12]
    add x11, x11, #32
    b   test_loop_x_eo_135_r0

test_maskmove_eo_135_r0:
    sub x7, x9, x10
    add x7, x5, x7, lsl #4              // offset = 16*rownum
    ld1 {v30.4s, v31.4s}, [x7]          // load mask_r0
    ld1 {v21.8h, v22.8h}, [x12]         // load 16 pixels from dst+x
    bif v23.16b, v21.16b, v30.16b
    bif v24.16b, v22.16b, v31.16b
    st1 {v23.8h, v24.8h}, [x12]

test_loop_x_eo_135_end_r0:
    add x0, x0, x2                      // src+=src_stride
    add x1, x1, x3                      // dst+=dst_stride

    // ------- middle rows -------
    // get param
#if defined(__APPLE__)
    ldp w7, w8, [sp, #8]
#else
    ldp x7, x8, [sp, #16]
#endif
    sxtw x7, w7                         // x7 start_x_r
    sxtw x8, w8                         // x8 end_x_r

    sub x9, x8, x7
    and x9, x9, #15
    add x12, x5, x9, lsl #5
    ld1 {v30.4s, v31.4s}, [x12]         // mask_r

    sub x10, x8, x9                     // end_x_r_16
    lsl x7, x7, #1
    lsl x8, x8, #1
    lsl x10, x10, #1

    sub x11, x6, #2                     // y = mb_height - 2

test_loop_y_eo_135_r:

    mov x9, x7                          // x = start_x_r

test_loop_x_eo_135_r:
    add x12, x0, x9
    sub x13, x12, x2
    add x14, x12, x2
    sub x13, x13, #2
    add x14, x14, #2
    ld1  {v16.8h, v17.8h}, [x13]        // src[x-src_stride-1]
    ld1  {v18.8h, v19.8h}, [x12]        // src[x]
    ld1  {v20.8h, v21.8h}, [x14]        // src[x+src_stride+1]

    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h

    xtn  v16.8b, v16.8h
    xtn2 v16.16b, v17.8h

    add v16.16b, v16.16b, v1.16b        // edgetype+2

    tbl v25.16b, {v0.16b}, v16.16b      // offset

    saddw  v23.8h, v18.8h, v25.8b       // offset+src[x] low 8 samples
    saddw2 v24.8h, v19.8h, v25.16b      // offset+src[x] high 8 samples

    smax v23.8h, v23.8h, v6.8h
    smax v24.8h, v24.8h, v6.8h
    smin v23.8h, v23.8h, v7.8h
    smin v24.8h, v24.8h, v7.8h

    add x12, x1, x9
    cmp x9, x10
    bge test_maskmove_eo_135_r
    add x9, x9, #32
    st1 {v23.8h, v24.8h}, [x12]
    cmp x9, x8
    blt test_loop_x_eo_135_r
    b   test_loop_x_eo_135_end_r

test_maskmove_eo_135_r:
    ld1 {v21.8h, v22.8h}, [x12]         // load 16 pixels from dst+x
    bif v23.16b, v21.16b, v30.16b
    bif v24.16b, v22.16b, v31.16b
    st1 {v23.8h, v24.8h}, [x12]

test_loop_x_eo_135_end_r:
    subs x11, x11, #1
    add x0, x0, x2                      // src += src_stride
    add x1, x1, x3                      // dst += dst_stride
    bgt test_loop_y_eo_135_r

// ------- last row -------
#if defined(__APPLE__)
    ldp w6, w7, [sp, #16]
#else
    ldp x6, x7, [sp, #32]
#endif
    sxtw x6, w6                         // start_x_rn
    sxtw x7, w7                         // end_x_rn

    sub x8, x7, x6
    and x8, x8, #15
    sub x10, x7, x8                     // end_x_rn_16

    lsl x6, x6, #1
    lsl x7, x7, #1
    lsl x10, x10, #1

    mov x9, x6                          // x = start_x_rn

test_loop_x_eo_135_rn:
    cmp x9, x7
    bge test_loop_x_eo_135_end_rn

    add x12, x0, x9
    sub x13, x12, x2
    add x14, x12, x2
    sub x13, x13, #2
    add x14, x14, #2
    ld1  {v16.8h, v17.8h}, [x13]        // src[x-src_stride-1]
    ld1  {v18.8h, v19.8h}, [x12]        // src[x]
    ld1  {v20.8h, v21.8h}, [x14]        // src[x+src_stride+1]

    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h

    xtn  v16.8b, v16.8h
    xtn2 v16.16b, v17.8h

    add v16.16b, v16.16b, v1.16b        // edgetype+2

    tbl v25.16b, {v0.16b}, v16.16b      // offset

    saddw  v23.8h, v18.8h, v25.8b       // offset+src[x] low 8 samples
    saddw2 v24.8h, v19.8h, v25.16b      // offset+src[x] high 8 samples

    smax v23.8h, v23.8h, v6.8h
    smax v24.8h, v24.8h, v6.8h
    smin v23.8h, v23.8h, v7.8h
    smin v24.8h, v24.8h, v7.8h

    add x12, x1, x9
    cmp x9, x10
    bge test_maskmove_eo_135_rn
    st1 {v23.8h, v24.8h}, [x12]
    add x9, x9, #32
    b   test_loop_x_eo_135_rn

test_maskmove_eo_135_rn:
    sub x6, x7, x10
    add x6, x5, x6, lsl #4              // offset = 16*rownum
    ld1 {v30.4s, v31.4s}, [x6]          // load mask_r0
    ld1 {v21.8h, v22.8h}, [x12]         // load 16 pixels from dst+x
    bif v23.16b, v21.16b, v30.16b
    bif v24.16b, v22.16b, v31.16b
    st1 {v23.8h, v24.8h}, [x12]

test_loop_x_eo_135_end_rn:

    ret

/***********************************************************************************************************************************
 *  void sao_eo_45_arm64(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, char_t* mask, int mb_height, int bit_depth, int start_x_r0,
 *  int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
 *  src->x0, dst->x1, src_stride->x2, dst_stride->x3, offset->x4, mask->x5, mb_height->x6, bit_depth->x7
 ************************************************************************************************************************************/
function sao_eo_45_arm64
#if defined(__APPLE__)
    ldp w8, w9, [sp]
#else
    ldp x8, x9, [sp]                // start_x_r0 and end_x_r0
#endif

    mov w12, #1

    sxtw x8, w8                     // start_x_r0
    sxtw x9, w9                     // end_x_r0

    // get end_x_r0_16
    sub x11, x9, x8
    and x11, x11, #15
    sub x10, x9, x11                // end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f

    lsl w12, w12, w7
    lsl x2, x2, #1
    lsl x3, x3, #1
    lsl x8, x8, #1
    lsl x9, x9, #1
    lsl x10, x10, #1
    sub w12, w12, #1

    // ------- set offset table -------
    ld1  {v20.4s}, [x4]             // offset[0-3]
    ldr  w11, [x4, #16]             // offset[4]
    movi v2.4s, #0
    mov  v2.s[0], w11
    xtn  v0.4h, v20.4s
    xtn2 v0.8h, v2.4s
    xtn  v0.8b, v0.8h               // offset[0-4]

    movi v1.16b, #2
    movi v6.8h, #0
    dup  v7.8h, w12

    // ------- first row -------
    mov  x11, x8                     // x = start_x_r0

test_loop_x_eo_45_r0:

    cmp x11, x9
    bge test_loop_x_eo_45_end_r0
    add x12, x0, x11
    sub x13, x12, x2
    add x14, x12, x2
    add x13, x13, #2
    sub x14, x14, #2
    ld1  {v16.8h, v17.8h}, [x13]        // src[x-src_stride+1]
    ld1  {v18.8h, v19.8h}, [x12]        // src[x]
    ld1  {v20.8h, v21.8h}, [x14]        // src[x+src_stride-1]

    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h

    xtn  v16.8b, v16.8h
    xtn2 v16.16b, v17.8h

    add v16.16b, v16.16b, v1.16b        // edgetype+2

    tbl v25.16b, {v0.16b}, v16.16b      // offset

    saddw  v23.8h, v18.8h, v25.8b       // offset+src[x] low 8 samples
    saddw2 v24.8h, v19.8h, v25.16b      // offset+src[x] high 8 samples

    smax v23.8h, v23.8h, v6.8h
    smax v24.8h, v24.8h, v6.8h
    smin v23.8h, v23.8h, v7.8h
    smin v24.8h, v24.8h, v7.8h

    add x12, x1, x11
    cmp x11, x10
    bge test_maskmove_eo_45_r0
    st1 {v23.8h, v24.8h}, [x12]
    add x11, x11, #32
    b   test_loop_x_eo_45_r0

test_maskmove_eo_45_r0:
    sub x7, x9, x10
    add x7, x5, x7, lsl #4              // offset = 16*rownum
    ld1 {v30.4s, v31.4s}, [x7]          // load mask_r0
    ld1 {v21.8h, v22.8h}, [x12]         // load 16 pixels from dst+x
    bif v23.16b, v21.16b, v30.16b
    bif v24.16b, v22.16b, v31.16b
    st1 {v23.8h, v24.8h}, [x12]

test_loop_x_eo_45_end_r0:
    add x0, x0, x2                      // src+=src_stride
    add x1, x1, x3                      // dst+=dst_stride

    // ------- middle rows -------
    // get param
#if defined(__APPLE__)
    ldp w7, w8, [sp, #8]                // x7 start_x_r; x8 end_x_r
#else
    ldp x7, x8, [sp, #16]               // x7 start_x_r; x8 end_x_r
#endif
    sxtw x7, w7
    sxtw x8, w8

    sub x9, x8, x7
    and x9, x9, #15
    add x12, x5, x9, lsl #5
    ld1 {v30.4s, v31.4s}, [x12]         // mask_r

    sub x10, x8, x9                     // end_x_r_16

    sub x11, x6, #2                     // y = mb_height - 2

    lsl x7, x7, #1
    lsl x8, x8, #1
    lsl x10, x10, #1

test_loop_y_eo_45_r:
    mov x9, x7                          // x = start_x_r

test_loop_x_eo_45_r:
    add x12, x0, x9
    sub x13, x12, x2
    add x14, x12, x2
    add x13, x13, #2
    sub x14, x14, #2
    ld1  {v16.8h, v17.8h}, [x13]        // src[x-src_stride+1]
    ld1  {v18.8h, v19.8h}, [x12]        // src[x]
    ld1  {v20.8h, v21.8h}, [x14]        // src[x+src_stride-1]

    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h

    xtn  v16.8b, v16.8h
    xtn2 v16.16b, v17.8h

    add v16.16b, v16.16b, v1.16b        // edgetype+2

    tbl v25.16b, {v0.16b}, v16.16b      // offset

    saddw  v23.8h, v18.8h, v25.8b       // offset+src[x] low 8 samples
    saddw2 v24.8h, v19.8h, v25.16b      // offset+src[x] high 8 samples

    smax v23.8h, v23.8h, v6.8h
    smax v24.8h, v24.8h, v6.8h
    smin v23.8h, v23.8h, v7.8h
    smin v24.8h, v24.8h, v7.8h

    add x12, x1, x9
    cmp x9, x10
    bge test_maskmove_eo_45_r
    add x9, x9, #32
    st1 {v23.8h, v24.8h}, [x12]
    cmp x9, x8
    blt test_loop_x_eo_45_r
    b   test_loop_x_eo_45_end_r

test_maskmove_eo_45_r:
    ld1 {v21.8h, v22.8h}, [x12]         // load 16 pixels from dst+x
    bif v23.16b, v21.16b, v30.16b
    bif v24.16b, v22.16b, v31.16b
    st1 {v23.8h, v24.8h}, [x12]

test_loop_x_eo_45_end_r:
    subs x11, x11, #1
    add x0, x0, x2                      // src+=src_stride
    add x1, x1, x3                      // dst+=dst_stride
    bgt test_loop_y_eo_45_r

    // ------- last row -------
#if defined(__APPLE__)
    ldp w6, w7, [sp, #16]
#else
    ldp x6, x7, [sp, #32]
#endif
    sxtw x6, w6                         // start_x_rn
    sxtw x7, w7                         // end_x_rn

    sub x8, x7, x6
    and x8, x8, #15
    sub x10, x7, x8                     // end_x_rn_16

    lsl x6, x6, #1
    lsl x7, x7, #1
    lsl x10, x10, #1

    mov x9, x6                          // x = start_x_rn

test_loop_x_eo_45_rn:
    cmp x9, x7
    bge test_loop_x_eo_45_end_rn
    add x12, x0, x9
    sub x13, x12, x2
    add x14, x12, x2
    add x13, x13, #2
    sub x14, x14, #2
    ld1  {v16.8h, v17.8h}, [x13]        // src[x-src_stride+1]
    ld1  {v18.8h, v19.8h}, [x12]        // src[x]
    ld1  {v20.8h, v21.8h}, [x14]        // src[x+src_stride-1]

    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h

    xtn  v16.8b, v16.8h
    xtn2 v16.16b, v17.8h

    add v16.16b, v16.16b, v1.16b        // edgetype+2

    tbl v25.16b, {v0.16b}, v16.16b      // offset

    saddw  v23.8h, v18.8h, v25.8b       // offset+src[x] low 8 samples
    saddw2 v24.8h, v19.8h, v25.16b      // offset+src[x] high 8 samples

    smax v23.8h, v23.8h, v6.8h
    smax v24.8h, v24.8h, v6.8h
    smin v23.8h, v23.8h, v7.8h
    smin v24.8h, v24.8h, v7.8h

    add x12, x1, x9
    cmp x9, x10
    bge test_maskmove_eo_45_rn
    st1 {v23.8h, v24.8h}, [x12]
    add x9, x9, #32
    b   test_loop_x_eo_45_rn

test_maskmove_eo_45_rn:
    sub x6, x7, x10
    add x6, x5, x6, lsl #4              // offset = 16*rownum
    ld1 {v30.4s, v31.4s}, [x6]          // load mask_r0
    ld1 {v21.8h, v22.8h}, [x12]         // load 16 pixels from dst+x
    bif v23.16b, v21.16b, v30.16b
    bif v24.16b, v22.16b, v31.16b
    st1 {v23.8h, v24.8h}, [x12]

test_loop_x_eo_45_end_rn:

    ret

/***********************************************************************************************************************************
*   void sao_getStatblk_eo_0_arm64(pel_t* rec, pel_t* org, int i_rec, int i_org, i32s_t* pdiff, i32s_t* pedgetype, int start_x, int end_x, int end_y, pel_t* mask);
*  src->x0, org->x1, i_rec->x2, i_org->x3, pdiff->x4, pdegetype->x5, start_x->x6, end_x->x7, end_y->w8, mask->x9
************************************************************************************************************************************/
function sao_getStatblk_eo_0_arm64
    mov x10, sp
    ldr x8, [x10], #8
    ldr x9, [x10]

    sub sp, sp, #64
    st1 {v8.8h - v11.8h}, [sp]
    sub sp, sp, #64
    st1 {v12.8h - v15.8h}, [sp]

    sub x10, x7, x6                 // width = end_x - start_x

    // ------- load mask -------
    and x11, x10, #15
    add x12, x9, x11, lsl #5
    ld1 {v30.8h, v31.8h}, [x12]     // mask + ((end_x - start_x) & 0x0f) * 16 * sizeof(pel)

    sub x10, x7, x11                // end_x_16 = end_x - ((end_x - start_x) & 0x0f)
    
    lsl x2, x2, #1
    lsl x3, x3, #1
    lsl x7, x7, #1              //end_x
    lsl x6, x6, #1              //start_x
    lsl x10, x10, #1            //end_x_16
    
    movi v6.8h, #0
    movi v7.8h, #0
    movi v8.8h, #0
    movi v9.8h, #0
    movi v10.8h, #0
    movi v11.8h, #0
    movi v12.8h, #0
    movi v13.8h, #0
    movi v14.8h, #0
    movi v15.8h, #0

getStat_loop_y_eo_0:

    mov x15, x6                  // x = start_x
getStat_loop_x_eo_0:

    add x12, x0, x15             //rec
    sub x13, x12, #2
    add x14, x12, #2
    add x11, x1, x15             //org

    ld1 {v16.8h, v17.8h}, [x13]        // rec[x-1]
    ld1 {v18.8h, v19.8h}, [x12]        // rec[x]
    ld1 {v20.8h, v21.8h}, [x14]        // rec[x+1]
    
    ld1 {v0.8h, v1.8h}, [x11]
    
    sub v0.8h, v0.8h, v18.8h
    sub v1.8h, v1.8h, v19.8h           //pdiff
    
    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h
    movi v21.8h, #2
    add v16.8h, v16.8h, v21.8h
    add v17.8h, v17.8h, v21.8h
    
    cmp x15, x10
    bne getStat_nomask_eo_0
    movi v25.8h, #5
    and v30.16b, v25.16b, v30.16b
    and v31.16b, v25.16b, v31.16b
    add v16.8h, v16.8h, v30.8h
    add v17.8h, v17.8h, v31.8h

getStat_nomask_eo_0:
    //edgetype[0] diff[0]
    movi v25.8h, #0
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v23.8h
    
    //edgetype[1] diff[1]
    movi v25.8h, #1
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v23.8h
    
    //edgetype[2] diff[2]
    movi v25.8h, #2
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v23.8h
    
    //edgetype[3] diff[3]
    movi v25.8h, #3
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v23.8h
    
    //edgetype[4] diff[4]
    movi v25.8h, #4
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v23.8h

    add x15, x15, #32
    cmp x15, x7
    blt getStat_loop_x_eo_0

    subs w8, w8, #1
    add x0, x0, x2
    add x1, x1, x3
    bgt getStat_loop_y_eo_0

    addp v6.8h, v6.8h, v8.8h
    addp v10.8h, v10.8h, v12.8h
    addp v6.8h, v6.8h, v10.8h
    saddlp v6.4s, v6.8h
    neg v6.4s, v6.4s

    addp v7.8h, v7.8h, v9.8h
    addp v11.8h, v11.8h, v13.8h
    addp v7.8h, v7.8h, v11.8h
    saddlp v7.4s, v7.8h

    addp v14.8h, v14.8h, v14.8h
    addp v14.8h, v14.8h, v14.8h
    saddlp v14.4s, v14.8h
    neg v14.4s, v14.4s
    
    addp v15.8h, v15.8h, v15.8h
    addp v15.8h, v15.8h, v15.8h
    saddlp v15.4s, v15.8h

    st1 {v7.4s}, [x4], #16
    st1 {v15.s}[0], [x4]

    st1 {v6.4s}, [x5], #16
    st1 {v14.s}[0], [x5]

    ld1 {v12.8h, v13.8h, v14.8h, v15.8h}, [sp], #64
    ld1 {v8.8h, v9.8h, v10.8h, v11.8h}, [sp], #64

    ret

/***********************************************************************************************************************************
 *  void sao_getStatblk_eo_90_arm64(pel_t* rec_base, pel_t* org_base, int i_rec, int i_org, i16s_t* pdiff, i16u_t* pedgetype, int end_x, int start_y, int end_y);
 *  rec->x0, org->x1, i_rec->x2, i_org->x3, pdiff->x4, pedgetype->x5, end_x->x6, start_y->x7, end_y->w8
 ************************************************************************************************************************************/
function sao_getStatblk_eo_90_arm64
    ldr w8, [sp]

    sub sp, sp, #64
    st1 {v8.8h - v11.8h}, [sp]
    sub sp, sp, #64
    st1 {v12.8h - v15.8h}, [sp]

    and x15, x6, #15

    lsl x2, x2, #1          // i_rec
    lsl x3, x3, #1          // i_org
    lsl x6, x6, #1          // end_x

    sub x10, x6, #30            // end_x_16 = (mb_width - 15) * sizeof(pel)

    sub  w8, w8, w7             // y = end_y - start_y

    movi v6.8h, #0
    movi v7.8h, #0
    movi v8.8h, #0
    movi v9.8h, #0
    movi v10.8h, #0
    movi v11.8h, #0
    movi v12.8h, #0
    movi v13.8h, #0
    movi v14.8h, #0
    movi v15.8h, #0

    mov x9, #-1
    cmp x15, #4
    beq getStat_set_mask_width_4
    cmp x15, #0
    beq getStat_loop_y_eo_90
    movi v30.4s, #0
    movi v31.4s, #0             // v30.8h: "0, 0, 0, 0, 0, 0, 0, 0"
    mov v31.d[1], x9           // v31.8h: "0, 0, 0, 0, -1, -1, -1, -1"
    b getStat_loop_y_eo_90
    
getStat_set_mask_width_4:
    movi v30.4s, #0
    mov  v30.d[1], x9           // v30.8h: "0, 0, 0, 0, -1, -1, -1, -1"
    movi v31.16b, #255             // v31.8h: "-1, -1, -1, -1, -1, -1, -1, -1"

getStat_loop_y_eo_90:

    mov  x9, #0                 // x = 0

getStat_loop_x_eo_90:
    add  x12, x0, x9            // src
    sub  x13, x12, x2
    add  x14, x12, x2
    add x11, x1, x9             // org
    //add x15, x4, x9             // pdiff
    //add x19, x5, x9             // pedgetype

    ld1  {v18.8h, v19.8h}, [x12]        // rec[x]
    ld1  {v16.8h, v17.8h}, [x13]        // rec[x-src_stride]
    ld1  {v20.8h, v21.8h}, [x14]        // rec[x+src_stride]
    
    ld1 {v0.8h, v1.8h}, [x11]
    sub v0.8h, v0.8h, v18.8h
    sub v1.8h, v1.8h, v19.8h            //pdiff
    //st1 {v1.8h, v2.8h}, [x15]
    
    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h
    add v17.8h, v17.8h, v21.8h
    movi v21.8h, #2
    add v16.8h, v16.8h, v21.8h
    add v17.8h, v17.8h, v21.8h
    
    //st1 {v16.8h, v17.8h}, [x19]         //pedgetype
    cmp x9, x10
    blt getStat_nomask_eo_90
    
    movi v25.8h, #5
    and v30.16b, v25.16b, v30.16b
    and v31.16b, v25.16b, v31.16b
    add v16.8h, v16.8h, v30.8h
    add v17.8h, v17.8h, v31.8h

getStat_nomask_eo_90:
    movi v25.8h, #0
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v23.8h
    
    //edgetype[1] diff[1]
    movi v25.8h, #1
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v23.8h
    
    //edgetype[2] diff[2]
    movi v25.8h, #2
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v23.8h
    
    //edgetype[3] diff[3]
    movi v25.8h, #3
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v23.8h
    
    //edgetype[4] diff[4]
    movi v25.8h, #4
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v23.8h

    add x9, x9, #32
    cmp x9, x6
    blt getStat_loop_x_eo_90

    subs w8, w8, #1
    add x0, x0, x2
    add x1, x1, x3
    //add x4, x4, x6
    //add x5, x5, x6
    bgt getStat_loop_y_eo_90

    addp v6.8h, v6.8h, v8.8h
    addp v10.8h, v10.8h, v12.8h
    addp v6.8h, v6.8h, v10.8h
    saddlp v6.4s, v6.8h
    neg v6.4s, v6.4s
    
    addp v7.8h, v7.8h, v9.8h
    addp v11.8h, v11.8h, v13.8h
    addp v7.8h, v7.8h, v11.8h
    saddlp v7.4s, v7.8h
    
    addp v14.8h, v14.8h, v14.8h
    addp v14.8h, v14.8h, v14.8h
    saddlp v14.4s, v14.8h
    neg v14.4s, v14.4s
    
    addp v15.8h, v15.8h, v15.8h
    addp v15.8h, v15.8h, v15.8h
    saddlp v15.4s, v15.8h

    st1 {v7.4s}, [x4], #16
    st1 {v15.s}[0], [x4]
    
    st1 {v6.4s}, [x5], #16
    st1 {v14.s}[0], [x5]

    ld1 {v12.8h, v13.8h, v14.8h, v15.8h}, [sp], #64
    ld1 {v8.8h, v9.8h, v10.8h, v11.8h}, [sp], #64

    ret

/***********************************************************************************************************************************
 *  void sao_getStatblk_eo_135_arm64(pel_t* rec, pel_t* org, int i_rec, int i_org, i16s_t* pdiff, i16u_t* pedgetype, int lcu_pix_height, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn, pel_t* uavs3e_sao_mask);
 *  rec->x0, org->x1, i_rec->x2, i_org->x3, pdiff->x4, pedgetype->x5, lcu_pix_height->x6, start_x_r0->x7, end_x_r0->w8, start_x_r->w9, end_x_r->w10, start_x_rn->w11, end_x_rn->w12, mask->x13
 ************************************************************************************************************************************/
function sao_getStatblk_eo_135_arm64
#if defined(__APPLE__)
    ldp w8, w9, [sp]
    ldr w10, [sp, #8]
    ldr w11, [sp, #12]
    ldr w12, [sp, #16]
    ldr x13, [sp, #24]

#else   //未测试
    ldp x8, x9, [sp]                // start_x_r0 and end_x_r0
    ldr x10, [sp, #16]              //
    ldr x11, [sp, #24]
    ldr x12, [sp, #32]
    ldr x13, [sp, #40]
#endif

    sxtw x8, w8                     // end_x_r0
    sxtw x9, w9                     // start_x_r
    sxtw x10, w10
    sxtw x11, w11
    sxtw x12, w12

    sub sp, sp, #16
    stp x19, x20, [sp]
    sub sp, sp, #16
    stp x21, x22, [sp]
    sub sp, sp, #16
    stp x23, x24, [sp]
    sub sp, sp, #64
    st1 {v8.8h - v11.8h}, [sp]
    sub sp, sp, #64
    st1 {v12.8h - v15.8h}, [sp]

    lsl x2, x2, #1
    lsl x3, x3, #1

    movi v6.8h, #0
    movi v7.8h, #0
    movi v8.8h, #0
    movi v9.8h, #0
    movi v10.8h, #0
    movi v11.8h, #0
    movi v12.8h, #0
    movi v13.8h, #0
    movi v14.8h, #0
    movi v15.8h, #0

    // ------- first row -------
    sub x21, x8, x7
    and x21, x21, #15
    sub x22, x8, x21                 // end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f

    lsl x7, x7, #1
    lsl x8, x8, #1
    lsl x22, x22, #1

    mov  x23, x7                     // x = start_x_r0

getStat_loop_x_eo_135_r0:
    cmp x23, x8
    bge getStat_loop_x_eo_135_end_r0
    add x14, x0, x23                // rec[x]
    add x20, x1, x23                // org[x]
    sub x15, x14, x2                // rec[x - i_rec]
    add x19, x14, x2                // rec[x + i_rec]
    sub x15, x15, #2                // rec[x - i_rec - 2]
    add x19, x19, #2                // rec[x + i_rec + 2]
    
    ld1 {v16.8h, v17.8h}, [x15]        // rec[x - i_rec - 2]
    ld1 {v18.8h, v19.8h}, [x14]        // rec[x]
    ld1 {v20.8h, v21.8h}, [x19]        // rec[x + i_rec + 2]
    ld1 {v0.8h, v1.8h}, [x20]          // org[x]
    
    sub v0.8h, v0.8h, v18.8h            //pdiff
    sub v1.8h, v1.8h, v19.8h
    
    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h
    movi v18.8h, #2
    add v16.8h, v16.8h, v18.8h
    add v17.8h, v17.8h, v18.8h

    cmp x23, x22
    bne getStat_nomask_eo_135_r0
    add x24, x13, x21, lsl #5
    ld1 {v30.8h, v31.8h}, [x24]
    movi v25.8h, #5
    and v30.16b, v25.16b, v30.16b
    and v31.16b, v25.16b, v31.16b
    add v16.8h, v16.8h, v30.8h
    add v17.8h, v17.8h, v31.8h
    
getStat_nomask_eo_135_r0:
    movi v25.8h, #0
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v23.8h
    
    //edgetype[1] diff[1]
    movi v25.8h, #1
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v23.8h
    
    //edgetype[2] diff[2]
    movi v25.8h, #2
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v23.8h
    
    //edgetype[3] diff[3]
    movi v25.8h, #3
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v23.8h
    
    //edgetype[4] diff[4]
    movi v25.8h, #4
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v23.8h
    add x23, x23, #32
    
    b getStat_loop_x_eo_135_r0

getStat_loop_x_eo_135_end_r0:
    add x0, x0, x2                      // rec += i_rec
    add x1, x1, x3                      // org += i_org

    // ------- middle rows -------

    sub x8, x6, #2                     // y = mb_height - 2

    sub x21, x10, x9
    and x21, x21, #15
    sub x22, x10, x21                 // end_x_r_16 = end_x_r - ((end_x_r - start_x_r) & 0x0f
    
    lsl x9, x9, #1
    lsl x10, x10, #1
    lsl x22, x22, #1

getStat_loop_y_eo_135_r:
    mov x23, x9                          // x = start_x_r

getStat_loop_x_eo_135_r:
    add x14, x0, x23                // rec[x]
    add x20, x1, x23                // org[x]
    sub x15, x14, x2                // rec[x - i_rec]
    add x19, x14, x2                // rec[x + i_rec]
    sub x15, x15, #2                // rec[x - i_rec - 2]
    add x19, x19, #2                // rec[x + i_rec + 2]

    ld1  {v16.8h, v17.8h}, [x15]        // rec[x - i_rec - 2]
    ld1  {v18.8h, v19.8h}, [x14]        // rec[x]
    ld1  {v20.8h, v21.8h}, [x19]        // rec[x + i_rec + 2]
    ld1 {v0.8h, v1.8h}, [x20]          // org[x]
    
    sub v0.8h, v0.8h, v18.8h            //pdiff
    sub v1.8h, v1.8h, v19.8h
    
    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h
    movi v18.8h, #2
    add v16.8h, v16.8h, v18.8h
    add v17.8h, v17.8h, v18.8h
    
    //st1 {v16.8h, v17.8h}, [x22]

    cmp x23, x22
    bne getStat_nomask_eo_135_r
    add x24, x13, x21, lsl #5
    ld1 {v30.8h, v31.8h}, [x24]
    movi v25.8h, #5
    and v30.16b, v25.16b, v30.16b
    and v31.16b, v25.16b, v31.16b
    add v16.8h, v16.8h, v30.8h
    add v17.8h, v17.8h, v31.8h
    
getStat_nomask_eo_135_r:
    movi v25.8h, #0
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v23.8h
    
    //edgetype[1] diff[1]
    movi v25.8h, #1
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v23.8h
    
    //edgetype[2] diff[2]
    movi v25.8h, #2
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v23.8h
    
    //edgetype[3] diff[3]
    movi v25.8h, #3
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v23.8h
    
    //edgetype[4] diff[4]
    movi v25.8h, #4
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v23.8h
    
    add x23, x23, #32
    cmp x23, x10
    blt getStat_loop_x_eo_135_r

    subs x8, x8, #1
    add x0, x0, x2                      // rec += i_rec
    add x1, x1, x3                      // org += i_org

    bgt getStat_loop_y_eo_135_r

    // ------- last row -------
    sub x21, x12, x11
    and x21, x21, #15
    sub x22, x12, x21                 // end_x_r_16 = end_x_r - ((end_x_r - start_x_r) & 0x0f
    
    lsl x11, x11, #1
    lsl x12, x12, #1
    lsl x22, x22, #1

    mov x23, x11                          // x = start_x_rn

getStat_loop_x_eo_135_rn:
    cmp x23, x12
    bge getStat_loop_x_eo_135_end_rn
    add x14, x0, x23                // rec[x]
    add x20, x1, x23                // org[x]
    sub x15, x14, x2                // rec[x - i_rec]
    add x19, x14, x2                // rec[x + i_rec]
    sub x15, x15, #2                // rec[x - i_rec - 2]
    add x19, x19, #2                // rec[x + i_rec + 2]

    ld1 {v16.8h, v17.8h}, [x15]        // rec[x - i_rec - 2]
    ld1 {v18.8h, v19.8h}, [x14]        // rec[x]
    ld1 {v20.8h, v21.8h}, [x19]        // rec[x + i_rec + 2]
    ld1 {v0.8h, v1.8h}, [x20]          // org[x]

    sub v0.8h, v0.8h, v18.8h            //pdiff
    sub v1.8h, v1.8h, v19.8h

    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h
    movi v18.8h, #2
    add v16.8h, v16.8h, v18.8h
    add v17.8h, v17.8h, v18.8h
    
    cmp x23, x22
    bne getStat_nomask_eo_135_rn
    add x24, x13, x21, lsl #5
    ld1 {v30.8h, v31.8h}, [x24]
    movi v25.8h, #5
    and v30.16b, v25.16b, v30.16b
    and v31.16b, v25.16b, v31.16b
    add v16.8h, v16.8h, v30.8h
    add v17.8h, v17.8h, v31.8h
    
    getStat_nomask_eo_135_rn:
    movi v25.8h, #0
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v23.8h
    
    //edgetype[1] diff[1]
    movi v25.8h, #1
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v23.8h
    
    //edgetype[2] diff[2]
    movi v25.8h, #2
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v23.8h
    
    //edgetype[3] diff[3]
    movi v25.8h, #3
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v23.8h
    
    //edgetype[4] diff[4]
    movi v25.8h, #4
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v23.8h

    add x23, x23, #32
    b   getStat_loop_x_eo_135_rn

getStat_loop_x_eo_135_end_rn:

    addp v6.8h, v6.8h, v8.8h
    addp v10.8h, v10.8h, v12.8h
    addp v6.8h, v6.8h, v10.8h
    saddlp v6.4s, v6.8h
    neg v6.4s, v6.4s
    
    addp v7.8h, v7.8h, v9.8h
    addp v11.8h, v11.8h, v13.8h
    addp v7.8h, v7.8h, v11.8h
    saddlp v7.4s, v7.8h
    
    addp v14.8h, v14.8h, v14.8h
    addp v14.8h, v14.8h, v14.8h
    saddlp v14.4s, v14.8h
    neg v14.4s, v14.4s
    
    addp v15.8h, v15.8h, v15.8h
    addp v15.8h, v15.8h, v15.8h
    saddlp v15.4s, v15.8h
    
    st1 {v7.4s}, [x4], #16
    st1 {v15.s}[0], [x4]
    
    st1 {v6.4s}, [x5], #16
    st1 {v14.s}[0], [x5]
    
    ld1 {v12.8h, v13.8h, v14.8h, v15.8h}, [sp], #64
    ld1 {v8.8h, v9.8h, v10.8h, v11.8h}, [sp], #64
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16

    ret

/***********************************************************************************************************************************
 *  void sao_getStatblk_eo_45_arm64(pel_t* rec, pel_t* org, int i_rec, int i_org, i16s_t* pdiff, i16u_t* pedgetype, int lcu_pix_height, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn, pel_t* uavs3e_sao_mask);
 *  rec->x0, org->x1, i_rec->x2, i_org->x3, pdiff->x4, pedgetype->x5, lcu_pix_height->x6, start_x_r0->x7, end_x_r0->w8, start_x_r->w9, end_x_r->w10, start_x_rn->w11, end_x_rn->w12
 ************************************************************************************************************************************/
function sao_getStatblk_eo_45_arm64
#if defined(__APPLE__)
    ldp w8, w9, [sp]
    ldr w10, [sp, #8]
    ldr w11, [sp, #12]
    ldr w12, [sp, #16]
    ldr x13, [sp, #24]

#else   //未测试
    ldp x8, x9, [sp]                // start_x_r0 and end_x_r0
    ldr x10, [sp, #16]              //
    ldr x11, [sp, #24]
    ldr x12, [sp, #32]
    ldr x13, [sp, #40]
#endif

    sxtw x8, w8                     // end_x_r0
    sxtw x9, w9                     // start_x_r
    sxtw x10, w10
    sxtw x11, w11
    sxtw x12, w12

    sub sp, sp, #16
    stp x19, x20, [sp]
    sub sp, sp, #16
    stp x21, x22, [sp]
    sub sp, sp, #16
    stp x23, x24, [sp]
    sub sp, sp, #64
    st1 {v8.8h - v11.8h}, [sp]
    sub sp, sp, #64
    st1 {v12.8h - v15.8h}, [sp]

    lsl x2, x2, #1
    lsl x3, x3, #1

    movi v6.8h, #0
    movi v7.8h, #0
    movi v8.8h, #0
    movi v9.8h, #0
    movi v10.8h, #0
    movi v11.8h, #0
    movi v12.8h, #0
    movi v13.8h, #0
    movi v14.8h, #0
    movi v15.8h, #0
    
    // ------- first row -------
    sub x21, x8, x7
    and x21, x21, #15
    sub x22, x8, x21                 // end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f
    
    lsl x7, x7, #1
    lsl x8, x8, #1
    lsl x22, x22, #1
    
    mov  x23, x7                     // x = start_x_r0

getStat_loop_x_eo_45_r0:
    cmp x23, x8
    bge getStat_loop_x_eo_45_end_r0
    add x14, x0, x23                // rec[x]
    add x20, x1, x23                // org[x]
    sub x15, x14, x2                // rec[x - i_rec]
    add x19, x14, x2                // rec[x + i_rec]
    add x15, x15, #2                // rec[x - i_rec + 2]
    sub x19, x19, #2                // rec[x + i_rec - 2]
    
    ld1 {v16.8h, v17.8h}, [x15]        // rec[x - i_rec + 2]
    ld1 {v18.8h, v19.8h}, [x14]        // rec[x]
    ld1 {v20.8h, v21.8h}, [x19]        // rec[x + i_rec - 2]
    ld1 {v0.8h, v1.8h}, [x20]          // org[x]
    
    sub v0.8h, v0.8h, v18.8h            //pdiff
    sub v1.8h, v1.8h, v19.8h
    
    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h
    movi v20.8h, #2
    add v16.8h, v16.8h, v20.8h
    add v17.8h, v17.8h, v20.8h

    cmp x23, x22
    bne getStat_nomask_eo_45_r0
    add x24, x13, x21, lsl #5
    ld1 {v30.8h, v31.8h}, [x24]
    movi v25.8h, #5
    and v30.16b, v25.16b, v30.16b
    and v31.16b, v25.16b, v31.16b
    add v16.8h, v16.8h, v30.8h
    add v17.8h, v17.8h, v31.8h
    
getStat_nomask_eo_45_r0:
    movi v25.8h, #0
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v23.8h
    
    //edgetype[1] diff[1]
    movi v25.8h, #1
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v23.8h
    
    //edgetype[2] diff[2]
    movi v25.8h, #2
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v23.8h
    
    //edgetype[3] diff[3]
    movi v25.8h, #3
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v23.8h
    
    //edgetype[4] diff[4]
    movi v25.8h, #4
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v23.8h
    add x23, x23, #32
    
    b getStat_loop_x_eo_45_r0

getStat_loop_x_eo_45_end_r0:
    add x0, x0, x2                      // rec += i_rec
    add x1, x1, x3                      // org += i_org

    // ------- middle rows -------

    sub x8, x6, #2                     // y = mb_height - 2
    sub x21, x10, x9
    and x21, x21, #15
    sub x22, x10, x21                 // end_x_r_16 = end_x_r - ((end_x_r - start_x_r) & 0x0f
    
    lsl x9, x9, #1
    lsl x10, x10, #1
    lsl x22, x22, #1

getStat_loop_y_eo_45_r:
    mov x23, x9                          // x = start_x_r

getStat_loop_x_eo_45_r:
    add x14, x0, x23                // rec[x]
    add x20, x1, x23                // org[x]
    sub x15, x14, x2                // rec[x - i_rec]
    add x19, x14, x2                // rec[x + i_rec]
    add x15, x15, #2                // rec[x - i_rec + 2]
    sub x19, x19, #2                // rec[x + i_rec - 2]

    ld1  {v16.8h, v17.8h}, [x15]        // rec[x - i_rec + 2]
    ld1  {v18.8h, v19.8h}, [x14]        // src[x]
    ld1  {v20.8h, v21.8h}, [x19]        // rec[x + i_rec - 2]
    ld1 {v0.8h, v1.8h}, [x20]          // org[x]
    
    sub v0.8h, v0.8h, v18.8h            //pdiff
    sub v1.8h, v1.8h, v19.8h
    
    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h
    movi v20.8h, #2
    add v16.8h, v16.8h, v20.8h
    add v17.8h, v17.8h, v20.8h

    cmp x23, x22
    bne getStat_nomask_eo_45_r
    add x24, x13, x21, lsl #5
    ld1 {v30.8h, v31.8h}, [x24]
    movi v25.8h, #5
    and v30.16b, v25.16b, v30.16b
    and v31.16b, v25.16b, v31.16b
    add v16.8h, v16.8h, v30.8h
    add v17.8h, v17.8h, v31.8h
    
    getStat_nomask_eo_45_r:
    movi v25.8h, #0
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v23.8h
    
    //edgetype[1] diff[1]
    movi v25.8h, #1
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v23.8h
    
    //edgetype[2] diff[2]
    movi v25.8h, #2
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v23.8h
    
    //edgetype[3] diff[3]
    movi v25.8h, #3
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v23.8h
    
    //edgetype[4] diff[4]
    movi v25.8h, #4
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v23.8h
    
    add x23, x23, #32
    cmp x23, x10
    blt getStat_loop_x_eo_45_r

    subs x8, x8, #1
    add x0, x0, x2                      // rec += i_rec
    add x1, x1, x3                      // org += i_org
    bgt getStat_loop_y_eo_45_r

    // ------- last row -------
    sub x21, x12, x11

    and x21, x21, #15
    sub x22, x12, x21                 // end_x_r_16 = end_x_r - ((end_x_r - start_x_r) & 0x0f
    lsl x11, x11, #1
    lsl x12, x12, #1
    lsl x22, x22, #1
    mov x23, x11                          // x = start_x_rn

getStat_loop_x_eo_45_rn:
    cmp x23, x12
    bge getStat_loop_x_eo_45_end_rn
    add x14, x0, x23                // rec[x]
    add x20, x1, x23                // org[x]
    sub x15, x14, x2                // rec[x - i_rec]
    add x19, x14, x2                // rec[x + i_rec]
    add x15, x15, #2                // rec[x - i_rec + 2]
    sub x19, x19, #2                // rec[x + i_rec - 2]

    ld1 {v16.8h, v17.8h}, [x15]        // rec[x - i_rec + 2]
    ld1 {v18.8h, v19.8h}, [x14]        // rec[x]
    ld1 {v20.8h, v21.8h}, [x19]        // rec[x + i_rec - 2]
    ld1 {v0.8h, v1.8h}, [x20]          // org[x]

    sub v0.8h, v0.8h, v18.8h            //pdiff
    sub v1.8h, v1.8h, v19.8h

    // leftsign & rightsign
    umin v2.8h, v16.8h, v18.8h
    umin v3.8h, v17.8h, v19.8h
    umin v4.8h, v18.8h, v20.8h
    umin v5.8h, v19.8h, v21.8h

    cmeq v22.8h, v2.8h, v16.8h
    cmeq v23.8h, v2.8h, v18.8h
    cmeq v24.8h, v3.8h, v17.8h
    cmeq v25.8h, v3.8h, v19.8h
    cmeq v26.8h, v4.8h, v18.8h
    cmeq v27.8h, v4.8h, v20.8h
    cmeq v28.8h, v5.8h, v19.8h
    cmeq v29.8h, v5.8h, v21.8h

    sub  v16.8h, v23.8h, v22.8h         // leftsign
    sub  v17.8h, v25.8h, v24.8h
    sub  v20.8h, v26.8h, v27.8h         // rightsign
    sub  v21.8h, v28.8h, v29.8h

    // get edgetype
    add v16.8h, v16.8h, v20.8h          // edgetype
    add v17.8h, v17.8h, v21.8h
    movi v20.8h, #2
    add v16.8h, v16.8h, v20.8h
    add v17.8h, v17.8h, v20.8h

    cmp x23, x22
    bne getStat_nomask_eo_45_rn
    add x24, x13, x21, lsl #5
    ld1 {v30.8h, v31.8h}, [x24]
    movi v25.8h, #5
    and v30.16b, v25.16b, v30.16b
    and v31.16b, v25.16b, v31.16b
    add v16.8h, v16.8h, v30.8h
    add v17.8h, v17.8h, v31.8h
    
    getStat_nomask_eo_45_rn:
    movi v25.8h, #0
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v6.8h, v6.8h, v21.8h
    add v7.8h, v7.8h, v23.8h
    
    //edgetype[1] diff[1]
    movi v25.8h, #1
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v8.8h, v8.8h, v21.8h
    add v9.8h, v9.8h, v23.8h
    
    //edgetype[2] diff[2]
    movi v25.8h, #2
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v10.8h, v10.8h, v21.8h
    add v11.8h, v11.8h, v23.8h
    
    //edgetype[3] diff[3]
    movi v25.8h, #3
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v12.8h, v12.8h, v21.8h
    add v13.8h, v13.8h, v23.8h
    
    //edgetype[4] diff[4]
    movi v25.8h, #4
    cmeq v21.8h, v16.8h, v25.8h
    cmeq v22.8h, v17.8h, v25.8h
    and v23.16b, v21.16b, v0.16b
    and v24.16b, v22.16b, v1.16b
    add v21.8h, v21.8h, v22.8h
    add v23.8h, v23.8h, v24.8h
    add v14.8h, v14.8h, v21.8h
    add v15.8h, v15.8h, v23.8h
    
    add x23, x23, #32
    b   getStat_loop_x_eo_45_rn

getStat_loop_x_eo_45_end_rn:

    addp v6.8h, v6.8h, v8.8h
    addp v10.8h, v10.8h, v12.8h
    addp v6.8h, v6.8h, v10.8h
    saddlp v6.4s, v6.8h
    neg v6.4s, v6.4s
    
    addp v7.8h, v7.8h, v9.8h
    addp v11.8h, v11.8h, v13.8h
    addp v7.8h, v7.8h, v11.8h
    saddlp v7.4s, v7.8h
    
    addp v14.8h, v14.8h, v14.8h
    addp v14.8h, v14.8h, v14.8h
    saddlp v14.4s, v14.8h
    neg v14.4s, v14.4s
    
    addp v15.8h, v15.8h, v15.8h
    addp v15.8h, v15.8h, v15.8h
    saddlp v15.4s, v15.8h
    
    st1 {v7.4s}, [x4], #16
    st1 {v15.s}[0], [x4]
    
    st1 {v6.4s}, [x5], #16
    st1 {v14.s}[0], [x5]
    
    ld1 {v12.8h, v13.8h, v14.8h, v15.8h}, [sp], #64
    ld1 {v8.8h, v9.8h, v10.8h, v11.8h}, [sp], #64
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16

    ret

#endif  // COMPILE_10BIT

#endif
