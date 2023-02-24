#include "def_arm64.S"
#if defined(__arm64__)

#if !COMPILE_10BIT

//void com_if_filter_hor_8_arm64(const pel_t *src, int i_src, pel_t *dst[3], int i_dst, i16s_t *dst_tmp[3], int i_dst_tmp, int width, int height, tab_char_t (coeff)[8], int bit_depth);
//src->x0, i_src->x1, dst[3]->x2, i_dst->x3, dst_tmp[3]->x4, i_dst_tmp->x5, width->x6, height->x7, coeff->x8
function com_if_filter_hor_8_arm64
    ldr x8, [sp]    //coeff[3]
    sub sp, sp, #16
    stp x19, x20, [sp]
    sub sp, sp, #16
    stp x21, x22, [sp]
    sub sp, sp, #16
    stp x23, x24, [sp]
    sub sp, sp, #64
    st1 {v8.8h - v11.8h}, [sp]

    ld1 {v0.d}[0], [x8], #8
    abs v31.8b, v0.8b

    dup v0.16b, v31.b[0]     //1
    dup v1.16b, v31.b[1]     //4
    dup v2.16b, v31.b[2]     //10
    dup v3.16b, v31.b[3]     //57
    dup v4.16b, v31.b[4]     //19
    dup v5.16b, v31.b[5]     //7
    dup v6.16b, v31.b[6]     //3
    mov w9, #11
    dup v7.16b, w9           //11
    mov w9, #40
    dup v8.16b, w9           //40
    
    mov x9, #1
    lsl x9, x9, #8
    sub x9, x9, #1
    dup v31.16b, w9      //max_val
    mov x9, #0
    dup v16.16b, w9      //0

    lsl x5, x5, #1      //i_dst_tmp
        
    ldr x9, [x2], #8    //d0
    ldr x10, [x2], #8   //d1
    ldr x11, [x2]       //d2
    ldr x12, [x4], #8   //dt0
    ldr x13, [x4], #8   //dt1
    ldr x14, [x4]       //dt2

com_if_filter_hor_8_y:
    sub x15, x0, #3     // x-3
    mov x16, x6         //i
    mov x19, x9
    mov x20, x10
    mov x21, x11
    mov x22, x12
    mov x23, x13
    mov x24, x14

com_if_filter_hor_8_x:
    ld1 {v20.8b}, [x15], #8
    ld1 {v21.8b}, [x15]      // src[x-3]

    ext v22.8b, v20.8b, v21.8b, #1
    ext v23.8b, v20.8b, v21.8b, #2
    ext v24.8b, v20.8b, v21.8b, #3
    ext v25.8b, v20.8b, v21.8b, #4
    ext v26.8b, v20.8b, v21.8b, #5
    ext v27.8b, v20.8b, v21.8b, #6
    ext v28.8b, v20.8b, v21.8b, #7

    umull  v17.8h, v22.8b, v1.8b
    umlsl  v17.8h, v20.8b, v0.8b
    umlsl  v17.8h, v23.8b, v2.8b
    umlal  v17.8h, v24.8b, v3.8b
    umlal  v17.8h, v25.8b, v4.8b
    umlsl  v17.8h, v26.8b, v5.8b
    umlal  v17.8h, v27.8b, v6.8b
    umlsl  v17.8h, v28.8b, v0.8b

    //(t1 + 32) >> 6
    sqrshrun  v30.8b, v17.8h, #6        //d0

    umin v30.8b, v30.8b, v31.8b
    st1 {v17.8h}, [x22], #16
    st1 {v30.8b}, [x19], #8

    umull  v17.8h, v22.8b, v1.8b
    umlsl  v17.8h, v20.8b, v0.8b
    umlsl  v17.8h, v23.8b, v7.8b
    umlal  v17.8h, v24.8b, v8.8b
    umlal  v17.8h, v25.8b, v8.8b
    umlsl  v17.8h, v26.8b, v7.8b
    umlal  v17.8h, v27.8b, v1.8b
    umlsl  v17.8h, v28.8b, v0.8b

    //(t1 + 32) >> 6
    sqrshrun  v30.8b, v17.8h, #6        //d1

    umin v30.8b, v30.8b, v31.8b
    st1 {v17.8h}, [x23], #16
    st1 {v30.8b}, [x20], #8

    umull  v17.8h, v22.8b, v6.8b
    umlsl  v17.8h, v20.8b, v0.8b
    umlsl  v17.8h, v23.8b, v5.8b
    umlal  v17.8h, v24.8b, v4.8b
    umlal  v17.8h, v25.8b, v3.8b
    umlsl  v17.8h, v26.8b, v2.8b
    umlal  v17.8h, v27.8b, v1.8b
    umlsl  v17.8h, v28.8b, v0.8b

    //(t1 + 32) >> 6
    sqrshrun  v30.8b, v17.8h, #6        //d1
    
    umin v30.8b, v30.8b, v31.8b
    st1 {v17.8h}, [x24], #16
    st1 {v30.8b}, [x21], #8

    subs w16, w16, #8
    bgt com_if_filter_hor_8_x
    add x9, x9, x3
    add x10, x10, x3
    add x11, x11, x3
    add x12, x12, x5
    add x13, x13, x5
    add x14, x14, x5
    add x0, x0, x1
    subs w7, w7, #1
    bgt com_if_filter_hor_8_y

    ld1 {v8.8h - v11.8h}, [sp], #64
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16

    ret

//void com_if_filter_ver_8_arm64(const pel_t *src, int i_src, pel_t *dst[3], int i_dst, int width, int height, tab_char_t (coeff)[8], int bit_depth);
//src->x0, i_src->x1, dst[3]->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_ver_8_arm64
    ld1 {v31.d}[0], [x6]
    abs  v31.8b, v31.8b
    dup v0.16b, v31.b[0]     //1
    dup v1.16b, v31.b[1]     //4
    dup v2.16b, v31.b[2]     //10
    dup v3.16b, v31.b[3]     //57
    dup v4.16b, v31.b[4]     //19
    dup v5.16b, v31.b[5]     //7
    dup v6.16b, v31.b[6]     //3
    mov w9, #11
    dup v7.16b, w9           //11
    mov w9, #40
    dup v24.16b, w9          //40

    ldr x7, [x2], #8        //d0
    ldr x8, [x2], #8        //d1
    ldr x9, [x2]            //d2

if_ver_luma_w8_loop_y:
    mov x10, x4             //i
    sub x11, x0, x1, lsl #1
    sub x11, x11, x1                   // src - 3*i_src
    mov x13, x7
    mov x14, x8
    mov x15, x9

if_ver_luma_w8_loop_x:
    mov x12, x11
    ld1 {v16.8b}, [x12], x1            // x-3*i_src
    ld1 {v17.8b}, [x12], x1            // x-2*i_src
    ld1 {v18.8b}, [x12], x1            // x-i_src
    ld1 {v19.8b}, [x12], x1            // x
    ld1 {v20.8b}, [x12], x1            // x+i_src
    ld1 {v21.8b}, [x12], x1            // x+2*i_src
    ld1 {v22.8b}, [x12], x1            // x+3*i_src
    ld1 {v23.8b}, [x12], x1            // x+4*i_src

    umull  v30.8h, v17.8b, v1.8b
    umlsl  v30.8h, v16.8b, v0.8b
    umlsl  v30.8h, v18.8b, v2.8b
    umlal  v30.8h, v19.8b, v3.8b
    umlal  v30.8h, v20.8b, v4.8b
    umlsl  v30.8h, v21.8b, v5.8b
    umlal  v30.8h, v22.8b, v6.8b
    umlsl  v30.8h, v23.8b, v0.8b

    sqrshrun  v29.8b, v30.8h, #6
    st1 {v29.8b}, [x13], #8      //d0

    umull  v30.8h, v17.8b, v1.8b
    umlsl  v30.8h, v16.8b, v0.8b
    umlsl  v30.8h, v18.8b, v7.8b
    umlal  v30.8h, v19.8b, v24.8b
    umlal  v30.8h, v20.8b, v24.8b
    umlsl  v30.8h, v21.8b, v7.8b
    umlal  v30.8h, v22.8b, v1.8b
    umlsl  v30.8h, v23.8b, v0.8b

    sqrshrun  v29.8b, v30.8h, #6
    st1 {v29.8b}, [x14], #8      //d1
    
    umull  v30.8h, v17.8b, v6.8b
    umlsl  v30.8h, v16.8b, v0.8b
    umlsl  v30.8h, v18.8b, v5.8b
    umlal  v30.8h, v19.8b, v4.8b
    umlal  v30.8h, v20.8b, v3.8b
    umlsl  v30.8h, v21.8b, v2.8b
    umlal  v30.8h, v22.8b, v1.8b
    umlsl  v30.8h, v23.8b, v0.8b
    
    sqrshrun  v29.8b, v30.8h, #6
    st1 {v29.8b}, [x15], #8      //d2
    
    add x11, x11, #8
    subs w10, w10, #8
    bgt if_ver_luma_w8_loop_x
    add x0, x0, x1
    add x7, x7, x3
    add x8, x8, x3
    add x9, x9, x3
    subs w5, w5, #1
    bgt if_ver_luma_w8_loop_y

    ret

//void com_if_filter_ver_8_ext_arm64(const pel_t *src, int i_src, pel_t *dst[3], int i_dst, int width, int height, tab_char_t (coeff)[8], int bit_depth);
//src->x0, i_src->x1, dst[3]->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_ver_8_ext_arm64
    lsl x1, x1, #1

    mov x7, #1
    lsl x7, x7, #10
    sub x7, x7, #1
    dup v25.8h, w7      //max_val
    mov x7, #0
    dup v26.8h, w7      //0

    ld1 {v31.d}[0], [x6]
    abs  v31.8b, v31.8b
    uxtl v31.8h, v31.8b
    dup v0.8h, v31.h[0]     //1
    dup v1.8h, v31.h[1]     //4
    dup v2.8h, v31.h[2]     //10
    dup v3.8h, v31.h[3]     //57
    dup v4.8h, v31.h[4]     //19
    dup v5.8h, v31.h[5]     //7
    dup v6.8h, v31.h[6]     //3
    mov w9, #11
    dup v7.8h, w9           //11
    mov w9, #40
    dup v24.8h, w9          //40

    ldr x7, [x2], #8        //d0
    ldr x8, [x2], #8        //d1
    ldr x9, [x2]            //d2

if_ver_luma_w8_loop_ext_y:
    mov x10, x4             //i
    sub x11, x0, x1, lsl #1
    sub x11, x11, x1                   // src - 3*i_src
    mov x13, x7
    mov x14, x8
    mov x15, x9

if_ver_luma_w8_loop_ext_x:
    mov x12, x11
    ld1 {v16.8h}, [x12], x1            // x-3*i_src
    ld1 {v17.8h}, [x12], x1            // x-2*i_src
    ld1 {v18.8h}, [x12], x1            // x-i_src
    ld1 {v19.8h}, [x12], x1            // x
    ld1 {v20.8h}, [x12], x1            // x+i_src
    ld1 {v21.8h}, [x12], x1            // x+2*i_src
    ld1 {v22.8h}, [x12], x1            // x+3*i_src
    ld1 {v23.8h}, [x12], x1            // x+4*i_src

    smull  v30.4s, v17.4h, v1.4h
    smull2 v31.4s, v17.8h, v1.8h
    smlsl  v30.4s, v16.4h, v0.4h
    smlsl2 v31.4s, v16.8h, v0.8h
    smlsl  v30.4s, v18.4h, v2.4h
    smlsl2 v31.4s, v18.8h, v2.8h
    smlal  v30.4s, v19.4h, v3.4h
    smlal2 v31.4s, v19.8h, v3.8h
    smlal  v30.4s, v20.4h, v4.4h
    smlal2 v31.4s, v20.8h, v4.8h
    smlsl  v30.4s, v21.4h, v5.4h
    smlsl2 v31.4s, v21.8h, v5.8h
    smlal  v30.4s, v22.4h, v6.4h
    smlal2 v31.4s, v22.8h, v6.8h
    smlsl  v30.4s, v23.4h, v0.4h
    smlsl2 v31.4s, v23.8h, v0.8h

    sqrshrun  v29.4h, v30.4s, #12
    sqrshrun2 v29.8h, v31.4s, #12
    sqxtun v29.8b, v29.8h

    st1 {v29.8b}, [x13], #8      //d0

    smull  v30.4s, v17.4h, v1.4h
    smull2 v31.4s, v17.8h, v1.8h
    smlsl  v30.4s, v16.4h, v0.4h
    smlsl2 v31.4s, v16.8h, v0.8h
    smlsl  v30.4s, v18.4h, v7.4h
    smlsl2 v31.4s, v18.8h, v7.8h
    smlal  v30.4s, v19.4h, v24.4h
    smlal2 v31.4s, v19.8h, v24.8h
    smlal  v30.4s, v20.4h, v24.4h
    smlal2 v31.4s, v20.8h, v24.8h
    smlsl  v30.4s, v21.4h, v7.4h
    smlsl2 v31.4s, v21.8h, v7.8h
    smlal  v30.4s, v22.4h, v1.4h
    smlal2 v31.4s, v22.8h, v1.8h
    smlsl  v30.4s, v23.4h, v0.4h
    smlsl2 v31.4s, v23.8h, v0.8h

    sqrshrun  v29.4h, v30.4s, #12
    sqrshrun2 v29.8h, v31.4s, #12
    sqxtun v29.8b, v29.8h
    st1 {v29.8b}, [x14], #8      //d1
    
    smull  v30.4s, v17.4h, v6.4h
    smull2 v31.4s, v17.8h, v6.8h
    smlsl  v30.4s, v16.4h, v0.4h
    smlsl2 v31.4s, v16.8h, v0.8h
    smlsl  v30.4s, v18.4h, v5.4h
    smlsl2 v31.4s, v18.8h, v5.8h
    smlal  v30.4s, v19.4h, v4.4h
    smlal2 v31.4s, v19.8h, v4.8h
    smlal  v30.4s, v20.4h, v3.4h
    smlal2 v31.4s, v20.8h, v3.8h
    smlsl  v30.4s, v21.4h, v2.4h
    smlsl2 v31.4s, v21.8h, v2.8h
    smlal  v30.4s, v22.4h, v1.4h
    smlal2 v31.4s, v22.8h, v1.8h
    smlsl  v30.4s, v23.4h, v0.4h
    smlsl2 v31.4s, v23.8h, v0.8h
    
    sqrshrun  v29.4h, v30.4s, #12
    sqrshrun2 v29.8h, v31.4s, #12
    sqxtun v29.8b, v29.8h
    st1 {v29.8b}, [x15], #8      //d2
    
    add x11, x11, #16
    subs w10, w10, #8
    bgt if_ver_luma_w8_loop_ext_x
    add x0, x0, x1
    add x7, x7, x3
    add x8, x8, x3
    add x9, x9, x3
    subs w5, w5, #1
    bgt if_ver_luma_w8_loop_ext_y

    ret

//void com_if_filter_hor_4_w4_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_hor_4_w4_arm64
    mov x8, #1
    lsl x7, x8, X7
    sub x7, x7, #1  //max_pixel

    ld1 {v4.s}[0], [x6]
    abs  v3.8b, v4.8b
    dup v0.16b, v3.b[0]
    dup v1.16b, v3.b[1]
    dup v2.16b, v3.b[2]
    dup v3.16b, v3.b[3]

    sub x0, x0, #1                      // src - 1
    dup v31.8b, w7                      // max_val

if_hor_chroma_w4_loop_y:
    ld1 {v20.8b}, [x0], x1      // src[x-1]
    ld1 {v21.8b}, [x0], x1

    ext v17.16b, v20.16b, v20.16b, #1   // src[x]
    ext v18.16b, v20.16b, v20.16b, #2   // src[x+1]
    ext v19.16b, v20.16b, v20.16b, #3   // src[x+2]
    ext v24.16b, v21.16b, v21.16b, #1   // src[x]
    ext v25.16b, v21.16b, v21.16b, #2   // src[x+1]
    ext v26.16b, v21.16b, v21.16b, #3   // src[x+2]

    umull  v4.8h, v17.8b, v1.8b
    umlsl  v4.8h, v20.8b, v0.8b
    umlal  v4.8h, v18.8b, v2.8b
    umlsl  v4.8h, v19.8b, v3.8b

    umull  v5.8h, v24.8b, v1.8b
    umlsl  v5.8h, v21.8b, v0.8b
    umlal  v5.8h, v25.8b, v2.8b
    umlsl  v5.8h, v26.8b, v3.8b

    sqrshrun v4.8b, v4.8h, #6       // saturate s16 -> u8
    sqrshrun v5.8b, v5.8h, #6

    umin v4.8b, v4.8b, v31.8b
    umin v5.8b, v5.8b, v31.8b

    subs w5, w5, #2
    st1 {v4.s}[0], [x2], x3
    st1 {v5.s}[0], [x2], x3
    bgt if_hor_chroma_w4_loop_y

    ret

//void com_if_filter_hor_4_w8_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_hor_4_w8_arm64
    mov x8, #1
    lsl x7, x8, X7
    sub x7, x7, #1  //max_pixel

    ld1 {v4.s}[0], [x6]
    abs  v3.8b, v4.8b
    dup v0.16b, v3.b[0]
    dup v1.16b, v3.b[1]
    dup v2.16b, v3.b[2]
    dup v3.16b, v3.b[3]

    sub x0, x0, #1                      // src - 1
    dup v31.8b, w7                      // max_val

if_hor_chroma_w8_loop_y:
    ld1 {v20.16b}, [x0], x1      // src[x-1]
    ld1 {v21.16b}, [x0], x1
    ext v17.16b, v20.16b, v20.16b, #1   // src[x]
    ext v18.16b, v20.16b, v20.16b, #2   // src[x+1]
    ext v19.16b, v20.16b, v20.16b, #3   // src[x+2]
    ext v24.16b, v21.16b, v21.16b, #1   // src[x]
    ext v25.16b, v21.16b, v21.16b, #2   // src[x+1]
    ext v26.16b, v21.16b, v21.16b, #3   // src[x+2]

    umull  v4.8h, v17.8b, v1.8b
    umlsl  v4.8h, v20.8b, v0.8b
    umlal  v4.8h, v18.8b, v2.8b
    umlsl  v4.8h, v19.8b, v3.8b

    umull  v5.8h, v24.8b, v1.8b
    umlsl  v5.8h, v21.8b, v0.8b
    umlal  v5.8h, v25.8b, v2.8b
    umlsl  v5.8h, v26.8b, v3.8b

    sqrshrun v4.8b, v4.8h, #6       // saturate s16 -> u8
    sqrshrun v5.8b, v5.8h, #6
    
    umin v4.8b, v4.8b, v31.8b
    umin v5.8b, v5.8b, v31.8b

    subs w5, w5, #2
    st1 {v4.8b}, [x2], x3
    st1 {v5.8b}, [x2], x3
    bgt if_hor_chroma_w8_loop_y

    ret


//void com_if_filter_hor_4_w16_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_hor_4_w16_arm64
    mov x8, #1
    lsl x7, x8, X7
    sub x7, x7, #1  //max_pixel

    ld1 {v4.s}[0], [x6]
    abs v3.8b, v4.8b
    dup v0.16b, v3.b[0]
    dup v1.16b, v3.b[1]
    dup v2.16b, v3.b[2]
    dup v3.16b, v3.b[3]

    sub x0, x0, #1                       // src - 1
    dup v31.16b, w7                      // max_val
if_hor_chroma_w16_loop_y:
    ld1 {v20.16b, v21.16b}, [x0], x1     // src[x-1]
    ld1 {v22.16b, v23.16b}, [x0], x1

    ext v17.16b, v20.16b, v21.16b, #1   // src[x]
    ext v18.16b, v20.16b, v21.16b, #2   // src[x+1]
    ext v19.16b, v20.16b, v21.16b, #3   // src[x+2]
    ext v24.16b, v22.16b, v23.16b, #1   // src[x]
    ext v25.16b, v22.16b, v23.16b, #2   // src[x+1]
    ext v26.16b, v22.16b, v23.16b, #3   // src[x+2]

    umull  v27.8h, v17.8b, v1.8b
    umull2 v28.8h, v17.16b, v1.16b
    umull  v29.8h, v24.8b, v1.8b
    umull2 v30.8h, v24.16b, v1.16b
    umlsl  v27.8h, v20.8b, v0.8b
    umlsl2 v28.8h, v20.16b, v0.16b
    umlsl  v29.8h, v22.8b, v0.8b
    umlsl2 v30.8h, v22.16b, v0.16b
    umlal  v27.8h, v18.8b, v2.8b
    umlal2 v28.8h, v18.16b, v2.16b
    umlal  v29.8h, v25.8b, v2.8b
    umlal2 v30.8h, v25.16b, v2.16b
    umlsl  v27.8h, v19.8b, v3.8b
    umlsl2 v28.8h, v19.16b, v3.16b
    umlsl  v29.8h, v26.8b, v3.8b
    umlsl2 v30.8h, v26.16b, v3.16b

    sqrshrun v27.8b, v27.8h, #6           // saturate s32 -> u16
    sqrshrun v28.8b, v28.8h, #6
    sqrshrun v29.8b, v29.8h, #6
    sqrshrun v30.8b, v30.8h, #6

    umin v27.8b, v27.8b, v31.8b
    umin v28.8b, v28.8b, v31.8b
    umin v29.8b, v29.8b, v31.8b
    umin v30.8b, v30.8b, v31.8b

    subs w5, w5, #2
    st1 {v27.8b, v28.8b}, [x2], x3
    st1 {v29.8b, v30.8b}, [x2], x3
    bgt if_hor_chroma_w16_loop_y

    ret

//void com_if_filter_ver_4_w4_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_ver_4_w4_arm64
    mov x7, #1
    lsl x7, x7, #10
    sub x7, x7, #1
    
    // load coeff
    ld1 {v4.s}[0], [x6]
    abs  v3.8b, v4.8b
    dup v0.16b, v3.b[0]
    dup v1.16b, v3.b[1]
    dup v2.16b, v3.b[2]
    dup v3.16b, v3.b[3]
    
    sub x0, x0, x1                  // src - i_src
    dup v30.8b, w7
    if_ver_chroma_w4_loop_y:
    ld1 {v16.s}[0], [x0], x1         // src-i_src
    ld1 {v17.s}[0], [x0], x1         // src
    ld1 {v18.s}[0], [x0], x1         // src+i_src
    ld1 {v19.s}[0], [x0], x1         // src+2*i_src
    mov x10, x0
    ld1 {v20.s}[0], [x0], x1
    ld1 {v21.s}[0], [x0], x1
    ld1 {v31.s}[0], [x0]
    
    umull  v22.8h, v17.8b, v1.8b
    umull  v23.8h, v18.8b, v1.8b
    umlsl  v22.8h, v16.8b, v0.8b
    umlsl  v23.8h, v17.8b, v0.8b
    umlal  v22.8h, v18.8b, v2.8b
    umlal  v23.8h, v19.8b, v2.8b
    umlsl  v22.8h, v19.8b, v3.8b
    umlsl  v23.8h, v20.8b, v3.8b
    
    umull  v24.8h, v19.8b, v1.8b
    umull  v25.8h, v20.8b, v1.8b
    umlsl  v24.8h, v18.8b, v0.8b
    umlsl  v25.8h, v19.8b, v0.8b
    umlal  v24.8h, v20.8b, v2.8b
    umlal  v25.8h, v21.8b, v2.8b
    umlsl  v24.8h, v21.8b, v3.8b
    umlsl  v25.8h, v31.8b, v3.8b
    
    //(sum + 32) >> 6
    sqrshrun  v22.8b, v22.8h, #6
    sqrshrun  v23.8b, v23.8h, #6
    sqrshrun  v24.8b, v24.8h, #6
    sqrshrun  v25.8b, v25.8h, #6
    
    umin v22.8b, v22.8b, v30.8b
    umin v23.8b, v23.8b, v30.8b
    umin v24.8b, v24.8b, v30.8b
    umin v25.8b, v25.8b, v30.8b
    
    st1 {v22.s}[0], [x2], x3
    subs w5, w5, #4
    mov x0, x10
    st1 {v23.s}[0], [x2], x3
    st1 {v24.s}[0], [x2], x3
    st1 {v25.s}[0], [x2], x3
    
    bgt if_ver_chroma_w4_loop_y
    
    ret


//void com_if_filter_ver_4_w8_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_ver_4_w8_arm64
    mov x7, #1
    lsl x7, x7, #10
    sub x7, x7, #1
    
    // load coeff
    ld1 {v4.s}[0], [x6]
    abs  v3.8b, v4.8b
    dup v0.8b, v3.b[0]
    dup v1.8b, v3.b[1]
    dup v2.8b, v3.b[2]
    dup v3.8b, v3.b[3]
    
    sub x0, x0, x1                  // src - i_src
    dup v30.8b, w7
    if_ver_chroma_w8_loop_y:
    ld1 {v16.d}[0], [x0], x1         // src-i_src
    ld1 {v17.d}[0], [x0], x1         // src
    ld1 {v18.d}[0], [x0], x1         // src+i_src
    ld1 {v19.d}[0], [x0], x1         // src+2*i_src
    mov x10, x0
    ld1 {v20.d}[0], [x0], x1
    ld1 {v21.d}[0], [x0], x1
    ld1 {v31.d}[0], [x0]
    
    umull  v22.8h, v17.8b, v1.8b
    umull  v24.8h, v18.8b, v1.8b
    umlsl  v22.8h, v16.8b, v0.8b
    umlsl  v24.8h, v17.8b, v0.8b
    umlal  v22.8h, v18.8b, v2.8b
    umlal  v24.8h, v19.8b, v2.8b
    umlsl  v22.8h, v19.8b, v3.8b
    umlsl  v24.8h, v20.8b, v3.8b
    
    umull  v26.8h, v19.8b, v1.8b
    umull  v28.8h, v20.8b, v1.8b
    umlsl  v26.8h, v18.8b, v0.8b
    umlsl  v28.8h, v19.8b, v0.8b
    umlal  v26.8h, v20.8b, v2.8b
    umlal  v28.8h, v21.8b, v2.8b
    umlsl  v26.8h, v21.8b, v3.8b
    umlsl  v28.8h, v31.8b, v3.8b
    
    //(sum + 32) >> 6
    sqrshrun  v22.8b, v22.8h, #6
    sqrshrun  v23.8b, v24.8h, #6
    sqrshrun  v24.8b, v26.8h, #6
    sqrshrun  v25.8b, v28.8h, #6
    
    umin v22.8b, v22.8b, v30.8b
    umin v23.8b, v23.8b, v30.8b
    umin v24.8b, v24.8b, v30.8b
    umin v25.8b, v25.8b, v30.8b
    
    st1 {v22.8b}, [x2], x3
    subs w5, w5, #4
    mov x0, x10
    st1 {v23.8b}, [x2], x3
    st1 {v24.8b}, [x2], x3
    st1 {v25.8b}, [x2], x3
    
    bgt if_ver_chroma_w8_loop_y
    
    ret

//void com_if_filter_ver_4_w16_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int max_val);
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff->x6, max_val->x7
function com_if_filter_ver_4_w16_arm64
    mov x7, #1
    lsl x7, x7, #10
    sub x7, x7, #1
    
    // load coeff
    ld1 {v4.s}[0], [x6]
    abs  v3.8b, v4.8b
    dup v0.16b, v3.b[0]
    dup v1.16b, v3.b[1]
    dup v2.16b, v3.b[2]
    dup v3.16b, v3.b[3]

    sub x0, x0, x1
    dup v6.8b, w7
if_ver_chroma_w16_loop_y:
    ld1 {v16.16b}, [x0], x1        // src + x - i_src
    ld1 {v17.16b}, [x0], x1        // src + x
    ld1 {v18.16b}, [x0], x1        // src + x + i_src
    ld1 {v19.16b}, [x0], x1        // src + x + 2*i_src
    mov x10, x0
    ld1 {v20.16b}, [x0], x1
    ld1 {v21.16b}, [x0], x1
    ld1 {v31.16b}, [x0]

    umull  v22.8h, v17.8b, v1.8b
    umull2 v23.8h, v17.16b, v1.16b
    umull  v24.8h, v18.8b, v1.8b
    umull2 v25.8h, v18.16b, v1.16b
    umlsl  v22.8h, v16.8b, v0.8b
    umlsl2 v23.8h, v16.16b, v0.16b
    umlsl  v24.8h, v17.8b, v0.8b
    umlsl2 v25.8h, v17.16b, v0.16b
    umlal  v22.8h, v18.8b, v2.8b
    umlal2 v23.8h, v18.16b, v2.16b
    umlal  v24.8h, v19.8b, v2.8b
    umlal2 v25.8h, v19.16b, v2.16b
    umlsl  v22.8h, v19.8b, v3.8b
    umlsl2 v23.8h, v19.16b, v3.16b
    umlsl  v24.8h, v20.8b, v3.8b
    umlsl2 v25.8h, v20.16b, v3.16b

    umull  v26.8h, v19.8b, v1.8b
    umull2 v27.8h, v19.16b, v1.16b
    umull  v28.8h, v20.8b, v1.8b
    umull2 v29.8h, v20.16b, v1.16b
    umlsl  v26.8h, v18.8b, v0.8b
    umlsl2 v27.8h, v18.16b, v0.16b
    umlsl  v28.8h, v19.8b, v0.8b
    umlsl2 v29.8h, v19.16b, v0.16b
    umlal  v26.8h, v20.8b, v2.8b
    umlal2 v27.8h, v20.16b, v2.16b
    umlal  v28.8h, v21.8b, v2.8b
    umlal2 v29.8h, v21.16b, v2.16b
    umlsl  v26.8h, v21.8b, v3.8b
    umlsl2 v27.8h, v21.16b, v3.16b
    umlsl  v28.8h, v31.8b, v3.8b
    umlsl2 v29.8h, v31.16b, v3.16b

    //(sum + 32) >> 6
    sqrshrun v22.8b, v22.8h, #6
    sqrshrun v23.8b, v23.8h, #6
    sqrshrun v24.8b, v24.8h, #6
    sqrshrun v25.8b, v25.8h, #6
    sqrshrun v26.8b, v26.8h, #6
    sqrshrun v27.8b, v27.8h, #6
    sqrshrun v28.8b, v28.8h, #6
    sqrshrun v29.8b, v29.8h, #6

    umin v22.8b, v22.8b, v6.8b
    umin v23.8b, v23.8b, v6.8b
    umin v24.8b, v24.8b, v6.8b
    umin v25.8b, v25.8b, v6.8b
    umin v26.8b, v26.8b, v6.8b
    umin v27.8b, v27.8b, v6.8b
    umin v28.8b, v28.8b, v6.8b
    umin v29.8b, v29.8b, v6.8b

    subs w5, w5, #4
    mov x0, x10
    st1 {v22.8b, v23.8b}, [x2], x3
    st1 {v24.8b, v25.8b}, [x2], x3
    st1 {v26.8b, v27.8b}, [x2], x3
    st1 {v28.8b, v29.8b}, [x2], x3
    bgt if_ver_chroma_w16_loop_y

    ret

//void com_if_filter_hor_ver_4_w8_arm64(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8 *coeff_v, int bit_depth)
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff_h->x6, coeff_v->x7
function com_if_filter_hor_ver_4_w8_arm64
//--------------------------------
// HOR first 3 rows
//--------------------------------
    sub x0, x0, x1                      // src -= i_src
    ld1 {v4.s}[0], [x6]
    abs v3.8b, v4.8b
    dup v0.16b, v3.b[0]
    dup v1.16b, v3.b[1]
    dup v2.16b, v3.b[2]
    dup v3.16b, v3.b[3]
    sub x0, x0, #1                      // x - 1

    //the first three rows
    ld1 {v4.8b, v5.8b}, [x0], x1        // src[x-1]
    ld1 {v6.8b, v7.8b}, [x0], x1
    ld1 {v20.8b, v21.8b}, [x0], x1

    ext v22.8b, v4.8b, v5.8b, #1        // src[x]
    ext v23.8b, v4.8b, v5.8b, #2        // src[x+1]
    ext v24.8b, v4.8b, v5.8b, #3        // src[x+2]

    ext v25.8b, v6.8b, v7.8b, #1        // src[x]
    ext v26.8b, v6.8b, v7.8b, #2        // src[x+1]
    ext v27.8b, v6.8b, v7.8b, #3        // src[x+2]

    ext v28.8b, v20.8b, v21.8b, #1      // src[x]
    ext v29.8b, v20.8b, v21.8b, #2      // src[x+1]
    ext v30.8b, v20.8b, v21.8b, #3      // src[x+2]

    umull v16.8h, v22.8b, v1.8b
    umull v17.8h, v25.8b, v1.8b
    umull v18.8h, v28.8b, v1.8b
    umlsl v16.8h, v4.8b, v0.8b
    umlsl v17.8h, v6.8b, v0.8b
    umlsl v18.8h, v20.8b, v0.8b
    umlal v16.8h, v23.8b, v2.8b
    umlal v17.8h, v26.8b, v2.8b
    umlal v18.8h, v29.8b, v2.8b
    umlsl v16.8h, v24.8b, v3.8b
    umlsl v17.8h, v27.8b, v3.8b
    umlsl v18.8h, v30.8b, v3.8b

    ld1 {v7.s}[0], [x7]                 // load coeff
    sxtl v7.8h, v7.8b                   // 8bit to 16bit

if_hor_ver_chroma_w8_loop_y:
    ld1 {v24.8b, v25.8b}, [x0], x1      // src[x-1]
    ld1 {v26.8b, v27.8b}, [x0], x1      //
    ld1 {v28.8b, v29.8b}, [x0], x1
    ld1 {v30.8b, v31.8b}, [x0], x1

    ext v4.8b, v24.8b, v25.8b, #1       // src[x]
    ext v5.8b, v24.8b, v25.8b, #2       // src[x+1]
    ext v6.8b, v24.8b, v25.8b, #3       // src[x+2]

    ext v23.8b, v26.8b, v27.8b, #1      // src[x]
    ext v25.8b, v26.8b, v27.8b, #2      // src[x+1]
    ext v27.8b, v26.8b, v27.8b, #3      // src[x+2]

    umull v19.8h, v4.8b , v1.8b
    umull v20.8h, v23.8b, v1.8b
    umlsl v19.8h, v24.8b, v0.8b
    umlsl v20.8h, v26.8b, v0.8b
    umlal v19.8h, v5.8b , v2.8b
    umlal v20.8h, v25.8b, v2.8b
    umlsl v19.8h, v6.8b , v3.8b
    umlsl v20.8h, v27.8b, v3.8b

    ext v4.8b, v28.8b, v29.8b, #1       // src[x]
    ext v5.8b, v28.8b, v29.8b, #2       // src[x+1]
    ext v6.8b, v28.8b, v29.8b, #3       // src[x+2]

    ext v23.8b, v30.8b, v31.8b, #1      // src[x]
    ext v25.8b, v30.8b, v31.8b, #2      // src[x+1]
    ext v27.8b, v30.8b, v31.8b, #3      // src[x+2]

    umull v21.8h, v4.8b , v1.8b
    umull v22.8h, v23.8b, v1.8b
    umlsl v21.8h, v28.8b, v0.8b
    umlsl v22.8h, v30.8b, v0.8b
    umlal v21.8h, v5.8b , v2.8b
    umlal v22.8h, v25.8b, v2.8b
    umlsl v21.8h, v6.8b , v3.8b
    umlsl v22.8h, v27.8b, v3.8b

    smull  v24.4s, v16.4h, v7.h[0]
    smull2 v25.4s, v16.8h, v7.h[0]
    smull  v26.4s, v17.4h, v7.h[0]
    smull2 v27.4s, v17.8h, v7.h[0]
    smlal  v24.4s, v17.4h, v7.h[1]
    smlal2 v25.4s, v17.8h, v7.h[1]
    smlal  v26.4s, v18.4h, v7.h[1]
    smlal2 v27.4s, v18.8h, v7.h[1]
    smlal  v24.4s, v18.4h, v7.h[2]
    smlal2 v25.4s, v18.8h, v7.h[2]
    smlal  v26.4s, v19.4h, v7.h[2]
    smlal2 v27.4s, v19.8h, v7.h[2]
    smlal  v24.4s, v19.4h, v7.h[3]
    smlal2 v25.4s, v19.8h, v7.h[3]
    smlal  v26.4s, v20.4h, v7.h[3]
    smlal2 v27.4s, v20.8h, v7.h[3]

    smull  v28.4s, v18.4h, v7.h[0]
    smull2 v29.4s, v18.8h, v7.h[0]
    smull  v30.4s, v19.4h, v7.h[0]
    smull2 v31.4s, v19.8h, v7.h[0]
    smlal  v28.4s, v19.4h, v7.h[1]
    smlal2 v29.4s, v19.8h, v7.h[1]
    smlal  v30.4s, v20.4h, v7.h[1]
    smlal2 v31.4s, v20.8h, v7.h[1]
    smlal  v28.4s, v20.4h, v7.h[2]
    smlal2 v29.4s, v20.8h, v7.h[2]
    smlal  v30.4s, v21.4h, v7.h[2]
    smlal2 v31.4s, v21.8h, v7.h[2]
    smlal  v28.4s, v21.4h, v7.h[3]
    smlal2 v29.4s, v21.8h, v7.h[3]
    smlal  v30.4s, v22.4h, v7.h[3]
    smlal2 v31.4s, v22.8h, v7.h[3]

    mov v16.16b, v20.16b
    mov v17.16b, v21.16b
    mov v18.16b, v22.16b

    rshrn  v24.4h, v24.4s, #12
    rshrn2 v24.8h, v25.4s, #12
    rshrn  v25.4h, v26.4s, #12
    rshrn2 v25.8h, v27.4s, #12
    rshrn  v26.4h, v28.4s, #12
    rshrn2 v26.8h, v29.4s, #12
    rshrn  v27.4h, v30.4s, #12
    rshrn2 v27.8h, v31.4s, #12

    sqxtun v24.8b, v24.8h               // 16bit to 8bit
    sqxtun v25.8b, v25.8h
    sqxtun v26.8b, v26.8h               // 16bit to 8bit
    sqxtun v27.8b, v27.8h

    subs w5, w5, #4
    st1 {v24.8b}, [x2], x3
    st1 {v25.8b}, [x2], x3
    st1 {v26.8b}, [x2], x3
    st1 {v27.8b}, [x2], x3
    bgt if_hor_ver_chroma_w8_loop_y

    ret
    
//void com_if_filter_hor_Ver_4_w16_arm64(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8n 0- *coeff_v, int bit_depth)
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff_h->x6, coeff_v->x7
function com_if_filter_hor_Ver_4_w16_arm64
    
    // align (x17)
    // x17-->tmp
    ldr x15, =2176
    sub x17, sp, x15                        // (64 + 4)*16*sizeof(short)
    sub x0, x0, x1                          // src += -1 * i_src;
    mov sp, x17
    
    //--------------------------------
    // HOR
    //--------------------------------
    ld1 {v4.s}[0], [x6]
    abs v3.8b, v4.8b
    dup v0.16b, v3.b[0]
    dup v1.16b, v3.b[1]
    dup v2.16b, v3.b[2]
    dup v3.16b, v3.b[3]
    sub x0, x0, #1                          // x - 1
    
    //the first three rows
    ld1 {v16.16b, v17.16b}, [x0], x1       // src[x-1]
    ld1 {v18.16b, v19.16b}, [x0], x1
    ld1 {v20.16b, v21.16b}, [x0], x1
    
    ext v22.16b, v16.16b, v17.16b, #1       // src[x]
    ext v23.16b, v16.16b, v17.16b, #2       // src[x+1]
    ext v24.16b, v16.16b, v17.16b, #3       // src[x+2]
    
    ext v25.16b, v18.16b, v19.16b, #1
    ext v26.16b, v18.16b, v19.16b, #2
    ext v27.16b, v18.16b, v19.16b, #3
    
    ext v28.16b, v20.16b, v21.16b, #1
    ext v29.16b, v20.16b, v21.16b, #2
    ext v30.16b, v20.16b, v21.16b, #3
    
    umull  v4.8h, v22.8b, v1.8b
    umull2 v5.8h, v22.16b, v1.16b
    umlsl  v4.8h, v16.8b, v0.8b
    umlsl2 v5.8h, v16.16b, v0.16b
    umlal  v4.8h, v23.8b, v2.8b
    umlal2 v5.8h, v23.16b, v2.16b
    umlsl  v4.8h, v24.8b, v3.8b
    umlsl2 v5.8h, v24.16b, v3.16b
    
    umull  v6.8h, v25.8b, v1.8b
    umull2 v7.8h, v25.16b, v1.16b
    umlsl  v6.8h, v18.8b, v0.8b
    umlsl2 v7.8h, v18.16b, v0.16b
    umlal  v6.8h, v26.8b, v2.8b
    umlal2 v7.8h, v26.16b, v2.16b
    umlsl  v6.8h, v27.8b, v3.8b
    umlsl2 v7.8h, v27.16b, v3.16b
    
    umull  v16.8h, v28.8b, v1.8b
    umull2 v17.8h, v28.16b, v1.16b
    umlsl  v16.8h, v20.8b, v0.8b
    umlsl2 v17.8h, v20.16b, v0.16b
    umlal  v16.8h, v29.8b, v2.8b
    umlal2 v17.8h, v29.16b, v2.16b
    umlsl  v16.8h, v30.8b, v3.8b
    umlsl2 v17.8h, v30.16b, v3.16b
    
    st1 {v4.2d, v5.2d, v6.2d, v7.2d}, [x17], #64
    st1 {v16.2d, v17.2d}, [x17], #32
    
    mov w8, w5
    if_hor_ver_chroma_w16_hor_loop_y:
    ld1 {v20.16b, v21.16b}, [x0], x1        // src[x-1]
    ld1 {v22.16b, v23.16b}, [x0], x1
    
    ext v17.16b, v20.16b, v21.16b, #1       // src[x]
    ext v18.16b, v20.16b, v21.16b, #2       // src[x+1]
    ext v19.16b, v20.16b, v21.16b, #3       // src[x+2]
    ext v29.16b, v22.16b, v23.16b, #1       // src[x]
    ext v30.16b, v22.16b, v23.16b, #2       // src[x+1]
    ext v31.16b, v22.16b, v23.16b, #3       // src[x+2]
    
    umull  v24.8h, v17.8b, v1.8b
    umull2 v25.8h, v17.16b, v1.16b
    umull  v26.8h, v29.8b, v1.8b
    umull2 v27.8h, v29.16b, v1.16b
    umlsl  v24.8h, v20.8b, v0.8b
    umlsl2 v25.8h, v20.16b, v0.16b
    umlsl  v26.8h, v22.8b, v0.8b
    umlsl2 v27.8h, v22.16b, v0.16b
    umlal  v24.8h, v18.8b, v2.8b
    umlal2 v25.8h, v18.16b, v2.16b
    umlal  v26.8h, v30.8b, v2.8b
    umlal2 v27.8h, v30.16b, v2.16b
    umlsl  v24.8h, v19.8b, v3.8b
    umlsl2 v25.8h, v19.16b, v3.16b
    umlsl  v26.8h, v31.8b, v3.8b
    umlsl2 v27.8h, v31.16b, v3.16b
    
    subs w8, w8, #2
    st1 {v24.2d, v25.2d, v26.2d, v27.2d}, [x17], #64
    bgt if_hor_ver_chroma_w16_hor_loop_y
    
    //--------------------------------
    // VER
    //--------------------------------
    mov x17, sp
    
    ld1 {v0.s}[0], [x7]                     // load coeff
    sxtl v0.8h, v0.8b                       // 8bit to 16bit
    if_hor_ver_chroma_w16_ver_loop_y:
    ld1 {v16.8h, v17.8h, v18.8h, v19.8h}, [x17], #64
    mov x10, x17
    ld1 {v20.8h, v21.8h, v22.8h, v23.8h}, [x17], #64
    ld1 {v2.8h, v3.8h}, [x17]
    
    smull  v24.4s, v16.4h, v0.h[0]
    smull2 v25.4s, v16.8h, v0.h[0]
    smull  v26.4s, v17.4h, v0.h[0]
    smull2 v27.4s, v17.8h, v0.h[0]
    smlal  v24.4s, v18.4h, v0.h[1]
    smlal2 v25.4s, v18.8h, v0.h[1]
    smlal  v26.4s, v19.4h, v0.h[1]
    smlal2 v27.4s, v19.8h, v0.h[1]
    smlal  v24.4s, v20.4h, v0.h[2]
    smlal2 v25.4s, v20.8h, v0.h[2]
    smlal  v26.4s, v21.4h, v0.h[2]
    smlal2 v27.4s, v21.8h, v0.h[2]
    smlal  v24.4s, v22.4h, v0.h[3]
    smlal2 v25.4s, v22.8h, v0.h[3]
    smlal  v26.4s, v23.4h, v0.h[3]
    smlal2 v27.4s, v23.8h, v0.h[3]
    
    smull  v28.4s, v18.4h, v0.h[0]
    smull2 v29.4s, v18.8h, v0.h[0]
    smull  v30.4s, v19.4h, v0.h[0]
    smull2 v31.4s, v19.8h, v0.h[0]
    smlal  v28.4s, v20.4h, v0.h[1]
    smlal2 v29.4s, v20.8h, v0.h[1]
    smlal  v30.4s, v21.4h, v0.h[1]
    smlal2 v31.4s, v21.8h, v0.h[1]
    smlal  v28.4s, v22.4h, v0.h[2]
    smlal2 v29.4s, v22.8h, v0.h[2]
    smlal  v30.4s, v23.4h, v0.h[2]
    smlal2 v31.4s, v23.8h, v0.h[2]
    smlal  v28.4s, v2.4h, v0.h[3]
    smlal2 v29.4s, v2.8h, v0.h[3]
    smlal  v30.4s, v3.4h, v0.h[3]
    smlal2 v31.4s, v3.8h, v0.h[3]
    
    rshrn  v24.4h, v24.4s, #12
    rshrn2 v24.8h, v25.4s, #12
    rshrn  v25.4h, v26.4s, #12
    rshrn2 v25.8h, v27.4s, #12
    rshrn  v26.4h, v28.4s, #12
    rshrn2 v26.8h, v29.4s, #12
    rshrn  v27.4h, v30.4s, #12
    rshrn2 v27.8h, v31.4s, #12
    
    sqxtun v24.8b, v24.8h                   // 16bit to 8bit
    sqxtun v25.8b, v25.8h
    sqxtun v26.8b, v26.8h
    sqxtun v27.8b, v27.8h
    
    subs w5, w5, #2
    mov x17, x10                            // tmp += 64;
    st1 {v24.8b, v25.8b}, [x2], x3
    st1 {v26.8b, v27.8b}, [x2], x3
    bgt if_hor_ver_chroma_w16_ver_loop_y
    
    add sp, sp, x15                         // (64 + 4)*16*sizeof(short)
    
    ret

#else   //10bit
//void com_if_filter_hor_8_arm64(const pel_t *src, int i_src, pel_t *dst[3], int i_dst, i16s_t *dst_tmp[3], int i_dst_tmp, int width, int height, tab_char_t (coeff)[8], int bit_depth);
//src->x0, i_src->x1, dst[3]->x2, i_dst->x3, dst_tmp[3]->x4, i_dst_tmp->x5, width->x6, height->x7, coeff->x8
function com_if_filter_hor_8_arm64
    ldr x8, [sp]    //coeff[3]
    ldr w10, [sp, #8]
    sub sp, sp, #16
    stp x19, x20, [sp]
    sub sp, sp, #16
    stp x21, x22, [sp]
    sub sp, sp, #16
    stp x23, x24, [sp]
    sub sp, sp, #64
    st1 {v8.8h - v11.8h}, [sp]

    ld1 {v0.d}[0], [x8], #8
    abs v0.8b, v0.8b
    uxtl v31.8h, v0.8b

    dup v0.8h, v31.h[0]     //1
    dup v1.8h, v31.h[1]     //4
    dup v2.8h, v31.h[2]     //10
    dup v3.8h, v31.h[3]     //57
    dup v4.8h, v31.h[4]     //19
    dup v5.8h, v31.h[5]     //7
    dup v6.8h, v31.h[6]     //3
    mov w9, #11
    dup v7.8h, w9           //11
    mov w9, #40
    dup v8.8h, w9           //40

    lsl x1, x1, #1      //i_src
    lsl x3, x3, #1      //i_dst
    lsl x5, x5, #1      //i_dst_tmp
    
    mov x9, #1
    lslv x9, x9, x10
    sub x9, x9, #1
    dup v31.8h, w9      //max_val
    mov x9, #0
    dup v16.8h, w9      //0
    mov x8, x10
        
    ldr x9, [x2], #8    //d0
    ldr x10, [x2], #8   //d1
    ldr x11, [x2]       //d2
    ldr x12, [x4], #8   //dt0
    ldr x13, [x4], #8   //dt1
    ldr x14, [x4]       //dt2

com_if_filter_hor_8_y:
    sub x15, x0, #6     // x-3
    mov x16, x6         //i
    mov x19, x9
    mov x20, x10
    mov x21, x11
    mov x22, x12
    mov x23, x13
    mov x24, x14

com_if_filter_hor_8_x:
    ld1 {v20.8h}, [x15], #16
    ld1 {v21.8h}, [x15]      // src[x-3]

    ext v22.16b, v20.16b, v21.16b, #2
    ext v23.16b, v20.16b, v21.16b, #4
    ext v24.16b, v20.16b, v21.16b, #6
    ext v25.16b, v20.16b, v21.16b, #8
    ext v26.16b, v20.16b, v21.16b, #10
    ext v27.16b, v20.16b, v21.16b, #12
    ext v28.16b, v20.16b, v21.16b, #14

    umull  v17.4s, v22.4h, v1.4h
    umull2 v18.4s, v22.8h, v1.8h
    umlsl  v17.4s, v20.4h, v0.4h
    umlsl2 v18.4s, v20.8h, v0.8h
    umlsl  v17.4s, v23.4h, v2.4h
    umlsl2 v18.4s, v23.8h, v2.8h
    umlal  v17.4s, v24.4h, v3.4h
    umlal2 v18.4s, v24.8h, v3.8h
    umlal  v17.4s, v25.4h, v4.4h
    umlal2 v18.4s, v25.8h, v4.8h
    umlsl  v17.4s, v26.4h, v5.4h
    umlsl2 v18.4s, v26.8h, v5.8h
    umlal  v17.4s, v27.4h, v6.4h
    umlal2 v18.4s, v27.8h, v6.8h
    umlsl  v17.4s, v28.4h, v0.4h
    umlsl2 v18.4s, v28.8h, v0.8h
    //(t1 + 2) >> 2
    cmp w8, #10
    bne com_if_filter_hor_8_dt0_8bit
    sqrshrn  v29.4h, v17.4s, #2
    sqrshrn2 v29.8h, v18.4s, #2        //dt0
    b com_if_filter_hor_8_dt0_end
com_if_filter_hor_8_dt0_8bit:
    sqxtn  v29.4h, v17.4s
    sqxtn2 v29.8h, v18.4s        //dt0
com_if_filter_hor_8_dt0_end:

    //(t1 + 32) >> 6
    sqrshrun  v30.4h, v17.4s, #6
    sqrshrun2 v30.8h, v18.4s, #6        //d0

    umin v30.8h, v30.8h, v31.8h
    st1 {v29.8h}, [x22], #16
    st1 {v30.8h}, [x19], #16

    umull  v17.4s, v22.4h, v1.4h
    umull2 v18.4s, v22.8h, v1.8h
    umlsl  v17.4s, v20.4h, v0.4h
    umlsl2 v18.4s, v20.8h, v0.8h
    umlsl  v17.4s, v23.4h, v7.4h
    umlsl2 v18.4s, v23.8h, v7.8h
    umlal  v17.4s, v24.4h, v8.4h
    umlal2 v18.4s, v24.8h, v8.8h
    umlal  v17.4s, v25.4h, v8.4h
    umlal2 v18.4s, v25.8h, v8.8h
    umlsl  v17.4s, v26.4h, v7.4h
    umlsl2 v18.4s, v26.8h, v7.8h
    umlal  v17.4s, v27.4h, v1.4h
    umlal2 v18.4s, v27.8h, v1.8h
    umlsl  v17.4s, v28.4h, v0.4h
    umlsl2 v18.4s, v28.8h, v0.8h
    //(t1+2)>>2
    cmp w8, #10
    bne com_if_filter_hor_8_dt1_8bit
    sqrshrn  v29.4h, v17.4s, #2
    sqrshrn2 v29.8h, v18.4s, #2        //dt1
    b com_if_filter_hor_8_dt1_end
com_if_filter_hor_8_dt1_8bit:
    sqxtn  v29.4h, v17.4s
    sqxtn2 v29.8h, v18.4s        //dt1
com_if_filter_hor_8_dt1_end:

    //(t1 + 32) >> 6
    sqrshrun  v30.4h, v17.4s, #6
    sqrshrun2 v30.8h, v18.4s, #6        //d1
    umin v30.8h, v30.8h, v31.8h
    st1 {v29.8h}, [x23], #16
    st1 {v30.8h}, [x20], #16

    smull  v17.4s, v22.4h, v6.4h
    smull2 v18.4s, v22.8h, v6.8h
    smlsl  v17.4s, v20.4h, v0.4h
    smlsl2 v18.4s, v20.8h, v0.8h
    smlsl  v17.4s, v23.4h, v5.4h
    smlsl2 v18.4s, v23.8h, v5.8h
    smlal  v17.4s, v24.4h, v4.4h
    smlal2 v18.4s, v24.8h, v4.8h
    smlal  v17.4s, v25.4h, v3.4h
    smlal2 v18.4s, v25.8h, v3.8h
    smlsl  v17.4s, v26.4h, v2.4h
    smlsl2 v18.4s, v26.8h, v2.8h
    smlal  v17.4s, v27.4h, v1.4h
    smlal2 v18.4s, v27.8h, v1.8h
    smlsl  v17.4s, v28.4h, v0.4h
    smlsl2 v18.4s, v28.8h, v0.8h
    //(t1+2)>>2
    cmp w8, #10
    bne com_if_filter_hor_8_dt2_8bit
    sqrshrn  v29.4h, v17.4s, #2
    sqrshrn2 v29.8h, v18.4s, #2        //dt2
    b com_if_filter_hor_8_dt2_end
com_if_filter_hor_8_dt2_8bit:
    sqxtn  v29.4h, v17.4s
    sqxtn2 v29.8h, v18.4s        //dt2
com_if_filter_hor_8_dt2_end:

    //(t1 + 32) >> 6
    sqrshrun  v30.4h, v17.4s, #6
    sqrshrun2 v30.8h, v18.4s, #6        //d2

    umin v30.8h, v30.8h, v31.8h
    st1 {v29.8h}, [x24], #16
    st1 {v30.8h}, [x21], #16

    subs w16, w16, #8
    bgt com_if_filter_hor_8_x
    add x9, x9, x3
    add x10, x10, x3
    add x11, x11, x3
    add x12, x12, x5
    add x13, x13, x5
    add x14, x14, x5
    add x0, x0, x1
    subs w7, w7, #1
    bgt com_if_filter_hor_8_y

    ld1 {v8.8h - v11.8h}, [sp], #64
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16

    ret

//void com_if_filter_ver_8_arm64(const pel_t *src, int i_src, pel_t *dst[3], int i_dst, int width, int height, tab_char_t (coeff)[8], int bit_depth);
//src->x0, i_src->x1, dst[3]->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_ver_8_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1

    mov x9, #1
    lslv x7, x9, x7
    sub x7, x7, #1
    dup v25.8h, w7      //max_val
    mov x7, #0
    dup v26.8h, w7      //0

    ld1 {v31.d}[0], [x6]
    abs  v31.8b, v31.8b
    uxtl v31.8h, v31.8b
    dup v0.8h, v31.h[0]     //1
    dup v1.8h, v31.h[1]     //4
    dup v2.8h, v31.h[2]     //10
    dup v3.8h, v31.h[3]     //57
    dup v4.8h, v31.h[4]     //19
    dup v5.8h, v31.h[5]     //7
    dup v6.8h, v31.h[6]     //3
    mov w9, #11
    dup v7.8h, w9           //11
    mov w9, #40
    dup v24.8h, w9          //40

    ldr x7, [x2], #8        //d0
    ldr x8, [x2], #8        //d1
    ldr x9, [x2]            //d2

if_ver_luma_w8_loop_y:
    mov x10, x4             //i
    sub x11, x0, x1, lsl #1
    sub x11, x11, x1                   // src - 3*i_src
    mov x13, x7
    mov x14, x8
    mov x15, x9

if_ver_luma_w8_loop_x:
    mov x12, x11
    ld1 {v16.8h}, [x12], x1            // x-3*i_src
    ld1 {v17.8h}, [x12], x1            // x-2*i_src
    ld1 {v18.8h}, [x12], x1            // x-i_src
    ld1 {v19.8h}, [x12], x1            // x
    ld1 {v20.8h}, [x12], x1            // x+i_src
    ld1 {v21.8h}, [x12], x1            // x+2*i_src
    ld1 {v22.8h}, [x12], x1            // x+3*i_src
    ld1 {v23.8h}, [x12], x1            // x+4*i_src

    umull  v30.4s, v17.4h, v1.4h
    umull2 v31.4s, v17.8h, v1.8h
    umlsl  v30.4s, v16.4h, v0.4h
    umlsl2 v31.4s, v16.8h, v0.8h
    umlsl  v30.4s, v18.4h, v2.4h
    umlsl2 v31.4s, v18.8h, v2.8h
    umlal  v30.4s, v19.4h, v3.4h
    umlal2 v31.4s, v19.8h, v3.8h
    umlal  v30.4s, v20.4h, v4.4h
    umlal2 v31.4s, v20.8h, v4.8h
    umlsl  v30.4s, v21.4h, v5.4h
    umlsl2 v31.4s, v21.8h, v5.8h
    umlal  v30.4s, v22.4h, v6.4h
    umlal2 v31.4s, v22.8h, v6.8h
    umlsl  v30.4s, v23.4h, v0.4h
    umlsl2 v31.4s, v23.8h, v0.8h

    sqrshrun  v29.4h, v30.4s, #6
    sqrshrun2 v29.8h, v31.4s, #6
    smin v29.8h, v29.8h, v25.8h
    smax v29.8h, v29.8h, v26.8h
    st1 {v29.8h}, [x13], #16      //d0

    umull  v30.4s, v17.4h, v1.4h
    umull2 v31.4s, v17.8h, v1.8h
    umlsl  v30.4s, v16.4h, v0.4h
    umlsl2 v31.4s, v16.8h, v0.8h
    umlsl  v30.4s, v18.4h, v7.4h
    umlsl2 v31.4s, v18.8h, v7.8h
    umlal  v30.4s, v19.4h, v24.4h
    umlal2 v31.4s, v19.8h, v24.8h
    umlal  v30.4s, v20.4h, v24.4h
    umlal2 v31.4s, v20.8h, v24.8h
    umlsl  v30.4s, v21.4h, v7.4h
    umlsl2 v31.4s, v21.8h, v7.8h
    umlal  v30.4s, v22.4h, v1.4h
    umlal2 v31.4s, v22.8h, v1.8h
    umlsl  v30.4s, v23.4h, v0.4h
    umlsl2 v31.4s, v23.8h, v0.8h

    sqrshrun  v29.4h, v30.4s, #6
    sqrshrun2 v29.8h, v31.4s, #6
    smin v29.8h, v29.8h, v25.8h
    smax v29.8h, v29.8h, v26.8h
    st1 {v29.8h}, [x14], #16      //d1
    
    umull  v30.4s, v17.4h, v6.4h
    umull2 v31.4s, v17.8h, v6.8h
    umlsl  v30.4s, v16.4h, v0.4h
    umlsl2 v31.4s, v16.8h, v0.8h
    umlsl  v30.4s, v18.4h, v5.4h
    umlsl2 v31.4s, v18.8h, v5.8h
    umlal  v30.4s, v19.4h, v4.4h
    umlal2 v31.4s, v19.8h, v4.8h
    umlal  v30.4s, v20.4h, v3.4h
    umlal2 v31.4s, v20.8h, v3.8h
    umlsl  v30.4s, v21.4h, v2.4h
    umlsl2 v31.4s, v21.8h, v2.8h
    umlal  v30.4s, v22.4h, v1.4h
    umlal2 v31.4s, v22.8h, v1.8h
    umlsl  v30.4s, v23.4h, v0.4h
    umlsl2 v31.4s, v23.8h, v0.8h
    
    sqrshrun  v29.4h, v30.4s, #6
    sqrshrun2 v29.8h, v31.4s, #6
    smin v29.8h, v29.8h, v25.8h
    smax v29.8h, v29.8h, v26.8h
    st1 {v29.8h}, [x15], #16      //d2
    
    add x11, x11, #16
    subs w10, w10, #8
    bgt if_ver_luma_w8_loop_x
    add x0, x0, x1
    add x7, x7, x3
    add x8, x8, x3
    add x9, x9, x3
    subs w5, w5, #1
    bgt if_ver_luma_w8_loop_y

    ret

//void com_if_filter_ver_8_ext_arm64(const pel_t *src, int i_src, pel_t *dst[3], int i_dst, int width, int height, tab_char_t (coeff)[8], int bit_depth);
//src->x0, i_src->x1, dst[3]->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_ver_8_ext_arm64
    sub sp, sp, #16
    stp x19, x20, [sp]

    lsl x1, x1, #1
    lsl x3, x3, #1

    mov x19, x7
    mov x7, #1
    lslv x7, x7, x19
    sub x7, x7, #1
    dup v25.8h, w7      //max_val
    mov x7, #0
    dup v26.8h, w7      //0

    ld1 {v31.d}[0], [x6]
    abs  v31.8b, v31.8b
    uxtl v31.8h, v31.8b
    dup v0.8h, v31.h[0]     //1
    dup v1.8h, v31.h[1]     //4
    dup v2.8h, v31.h[2]     //10
    dup v3.8h, v31.h[3]     //57
    dup v4.8h, v31.h[4]     //19
    dup v5.8h, v31.h[5]     //7
    dup v6.8h, v31.h[6]     //3
    mov w9, #11
    dup v7.8h, w9           //11
    mov w9, #40
    dup v24.8h, w9          //40

    ldr x7, [x2], #8        //d0
    ldr x8, [x2], #8        //d1
    ldr x9, [x2]            //d2

if_ver_luma_w8_loop_ext_y:
    mov x10, x4             //i
    sub x11, x0, x1, lsl #1
    sub x11, x11, x1                   // src - 3*i_src
    mov x13, x7
    mov x14, x8
    mov x15, x9

if_ver_luma_w8_loop_ext_x:
    mov x12, x11
    ld1 {v16.8h}, [x12], x1            // x-3*i_src
    ld1 {v17.8h}, [x12], x1            // x-2*i_src
    ld1 {v18.8h}, [x12], x1            // x-i_src
    ld1 {v19.8h}, [x12], x1            // x
    ld1 {v20.8h}, [x12], x1            // x+i_src
    ld1 {v21.8h}, [x12], x1            // x+2*i_src
    ld1 {v22.8h}, [x12], x1            // x+3*i_src
    ld1 {v23.8h}, [x12], x1            // x+4*i_src

    smull  v30.4s, v17.4h, v1.4h
    smull2 v31.4s, v17.8h, v1.8h
    smlsl  v30.4s, v16.4h, v0.4h
    smlsl2 v31.4s, v16.8h, v0.8h
    smlsl  v30.4s, v18.4h, v2.4h
    smlsl2 v31.4s, v18.8h, v2.8h
    smlal  v30.4s, v19.4h, v3.4h
    smlal2 v31.4s, v19.8h, v3.8h
    smlal  v30.4s, v20.4h, v4.4h
    smlal2 v31.4s, v20.8h, v4.8h
    smlsl  v30.4s, v21.4h, v5.4h
    smlsl2 v31.4s, v21.8h, v5.8h
    smlal  v30.4s, v22.4h, v6.4h
    smlal2 v31.4s, v22.8h, v6.8h
    smlsl  v30.4s, v23.4h, v0.4h
    smlsl2 v31.4s, v23.8h, v0.8h

    cmp w19, #10
    bne if_ver_luma_w8_loop_ext_x_d0_8bit
    sqrshrun  v29.4h, v30.4s, #10
    sqrshrun2 v29.8h, v31.4s, #10
    b if_ver_luma_w8_loop_ext_x_d0_end
if_ver_luma_w8_loop_ext_x_d0_8bit:
    sqrshrun  v29.4h, v30.4s, #12
    sqrshrun2 v29.8h, v31.4s, #12
if_ver_luma_w8_loop_ext_x_d0_end:
    smin v29.8h, v29.8h, v25.8h
    smax v29.8h, v29.8h, v26.8h
    st1 {v29.8h}, [x13], #16      //d0

    smull  v30.4s, v17.4h, v1.4h
    smull2 v31.4s, v17.8h, v1.8h
    smlsl  v30.4s, v16.4h, v0.4h
    smlsl2 v31.4s, v16.8h, v0.8h
    smlsl  v30.4s, v18.4h, v7.4h
    smlsl2 v31.4s, v18.8h, v7.8h
    smlal  v30.4s, v19.4h, v24.4h
    smlal2 v31.4s, v19.8h, v24.8h
    smlal  v30.4s, v20.4h, v24.4h
    smlal2 v31.4s, v20.8h, v24.8h
    smlsl  v30.4s, v21.4h, v7.4h
    smlsl2 v31.4s, v21.8h, v7.8h
    smlal  v30.4s, v22.4h, v1.4h
    smlal2 v31.4s, v22.8h, v1.8h
    smlsl  v30.4s, v23.4h, v0.4h
    smlsl2 v31.4s, v23.8h, v0.8h

    cmp w19, #10
    bne if_ver_luma_w8_loop_ext_x_d1_8bit
    sqrshrun  v29.4h, v30.4s, #10
    sqrshrun2 v29.8h, v31.4s, #10
    b if_ver_luma_w8_loop_ext_x_d1_end
if_ver_luma_w8_loop_ext_x_d1_8bit:
    sqrshrun  v29.4h, v30.4s, #12
    sqrshrun2 v29.8h, v31.4s, #12
if_ver_luma_w8_loop_ext_x_d1_end:
    smin v29.8h, v29.8h, v25.8h
    smax v29.8h, v29.8h, v26.8h
    st1 {v29.8h}, [x14], #16      //d1
    
    smull  v30.4s, v17.4h, v6.4h
    smull2 v31.4s, v17.8h, v6.8h
    smlsl  v30.4s, v16.4h, v0.4h
    smlsl2 v31.4s, v16.8h, v0.8h
    smlsl  v30.4s, v18.4h, v5.4h
    smlsl2 v31.4s, v18.8h, v5.8h
    smlal  v30.4s, v19.4h, v4.4h
    smlal2 v31.4s, v19.8h, v4.8h
    smlal  v30.4s, v20.4h, v3.4h
    smlal2 v31.4s, v20.8h, v3.8h
    smlsl  v30.4s, v21.4h, v2.4h
    smlsl2 v31.4s, v21.8h, v2.8h
    smlal  v30.4s, v22.4h, v1.4h
    smlal2 v31.4s, v22.8h, v1.8h
    smlsl  v30.4s, v23.4h, v0.4h
    smlsl2 v31.4s, v23.8h, v0.8h
    
    cmp w19, #10
    bne if_ver_luma_w8_loop_ext_x_d2_8bit
    sqrshrun  v29.4h, v30.4s, #10
    sqrshrun2 v29.8h, v31.4s, #10
    b if_ver_luma_w8_loop_ext_x_d2_end
if_ver_luma_w8_loop_ext_x_d2_8bit:
    sqrshrun  v29.4h, v30.4s, #12
    sqrshrun2 v29.8h, v31.4s, #12
if_ver_luma_w8_loop_ext_x_d2_end:
    smin v29.8h, v29.8h, v25.8h
    smax v29.8h, v29.8h, v26.8h
    st1 {v29.8h}, [x15], #16      //d2
    
    add x11, x11, #16
    subs w10, w10, #8
    bgt if_ver_luma_w8_loop_ext_x
    add x0, x0, x1
    add x7, x7, x3
    add x8, x8, x3
    add x9, x9, x3
    subs w5, w5, #1
    bgt if_ver_luma_w8_loop_ext_y

    ldp x19, x20, [sp], #16
    ret

//void com_if_filter_hor_4_w4_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_hor_4_w4_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    mov x8, #1
    lsl x7, x8, X7
    sub x7, x7, #1  //max_pixel

    ld1 {v4.s}[0], [x6]
    abs  v3.8b, v4.8b
    uxtl v3.8h, v3.8b
    dup v0.8h, v3.h[0]
    dup v1.8h, v3.h[1]
    dup v2.8h, v3.h[2]
    dup v3.8h, v3.h[3]

    sub x0, x0, #2                      // src - 1
    dup v31.8h, w7                      // max_val

if_hor_chroma_w4_loop_y:
    ld1 {v20.8h}, [x0], x1      // src[x-1]
    ld1 {v21.8h}, [x0], x1
    ext v17.16b, v20.16b, v20.16b, #2   // src[x]
    ext v18.16b, v20.16b, v20.16b, #4   // src[x+1]
    ext v19.16b, v20.16b, v20.16b, #6   // src[x+2]
    ext v24.16b, v21.16b, v21.16b, #2   // src[x]
    ext v25.16b, v21.16b, v21.16b, #4   // src[x+1]
    ext v26.16b, v21.16b, v21.16b, #6   // src[x+2]

    umull  v4.4s, v17.4h, v1.4h
    umlsl  v4.4s, v20.4h, v0.4h
    umlal  v4.4s, v18.4h, v2.4h
    umlsl  v4.4s, v19.4h, v3.4h

    umull  v6.4s, v24.4h, v1.4h
    umlsl  v6.4s, v21.4h, v0.4h
    umlal  v6.4s, v25.4h, v2.4h
    umlsl  v6.4s, v26.4h, v3.4h

    sqrshrun v4.4h, v4.4s, #6       // saturate s32 -> u16
    sqrshrun v6.4h, v6.4s, #6

    umin v4.4h, v4.4h, v31.4h
    umin v6.4h, v6.4h, v31.4h

    subs w5, w5, #2
    st1 {v4.4h}, [x2], x3
    st1 {v6.4h}, [x2], x3
    bgt if_hor_chroma_w4_loop_y

    ret

//void com_if_filter_hor_4_w8_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_hor_4_w8_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    mov x8, #1
    lsl x7, x8, X7
    sub x7, x7, #1  //max_pixel

    ld1 {v4.s}[0], [x6]
    abs  v3.8b, v4.8b
    uxtl v3.8h, v3.8b
    dup v0.8h, v3.h[0]
    dup v1.8h, v3.h[1]
    dup v2.8h, v3.h[2]
    dup v3.8h, v3.h[3]

    sub x0, x0, #2                      // src - 1
    dup v31.8h, w7                      // max_val

if_hor_chroma_w8_loop_y:
    ld1 {v20.8h, v21.8h}, [x0], x1      // src[x-1]
    ld1 {v22.8h, v23.8h}, [x0], x1
    ext v17.16b, v20.16b, v21.16b, #2   // src[x]
    ext v18.16b, v20.16b, v21.16b, #4   // src[x+1]
    ext v19.16b, v20.16b, v21.16b, #6   // src[x+2]
    ext v24.16b, v22.16b, v23.16b, #2   // src[x]
    ext v25.16b, v22.16b, v23.16b, #4   // src[x+1]
    ext v26.16b, v22.16b, v23.16b, #6   // src[x+2]

    umull  v4.4s, v17.4h, v1.4h
    umull2 v5.4s, v17.8h, v1.8h
    umlsl  v4.4s, v20.4h, v0.4h
    umlsl2 v5.4s, v20.8h, v0.8h
    umlal  v4.4s, v18.4h, v2.4h
    umlal2 v5.4s, v18.8h, v2.8h
    umlsl  v4.4s, v19.4h, v3.4h
    umlsl2 v5.4s, v19.8h, v3.8h

    umull  v6.4s, v24.4h, v1.4h
    umull2 v7.4s, v24.8h, v1.8h
    umlsl  v6.4s, v22.4h, v0.4h
    umlsl2 v7.4s, v22.8h, v0.8h
    umlal  v6.4s, v25.4h, v2.4h
    umlal2 v7.4s, v25.8h, v2.8h
    umlsl  v6.4s, v26.4h, v3.4h
    umlsl2 v7.4s, v26.8h, v3.8h

    sqrshrun v4.4h, v4.4s, #6       // saturate s32 -> u16
    sqrshrun v5.4h, v5.4s, #6
    sqrshrun v6.4h, v6.4s, #6
    sqrshrun v7.4h, v7.4s, #6

    umin v4.4h, v4.4h, v31.4h
    umin v5.4h, v5.4h, v31.4h
    umin v6.4h, v6.4h, v31.4h
    umin v7.4h, v7.4h, v31.4h

    subs w5, w5, #2
    st1 {v4.4h, v5.4h}, [x2], x3
    st1 {v6.4h, v7.4h}, [x2], x3
    bgt if_hor_chroma_w8_loop_y

    ret


//void com_if_filter_hor_4_w16_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_hor_4_w16_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    mov x8, #1
    lsl x7, x8, X7
    sub x7, x7, #1  //max_pixel

    ld1 {v4.s}[0], [x6]
    abs v3.8b, v4.8b
    uxtl v3.8h, v3.8b
    dup v0.8h, v3.h[0]
    dup v1.8h, v3.h[1]
    dup v2.8h, v3.h[2]
    dup v3.8h, v3.h[3]

    sub x0, x0, #2                      // src - 1
    sub x1, x1, #32
    dup v31.8h, w7                      // max_val
if_hor_chroma_w16_loop_y:
    ld1 {v16.8h, v17.8h}, [x0], #32     // src[x-1]
    ld1 {v18.8h}, [x0], x1

    ext v19.16b, v16.16b, v17.16b, #2   // src[x]
    ext v20.16b, v16.16b, v17.16b, #4   // src[x+1]
    ext v21.16b, v16.16b, v17.16b, #6   // src[x+2]
    ext v22.16b, v17.16b, v18.16b, #2   // src[x+8]
    ext v23.16b, v17.16b, v18.16b, #4   // src[x+9]
    ext v24.16b, v17.16b, v18.16b, #6   // src[x+10]

    umull  v4.4s, v19.4h, v1.4h
    umull2 v5.4s, v19.8h, v1.8h
    umull  v6.4s, v22.4h, v1.4h
    umull2 v7.4s, v22.8h, v1.8h
    umlsl  v4.4s, v16.4h, v0.4h
    umlsl2 v5.4s, v16.8h, v0.8h
    umlsl  v6.4s, v17.4h, v0.4h
    umlsl2 v7.4s, v17.8h, v0.8h
    umlal  v4.4s, v20.4h, v2.4h
    umlal2 v5.4s, v20.8h, v2.8h
    umlal  v6.4s, v23.4h, v2.4h
    umlal2 v7.4s, v23.8h, v2.8h
    umlsl  v4.4s, v21.4h, v3.4h
    umlsl2 v5.4s, v21.8h, v3.8h
    umlsl  v6.4s, v24.4h, v3.4h
    umlsl2 v7.4s, v24.8h, v3.8h

    sqrshrun v4.4h, v4.4s, #6           // saturate s32 -> u16
    sqrshrun v5.4h, v5.4s, #6
    sqrshrun v6.4h, v6.4s, #6
    sqrshrun v7.4h, v7.4s, #6

    umin v4.4h, v4.4h, v31.4h
    umin v5.4h, v5.4h, v31.4h
    umin v6.4h, v6.4h, v31.4h
    umin v7.4h, v7.4h, v31.4h

    subs w5, w5, #1
    st1 {v4.4h, v5.4h, v6.4h, v7.4h}, [x2], x3
    bgt if_hor_chroma_w16_loop_y

    ret

//void com_if_filter_ver_4_w4_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_ver_4_w4_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    mov x7, #1
    lsl x7, x7, #10
    sub x7, x7, #1
    
    // load coeff
    ld1 {v4.s}[0], [x6]
    abs  v3.8b, v4.8b
    uxtl v3.8h, v3.8b
    dup v0.8h, v3.h[0]
    dup v1.8h, v3.h[1]
    dup v2.8h, v3.h[2]
    dup v3.8h, v3.h[3]
    
    sub x0, x0, x1                  // src - i_src
    dup v30.8h, w7
    if_ver_chroma_w4_loop_y:
    ld1 {v16.d}[0], [x0], x1         // src-i_src
    ld1 {v17.d}[0], [x0], x1         // src
    ld1 {v18.d}[0], [x0], x1         // src+i_src
    ld1 {v19.d}[0], [x0], x1         // src+2*i_src
    mov x10, x0
    ld1 {v20.d}[0], [x0], x1
    ld1 {v21.d}[0], [x0], x1
    ld1 {v31.d}[0], [x0]
    
    umull  v22.4s, v17.4h, v1.4h
    umull  v23.4s, v18.4h, v1.4h
    umlsl  v22.4s, v16.4h, v0.4h
    umlsl  v23.4s, v17.4h, v0.4h
    umlal  v22.4s, v18.4h, v2.4h
    umlal  v23.4s, v19.4h, v2.4h
    umlsl  v22.4s, v19.4h, v3.4h
    umlsl  v23.4s, v20.4h, v3.4h
    
    umull  v24.4s, v19.4h, v1.4h
    umull  v25.4s, v20.4h, v1.4h
    umlsl  v24.4s, v18.4h, v0.4h
    umlsl  v25.4s, v19.4h, v0.4h
    umlal  v24.4s, v20.4h, v2.4h
    umlal  v25.4s, v21.4h, v2.4h
    umlsl  v24.4s, v21.4h, v3.4h
    umlsl  v25.4s, v31.4h, v3.4h
    
    //(sum + 32) >> 6
    sqrshrun  v22.4h, v22.4s, #6
    sqrshrun  v23.4h, v23.4s, #6
    sqrshrun  v24.4h, v24.4s, #6
    sqrshrun  v25.4h, v25.4s, #6
    
    umin v22.8h, v22.8h, v30.8h
    umin v23.8h, v23.8h, v30.8h
    umin v24.8h, v24.8h, v30.8h
    umin v25.8h, v25.8h, v30.8h
    
    st1 {v22.d}[0], [x2], x3
    subs w5, w5, #4
    mov x0, x10
    st1 {v23.d}[0], [x2], x3
    st1 {v24.d}[0], [x2], x3
    st1 {v25.d}[0], [x2], x3
    
    bgt if_ver_chroma_w4_loop_y
    
    ret


//void com_if_filter_ver_4_w8_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int bit_depth);
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff->x6, bit_depth->x7
function com_if_filter_ver_4_w8_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    mov x7, #1
    lsl x7, x7, #10
    sub x7, x7, #1
    
    // load coeff
    ld1 {v4.s}[0], [x6]
    abs  v3.8b, v4.8b
    uxtl v3.8h, v3.8b
    dup v0.8h, v3.h[0]
    dup v1.8h, v3.h[1]
    dup v2.8h, v3.h[2]
    dup v3.8h, v3.h[3]
    
    sub x0, x0, x1                  // src - i_src
    dup v30.8h, w7
    if_ver_chroma_w8_loop_y:
    ld1 {v16.8h}, [x0], x1         // src-i_src
    ld1 {v17.8h}, [x0], x1         // src
    ld1 {v18.8h}, [x0], x1         // src+i_src
    ld1 {v19.8h}, [x0], x1         // src+2*i_src
    mov x10, x0
    ld1 {v20.8h}, [x0], x1
    ld1 {v21.8h}, [x0], x1
    ld1 {v31.8h}, [x0]
    
    umull  v22.4s, v17.4h, v1.4h
    umull2 v23.4s, v17.8h, v1.8h
    umull  v24.4s, v18.4h, v1.4h
    umull2 v25.4s, v18.8h, v1.8h
    umlsl  v22.4s, v16.4h, v0.4h
    umlsl2 v23.4s, v16.8h, v0.8h
    umlsl  v24.4s, v17.4h, v0.4h
    umlsl2 v25.4s, v17.8h, v0.8h
    umlal  v22.4s, v18.4h, v2.4h
    umlal2 v23.4s, v18.8h, v2.8h
    umlal  v24.4s, v19.4h, v2.4h
    umlal2 v25.4s, v19.8h, v2.8h
    umlsl  v22.4s, v19.4h, v3.4h
    umlsl2 v23.4s, v19.8h, v3.8h
    umlsl  v24.4s, v20.4h, v3.4h
    umlsl2 v25.4s, v20.8h, v3.8h
    
    umull  v26.4s, v19.4h, v1.4h
    umull2 v27.4s, v19.8h, v1.8h
    umull  v28.4s, v20.4h, v1.4h
    umull2 v29.4s, v20.8h, v1.8h
    umlsl  v26.4s, v18.4h, v0.4h
    umlsl2 v27.4s, v18.8h, v0.8h
    umlsl  v28.4s, v19.4h, v0.4h
    umlsl2 v29.4s, v19.8h, v0.8h
    umlal  v26.4s, v20.4h, v2.4h
    umlal2 v27.4s, v20.8h, v2.8h
    umlal  v28.4s, v21.4h, v2.4h
    umlal2 v29.4s, v21.8h, v2.8h
    umlsl  v26.4s, v21.4h, v3.4h
    umlsl2 v27.4s, v21.8h, v3.8h
    umlsl  v28.4s, v31.4h, v3.4h
    umlsl2 v29.4s, v31.8h, v3.8h
    
    //(sum + 32) >> 6
    sqrshrun  v22.4h, v22.4s, #6
    sqrshrun2 v22.8h, v23.4s, #6
    sqrshrun  v23.4h, v24.4s, #6
    sqrshrun2 v23.8h, v25.4s, #6
    sqrshrun  v24.4h, v26.4s, #6
    sqrshrun2 v24.8h, v27.4s, #6
    sqrshrun  v25.4h, v28.4s, #6
    sqrshrun2 v25.8h, v29.4s, #6
    
    umin v22.8h, v22.8h, v30.8h
    umin v23.8h, v23.8h, v30.8h
    umin v24.8h, v24.8h, v30.8h
    umin v25.8h, v25.8h, v30.8h
    
    st1 {v22.8h}, [x2], x3
    subs w5, w5, #4
    mov x0, x10
    st1 {v23.8h}, [x2], x3
    st1 {v24.8h}, [x2], x3
    st1 {v25.8h}, [x2], x3
    
    bgt if_ver_chroma_w8_loop_y
    
    ret

//void com_if_filter_ver_4_w16_arm64(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int max_val);
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff->x6, max_val->x7
function com_if_filter_ver_4_w16_arm64

    lsl x1, x1, #1
    lsl x3, x3, #1
    mov x7, #1
    lsl x7, x7, #10
    sub x7, x7, #1
    
    // load coeff
    ld1 {v4.s}[0], [x6]
    abs  v3.8b, v4.8b
    uxtl v3.8h, v3.8b
    dup v0.8h, v3.h[0]
    dup v1.8h, v3.h[1]
    dup v2.8h, v3.h[2]
    dup v3.8h, v3.h[3]

    sub x0, x0, x1
    dup v6.8h, w7
if_ver_chroma_w16_loop_y:
    ld1 {v16.8h, v17.8h}, [x0], x1        // src + x - i_src
    ld1 {v18.8h, v19.8h}, [x0], x1        // src + x
    mov x10, x0
    ld1 {v20.8h, v21.8h}, [x0], x1        // src + x + i_src
    ld1 {v22.8h, v23.8h}, [x0], x1        // src + x + 2*i_src
    ld1 {v4.8h, v5.8h}, [x0]

    umull  v24.4s, v18.4h, v1.4h
    umull2 v25.4s, v18.8h, v1.8h
    umull  v26.4s, v19.4h, v1.4h
    umull2 v27.4s, v19.8h, v1.8h
    umlsl  v24.4s, v16.4h, v0.4h
    umlsl2 v25.4s, v16.8h, v0.8h
    umlsl  v26.4s, v17.4h, v0.4h
    umlsl2 v27.4s, v17.8h, v0.8h
    umlal  v24.4s, v20.4h, v2.4h
    umlal2 v25.4s, v20.8h, v2.8h
    umlal  v26.4s, v21.4h, v2.4h
    umlal2 v27.4s, v21.8h, v2.8h
    umlsl  v24.4s, v22.4h, v3.4h
    umlsl2 v25.4s, v22.8h, v3.8h
    umlsl  v26.4s, v23.4h, v3.4h
    umlsl2 v27.4s, v23.8h, v3.8h

    umull  v28.4s, v20.4h, v1.4h
    umull2 v29.4s, v20.8h, v1.8h
    umull  v30.4s, v21.4h, v1.4h
    umull2 v31.4s, v21.8h, v1.8h
    umlsl  v28.4s, v18.4h, v0.4h
    umlsl2 v29.4s, v18.8h, v0.8h
    umlsl  v30.4s, v19.4h, v0.4h
    umlsl2 v31.4s, v19.8h, v0.8h
    umlal  v28.4s, v22.4h, v2.4h
    umlal2 v29.4s, v22.8h, v2.8h
    umlal  v30.4s, v23.4h, v2.4h
    umlal2 v31.4s, v23.8h, v2.8h
    umlsl  v28.4s, v4.4h, v3.4h
    umlsl2 v29.4s, v4.8h, v3.8h
    umlsl  v30.4s, v5.4h, v3.4h
    umlsl2 v31.4s, v5.8h, v3.8h

    //(sum + 32) >> 6
    sqrshrun  v24.4h, v24.4s, #6
    sqrshrun2 v24.8h, v25.4s, #6
    sqrshrun  v25.4h, v26.4s, #6
    sqrshrun2 v25.8h, v27.4s, #6
    sqrshrun  v26.4h, v28.4s, #6
    sqrshrun2 v26.8h, v29.4s, #6
    sqrshrun  v27.4h, v30.4s, #6
    sqrshrun2 v27.8h, v31.4s, #6

    umin v24.8h, v24.8h, v6.8h
    umin v25.8h, v25.8h, v6.8h
    umin v26.8h, v26.8h, v6.8h
    umin v27.8h, v27.8h, v6.8h

    subs w5, w5, #2
    mov x0, x10
    st1 {v24.8h, v25.8h}, [x2], x3
    st1 {v26.8h, v27.8h}, [x2], x3
    bgt if_ver_chroma_w16_loop_y

    ret

//void com_if_filter_hor_ver_4_w8_arm64(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8 *coeff_v, int bit_depth)
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff_h->x6, coeff_v->x7
function com_if_filter_hor_ver_4_w8_arm64
    mov x8, #1
    lsl x8, x8, #10
    sub x8, x8, #1

    sub sp, sp, #16
    st1 {v15.2d}, [sp]

    lsl x1, x1, #1
    lsl x3, x3, #1

    // align (x17)
    // x17-->tmp
    mov x15, #36                            // #68
    lsl x15, x15, #4
    sub x17, sp, x15                        // (32 + 4)*8*sizeof(short)
    mov sp, x17
    sub x0, x0, x1                          // src += -1 * i_src;

//--------------------------------
// HOR
//--------------------------------
    ld1 {v4.s}[0], [x6]
    dup  v15.8h, w8
    abs  v3.8b, v4.8b
    uxtl v3.8h, v3.8b
    dup v0.8h, v3.h[0]
    dup v1.8h, v3.h[1]
    dup v2.8h, v3.h[2]
    dup v3.8h, v3.h[3]
    sub x0, x0, #2                          // x - 1 UV

    //the first three rows
    ld1 {v16.8h, v17.8h}, [x0], x1       // src[x-1]
    ld1 {v18.8h, v19.8h}, [x0], x1       // src[x-1]
    ld1 {v20.8h, v21.8h}, [x0], x1

    ext v22.16b, v16.16b, v17.16b, #2      // src[x]
    ext v23.16b, v16.16b, v17.16b, #4      // src[x+1]
    ext v24.16b, v16.16b, v17.16b, #6      // src[x+2]

    ext v25.16b, v18.16b, v19.16b, #2
    ext v26.16b, v18.16b, v19.16b, #4
    ext v27.16b, v18.16b, v19.16b, #6

    ext v28.16b, v20.16b, v21.16b, #2
    ext v29.16b, v20.16b, v21.16b, #4
    ext v30.16b, v20.16b, v21.16b, #6

    umull  v4.4s, v22.4h, v1.4h
    umull2 v5.4s, v22.8h, v1.8h
    umlsl  v4.4s, v16.4h, v0.4h
    umlsl2 v5.4s, v16.8h, v0.8h
    umlal  v4.4s, v23.4h, v2.4h
    umlal2 v5.4s, v23.8h, v2.8h
    umlsl  v4.4s, v24.4h, v3.4h
    umlsl2 v5.4s, v24.8h, v3.8h

    umull  v6.4s, v25.4h, v1.4h
    umull2 v7.4s, v25.8h, v1.8h
    umlsl  v6.4s, v18.4h, v0.4h
    umlsl2 v7.4s, v18.8h, v0.8h
    umlal  v6.4s, v26.4h, v2.4h
    umlal2 v7.4s, v26.8h, v2.8h
    umlsl  v6.4s, v27.4h, v3.4h
    umlsl2 v7.4s, v27.8h, v3.8h

    umull  v16.4s, v28.4h, v1.4h
    umull2 v17.4s, v28.8h, v1.8h
    umlsl  v16.4s, v20.4h, v0.4h
    umlsl2 v17.4s, v20.8h, v0.8h
    umlal  v16.4s, v29.4h, v2.4h
    umlal2 v17.4s, v29.8h, v2.8h
    umlsl  v16.4s, v30.4h, v3.4h
    umlsl2 v17.4s, v30.8h, v3.8h

    rshrn  v4.4h, v4.4s, #2
    rshrn2 v4.8h, v5.4s, #2
    rshrn  v5.4h, v6.4s, #2
    rshrn2 v5.8h, v7.4s, #2
    rshrn  v6.4h, v16.4s, #2
    rshrn2 v6.8h, v17.4s, #2

    st1 {v4.8h, v5.8h}, [x17], #32
    st1 {v6.8h}, [x17], #16

    // the next height rows
    mov w8, w5
if_hor_ver_chroma_w8_hor_10bit_loop_y:
    ld1 {v16.8h, v17.8h}, [x0], x1          // src[x-1]
    ld1 {v18.8h, v19.8h}, [x0], x1          // src[x-1]
    ld1 {v20.8h, v21.8h}, [x0], x1
    ld1 {v22.8h, v23.8h}, [x0], x1

    ext v24.16b, v16.16b, v17.16b, #2       // src[x]
    ext v25.16b, v16.16b, v17.16b, #4       // src[x+1]
    ext v26.16b, v16.16b, v17.16b, #6       // src[x+2]

    ext v27.16b, v18.16b, v19.16b, #2       // src[x]
    ext v28.16b, v18.16b, v19.16b, #4       // src[x+1]
    ext v29.16b, v18.16b, v19.16b, #6      // src[x+2]

    ext v30.16b, v20.16b, v21.16b, #2       // src[x]
    ext v31.16b, v20.16b, v21.16b, #4       // src[x+1]
    ext v17.16b, v20.16b, v21.16b, #6       // src[x+2]

    ext v19.16b, v22.16b, v23.16b, #2       // src[x]
    ext v21.16b, v22.16b, v23.16b, #4       // src[x+1]
    ext v23.16b, v22.16b, v23.16b, #6       // src[x+2]

    umull  v4.4s, v24.4h, v1.4h
    umull  v5.4s, v27.4h, v1.4h
    umull2 v6.4s, v24.8h, v1.8h
    umull2 v7.4s, v27.8h, v1.8h
    umlsl  v4.4s, v16.4h, v0.4h
    umlsl  v5.4s, v18.4h, v0.4h
    umlsl2 v6.4s, v16.8h, v0.8h
    umlsl2 v7.4s, v18.8h, v0.8h
    umlal  v4.4s, v25.4h, v2.4h
    umlal  v5.4s, v28.4h, v2.4h
    umlal2 v6.4s, v25.8h, v2.8h
    umlal2 v7.4s, v28.8h, v2.8h
    umlsl  v4.4s, v26.4h, v3.4h
    umlsl  v5.4s, v29.4h, v3.4h
    umlsl2 v6.4s, v26.8h, v3.8h
    umlsl2 v7.4s, v29.8h, v3.8h

    rshrn  v4.4h, v4.4s, #2
    rshrn2 v4.8h, v6.4s, #2
    rshrn  v5.4h, v5.4s, #2
    rshrn2 v5.8h, v7.4s, #2

    st1 {v4.8h, v5.8h}, [x17], #32

    umull  v4.4s, v30.4h, v1.4h
    umull  v5.4s, v19.4h, v1.4h
    umull2 v6.4s, v30.8h, v1.8h
    umull2 v7.4s, v19.8h, v1.8h
    umlsl  v4.4s, v20.4h, v0.4h
    umlsl  v5.4s, v22.4h, v0.4h
    umlsl2 v6.4s, v20.8h, v0.8h
    umlsl2 v7.4s, v22.8h, v0.8h
    umlal  v4.4s, v31.4h, v2.4h
    umlal  v5.4s, v21.4h, v2.4h
    umlal2 v6.4s, v31.8h, v2.8h
    umlal2 v7.4s, v21.8h, v2.8h
    umlsl  v4.4s, v17.4h, v3.4h
    umlsl  v5.4s, v23.4h, v3.4h
    umlsl2 v6.4s, v17.8h, v3.8h
    umlsl2 v7.4s, v23.8h, v3.8h

    rshrn  v4.4h, v4.4s, #2
    rshrn2 v4.8h, v6.4s, #2
    rshrn  v5.4h, v5.4s, #2
    rshrn2 v5.8h, v7.4s, #2

    subs w8, w8, #4

    st1 {v4.8h, v5.8h}, [x17], #32
    bgt if_hor_ver_chroma_w8_hor_10bit_loop_y

//--------------------------------
// VER
//--------------------------------
    mov x17, sp

    ld1 {v0.s}[0], [x7]                     // load coeff
    sxtl v0.8h, v0.8b                       // 8bit to 16bit

if_hor_ver_chroma_w8_ver_10bit_loop_y:
    ld1 {v16.2d, v17.2d, v18.2d, v19.2d}, [x17], #64    // x-i_src
    ld1 {v20.2d, v21.2d, v22.2d, v23.2d}, [x17]
    mov x10, x17

    smull  v24.4s, v16.4h, v0.h[0]
    smull2 v25.4s, v16.8h, v0.h[0]
    smull  v26.4s, v17.4h, v0.h[0]
    smull2 v27.4s, v17.8h, v0.h[0]
    smlal  v24.4s, v17.4h, v0.h[1]
    smlal2 v25.4s, v17.8h, v0.h[1]
    smlal  v26.4s, v18.4h, v0.h[1]
    smlal2 v27.4s, v18.8h, v0.h[1]
    smlal  v24.4s, v18.4h, v0.h[2]
    smlal2 v25.4s, v18.8h, v0.h[2]
    smlal  v26.4s, v19.4h, v0.h[2]
    smlal2 v27.4s, v19.8h, v0.h[2]
    smlal  v24.4s, v19.4h, v0.h[3]
    smlal2 v25.4s, v19.8h, v0.h[3]
    smlal  v26.4s, v20.4h, v0.h[3]
    smlal2 v27.4s, v20.8h, v0.h[3]

    smull  v28.4s, v18.4h, v0.h[0]
    smull2 v29.4s, v18.8h, v0.h[0]
    smull  v30.4s, v19.4h, v0.h[0]
    smull2 v31.4s, v19.8h, v0.h[0]
    smlal  v28.4s, v19.4h, v0.h[1]
    smlal2 v29.4s, v19.8h, v0.h[1]
    smlal  v30.4s, v20.4h, v0.h[1]
    smlal2 v31.4s, v20.8h, v0.h[1]
    smlal  v28.4s, v20.4h, v0.h[2]
    smlal2 v29.4s, v20.8h, v0.h[2]
    smlal  v30.4s, v21.4h, v0.h[2]
    smlal2 v31.4s, v21.8h, v0.h[2]
    smlal  v28.4s, v21.4h, v0.h[3]
    smlal2 v29.4s, v21.8h, v0.h[3]
    smlal  v30.4s, v22.4h, v0.h[3]
    smlal2 v31.4s, v22.8h, v0.h[3]

    sqrshrun  v24.4h, v24.4s, #10
    sqrshrun2 v24.8h, v25.4s, #10
    sqrshrun  v25.4h, v26.4s, #10
    sqrshrun2 v25.8h, v27.4s, #10
    sqrshrun  v26.4h, v28.4s, #10
    sqrshrun2 v26.8h, v29.4s, #10
    sqrshrun  v27.4h, v30.4s, #10
    sqrshrun2 v27.8h, v31.4s, #10

    umin v24.8h, v24.8h, v15.8h
    umin v25.8h, v25.8h, v15.8h
    umin v26.8h, v26.8h, v15.8h
    umin v27.8h, v27.8h, v15.8h

    subs w5, w5, #4
    mov x17, x10
    st1 {v24.8h}, [x2], x3
    st1 {v25.8h}, [x2], x3
    st1 {v26.8h}, [x2], x3
    st1 {v27.8h}, [x2], x3
    bgt if_hor_ver_chroma_w8_ver_10bit_loop_y

    add sp, sp, x15                     // (32 + 4)*8*sizeof(short)
    ld1 {v15.2d}, [sp], #16

    ret
    
//void com_if_filter_hor_Ver_4_w16_arm64(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8n 0- *coeff_v, int bit_depth)
//src->x0, i_src->x1, dst->x2, i_dst->x3, width->x4, height->x5, coeff_h->x6, coeff_v->x7
function com_if_filter_hor_Ver_4_w16_arm64
    mov x8, #1
    lsl x8, x8, #10
    sub x8, x8, #1

    sub sp, sp, #16
    st1 {v15.2d}, [sp]

    lsl x1, x1, #1
    lsl x3, x3, #1

    // align (x17)
    // x17-->tmp
    mov x15, #68                            // #68
    lsl x15, x15, #5
    sub x17, sp, x15                        // (64 + 4)*16*sizeof(short)
    mov sp, x17

    sub x0, x0, x1                          // src += -1 * i_src;
//--------------------------------
// HOR
//--------------------------------
    ld1 {v4.s}[0], [x6]
    dup v15.8h, w8
    abs v3.8b, v4.8b
    uxtl v3.8h, v3.8b

    dup v0.8h, v3.h[0]
    dup v1.8h, v3.h[1]
    dup v2.8h, v3.h[2]
    dup v3.8h, v3.h[3]
    sub x0, x0, #2                          // x - 1 UV
    sub x1, x1, #32

    add w8, w5, #3
if_hor_ver_chroma_w16_hor_10bit_loop_y:
    ld1 {v16.8h, v17.8h}, [x0], #32         // src[x-1]
    ld1 {v18.8h}, [x0], x1

    ext v19.16b, v16.16b, v17.16b, #2       // src[x]
    ext v20.16b, v16.16b, v17.16b, #4       // src[x+1]
    ext v21.16b, v16.16b, v17.16b, #6       // src[x+2]
    ext v22.16b, v17.16b, v18.16b, #2
    ext v23.16b, v17.16b, v18.16b, #4
    ext v24.16b, v17.16b, v18.16b, #6

    umull  v28.4s, v19.4h, v1.4h
    umull2 v29.4s, v19.8h, v1.8h
    umlsl  v28.4s, v16.4h, v0.4h
    umlsl2 v29.4s, v16.8h, v0.8h
    umlal  v28.4s, v20.4h, v2.4h
    umlal2 v29.4s, v20.8h, v2.8h
    umlsl  v28.4s, v21.4h, v3.4h
    umlsl2 v29.4s, v21.8h, v3.8h

    umull  v30.4s, v22.4h, v1.4h
    umull2 v31.4s, v22.8h, v1.8h
    umlsl  v30.4s, v17.4h, v0.4h
    umlsl2 v31.4s, v17.8h, v0.8h
    umlal  v30.4s, v23.4h, v2.4h
    umlal2 v31.4s, v23.8h, v2.8h
    umlsl  v30.4s, v24.4h, v3.4h
    umlsl2 v31.4s, v24.8h, v3.8h

    rshrn  v28.4h, v28.4s, #2
    rshrn2 v28.8h, v29.4s, #2
    rshrn  v29.4h, v30.4s, #2
    rshrn2 v29.8h, v31.4s, #2

    subs w8, w8, #1
    st1 {v28.8h, v29.8h}, [x17], #32
    bgt if_hor_ver_chroma_w16_hor_10bit_loop_y

//--------------------------------
// VER
//--------------------------------
    mov x17, sp

    ld1 {v0.s}[0], [x7]                     // load coeff
    sxtl v0.8h, v0.8b                       // 8bit to 16bit

if_hor_ver_chroma_w16_ver_10bit_loop_y:
    ld1 {v16.8h, v17.8h, v18.8h, v19.8h}, [x17], #64
    mov x10, x17
    ld1 {v20.8h, v21.8h, v22.8h, v23.8h}, [x17], #64
    ld1 {v2.8h, v3.8h}, [x17]

    smull  v24.4s, v16.4h, v0.h[0]
    smull2 v25.4s, v16.8h, v0.h[0]
    smull  v26.4s, v17.4h, v0.h[0]
    smull2 v27.4s, v17.8h, v0.h[0]
    smlal  v24.4s, v18.4h, v0.h[1]
    smlal2 v25.4s, v18.8h, v0.h[1]
    smlal  v26.4s, v19.4h, v0.h[1]
    smlal2 v27.4s, v19.8h, v0.h[1]
    smlal  v24.4s, v20.4h, v0.h[2]
    smlal2 v25.4s, v20.8h, v0.h[2]
    smlal  v26.4s, v21.4h, v0.h[2]
    smlal2 v27.4s, v21.8h, v0.h[2]
    smlal  v24.4s, v22.4h, v0.h[3]
    smlal2 v25.4s, v22.8h, v0.h[3]
    smlal  v26.4s, v23.4h, v0.h[3]
    smlal2 v27.4s, v23.8h, v0.h[3]

    smull  v28.4s, v18.4h, v0.h[0]
    smull2 v29.4s, v18.8h, v0.h[0]
    smull  v30.4s, v19.4h, v0.h[0]
    smull2 v31.4s, v19.8h, v0.h[0]
    smlal  v28.4s, v20.4h, v0.h[1]
    smlal2 v29.4s, v20.8h, v0.h[1]
    smlal  v30.4s, v21.4h, v0.h[1]
    smlal2 v31.4s, v21.8h, v0.h[1]
    smlal  v28.4s, v22.4h, v0.h[2]
    smlal2 v29.4s, v22.8h, v0.h[2]
    smlal  v30.4s, v23.4h, v0.h[2]
    smlal2 v31.4s, v23.8h, v0.h[2]
    smlal  v28.4s, v2.4h, v0.h[3]
    smlal2 v29.4s, v2.8h, v0.h[3]
    smlal  v30.4s, v3.4h, v0.h[3]
    smlal2 v31.4s, v3.8h, v0.h[3]

    sqrshrun  v24.4h, v24.4s, #10
    sqrshrun2 v24.8h, v25.4s, #10
    sqrshrun  v25.4h, v26.4s, #10
    sqrshrun2 v25.8h, v27.4s, #10
    sqrshrun  v26.4h, v28.4s, #10
    sqrshrun2 v26.8h, v29.4s, #10
    sqrshrun  v27.4h, v30.4s, #10
    sqrshrun2 v27.8h, v31.4s, #10

    umin v24.8h, v24.8h, v15.8h
    umin v25.8h, v25.8h, v15.8h
    umin v26.8h, v26.8h, v15.8h
    umin v27.8h, v27.8h, v15.8h

    subs w5, w5, #2
    mov x17, x10                            // tmp += 64;
    st1 {v24.8h, v25.8h}, [x2], x3
    st1 {v26.8h, v27.8h}, [x2], x3
    bgt if_hor_ver_chroma_w16_ver_10bit_loop_y

    add sp, sp, x15                     // (64 + 4)*16*sizeof(short)
    ld1 {v15.2d}, [sp], #16

    ret

#endif

#endif
