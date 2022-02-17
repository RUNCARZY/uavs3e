#include "def_arm64.S"
#if defined(__arm64__)

//*************************************************************************************************
//void partialButterfly4x4_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift);
//x0: coeff blk, 16 bit
//x1: i_src
//x2: dst
//x3: i_dst
//x4: shift
//*************************************************************************************************
function partialButterfly4x4_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1

    //transcode coeffs
    mov w5, #32
    neg w6, w5
    mov w7, #42
    neg w8, w7
    mov w9, #17
    neg w10, w9
    mov v4.h[0], w5
    mov v4.h[1], w7
    mov v4.h[2], w5
    mov v4.h[3], w9         //32 42 32 17
    mov v5.h[0], w5
    mov v5.h[1], w9
    mov v5.h[2], w6
    mov v5.h[3], w8         //32 17 -32 -42
    mov v6.h[0], w5
    mov v6.h[1], w10
    mov v6.h[2], w6
    mov v6.h[3], w7         //32 -17 -32 42
    mov v7.h[0], w5
    mov v7.h[1], w8
    mov v7.h[2], w5
    mov v7.h[3], w10        //32 -42 32 -17

    //load src
    ld1 {v0.d}[0], [x0], x1
    ld1 {v1.d}[0], [x0], x1
    ld1 {v2.d}[0], [x0], x1
    ld1 {v3.d}[0], [x0], x1

    smull v16.4s, v4.4h, v0.h[0]
    smlal v16.4s, v5.4h, v0.h[1]
    smlal v16.4s, v6.4h, v0.h[2]
    smlal v16.4s, v7.4h, v0.h[3]
    smull v17.4s, v4.4h, v1.h[0]
    smlal v17.4s, v5.4h, v1.h[1]
    smlal v17.4s, v6.4h, v1.h[2]
    smlal v17.4s, v7.4h, v1.h[3]
    smull v18.4s, v4.4h, v2.h[0]
    smlal v18.4s, v5.4h, v2.h[1]
    smlal v18.4s, v6.4h, v2.h[2]
    smlal v18.4s, v7.4h, v2.h[3]
    smull v19.4s, v4.4h, v3.h[0]
    smlal v19.4s, v5.4h, v3.h[1]
    smlal v19.4s, v6.4h, v3.h[2]
    smlal v19.4s, v7.4h, v3.h[3]

    cmp x4, #0
    bgt tx_dct2_pb4_shift2
    sqxtn v16.4h, v16.4s
    sqxtn v17.4h, v17.4s
    sqxtn v18.4h, v18.4s
    sqxtn v19.4h, v19.4s
    b tx_dct2_pb4_end
    
tx_dct2_pb4_shift2:
    cmp x4, #2
    bgt tx_dct2_pb4_shift7
    sqrshrn v16.4h, v16.4s, #2
    sqrshrn v17.4h, v17.4s, #2
    sqrshrn v18.4h, v18.4s, #2
    sqrshrn v19.4h, v19.4s, #2
    b tx_dct2_pb4_end

tx_dct2_pb4_shift7:
    sqrshrn v16.4h, v16.4s, #7
    sqrshrn v17.4h, v17.4s, #7
    sqrshrn v18.4h, v18.4s, #7
    sqrshrn v19.4h, v19.4s, #7

tx_dct2_pb4_end:
    st4 {v16.h - v19.h}[0], [x2], x3
    st4 {v16.h - v19.h}[1], [x2], x3
    st4 {v16.h - v19.h}[2], [x2], x3
    st4 {v16.h - v19.h}[3], [x2], x3

    ret


tx_dct2_pb8_coef:
.hword 32, 44, 42, 38, 32, 25, 17, 9, \
       32, 38, 17, -9, -32, -44, -42, -25, \
       32, 25, -17, -44, -32, 9, 42, 38, \
       32, 9, -42, -25, 32, 38, -17, -44, \
       32, -9, -42, 25, 32, -38, -17, 44, \
       32, -25, -17, 44, -32, -9, 42, -38, \
       32, -38, 17, 9, -32, 44, -42, 25, \
       32, -44, 42, -38, 32, -25, 17, -9

//*************************************************************************************************
//void partialButterfly8x8_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift);
//x0: coeff blk, 16 bit
//x1: i_src
//x2: dst
//x3: i_dst
//x4: shift
//*************************************************************************************************
function partialButterfly8x8_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1

    adr x7, tx_dct2_pb8_coef
    ld1 {v16.8h - v19.8h}, [x7], #64
    ld1 {v20.8h - v23.8h}, [x7]
    mov x7, #0
    mov x8, #2

tx_dct2_pb8_loop:
    //load src
    ld1 {v0.8h}, [x0], x1
    ld1 {v1.8h}, [x0], x1
    ld1 {v2.8h}, [x0], x1
    ld1 {v3.8h}, [x0], x1

    smull v24.4s, v16.4h, v0.h[0]
    smull2 v25.4s, v16.8h, v0.h[0]
    smlal v24.4s, v17.4h, v0.h[1]
    smlal2 v25.4s, v17.8h, v0.h[1]
    smlal v24.4s, v18.4h, v0.h[2]
    smlal2 v25.4s, v18.8h, v0.h[2]
    smlal v24.4s, v19.4h, v0.h[3]
    smlal2 v25.4s, v19.8h, v0.h[3]
    smlal v24.4s, v20.4h, v0.h[4]
    smlal2 v25.4s, v20.8h, v0.h[4]
    smlal v24.4s, v21.4h, v0.h[5]
    smlal2 v25.4s, v21.8h, v0.h[5]
    smlal v24.4s, v22.4h, v0.h[6]
    smlal2 v25.4s, v22.8h, v0.h[6]
    smlal v24.4s, v23.4h, v0.h[7]
    smlal2 v25.4s, v23.8h, v0.h[7]

    smull v26.4s, v16.4h, v1.h[0]
    smull2 v27.4s, v16.8h, v1.h[0]
    smlal v26.4s, v17.4h, v1.h[1]
    smlal2 v27.4s, v17.8h, v1.h[1]
    smlal v26.4s, v18.4h, v1.h[2]
    smlal2 v27.4s, v18.8h, v1.h[2]
    smlal v26.4s, v19.4h, v1.h[3]
    smlal2 v27.4s, v19.8h, v1.h[3]
    smlal v26.4s, v20.4h, v1.h[4]
    smlal2 v27.4s, v20.8h, v1.h[4]
    smlal v26.4s, v21.4h, v1.h[5]
    smlal2 v27.4s, v21.8h, v1.h[5]
    smlal v26.4s, v22.4h, v1.h[6]
    smlal2 v27.4s, v22.8h, v1.h[6]
    smlal v26.4s, v23.4h, v1.h[7]
    smlal2 v27.4s, v23.8h, v1.h[7]

    smull v28.4s, v16.4h, v2.h[0]
    smull2 v29.4s, v16.8h, v2.h[0]
    smlal v28.4s, v17.4h, v2.h[1]
    smlal2 v29.4s, v17.8h, v2.h[1]
    smlal v28.4s, v18.4h, v2.h[2]
    smlal2 v29.4s, v18.8h, v2.h[2]
    smlal v28.4s, v19.4h, v2.h[3]
    smlal2 v29.4s, v19.8h, v2.h[3]
    smlal v28.4s, v20.4h, v2.h[4]
    smlal2 v29.4s, v20.8h, v2.h[4]
    smlal v28.4s, v21.4h, v2.h[5]
    smlal2 v29.4s, v21.8h, v2.h[5]
    smlal v28.4s, v22.4h, v2.h[6]
    smlal2 v29.4s, v22.8h, v2.h[6]
    smlal v28.4s, v23.4h, v2.h[7]
    smlal2 v29.4s, v23.8h, v2.h[7]

    smull v30.4s, v16.4h, v3.h[0]
    smull2 v31.4s, v16.8h, v3.h[0]
    smlal v30.4s, v17.4h, v3.h[1]
    smlal2 v31.4s, v17.8h, v3.h[1]
    smlal v30.4s, v18.4h, v3.h[2]
    smlal2 v31.4s, v18.8h, v3.h[2]
    smlal v30.4s, v19.4h, v3.h[3]
    smlal2 v31.4s, v19.8h, v3.h[3]
    smlal v30.4s, v20.4h, v3.h[4]
    smlal2 v31.4s, v20.8h, v3.h[4]
    smlal v30.4s, v21.4h, v3.h[5]
    smlal2 v31.4s, v21.8h, v3.h[5]
    smlal v30.4s, v22.4h, v3.h[6]
    smlal2 v31.4s, v22.8h, v3.h[6]
    smlal v30.4s, v23.4h, v3.h[7]
    smlal2 v31.4s, v23.8h, v3.h[7]

    cmp w4, #1
    bgt tx_dct2_pb8_shift3
    sqrshrn v0.4h, v24.4s, #1
    sqrshrn v1.4h, v26.4s, #1
    sqrshrn v2.4h, v28.4s, #1
    sqrshrn v3.4h, v30.4s, #1
    sqrshrn v4.4h, v25.4s, #1
    sqrshrn v5.4h, v27.4s, #1
    sqrshrn v6.4h, v29.4s, #1
    sqrshrn v7.4h, v31.4s, #1
    b tx_dct2_pb8_end

tx_dct2_pb8_shift3:
    cmp w4, #3
    bgt tx_dct2_pb8_shift8
    sqrshrn v0.4h, v24.4s, #3
    sqrshrn v1.4h, v26.4s, #3
    sqrshrn v2.4h, v28.4s, #3
    sqrshrn v3.4h, v30.4s, #3
    sqrshrn v4.4h, v25.4s, #3
    sqrshrn v5.4h, v27.4s, #3
    sqrshrn v6.4h, v29.4s, #3
    sqrshrn v7.4h, v31.4s, #3
    b tx_dct2_pb8_end

tx_dct2_pb8_shift8:
    sqrshrn v0.4h, v24.4s, #8
    sqrshrn v1.4h, v26.4s, #8
    sqrshrn v2.4h, v28.4s, #8
    sqrshrn v3.4h, v30.4s, #8
    sqrshrn v4.4h, v25.4s, #8
    sqrshrn v5.4h, v27.4s, #8
    sqrshrn v6.4h, v29.4s, #8
    sqrshrn v7.4h, v31.4s, #8

tx_dct2_pb8_end:
    add x6, x2, x7
    mov x5, #16
    st4 {v0.h - v3.h}[0], [x6], x5
    st4 {v0.h - v3.h}[1], [x6], x5
    st4 {v0.h - v3.h}[2], [x6], x5
    st4 {v0.h - v3.h}[3], [x6], x5
    st4 {v4.h - v7.h}[0], [x6], x5
    st4 {v4.h - v7.h}[1], [x6], x5
    st4 {v4.h - v7.h}[2], [x6], x5
    st4 {v4.h - v7.h}[3], [x6], x5
    add x7, x7, #8
    subs x8, x8, #1
    bgt tx_dct2_pb8_loop

    ret


tx_dct2_pb16_coef:
.hword 32, 45, 44, 43, 42, 40, 38, 35, 32, 29, 25, 21, 17, 13, 9, 4, \
       32, 43, 38, 29, 17, 4, -9, -21, -32, -40, -44, -45, -42, -35, -25, -13, \
       32, 40, 25, 4, -17, -35, -44, -43, -32, -13, 9, 29, 42, 45, 38, 21, \
       32, 35, 9, -21, -42, -43, -25, 4, 32, 45, 38, 13, -17, -40, -44, -29, \
       32, 29, -9, -40, -42, -13, 25, 45, 32, -4, -38, -43, -17, 21, 44, 35, \
       32, 21, -25, -45, -17, 29, 44, 13, -32, -43, -9, 35, 42, 4, -38, -40, \
       32, 13, -38, -35, 17, 45, 9, -40, -32, 21, 44, 4, -42, -29, 25, 43, \
       32, 4, -44, -13, 42, 21, -38, -29, 32, 35, -25, -40, 17, 43, -9, -45, \
       32, -4, -44, 13, 42, -21, -38, 29, 32, -35, -25, 40, 17, -43, -9, 45, \
       32, -13, -38, 35, 17, -45, 9, 40, -32, -21, 44, -4, -42, 29, 25, -43, \
       32, -21, -25, 45, -17, -29, 44, -13, -32, 43, -9, -35, 42, -4, -38, 40, \
       32, -29, -9, 40, -42, 13, 25, -45, 32, 4, -38, 43, -17, -21, 44, -35, \
       32, -35, 9, 21, -42, 43, -25, -4, 32, -45, 38, -13, -17, 40, -44, 29, \
       32, -40, 25, -4, -17, 35, -44, 43, -32, 13, 9, -29, 42, -45, 38, -21, \
       32, -43, 38, -29, 17, -4, -9, 21, -32, 40, -44, 45, -42, 35, -25, 13, \
       32, -45, 44, -43, 42, -40, 38, -35, 32, -29, 25, -21, 17, -13, 9, -4

//*************************************************************************************************
//void partialButterfly16x16_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift);
//x0: coeff blk, 16 bit
//x1: i_src
//x2: dst
//x3: i_dst
//x4: shift
//*************************************************************************************************
function partialButterfly16x16_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    adr x7, tx_dct2_pb16_coef
    mov x12, #32    //i_src
    mov x10, #4     //k

tx_dct2_pb16_loopk:
    mov x8, #0
    mov x11, x2
tx_dct2_pb16_loopj:
    mov x5, #0
    movi v24.16b, #0
    movi v25.16b, #0
    movi v26.16b, #0
    movi v27.16b, #0
    movi v28.16b, #0
    movi v29.16b, #0
    movi v30.16b, #0
    movi v31.16b, #0
tx_dct2_pb16_loopi:
    //load src
    add x6, x0, x5
    ld1 {v0.8h}, [x6], x1
    ld1 {v1.8h}, [x6], x1
    ld1 {v2.8h}, [x6], x1
    ld1 {v3.8h}, [x6], x1

    //load coef
    add x9, x7, x8
    ld1 {v16.8h}, [x9], x12
    ld1 {v17.8h}, [x9], x12
    ld1 {v18.8h}, [x9], x12
    ld1 {v19.8h}, [x9], x12
    ld1 {v20.8h}, [x9], x12
    ld1 {v21.8h}, [x9], x12
    ld1 {v22.8h}, [x9], x12
    ld1 {v23.8h}, [x9], x12

    smlal v24.4s, v16.4h, v0.h[0]
    smlal2 v25.4s, v16.8h, v0.h[0]
    smlal v24.4s, v17.4h, v0.h[1]
    smlal2 v25.4s, v17.8h, v0.h[1]
    smlal v24.4s, v18.4h, v0.h[2]
    smlal2 v25.4s, v18.8h, v0.h[2]
    smlal v24.4s, v19.4h, v0.h[3]
    smlal2 v25.4s, v19.8h, v0.h[3]
    smlal v24.4s, v20.4h, v0.h[4]
    smlal2 v25.4s, v20.8h, v0.h[4]
    smlal v24.4s, v21.4h, v0.h[5]
    smlal2 v25.4s, v21.8h, v0.h[5]
    smlal v24.4s, v22.4h, v0.h[6]
    smlal2 v25.4s, v22.8h, v0.h[6]
    smlal v24.4s, v23.4h, v0.h[7]
    smlal2 v25.4s, v23.8h, v0.h[7]

    smlal v26.4s, v16.4h, v1.h[0]
    smlal2 v27.4s, v16.8h, v1.h[0]
    smlal v26.4s, v17.4h, v1.h[1]
    smlal2 v27.4s, v17.8h, v1.h[1]
    smlal v26.4s, v18.4h, v1.h[2]
    smlal2 v27.4s, v18.8h, v1.h[2]
    smlal v26.4s, v19.4h, v1.h[3]
    smlal2 v27.4s, v19.8h, v1.h[3]
    smlal v26.4s, v20.4h, v1.h[4]
    smlal2 v27.4s, v20.8h, v1.h[4]
    smlal v26.4s, v21.4h, v1.h[5]
    smlal2 v27.4s, v21.8h, v1.h[5]
    smlal v26.4s, v22.4h, v1.h[6]
    smlal2 v27.4s, v22.8h, v1.h[6]
    smlal v26.4s, v23.4h, v1.h[7]
    smlal2 v27.4s, v23.8h, v1.h[7]

    smlal v28.4s, v16.4h, v2.h[0]
    smlal2 v29.4s, v16.8h, v2.h[0]
    smlal v28.4s, v17.4h, v2.h[1]
    smlal2 v29.4s, v17.8h, v2.h[1]
    smlal v28.4s, v18.4h, v2.h[2]
    smlal2 v29.4s, v18.8h, v2.h[2]
    smlal v28.4s, v19.4h, v2.h[3]
    smlal2 v29.4s, v19.8h, v2.h[3]
    smlal v28.4s, v20.4h, v2.h[4]
    smlal2 v29.4s, v20.8h, v2.h[4]
    smlal v28.4s, v21.4h, v2.h[5]
    smlal2 v29.4s, v21.8h, v2.h[5]
    smlal v28.4s, v22.4h, v2.h[6]
    smlal2 v29.4s, v22.8h, v2.h[6]
    smlal v28.4s, v23.4h, v2.h[7]
    smlal2 v29.4s, v23.8h, v2.h[7]

    smlal v30.4s, v16.4h, v3.h[0]
    smlal2 v31.4s, v16.8h, v3.h[0]
    smlal v30.4s, v17.4h, v3.h[1]
    smlal2 v31.4s, v17.8h, v3.h[1]
    smlal v30.4s, v18.4h, v3.h[2]
    smlal2 v31.4s, v18.8h, v3.h[2]
    smlal v30.4s, v19.4h, v3.h[3]
    smlal2 v31.4s, v19.8h, v3.h[3]
    smlal v30.4s, v20.4h, v3.h[4]
    smlal2 v31.4s, v20.8h, v3.h[4]
    smlal v30.4s, v21.4h, v3.h[5]
    smlal2 v31.4s, v21.8h, v3.h[5]
    smlal v30.4s, v22.4h, v3.h[6]
    smlal2 v31.4s, v22.8h, v3.h[6]
    smlal v30.4s, v23.4h, v3.h[7]
    smlal2 v31.4s, v23.8h, v3.h[7]

    add x5, x5, #16
    add x8, x8, #256
    cmp x5, #16
    beq tx_dct2_pb16_loopi

    cmp w4, #2
    bgt tx_dct2_pb16_shift4
    sqrshrn v0.4h, v24.4s, #2
    sqrshrn v1.4h, v26.4s, #2
    sqrshrn v2.4h, v28.4s, #2
    sqrshrn v3.4h, v30.4s, #2
    sqrshrn v4.4h, v25.4s, #2
    sqrshrn v5.4h, v27.4s, #2
    sqrshrn v6.4h, v29.4s, #2
    sqrshrn v7.4h, v31.4s, #2
    b tx_dct2_pb16_end

tx_dct2_pb16_shift4:
    cmp w4, #4
    bgt tx_dct2_pb16_shift9
    sqrshrn v0.4h, v24.4s, #4
    sqrshrn v1.4h, v26.4s, #4
    sqrshrn v2.4h, v28.4s, #4
    sqrshrn v3.4h, v30.4s, #4
    sqrshrn v4.4h, v25.4s, #4
    sqrshrn v5.4h, v27.4s, #4
    sqrshrn v6.4h, v29.4s, #4
    sqrshrn v7.4h, v31.4s, #4
    b tx_dct2_pb16_end

tx_dct2_pb16_shift9:
    sqrshrn v0.4h, v24.4s, #9
    sqrshrn v1.4h, v26.4s, #9
    sqrshrn v2.4h, v28.4s, #9
    sqrshrn v3.4h, v30.4s, #9
    sqrshrn v4.4h, v25.4s, #9
    sqrshrn v5.4h, v27.4s, #9
    sqrshrn v6.4h, v29.4s, #9
    sqrshrn v7.4h, v31.4s, #9

tx_dct2_pb16_end:
    st4 {v0.h - v3.h}[0], [x11], x12
    st4 {v0.h - v3.h}[1], [x11], x12
    st4 {v0.h - v3.h}[2], [x11], x12
    st4 {v0.h - v3.h}[3], [x11], x12
    st4 {v4.h - v7.h}[0], [x11], x12
    st4 {v4.h - v7.h}[1], [x11], x12
    st4 {v4.h - v7.h}[2], [x11], x12
    st4 {v4.h - v7.h}[3], [x11], x12

    sub x8, x8, #496
    cmp x8, #16
    beq tx_dct2_pb16_loopj

    add x0, x0, #128
    add x2, x2, #8
    subs x10, x10, #1
    bgt tx_dct2_pb16_loopk

    ret

tx_dct2_pb32_coef:
.hword 32, 45, 45, 45, 44, 44, 43, 43, 42, 41, 40, 39, 38, 36, 35, 34, 32, 30, 29, 27, 25, 23, 21, 19, 17, 15, 13, 11, 9, 7, 4, 2, \
       32, 45, 43, 41, 38, 34, 29, 23, 17, 11, 4, -2, -9, -15, -21, -27, -32, -36, -40, -43, -44, -45, -45, -44, -42, -39, -35, -30, -25, -19, -13, -7, \
       32, 44, 40, 34, 25, 15, 4, -7, -17, -27, -35, -41, -44, -45, -43, -39, -32, -23, -13, -2, 9, 19, 29, 36, 42, 45, 45, 43, 38, 30, 21, 11, \
       32, 43, 35, 23, 9, -7, -21, -34, -42, -45, -43, -36, -25, -11, 4, 19, 32, 41, 45, 44, 38, 27, 13, -2, -17, -30, -40, -45, -44, -39, -29, -15, \
       32, 41, 29, 11, -9, -27, -40, -45, -42, -30, -13, 7, 25, 39, 45, 43, 32, 15, -4, -23, -38, -45, -43, -34, -17, 2, 21, 36, 44, 44, 35, 19, \
       32, 39, 21, -2, -25, -41, -45, -36, -17, 7, 29, 43, 44, 34, 13, -11, -32, -44, -43, -30, -9, 15, 35, 45, 42, 27, 4, -19, -38, -45, -40, -23, \
       32, 36, 13, -15, -38, -45, -35, -11, 17, 39, 45, 34, 9, -19, -40, -45, -32, -7, 21, 41, 44, 30, 4, -23, -42, -44, -29, -2, 25, 43, 43, 27, \
       32, 34, 4, -27, -44, -39, -13, 19, 42, 43, 21, -11, -38, -45, -29, 2, 32, 45, 35, 7, -25, -44, -40, -15, 17, 41, 43, 23, -9, -36, -45, -30, \
       32, 30, -4, -36, -44, -23, 13, 41, 42, 15, -21, -44, -38, -7, 29, 45, 32, -2, -35, -45, -25, 11, 40, 43, 17, -19, -43, -39, -9, 27, 45, 34, \
       32, 27, -13, -43, -38, -2, 35, 44, 17, -23, -45, -30, 9, 41, 40, 7, -32, -45, -21, 19, 44, 34, -4, -39, -42, -11, 29, 45, 25, -15, -43, -36, \
       32, 23, -21, -45, -25, 19, 45, 27, -17, -45, -29, 15, 44, 30, -13, -44, -32, 11, 43, 34, -9, -43, -35, 7, 42, 36, -4, -41, -38, 2, 40, 39, \
       32, 19, -29, -44, -9, 36, 40, -2, -42, -34, 13, 45, 25, -23, -45, -15, 32, 43, 4, -39, -38, 7, 43, 30, -17, -45, -21, 27, 44, 11, -35, -41, \
       32, 15, -35, -39, 9, 45, 21, -30, -42, 2, 43, 27, -25, -44, -4, 41, 32, -19, -45, -11, 38, 36, -13, -45, -17, 34, 40, -7, -44, -23, 29, 43, \
       32, 11, -40, -30, 25, 43, -4, -45, -17, 36, 35, -19, -44, -2, 43, 23, -32, -39, 13, 45, 9, -41, -29, 27, 42, -7, -45, -15, 38, 34, -21, -44, \
       32, 7, -43, -19, 38, 30, -29, -39, 17, 44, -4, -45, -9, 43, 21, -36, -32, 27, 40, -15, -44, 2, 45, 11, -42, -23, 35, 34, -25, -41, 13, 45, \
       32, 2, -45, -7, 44, 11, -43, -15, 42, 19, -40, -23, 38, 27, -35, -30, 32, 34, -29, -36, 25, 39, -21, -41, 17, 43, -13, -44, 9, 45, -4, -45, \
       32, -2, -45, 7, 44, -11, -43, 15, 42, -19, -40, 23, 38, -27, -35, 30, 32, -34, -29, 36, 25, -39, -21, 41, 17, -43, -13, 44, 9, -45, -4, 45, \
       32, -7, -43, 19, 38, -30, -29, 39, 17, -44, -4, 45, -9, -43, 21, 36, -32, -27, 40, 15, -44, -2, 45, -11, -42, 23, 35, -34, -25, 41, 13, -45, \
       32, -11, -40, 30, 25, -43, -4, 45, -17, -36, 35, 19, -44, 2, 43, -23, -32, 39, 13, -45, 9, 41, -29, -27, 42, 7, -45, 15, 38, -34, -21, 44, \
       32, -15, -35, 39, 9, -45, 21, 30, -42, -2, 43, -27, -25, 44, -4, -41, 32, 19, -45, 11, 38, -36, -13, 45, -17, -34, 40, 7, -44, 23, 29, -43, \
       32, -19, -29, 44, -9, -36, 40, 2, -42, 34, 13, -45, 25, 23, -45, 15, 32, -43, 4, 39, -38, -7, 43, -30, -17, 45, -21, -27, 44, -11, -35, 41, \
       32, -23, -21, 45, -25, -19, 45, -27, -17, 45, -29, -15, 44, -30, -13, 44, -32, -11, 43, -34, -9, 43, -35, -7, 42, -36, -4, 41, -38, -2, 40, -39, \
       32, -27, -13, 43, -38, 2, 35, -44, 17, 23, -45, 30, 9, -41, 40, -7, -32, 45, -21, -19, 44, -34, -4, 39, -42, 11, 29, -45, 25, 15, -43, 36, \
       32, -30, -4, 36, -44, 23, 13, -41, 42, -15, -21, 44, -38, 7, 29, -45, 32, 2, -35, 45, -25, -11, 40, -43, 17, 19, -43, 39, -9, -27, 45, -34, \
       32, -34, 4, 27, -44, 39, -13, -19, 42, -43, 21, 11, -38, 45, -29, -2, 32, -45, 35, -7, -25, 44, -40, 15, 17, -41, 43, -23, -9, 36, -45, 30, \
       32, -36, 13, 15, -38, 45, -35, 11, 17, -39, 45, -34, 9, 19, -40, 45, -32, 7, 21, -41, 44, -30, 4, 23, -42, 44, -29, 2, 25, -43, 43, -27, \
       32, -39, 21, 2, -25, 41, -45, 36, -17, -7, 29, -43, 44, -34, 13, 11, -32, 44, -43, 30, -9, -15, 35, -45, 42, -27, 4, 19, -38, 45, -40, 23, \
       32, -41, 29, -11, -9, 27, -40, 45, -42, 30, -13, -7, 25, -39, 45, -43, 32, -15, -4, 23, -38, 45, -43, 34, -17, -2, 21, -36, 44, -44, 35, -19, \
       32, -43, 35, -23, 9, 7, -21, 34, -42, 45, -43, 36, -25, 11, 4, -19, 32, -41, 45, -44, 38, -27, 13, 2, -17, 30, -40, 45, -44, 39, -29, 15, \
       32, -44, 40, -34, 25, -15, 4, 7, -17, 27, -35, 41, -44, 45, -43, 39, -32, 23, -13, 2, 9, -19, 29, -36, 42, -45, 45, -43, 38, -30, 21, -11, \
       32, -45, 43, -41, 38, -34, 29, -23, 17, -11, 4, 2, -9, 15, -21, 27, -32, 36, -40, 43, -44, 45, -45, 44, -42, 39, -35, 30, -25, 19, -13, 7, \
       32, -45, 45, -45, 44, -44, 43, -43, 42, -41, 40, -39, 38, -36, 35, -34, 32, -30, 29, -27, 25, -23, 21, -19, 17, -15, 13, -11, 9, -7, 4, -2
//*************************************************************************************************
//void partialButterfly32x32_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift);
//x0: coeff blk, 16 bit
//x1: i_src
//x2: dst
//x3: i_dst
//x4: shift
//*************************************************************************************************
function partialButterfly32x32_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    adr x7, tx_dct2_pb32_coef
    mov x12, #64    //i_src
    mov x10, #8     //k

tx_dct2_pb32_loopk:
    mov x8, #0
    mov x11, x2
tx_dct2_pb32_loopj:
    mov x5, #0
    movi v24.16b, #0
    movi v25.16b, #0
    movi v26.16b, #0
    movi v27.16b, #0
    movi v28.16b, #0
    movi v29.16b, #0
    movi v30.16b, #0
    movi v31.16b, #0
tx_dct2_pb32_loopi:
    //load src
    add x6, x0, x5
    ld1 {v0.8h}, [x6], x12
    ld1 {v1.8h}, [x6], x12
    ld1 {v2.8h}, [x6], x12
    ld1 {v3.8h}, [x6], x12

    add x9, x7, x8
    ld1 {v16.8h}, [x9], x12
    ld1 {v17.8h}, [x9], x12
    ld1 {v18.8h}, [x9], x12
    ld1 {v19.8h}, [x9], x12
    ld1 {v20.8h}, [x9], x12
    ld1 {v21.8h}, [x9], x12
    ld1 {v22.8h}, [x9], x12
    ld1 {v23.8h}, [x9], x12

    smlal v24.4s, v16.4h, v0.h[0]
    smlal2 v25.4s, v16.8h, v0.h[0]
    smlal v24.4s, v17.4h, v0.h[1]
    smlal2 v25.4s, v17.8h, v0.h[1]
    smlal v24.4s, v18.4h, v0.h[2]
    smlal2 v25.4s, v18.8h, v0.h[2]
    smlal v24.4s, v19.4h, v0.h[3]
    smlal2 v25.4s, v19.8h, v0.h[3]
    smlal v24.4s, v20.4h, v0.h[4]
    smlal2 v25.4s, v20.8h, v0.h[4]
    smlal v24.4s, v21.4h, v0.h[5]
    smlal2 v25.4s, v21.8h, v0.h[5]
    smlal v24.4s, v22.4h, v0.h[6]
    smlal2 v25.4s, v22.8h, v0.h[6]
    smlal v24.4s, v23.4h, v0.h[7]
    smlal2 v25.4s, v23.8h, v0.h[7]

    smlal v26.4s, v16.4h, v1.h[0]
    smlal2 v27.4s, v16.8h, v1.h[0]
    smlal v26.4s, v17.4h, v1.h[1]
    smlal2 v27.4s, v17.8h, v1.h[1]
    smlal v26.4s, v18.4h, v1.h[2]
    smlal2 v27.4s, v18.8h, v1.h[2]
    smlal v26.4s, v19.4h, v1.h[3]
    smlal2 v27.4s, v19.8h, v1.h[3]
    smlal v26.4s, v20.4h, v1.h[4]
    smlal2 v27.4s, v20.8h, v1.h[4]
    smlal v26.4s, v21.4h, v1.h[5]
    smlal2 v27.4s, v21.8h, v1.h[5]
    smlal v26.4s, v22.4h, v1.h[6]
    smlal2 v27.4s, v22.8h, v1.h[6]
    smlal v26.4s, v23.4h, v1.h[7]
    smlal2 v27.4s, v23.8h, v1.h[7]

    smlal v28.4s, v16.4h, v2.h[0]
    smlal2 v29.4s, v16.8h, v2.h[0]
    smlal v28.4s, v17.4h, v2.h[1]
    smlal2 v29.4s, v17.8h, v2.h[1]
    smlal v28.4s, v18.4h, v2.h[2]
    smlal2 v29.4s, v18.8h, v2.h[2]
    smlal v28.4s, v19.4h, v2.h[3]
    smlal2 v29.4s, v19.8h, v2.h[3]
    smlal v28.4s, v20.4h, v2.h[4]
    smlal2 v29.4s, v20.8h, v2.h[4]
    smlal v28.4s, v21.4h, v2.h[5]
    smlal2 v29.4s, v21.8h, v2.h[5]
    smlal v28.4s, v22.4h, v2.h[6]
    smlal2 v29.4s, v22.8h, v2.h[6]
    smlal v28.4s, v23.4h, v2.h[7]
    smlal2 v29.4s, v23.8h, v2.h[7]

    smlal v30.4s, v16.4h, v3.h[0]
    smlal2 v31.4s, v16.8h, v3.h[0]
    smlal v30.4s, v17.4h, v3.h[1]
    smlal2 v31.4s, v17.8h, v3.h[1]
    smlal v30.4s, v18.4h, v3.h[2]
    smlal2 v31.4s, v18.8h, v3.h[2]
    smlal v30.4s, v19.4h, v3.h[3]
    smlal2 v31.4s, v19.8h, v3.h[3]
    smlal v30.4s, v20.4h, v3.h[4]
    smlal2 v31.4s, v20.8h, v3.h[4]
    smlal v30.4s, v21.4h, v3.h[5]
    smlal2 v31.4s, v21.8h, v3.h[5]
    smlal v30.4s, v22.4h, v3.h[6]
    smlal2 v31.4s, v22.8h, v3.h[6]
    smlal v30.4s, v23.4h, v3.h[7]
    smlal2 v31.4s, v23.8h, v3.h[7]

    add x5, x5, #16
    add x8, x8, #512
    cmp x5, #64
    bne tx_dct2_pb32_loopi

    cmp w4, #3
    bgt tx_dct2_pb32_shift5
    sqrshrn v0.4h, v24.4s, #3
    sqrshrn v1.4h, v26.4s, #3
    sqrshrn v2.4h, v28.4s, #3
    sqrshrn v3.4h, v30.4s, #3
    sqrshrn v4.4h, v25.4s, #3
    sqrshrn v5.4h, v27.4s, #3
    sqrshrn v6.4h, v29.4s, #3
    sqrshrn v7.4h, v31.4s, #3
    b tx_dct2_pb32_end

    
tx_dct2_pb32_shift5:
    cmp w4, #5
    bgt tx_dct2_pb32_shift10
    sqrshrn v0.4h, v24.4s, #5
    sqrshrn v1.4h, v26.4s, #5
    sqrshrn v2.4h, v28.4s, #5
    sqrshrn v3.4h, v30.4s, #5
    sqrshrn v4.4h, v25.4s, #5
    sqrshrn v5.4h, v27.4s, #5
    sqrshrn v6.4h, v29.4s, #5
    sqrshrn v7.4h, v31.4s, #5
    b tx_dct2_pb32_end

tx_dct2_pb32_shift10:
    sqrshrn v0.4h, v24.4s, #10
    sqrshrn v1.4h, v26.4s, #10
    sqrshrn v2.4h, v28.4s, #10
    sqrshrn v3.4h, v30.4s, #10
    sqrshrn v4.4h, v25.4s, #10
    sqrshrn v5.4h, v27.4s, #10
    sqrshrn v6.4h, v29.4s, #10
    sqrshrn v7.4h, v31.4s, #10

tx_dct2_pb32_end:
    st4 {v0.h - v3.h}[0], [x11], x12
    st4 {v0.h - v3.h}[1], [x11], x12
    st4 {v0.h - v3.h}[2], [x11], x12
    st4 {v0.h - v3.h}[3], [x11], x12
    st4 {v4.h - v7.h}[0], [x11], x12
    st4 {v4.h - v7.h}[1], [x11], x12
    st4 {v4.h - v7.h}[2], [x11], x12
    st4 {v4.h - v7.h}[3], [x11], x12

    sub x8, x8, #2032
    cmp x8, #64
    bne tx_dct2_pb32_loopj

    add x0, x0, #256
    add x2, x2, #8
    subs x10, x10, #1
    bgt tx_dct2_pb32_loopk

    ret

//*************************************************************************************************
//void partialButterflyInverse4x4_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift, int bit_depth);
//x0: coeff blk, 16 bit
//x1: i_src
//x2: dst, 16 bit
//x3: i_dst
//x4: shift
//x5: bit_depth
//*************************************************************************************************
function partialButterflyInverse4x4_arm64

    lsl x1, x1, #1
    lsl x3, x3, #1
    //transcode coeffs
    mov w6, #32
    mov w7, #42
    mov w8, #17
    mov v4.h[0], w6
    mov v4.h[2], w7
    mov v4.h[3], w8

    mov w8, #1
    lsl w8, w8, w5
    sub w6, w5, #20                 // -shift = bit_depth - 20
    sub w9, w8, #1                  // max_pel = (1<<bit_depth) - 1
    neg w8, w8                      // min_pel = -(1<<bit_depth)
    dup v31.4s, w6                  // for left shift
    dup v5.4h, w8                   // min_pel
    dup v6.4h, w9                   // max_pel

    ld1 {v0.4h}, [x0], x1
    ld1 {v1.4h}, [x0], x1
    ld1 {v2.4h}, [x0], x1
    ld1 {v3.4h}, [x0], x1

    //O[0]
    smull v16.4s, v1.4h, v4.h[2]
    smlal v16.4s, v3.4h, v4.h[3]
    //O[1]
    smull v17.4s, v1.4h, v4.h[3]
    smlsl v17.4s, v3.4h, v4.h[2]
    //E[0]
    smull v18.4s, v0.4h, v4.h[0]
    smlal v18.4s, v2.4h, v4.h[0]
    //E[1]
    smull v19.4s, v0.4h, v4.h[0]
    smlsl v19.4s, v2.4h, v4.h[0]

    sqadd v20.4s, v16.4s, v18.4s
    sqadd v21.4s, v19.4s, v17.4s
    sqsub v22.4s, v19.4s, v17.4s
    sqsub v23.4s, v18.4s, v16.4s

    cmp w5, #15
    bne dct2_h4_2nd_shift_clip
    sqrshrn v0.4h, v20.4s, #5
    sqrshrn v1.4h, v21.4s, #5
    sqrshrn v2.4h, v22.4s, #5
    sqrshrn v3.4h, v23.4s, #5
    b dct2_h4_store

dct2_h4_2nd_shift_clip:    // second transform
    srshl v0.4s, v20.4s, v31.4s
    srshl v1.4s, v21.4s, v31.4s
    srshl v2.4s, v22.4s, v31.4s
    srshl v3.4s, v23.4s, v31.4s

    sqxtn v0.4h, v0.4s
    sqxtn v1.4h, v1.4s
    sqxtn v2.4h, v2.4s
    sqxtn v3.4h, v3.4s

    smin v0.4h, v0.4h, v6.4h
    smax v0.4h, v0.4h, v5.4h
    smin v1.4h, v1.4h, v6.4h
    smax v1.4h, v1.4h, v5.4h
    smin v2.4h, v2.4h, v6.4h
    smax v2.4h, v2.4h, v5.4h
    smin v3.4h, v3.4h, v6.4h
    smax v3.4h, v3.4h, v5.4h

dct2_h4_store:
    //transpose
    trn1 v20.2s, v0.2s, v2.2s
    trn2 v22.2s, v0.2s, v2.2s
    trn1 v21.2s, v1.2s, v3.2s
    trn2 v23.2s, v1.2s, v3.2s
    trn1 v0.4h, v20.4h, v21.4h
    trn2 v1.4h, v20.4h, v21.4h
    trn1 v2.4h, v22.4h, v23.4h
    trn2 v3.4h, v22.4h, v23.4h

    st1 {v0.4h, v1.4h, v2.4h, v3.4h}, [x2], #32

    ret

//************************************************************************
//void partialButterflyInverse8x8_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift, int bit_depth);
//x0: coeff blk, 16 bit
//x1: i_src
//x2: dst, 16 bit
//x3: i_dst
//x4: shift
//x5: bit_depth
//************************************************************************
function partialButterflyInverse8x8_arm64
    sub sp, sp, #16
    st1 {v8.8h}, [sp]   // protect v8

    // set transform coeffs
    mov w9, #32
    mov w6, #17
    mov w7, #42
    mov v8.h[0], w9
    mov v8.h[1], w9
    mov v8.h[2], w6
    mov v8.h[3], w7
    mov w9, #9
    mov w6, #25
    mov w7, #38
    mov w8, #44
    mov v8.h[4], w9
    mov v8.h[5], w6
    mov v8.h[6], w7
    mov v8.h[7], w8

    mov w8, #1
    lsl w8, w8, w5
    sub w6, w5, #20             // -shift = bit_depth - 20
    sub w9, w8, #1              // max_pel = (1<<bit_depth) - 1
    neg w8, w8                  // min_pel = -(1<<bit_depth)
    dup v31.4s, w6              // for left shift
    dup v25.8h, w8              // min_pel
    dup v26.8h, w9              // max_pel

    mov x8, #0                  // i = 0
    lsl x1, x1, #1              // i_src *= sizeof(s16)
    lsl x3, x3, #1              // width *= sizeof(s16)
dct2_h8_loopx:
    add x9, x0, x8
    ld1 {v0.4h}, [x9], x1
    ld1 {v1.4h}, [x9], x1
    ld1 {v2.4h}, [x9], x1
    ld1 {v3.4h}, [x9], x1
    ld1 {v4.4h}, [x9], x1
    ld1 {v5.4h}, [x9], x1
    ld1 {v6.4h}, [x9], x1
    ld1 {v7.4h}, [x9], x1

    //E[0]
    smull v16.4s, v0.4h, v8.H[0]
    smlal v16.4s, v2.4h, v8.H[3]
    smlal v16.4s, v4.4h, v8.H[0]
    smlal v16.4s, v6.4h, v8.H[2]
    //E[1]
    smull v17.4s, v0.4h, v8.H[0]
    smlal v17.4s, v2.4h, v8.H[2]
    smlsl v17.4s, v4.4h, v8.H[0]
    smlsl v17.4s, v6.4h, v8.H[3]
    //E[2]
    smull v18.4s, v0.4h, v8.H[0]
    smlsl v18.4s, v2.4h, v8.H[2]
    smlsl v18.4s, v4.4h, v8.H[0]
    smlal v18.4s, v6.4h, v8.H[3]
    //E[3]
    smull v19.4s, v0.4h, v8.H[0]
    smlsl v19.4s, v2.4h, v8.H[3]
    smlal v19.4s, v4.4h, v8.H[0]
    smlsl v19.4s, v6.4h, v8.H[2]

    //O[0]
    smull v20.4s, v1.4h, v8.H[7]
    smlal v20.4s, v3.4h, v8.H[6]
    smlal v20.4s, v5.4h, v8.H[5]
    smlal v20.4s, v7.4h, v8.H[4]
    //O[1]
    smull v21.4s, v1.4h, v8.H[6]
    smlsl v21.4s, v3.4h, v8.H[4]
    smlsl v21.4s, v5.4h, v8.H[7]
    smlsl v21.4s, v7.4h, v8.H[5]
    //O[2]
    smull v22.4s, v1.4h, v8.H[5]
    smlsl v22.4s, v3.4h, v8.H[7]
    smlal v22.4s, v5.4h, v8.H[4]
    smlal v22.4s, v7.4h, v8.H[6]
    //O[3]
    smull v23.4s, v1.4h, v8.H[4]
    smlsl v23.4s, v3.4h, v8.H[5]
    smlal v23.4s, v5.4h, v8.H[6]
    smlsl v23.4s, v7.4h, v8.H[7]

    //CALCULATE DST
    add v0.4s, v16.4s, v20.4s   //DST[0]
    add v1.4s, v17.4s, v21.4s   //DST[1]
    add v2.4s, v18.4s, v22.4s   //DST[2]
    add v3.4s, v19.4s, v23.4s   //DST[3]
    sub v4.4s, v19.4s, v23.4s   //DST[4]
    sub v5.4s, v18.4s, v22.4s   //DST[5]
    sub v6.4s, v17.4s, v21.4s   //DST[6]
    sub v7.4s, v16.4s, v20.4s   //DST[7]

    cmp w5, #15
    bne dct2_h8_2nd_shift_clip
    sqrshrn v0.4h, v0.4s, #5
    sqrshrn v1.4h, v1.4s, #5
    sqrshrn v2.4h, v2.4s, #5
    sqrshrn v3.4h, v3.4s, #5
    sqrshrn v4.4h, v4.4s, #5
    sqrshrn v5.4h, v5.4s, #5
    sqrshrn v6.4h, v6.4s, #5
    sqrshrn v7.4h, v7.4s, #5

    trn1 v16.2s, v0.2s, v2.2s
    trn1 v17.2s, v1.2s, v3.2s
    trn2 v18.2s, v0.2s, v2.2s
    trn2 v19.2s, v1.2s, v3.2s
    trn1 v20.2s, v4.2s, v6.2s
    trn1 v21.2s, v5.2s, v7.2s
    trn2 v22.2s, v4.2s, v6.2s
    trn2 v23.2s, v5.2s, v7.2s

    trn1 v0.4h, v16.4h, v17.4h
    trn2 v1.4h, v16.4h, v17.4h
    trn1 v2.4h, v18.4h, v19.4h
    trn2 v3.4h, v18.4h, v19.4h
    trn1 v4.4h, v20.4h, v21.4h
    trn2 v5.4h, v20.4h, v21.4h
    trn1 v6.4h, v22.4h, v23.4h
    trn2 v7.4h, v22.4h, v23.4h

    trn1 v0.2d, v0.2d, v4.2d
    trn1 v1.2d, v1.2d, v5.2d
    trn1 v2.2d, v2.2d, v6.2d
    trn1 v3.2d, v3.2d, v7.2d
    b dct2_h8_store
dct2_h8_2nd_shift_clip:
    srshl v0.4s, v0.4s, v31.4s
    srshl v1.4s, v1.4s, v31.4s
    srshl v2.4s, v2.4s, v31.4s
    srshl v3.4s, v3.4s, v31.4s
    srshl v4.4s, v4.4s, v31.4s
    srshl v5.4s, v5.4s, v31.4s
    srshl v6.4s, v6.4s, v31.4s
    srshl v7.4s, v7.4s, v31.4s

    sqxtn v0.4h, v0.4s
    sqxtn v1.4h, v1.4s
    sqxtn v2.4h, v2.4s
    sqxtn v3.4h, v3.4s
    sqxtn v4.4h, v4.4s
    sqxtn v5.4h, v5.4s
    sqxtn v6.4h, v6.4s
    sqxtn v7.4h, v7.4s

    trn1 v16.2s, v0.2s, v2.2s
    trn1 v17.2s, v1.2s, v3.2s
    trn2 v18.2s, v0.2s, v2.2s
    trn2 v19.2s, v1.2s, v3.2s
    trn1 v20.2s, v4.2s, v6.2s
    trn1 v21.2s, v5.2s, v7.2s
    trn2 v22.2s, v4.2s, v6.2s
    trn2 v23.2s, v5.2s, v7.2s

    trn1 v0.4h, v16.4h, v17.4h
    trn2 v1.4h, v16.4h, v17.4h
    trn1 v2.4h, v18.4h, v19.4h
    trn2 v3.4h, v18.4h, v19.4h
    trn1 v4.4h, v20.4h, v21.4h
    trn2 v5.4h, v20.4h, v21.4h
    trn1 v6.4h, v22.4h, v23.4h
    trn2 v7.4h, v22.4h, v23.4h

    trn1 v0.2d, v0.2d, v4.2d
    trn1 v1.2d, v1.2d, v5.2d
    trn1 v2.2d, v2.2d, v6.2d
    trn1 v3.2d, v3.2d, v7.2d

    smax v0.8h, v0.8h, v25.8h
    smax v1.8h, v1.8h, v25.8h
    smax v2.8h, v2.8h, v25.8h
    smax v3.8h, v3.8h, v25.8h
    smin v0.8h, v0.8h, v26.8h
    smin v1.8h, v1.8h, v26.8h
    smin v2.8h, v2.8h, v26.8h
    smin v3.8h, v3.8h, v26.8h

dct2_h8_store:
    add x8, x8, #8      // i += 4 * sizeof(s16)

    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x2], #64

    cmp x8, x3
    blt dct2_h8_loopx

    ld1 {v8.8h}, [sp]   // protect v8
    add sp, sp, #16

    ret

//************************************************************************
//void partialButterflyInverse16x16_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift, int bit_depth);
//x0: coeff blk, 16 bit
//x1: i_src
//x2: dst, 16 bit
//x3: i_dst
//x4: shift
//x5: bit_depth
//************************************************************************
function partialButterflyInverse16x16_arm64
    //protect v8,v9
    sub sp, sp, #32
    st1 {v8.8h, v9.8h}, [sp]

    mov w13 , #9
    mov w6 , #25
    mov w7 , #38
    mov w8 , #44
    mov w9 , #32
    mov w10, #32
    mov w11, #17
    mov w12, #42
    mov v8.h[0], w13
    mov v8.h[1], w6
    mov v8.h[2], w7
    mov v8.h[3], w8
    mov v8.h[4], w9
    mov v8.h[5], w10
    mov v8.h[6], w11
    mov v8.h[7], w12

    mov w13 , #4
    mov w6 , #13
    mov w7 , #21
    mov w8 , #29
    mov w9 , #35
    mov w10, #40
    mov w11, #43
    mov w12, #45
    mov v9.h[0], w13
    mov v9.h[1], w6
    mov v9.h[2], w7
    mov v9.h[3], w8
    mov v9.h[4], w9
    mov v9.h[5], w10
    mov v9.h[6], w11
    mov v9.h[7], w12

    cmp w5, #15
    bne dct2_h16_2nd_transform

    lsl x9, x1, #2                  // i_src * 2 * sizeof(s16)
    mov x8, #0                      // i = 0
    lsl x1, x1, #1                  // i_src * sizeof(s16)
    lsl x3, x3, #1                  // width * 2
dct2_h16_1st_loopx:
    add x10, x0, x8
    ld1 {v0.4h}, [x10], x9          //SRC[0*i_src]
    ld1 {v1.4h}, [x10], x9          //SRC[2*i_src]
    ld1 {v2.4h}, [x10], x9          //SRC[4*i_src]
    ld1 {v3.4h}, [x10], x9          //SRC[6*i_src]
    ld1 {v4.4h}, [x10], x9          //SRC[8*i_src]
    ld1 {v5.4h}, [x10], x9          //SRC[10*i_src]
    ld1 {v6.4h}, [x10], x9          //SRC[12*i_src]
    ld1 {v7.4h}, [x10], x9          //SRC[14*i_src]

    smull v16.4s, v1.4h, v8.H[3]
    smlal v16.4s, v3.4h, v8.H[2]
    smlal v16.4s, v5.4h, v8.H[1]
    smlal v16.4s, v7.4h, v8.H[0]    //EO[0]

    smull v17.4s, v1.4h, v8.H[2]
    smlsl v17.4s, v3.4h, v8.H[0]
    smlsl v17.4s, v5.4h, v8.H[3]
    smlsl v17.4s, v7.4h, v8.H[1]    //EO[1]

    smull v18.4s, v1.4h, v8.H[1]
    smlsl v18.4s, v3.4h, v8.H[3]
    smlal v18.4s, v5.4h, v8.H[0]
    smlal v18.4s, v7.4h, v8.H[2]    //EO[2]

    smull v19.4s, v1.4h, v8.H[0]
    smlsl v19.4s, v3.4h, v8.H[1]
    smlal v19.4s, v5.4h, v8.H[2]
    smlsl v19.4s, v7.4h, v8.H[3]    //EO[3]

    smull v20.4s, v2.4h, v8.H[7]
    smlal v20.4s, v6.4h, v8.H[6]    //EEO[0]
    smull v21.4s, v0.4h, v8.H[4]
    smlal v21.4s, v4.4h, v8.H[4]    //EEE[0]
    smull v22.4s, v2.4h, v8.H[6]
    smlsl v22.4s, v6.4h, v8.H[7]    //EEO[1]
    smull v23.4s, v0.4h, v8.H[4]
    smlsl v23.4s, v4.4h, v8.H[4]    //EEE[1]

    add v24.4s, v21.4s, v20.4s      //EE[0]
    add v25.4s, v23.4s, v22.4s      //EE[1]
    sub v26.4s, v23.4s, v22.4s      //EE[2]
    sub v27.4s, v21.4s, v20.4s      //EE[3]

    add v20.4s, v24.4s, v16.4s      //E[0]
    add v21.4s, v25.4s, v17.4s      //E[1]
    add v22.4s, v26.4s, v18.4s      //E[2]
    add v23.4s, v27.4s, v19.4s      //E[3]
    sub v28.4s, v27.4s, v19.4s      //E[4]
    sub v29.4s, v26.4s, v18.4s      //E[5]
    sub v30.4s, v25.4s, v17.4s      //E[6]
    sub v31.4s, v24.4s, v16.4s      //E[7]

    add x10, x0, x8
    add x10, x10, x1
    ld1 {v0.4h}, [x10], x9          //SRC[1*LINE]
    ld1 {v1.4h}, [x10], x9          //SRC[3*LINE]
    ld1 {v2.4h}, [x10], x9          //SRC[5*LINE]
    ld1 {v3.4h}, [x10], x9          //SRC[7*LINE]
    ld1 {v4.4h}, [x10], x9          //SRC[9*LINE]
    ld1 {v5.4h}, [x10], x9          //SRC[11*LINE]
    ld1 {v6.4h}, [x10], x9          //SRC[13*LINE]
    ld1 {v7.4h}, [x10], x9          //SRC[15*LINE]

    //O[0]
    smull v16.4s, v0.4h, v9.h[7]
    smlal v16.4s, v1.4h, v9.h[6]
    smlal v16.4s, v2.4h, v9.h[5]
    smlal v16.4s, v3.4h, v9.h[4]
    smlal v16.4s, v4.4h, v9.h[3]
    smlal v16.4s, v5.4h, v9.h[2]
    smlal v16.4s, v6.4h, v9.h[1]
    smlal v16.4s, v7.4h, v9.h[0]
    //O[1]
    smull v17.4s, v0.4h, v9.h[6]
    smlal v17.4s, v1.4h, v9.h[3]
    smlal v17.4s, v2.4h, v9.h[0]
    smlsl v17.4s, v3.4h, v9.h[2]
    smlsl v17.4s, v4.4h, v9.h[5]
    smlsl v17.4s, v5.4h, v9.h[7]
    smlsl v17.4s, v6.4h, v9.h[4]
    smlsl v17.4s, v7.4h, v9.h[1]
    //O[2]
    smull v18.4s, v0.4h, v9.h[5]
    smlal v18.4s, v1.4h, v9.h[0]
    smlsl v18.4s, v2.4h, v9.h[4]
    smlsl v18.4s, v3.4h, v9.h[6]
    smlsl v18.4s, v4.4h, v9.h[1]
    smlal v18.4s, v5.4h, v9.h[3]
    smlal v18.4s, v6.4h, v9.h[7]
    smlal v18.4s, v7.4h, v9.h[2]
    //O[3]
    smull v19.4s, v0.4h, v9.h[4]
    smlsl v19.4s, v1.4h, v9.h[2]
    smlsl v19.4s, v2.4h, v9.h[6]
    smlal v19.4s, v3.4h, v9.h[0]
    smlal v19.4s, v4.4h, v9.h[7]
    smlal v19.4s, v5.4h, v9.h[1]
    smlsl v19.4s, v6.4h, v9.h[5]
    smlsl v19.4s, v7.4h, v9.h[3]
    //O[4]
    smull v24.4s, v0.4h, v9.h[3]
    smlsl v24.4s, v1.4h, v9.h[5]
    smlsl v24.4s, v2.4h, v9.h[1]
    smlal v24.4s, v3.4h, v9.h[7]
    smlsl v24.4s, v4.4h, v9.h[0]
    smlsl v24.4s, v5.4h, v9.h[6]
    smlal v24.4s, v6.4h, v9.h[2]
    smlal v24.4s, v7.4h, v9.h[4]
    //O[5]
    smull v25.4s, v0.4h, v9.h[2]
    smlsl v25.4s, v1.4h, v9.h[7]
    smlal v25.4s, v2.4h, v9.h[3]
    smlal v25.4s, v3.4h, v9.h[1]
    smlsl v25.4s, v4.4h, v9.h[6]
    smlal v25.4s, v5.4h, v9.h[4]
    smlal v25.4s, v6.4h, v9.h[0]
    smlsl v25.4s, v7.4h, v9.h[5]
    //O[6]
    smull v26.4s, v0.4h, v9.h[1]
    smlsl v26.4s, v1.4h, v9.h[4]
    smlal v26.4s, v2.4h, v9.h[7]
    smlsl v26.4s, v3.4h, v9.h[5]
    smlal v26.4s, v4.4h, v9.h[2]
    smlal v26.4s, v5.4h, v9.h[0]
    smlsl v26.4s, v6.4h, v9.h[3]
    smlal v26.4s, v7.4h, v9.h[6]
    //O[7]
    smull v27.4s, v0.4h, v9.h[0]
    smlsl v27.4s, v1.4h, v9.h[1]
    smlal v27.4s, v2.4h, v9.h[2]
    smlsl v27.4s, v3.4h, v9.h[3]
    smlal v27.4s, v4.4h, v9.h[4]
    smlsl v27.4s, v5.4h, v9.h[5]
    smlal v27.4s, v6.4h, v9.h[6]
    smlsl v27.4s, v7.4h, v9.h[7]

    add v0.4s, v16.4s, v20.4s       //DST[0]
    add v1.4s, v17.4s, v21.4s       //DST[1]
    add v2.4s, v18.4s, v22.4s       //DST[2]
    add v3.4s, v19.4s, v23.4s       //DST[3]
    sub v7.4s, v20.4s, v16.4s       //DST[15]
    sub v6.4s, v21.4s, v17.4s       //DST[14]
    sub v5.4s, v22.4s, v18.4s       //DST[13]
    sub v4.4s, v23.4s, v19.4s       //DST[12]

    sqrshrn v0.4h, v0.4s, #5
    sqrshrn v1.4h, v1.4s, #5
    sqrshrn v2.4h, v2.4s, #5
    sqrshrn v3.4h, v3.4s, #5
    sqrshrn v4.4h, v4.4s, #5
    sqrshrn v5.4h, v5.4s, #5
    sqrshrn v6.4h, v6.4s, #5
    sqrshrn v7.4h, v7.4s, #5

    trn1 v16.2s, v0.2s, v2.2s
    trn2 v18.2s, v0.2s, v2.2s
    trn1 v17.2s, v1.2s, v3.2s
    trn2 v19.2s, v1.2s, v3.2s
    trn1 v0.4h, v16.4h, v17.4h
    trn2 v1.4h, v16.4h, v17.4h
    trn1 v2.4h, v18.4h, v19.4h
    trn2 v3.4h, v18.4h, v19.4h

    trn1 v16.2s, v4.2s, v6.2s
    trn2 v18.2s, v4.2s, v6.2s
    trn1 v17.2s, v5.2s, v7.2s
    trn2 v19.2s, v5.2s, v7.2s
    trn1 v4.4h, v16.4h, v17.4h
    trn2 v5.4h, v16.4h, v17.4h
    trn1 v6.4h, v18.4h, v19.4h
    trn2 v7.4h, v18.4h, v19.4h

    mov x11, x2
    add x12, x2, #24
    mov x13, #32
    st1 {v0.4h}, [x11], x13
    st1 {v4.4h}, [x12], x13
    st1 {v1.4h}, [x11], x13
    st1 {v5.4h}, [x12], x13
    st1 {v2.4h}, [x11], x13
    st1 {v6.4h}, [x12], x13
    st1 {v3.4h}, [x11]
    st1 {v7.4h}, [x12]

    add v0.4s, v28.4s, v24.4s       //DST[4]
    add v1.4s, v29.4s, v25.4s       //DST[5]
    add v2.4s, v30.4s, v26.4s       //DST[6]
    add v3.4s, v31.4s, v27.4s       //DST[7]
    sub v7.4s, v28.4s, v24.4s       //DST[11]
    sub v6.4s, v29.4s, v25.4s       //DST[10]
    sub v5.4s, v30.4s, v26.4s       //DST[9]
    sub v4.4s, v31.4s, v27.4s       //DST[8]

    sqrshrn v0.4h, v0.4s, #5
    sqrshrn v1.4h, v1.4s, #5
    sqrshrn v2.4h, v2.4s, #5
    sqrshrn v3.4h, v3.4s, #5
    sqrshrn v4.4h, v4.4s, #5
    sqrshrn v5.4h, v5.4s, #5
    sqrshrn v6.4h, v6.4s, #5
    sqrshrn v7.4h, v7.4s, #5

    trn1 v24.2s, v0.2s, v2.2s
    trn2 v26.2s, v0.2s, v2.2s
    trn1 v25.2s, v1.2s, v3.2s
    trn2 v27.2s, v1.2s, v3.2s
    trn1 v0.4h, v24.4h, v25.4h
    trn2 v1.4h, v24.4h, v25.4h
    trn1 v2.4h, v26.4h, v27.4h
    trn2 v3.4h, v26.4h, v27.4h

    trn1 v24.2s, v4.2s, v6.2s
    trn2 v26.2s, v4.2s, v6.2s
    trn1 v25.2s, v5.2s, v7.2s
    trn2 v27.2s, v5.2s, v7.2s
    trn1 v4.4h, v24.4h, v25.4h
    trn2 v5.4h, v24.4h, v25.4h
    trn1 v6.4h, v26.4h, v27.4h
    trn2 v7.4h, v26.4h, v27.4h

    add x11, x2, #8
    trn1 v0.2d, v0.2d, v4.2d
    trn1 v1.2d, v1.2d, v5.2d
    trn1 v2.2d, v2.2d, v6.2d
    trn1 v3.2d, v3.2d, v7.2d

    st1 {v0.8h}, [x11], x13
    st1 {v1.8h}, [x11], x13
    st1 {v2.8h}, [x11], x13
    st1 {v3.8h}, [x11]
    add x8, x8, #8
    add x2, x2, #128                // next 4*16*sizeof(s16)
    cmp x8, x3
    blt dct2_h16_1st_loopx

    ld1 {v8.8h, v9.8h}, [sp], #32
    b   dct2_h16_end
dct2_h16_2nd_transform:

    sub sp, sp, #48
    add x7, sp, #16
    st1 {v10.8h, v11.8h}, [x7]
    st1 {v12.8h}, [sp]
    
    mov w8, #1
    lsl w8, w8, w5
    sub w6, w5, #20                 // -shift = bit_depth - 20
    sub w9, w8, #1                  // max_pel = (1<<bit_depth) - 1
    neg w8, w8                      // min_pel = -(1<<bit_depth)
    dup v12.4s, w6                  // for left shift
    dup v10.8h, w8                  // min_pel
    dup v11.8h, w9                  // max_pel

    lsl x9, x1, #2                  // i_src * 2 * sizeof(s16)
    mov x8, #0                      // i = 0
    lsl x1, x1, #1                  // i_src * sizeof(s16)
    lsl x3, x3, #1
dct2_h16_2nd_loopx:
    add x10, x0, x8
    ld1 {v0.4h}, [x10], x9          //SRC[0*LINE]
    ld1 {v1.4h}, [x10], x9          //SRC[2*LINE]
    ld1 {v2.4h}, [x10], x9          //SRC[4*LINE]
    ld1 {v3.4h}, [x10], x9          //SRC[6*LINE]
    ld1 {v4.4h}, [x10], x9          //SRC[8*LINE]
    ld1 {v5.4h}, [x10], x9          //SRC[10*LINE]
    ld1 {v6.4h}, [x10], x9          //SRC[12*LINE]
    ld1 {v7.4h}, [x10], x9          //SRC[14*LINE]

    smull v16.4s, v1.4h, v8.h[3]
    smlal v16.4s, v3.4h, v8.h[2]
    smlal v16.4s, v5.4h, v8.h[1]
    smlal v16.4s, v7.4h, v8.h[0]    //EO[0]

    smull v17.4s, v1.4h, v8.h[2]
    smlsl v17.4s, v3.4h, v8.h[0]
    smlsl v17.4s, v5.4h, v8.h[3]
    smlsl v17.4s, v7.4h, v8.h[1]    //EO[1]

    smull v18.4s, v1.4h, v8.h[1]
    smlsl v18.4s, v3.4h, v8.h[3]
    smlal v18.4s, v5.4h, v8.h[0]
    smlal v18.4s, v7.4h, v8.h[2]    //EO[2]

    smull v19.4s, v1.4h, v8.h[0]
    smlsl v19.4s, v3.4h, v8.h[1]
    smlal v19.4s, v5.4h, v8.h[2]
    smlsl v19.4s, v7.4h, v8.h[3]    //EO[3]

    smull v20.4s, v2.4h, v8.h[7]
    smlal v20.4s, v6.4h, v8.h[6]    //EEO[0]
    smull v21.4s, v0.4h, v8.h[4]
    smlal v21.4s, v4.4h, v8.h[4]    //EEE[0]
    smull v22.4s, v2.4h, v8.h[6]
    smlsl v22.4s, v6.4h, v8.h[7]    //EEO[1]
    smull v23.4s, v0.4h, v8.h[4]
    smlsl v23.4s, v4.4h, v8.h[4]    //EEE[1]

    add v24.4s, v21.4s, v20.4s      //EE[0]
    add v25.4s, v23.4s, v22.4s      //EE[1]
    sub v26.4s, v23.4s, v22.4s      //EE[2]
    sub v27.4s, v21.4s, v20.4s      //EE[3]

    add v20.4s, v24.4s, v16.4s      //E[0]
    add v21.4s, v25.4s, v17.4s      //E[1]
    add v22.4s, v26.4s, v18.4s      //E[2]
    add v23.4s, v27.4s, v19.4s      //E[3]
    sub v28.4s, v27.4s, v19.4s      //E[4]
    sub v29.4s, v26.4s, v18.4s      //E[5]
    sub v30.4s, v25.4s, v17.4s      //E[6]
    sub v31.4s, v24.4s, v16.4s      //E[7]

    add x10, x0, x8
    add x10, x10, x1
    ld1 {v0.4h}, [x10], x9          //SRC[1*LINE]
    ld1 {v1.4h}, [x10], x9          //SRC[3*LINE]
    ld1 {v2.4h}, [x10], x9          //SRC[5*LINE]
    ld1 {v3.4h}, [x10], x9          //SRC[7*LINE]
    ld1 {v4.4h}, [x10], x9          //SRC[9*LINE]
    ld1 {v5.4h}, [x10], x9          //SRC[11*LINE]
    ld1 {v6.4h}, [x10], x9          //SRC[13*LINE]
    ld1 {v7.4h}, [x10], x9          //SRC[15*LINE]

    //O[0]
    smull v16.4s, v0.4h, v9.h[7]
    smlal v16.4s, v1.4h, v9.h[6]
    smlal v16.4s, v2.4h, v9.h[5]
    smlal v16.4s, v3.4h, v9.h[4]
    smlal v16.4s, v4.4h, v9.h[3]
    smlal v16.4s, v5.4h, v9.h[2]
    smlal v16.4s, v6.4h, v9.h[1]
    smlal v16.4s, v7.4h, v9.h[0]
    //O[1]
    smull v17.4s, v0.4h, v9.h[6]
    smlal v17.4s, v1.4h, v9.h[3]
    smlal v17.4s, v2.4h, v9.h[0]
    smlsl v17.4s, v3.4h, v9.h[2]
    smlsl v17.4s, v4.4h, v9.h[5]
    smlsl v17.4s, v5.4h, v9.h[7]
    smlsl v17.4s, v6.4h, v9.h[4]
    smlsl v17.4s, v7.4h, v9.h[1]
    //O[2]
    smull v18.4s, v0.4h, v9.h[5]
    smlal v18.4s, v1.4h, v9.h[0]
    smlsl v18.4s, v2.4h, v9.h[4]
    smlsl v18.4s, v3.4h, v9.h[6]
    smlsl v18.4s, v4.4h, v9.h[1]
    smlal v18.4s, v5.4h, v9.h[3]
    smlal v18.4s, v6.4h, v9.h[7]
    smlal v18.4s, v7.4h, v9.h[2]
    //O[3]
    smull v19.4s, v0.4h, v9.h[4]
    smlsl v19.4s, v1.4h, v9.h[2]
    smlsl v19.4s, v2.4h, v9.h[6]
    smlal v19.4s, v3.4h, v9.h[0]
    smlal v19.4s, v4.4h, v9.h[7]
    smlal v19.4s, v5.4h, v9.h[1]
    smlsl v19.4s, v6.4h, v9.h[5]
    smlsl v19.4s, v7.4h, v9.h[3]
    //O[4]
    smull v24.4s, v0.4h, v9.h[3]
    smlsl v24.4s, v1.4h, v9.h[5]
    smlsl v24.4s, v2.4h, v9.h[1]
    smlal v24.4s, v3.4h, v9.h[7]
    smlsl v24.4s, v4.4h, v9.h[0]
    smlsl v24.4s, v5.4h, v9.h[6]
    smlal v24.4s, v6.4h, v9.h[2]
    smlal v24.4s, v7.4h, v9.h[4]
    //O[5]
    smull v25.4s, v0.4h, v9.h[2]
    smlsl v25.4s, v1.4h, v9.h[7]
    smlal v25.4s, v2.4h, v9.h[3]
    smlal v25.4s, v3.4h, v9.h[1]
    smlsl v25.4s, v4.4h, v9.h[6]
    smlal v25.4s, v5.4h, v9.h[4]
    smlal v25.4s, v6.4h, v9.h[0]
    smlsl v25.4s, v7.4h, v9.h[5]
    //O[6]
    smull v26.4s, v0.4h, v9.h[1]
    smlsl v26.4s, v1.4h, v9.h[4]
    smlal v26.4s, v2.4h, v9.h[7]
    smlsl v26.4s, v3.4h, v9.h[5]
    smlal v26.4s, v4.4h, v9.h[2]
    smlal v26.4s, v5.4h, v9.h[0]
    smlsl v26.4s, v6.4h, v9.h[3]
    smlal v26.4s, v7.4h, v9.h[6]
    //O[7]
    smull v27.4s, v0.4h, v9.h[0]
    smlsl v27.4s, v1.4h, v9.h[1]
    smlal v27.4s, v2.4h, v9.h[2]
    smlsl v27.4s, v3.4h, v9.h[3]
    smlal v27.4s, v4.4h, v9.h[4]
    smlsl v27.4s, v5.4h, v9.h[5]
    smlal v27.4s, v6.4h, v9.h[6]
    smlsl v27.4s, v7.4h, v9.h[7]

    add v0.4s, v16.4s, v20.4s       //DST[0]
    add v1.4s, v17.4s, v21.4s       //DST[1]
    add v2.4s, v18.4s, v22.4s       //DST[2]
    add v3.4s, v19.4s, v23.4s       //DST[3]
    sub v7.4s, v20.4s, v16.4s       //DST[15]
    sub v6.4s, v21.4s, v17.4s       //DST[14]
    sub v5.4s, v22.4s, v18.4s       //DST[13]
    sub v4.4s, v23.4s, v19.4s       //DST[12]

#if !COMPILE_10BIT
    sqrshrn v0.4h, v0.4s, #12
    sqrshrn v1.4h, v1.4s, #12
    sqrshrn v2.4h, v2.4s, #12
    sqrshrn v3.4h, v3.4s, #12
    sqrshrn v4.4h, v4.4s, #12
    sqrshrn v5.4h, v5.4s, #12
    sqrshrn v6.4h, v6.4s, #12
    sqrshrn v7.4h, v7.4s, #12
#else
    srshl v0.4s, v0.4s, v12.4s
    srshl v1.4s, v1.4s, v12.4s
    srshl v2.4s, v2.4s, v12.4s
    srshl v3.4s, v3.4s, v12.4s
    srshl v4.4s, v4.4s, v12.4s
    srshl v5.4s, v5.4s, v12.4s
    srshl v6.4s, v6.4s, v12.4s
    srshl v7.4s, v7.4s, v12.4s

    sqxtn v0.4h, v0.4s
    sqxtn v1.4h, v1.4s
    sqxtn v2.4h, v2.4s
    sqxtn v3.4h, v3.4s
    sqxtn v4.4h, v4.4s
    sqxtn v5.4h, v5.4s
    sqxtn v6.4h, v6.4s
    sqxtn v7.4h, v7.4s
#endif

    trn1 v16.2s, v0.2s, v2.2s
    trn2 v18.2s, v0.2s, v2.2s
    trn1 v17.2s, v1.2s, v3.2s
    trn2 v19.2s, v1.2s, v3.2s
    trn1 v0.4h, v16.4h, v17.4h
    trn2 v1.4h, v16.4h, v17.4h
    trn1 v2.4h, v18.4h, v19.4h
    trn2 v3.4h, v18.4h, v19.4h

    trn1 v16.2s, v4.2s, v6.2s
    trn2 v18.2s, v4.2s, v6.2s
    trn1 v17.2s, v5.2s, v7.2s
    trn2 v19.2s, v5.2s, v7.2s
    trn1 v4.4h, v16.4h, v17.4h
    trn2 v5.4h, v16.4h, v17.4h
    trn1 v6.4h, v18.4h, v19.4h
    trn2 v7.4h, v18.4h, v19.4h

    add v16.4s, v28.4s, v24.4s       //DST[4]
    add v17.4s, v29.4s, v25.4s       //DST[5]
    add v18.4s, v30.4s, v26.4s       //DST[6]
    add v19.4s, v31.4s, v27.4s       //DST[7]
    sub v23.4s, v28.4s, v24.4s       //DST[11]
    sub v22.4s, v29.4s, v25.4s       //DST[10]
    sub v21.4s, v30.4s, v26.4s       //DST[9]
    sub v20.4s, v31.4s, v27.4s       //DST[8]

#if !COMPILE_10BIT
    sqrshrn v16.4h, v16.4s, #12
    sqrshrn v17.4h, v17.4s, #12
    sqrshrn v18.4h, v18.4s, #12
    sqrshrn v19.4h, v19.4s, #12
    sqrshrn v20.4h, v20.4s, #12
    sqrshrn v21.4h, v21.4s, #12
    sqrshrn v22.4h, v22.4s, #12
    sqrshrn v23.4h, v23.4s, #12
#else
    srshl v16.4s, v16.4s, v12.4s
    srshl v17.4s, v17.4s, v12.4s
    srshl v18.4s, v18.4s, v12.4s
    srshl v19.4s, v19.4s, v12.4s
    srshl v20.4s, v20.4s, v12.4s
    srshl v21.4s, v21.4s, v12.4s
    srshl v22.4s, v22.4s, v12.4s
    srshl v23.4s, v23.4s, v12.4s

    sqxtn v16.4h, v16.4s
    sqxtn v17.4h, v17.4s
    sqxtn v18.4h, v18.4s
    sqxtn v19.4h, v19.4s
    sqxtn v20.4h, v20.4s
    sqxtn v21.4h, v21.4s
    sqxtn v22.4h, v22.4s
    sqxtn v23.4h, v23.4s
#endif

    trn1 v24.2s, v16.2s, v18.2s
    trn2 v26.2s, v16.2s, v18.2s
    trn1 v25.2s, v17.2s, v19.2s
    trn2 v27.2s, v17.2s, v19.2s
    trn1 v16.4h, v24.4h, v25.4h
    trn2 v17.4h, v24.4h, v25.4h
    trn1 v18.4h, v26.4h, v27.4h
    trn2 v19.4h, v26.4h, v27.4h

    trn1 v24.2s, v20.2s, v22.2s
    trn2 v26.2s, v20.2s, v22.2s
    trn1 v25.2s, v21.2s, v23.2s
    trn2 v27.2s, v21.2s, v23.2s
    trn1 v20.4h, v24.4h, v25.4h
    trn2 v21.4h, v24.4h, v25.4h
    trn1 v22.4h, v26.4h, v27.4h
    trn2 v23.4h, v26.4h, v27.4h

    trn1 v24.2d, v0.2d, v16.2d
    trn1 v26.2d, v1.2d, v17.2d
    trn1 v28.2d, v2.2d, v18.2d
    trn1 v30.2d, v3.2d, v19.2d

    trn1 v25.2d, v20.2d, v4.2d
    trn1 v27.2d, v21.2d, v5.2d
    trn1 v29.2d, v22.2d, v6.2d
    trn1 v31.2d, v23.2d, v7.2d

    smax v0.8h, v0.8h, v10.8h
    smax v1.8h, v1.8h, v10.8h
    smax v2.8h, v2.8h, v10.8h
    smax v3.8h, v3.8h, v10.8h
    smax v4.8h, v4.8h, v10.8h
    smax v5.8h, v5.8h, v10.8h
    smax v6.8h, v6.8h, v10.8h
    smax v7.8h, v7.8h, v10.8h

    smin v0.8h, v0.8h, v11.8h
    smin v1.8h, v1.8h, v11.8h
    smin v2.8h, v2.8h, v11.8h
    smin v3.8h, v3.8h, v11.8h
    smin v4.8h, v4.8h, v11.8h
    smin v5.8h, v5.8h, v11.8h
    smin v6.8h, v6.8h, v11.8h
    smin v7.8h, v7.8h, v11.8h

    add x8, x8, #8
    st1 {v24.2d, v25.2d, v26.2d, v27.2d}, [x2], #64
    st1 {v28.2d, v29.2d, v30.2d, v31.2d}, [x2], #64
    cmp x8, x3
    blt dct2_h16_2nd_loopx

    ld1 {v12.8h}, [sp], #16
    ld1 {v10.8h, v11.8h}, [sp], #32
    ld1 {v8.8h, v9.8h}, [sp], #32

dct2_h16_end:
    ret

//**********************************************************
// input:
//   x10: src
//   x12: i_src*8
//   x6: i_src*4
//   x7: i_src*2
//   x2: i_src
//   v8, v9, v14, v15: dct2 coeffs
// output:
//   v0-v7: O[0]-O[7]
//   sp[0-127]: O[8]-O[15]
//   sp[128-383]: E[0]-E[15]
//**********************************************************
.macro dct2_h32_w4_calcu_E_O_arm64

    ld1 {v0.4h}, [x10], x12         // src[ 0       ]
    ld1 {v1.4h}, [x10], x12         // src[ 8*i_src  ]
    ld1 {v2.4h}, [x10], x12         // src[ 16*i_src ]
    ld1 {v3.4h}, [x10], x12         // src[ 24*i_src ]

    smull v4.4s, v1.4h, v14.H[3]
    smull v5.4s, v1.4h, v14.H[2]
    smull v6.4s, v0.4h, v14.H[0]
    smull v7.4s, v0.4h, v14.H[0]
    smlal v4.4s, v3.4h, v14.H[2]    // EEEO[0]
    smlsl v5.4s, v3.4h, v14.H[3]    // EEEO[1]
    smlal v6.4s, v2.4h, v14.H[0]    // EEEE[0]
    smlsl v7.4s, v2.4h, v14.H[0]    // EEEE[1]

    add v16.4s, v6.4s, v4.4s        // EEE[0]
    add v17.4s, v7.4s, v5.4s        // EEE[1]
    sub v18.4s, v7.4s, v5.4s        // EEE[2]
    sub v19.4s, v6.4s, v4.4s        // EEE[3]

    // CALCULATE EEO
    add x10, x0, x8
    add x10, x10, x6
    ld1 {v0.4h}, [x10], x12         // src[ 4*line  ]
    ld1 {v1.4h}, [x10], x12         // src[ 12*line  ]
    ld1 {v2.4h}, [x10], x12         // src[ 20*line ]
    ld1 {v3.4h}, [x10], x12         // src[ 28*line ]

    smull v20.4s, v0.4h, v14.H[7]
    smull v21.4s, v0.4h, v14.H[6]
    smull v22.4s, v0.4h, v14.H[5]
    smull v23.4s, v0.4h, v14.H[4]

    smlal v20.4s, v1.4h, v14.H[6]
    smlsl v21.4s, v1.4h, v14.H[4]
    smlsl v22.4s, v1.4h, v14.H[7]
    smlsl v23.4s, v1.4h, v14.H[5]

    smlal v20.4s, v2.4h, v14.H[5]
    smlsl v21.4s, v2.4h, v14.H[7]
    smlal v22.4s, v2.4h, v14.H[4]
    smlal v23.4s, v2.4h, v14.H[6]

    smlal v20.4s, v3.4h, v14.H[4]   // EEO[0]
    smlsl v21.4s, v3.4h, v14.H[5]   // EEO[1]
    smlal v22.4s, v3.4h, v14.H[6]   // EEO[2]
    smlsl v23.4s, v3.4h, v14.H[7]   // EEO[3]

    // CALCULATE EE
    add v24.4s, v16.4s, v20.4s      // EE[0]
    add v25.4s, v17.4s, v21.4s      // EE[1]
    add v26.4s, v18.4s, v22.4s      // EE[2]
    add v27.4s, v19.4s, v23.4s      // EE[3]
    sub v28.4s, v19.4s, v23.4s      // EE[4]
    sub v29.4s, v18.4s, v22.4s      // EE[5]
    sub v30.4s, v17.4s, v21.4s      // EE[6]
    sub v31.4s, v16.4s, v20.4s      // EE[7]

    //CALCULATE EO
    add x10, x0, x8
    add x10, x10, x7                // src + 2*i_src

    ld1 {v0.4h}, [x10], X6          // src[ 2*line ]
    ld1 {v1.4h}, [x10], X6          // src[ 6*line ]
    ld1 {v2.4h}, [x10], X6          // src[10*line ]
    ld1 {v3.4h}, [x10], X6          // src[14*line ]
    ld1 {v4.4h}, [x10], X6          // src[18*line ]
    ld1 {v5.4h}, [x10], X6          // src[22*line ]
    ld1 {v6.4h}, [x10], X6          // src[26*line ]
    ld1 {v7.4h}, [x10], X6          // src[30*line ]

    smull v16.4s, v0.4h, v15.H[0]
    smull v17.4s, v0.4h, v15.H[1]
    smull v18.4s, v0.4h, v15.H[2]
    smull v19.4s, v0.4h, v15.H[3]

    smlsl v16.4s, v1.4h, v15.H[1]
    smlsl v17.4s, v1.4h, v15.H[4]
    smlsl v18.4s, v1.4h, v15.H[7]
    smlsl v19.4s, v1.4h, v15.H[5]

    smlal v16.4s, v2.4h, v15.H[2]
    smlal v17.4s, v2.4h, v15.H[7]
    smlal v18.4s, v2.4h, v15.H[3]
    smlsl v19.4s, v2.4h, v15.H[1]

    smlsl v16.4s, v3.4h, v15.H[3]
    smlsl v17.4s, v3.4h, v15.H[5]
    smlal v18.4s, v3.4h, v15.H[1]
    smlal v19.4s, v3.4h, v15.H[7]

    smlal v16.4s, v4.4h, v15.H[4]
    smlal v17.4s, v4.4h, v15.H[2]
    smlsl v18.4s, v4.4h, v15.H[6]
    smlsl v19.4s, v4.4h, v15.H[0]

    smlsl v16.4s, v5.4h, v15.H[5]
    smlal v17.4s, v5.4h, v15.H[0]
    smlal v18.4s, v5.4h, v15.H[4]
    smlsl v19.4s, v5.4h, v15.H[6]

    smlal v16.4s, v6.4h, v15.H[6]
    smlsl v17.4s, v6.4h, v15.H[3]
    smlal v18.4s, v6.4h, v15.H[0]
    smlal v19.4s, v6.4h, v15.H[2]

    smlsl v16.4s, v7.4h, v15.H[7]   // EO[7]
    smlal v17.4s, v7.4h, v15.H[6]   // EO[6]
    smlsl v18.4s, v7.4h, v15.H[5]   // EO[5]
    smlal v19.4s, v7.4h, v15.H[4]   // EO[4]

    smull v20.4s, v0.4h, v15.H[4]
    smull v21.4s, v0.4h, v15.H[5]
    smull v22.4s, v0.4h, v15.H[6]
    smull v23.4s, v0.4h, v15.H[7]

    smlsl v20.4s, v1.4h, v15.H[2]
    smlal v21.4s, v1.4h, v15.H[0]
    smlal v22.4s, v1.4h, v15.H[3]
    smlal v23.4s, v1.4h, v15.H[6]

    smlsl v20.4s, v2.4h, v15.H[6]
    smlsl v21.4s, v2.4h, v15.H[4]
    smlal v22.4s, v2.4h, v15.H[0]
    smlal v23.4s, v2.4h, v15.H[5]

    smlal v20.4s, v3.4h, v15.H[0]
    smlsl v21.4s, v3.4h, v15.H[6]
    smlsl v22.4s, v3.4h, v15.H[2]
    smlal v23.4s, v3.4h, v15.H[4]

    smlal v20.4s, v4.4h, v15.H[7]
    smlsl v21.4s, v4.4h, v15.H[1]
    smlsl v22.4s, v4.4h, v15.H[5]
    smlal v23.4s, v4.4h, v15.H[3]

    smlal v20.4s, v5.4h, v15.H[1]
    smlal v21.4s, v5.4h, v15.H[3]
    smlsl v22.4s, v5.4h, v15.H[7]
    smlal v23.4s, v5.4h, v15.H[2]

    smlsl v20.4s, v6.4h, v15.H[5]
    smlal v21.4s, v6.4h, v15.H[7]
    smlsl v22.4s, v6.4h, v15.H[4]
    smlal v23.4s, v6.4h, v15.H[1]

    smlsl v20.4s, v7.4h, v15.H[3]   // EO[7]
    smlal v21.4s, v7.4h, v15.H[2]   // EO[6]
    smlsl v22.4s, v7.4h, v15.H[1]   // EO[5]
    smlal v23.4s, v7.4h, v15.H[0]   // EO[4]

    add v0.4s, v24.4s, v23.4s       // E[0]
    add v1.4s, v25.4s, v22.4s       // E[1]
    add v2.4s, v26.4s, v21.4s       // E[2]
    add v3.4s, v27.4s, v20.4s       // E[3]
    add v4.4s, v28.4s, v19.4s       // E[4]
    add v5.4s, v29.4s, v18.4s       // E[5]
    add v6.4s, v30.4s, v17.4s       // E[6]
    add v7.4s, v31.4s, v16.4s       // E[7]

    add x9, sp, #128
    st1 {v0.4s, v1.4s, v2.4s, v3.4s}, [x9], #64     // save E[0-7]
    st1 {v4.4s, v5.4s, v6.4s, v7.4s}, [x9], #64

    sub v0.4s, v31.4s, v16.4s       // E[8]
    sub v1.4s, v30.4s, v17.4s       // E[9]
    sub v2.4s, v29.4s, v18.4s       // E[10]
    sub v3.4s, v28.4s, v19.4s       // E[11]
    sub v4.4s, v27.4s, v20.4s       // E[12]
    sub v5.4s, v26.4s, v21.4s       // E[13]
    sub v6.4s, v25.4s, v22.4s       // E[14]
    sub v7.4s, v24.4s, v23.4s       // E[15]

    st1 {v0.4s, v1.4s, v2.4s, v3.4s}, [x9], #64     // save E[8-15]
    st1 {v4.4s, v5.4s, v6.4s, v7.4s}, [x9], #64

    //CALCULATE O
    add x10, x0, x8
    add x10, x10, x1                // src + i_src

    ld1 {v16.4h}, [x10], x7         //src[ 1*line ]
    ld1 {v17.4h}, [x10], x7         //src[ 3*line ]
    ld1 {v18.4h}, [x10], x7         //src[ 5*line ]
    ld1 {v19.4h}, [x10], x7         //src[ 7*line ]
    ld1 {v20.4h}, [x10], x7         //src[ 9*line ]
    ld1 {v21.4h}, [x10], x7         //src[11*line ]
    ld1 {v22.4h}, [x10], x7         //src[13*line ]
    ld1 {v23.4h}, [x10], x7         //src[15*line ]
    ld1 {v24.4h}, [x10], x7         //src[17*line ]
    ld1 {v25.4h}, [x10], x7         //src[19*line ]
    ld1 {v26.4h}, [x10], x7         //src[21*line ]
    ld1 {v27.4h}, [x10], x7         //src[23*line ]
    ld1 {v28.4h}, [x10], x7         //src[25*line ]
    ld1 {v29.4h}, [x10], x7         //src[27*line ]
    ld1 {v30.4h}, [x10], x7         //src[29*line ]
    ld1 {v31.4h}, [x10], x7         //src[31*line ]

    //O[15]
    smull v7.4s, v16.4h, v8.H[0]
    smlsl v7.4s, v17.4h, v8.H[1]
    smlal v7.4s, v18.4h, v8.H[2]
    smlsl v7.4s, v19.4h, v8.H[3]

    smlal v7.4s, v20.4h, v8.H[4]
    smlsl v7.4s, v21.4h, v8.H[5]
    smlal v7.4s, v22.4h, v8.H[6]
    smlsl v7.4s, v23.4h, v8.H[7]

    smlal v7.4s, v24.4h, v9.H[0]
    smlsl v7.4s, v25.4h, v9.H[1]
    smlal v7.4s, v26.4h, v9.H[2]
    smlsl v7.4s, v27.4h, v9.H[3]

    smlal v7.4s, v28.4h, v9.H[4]
    smlsl v7.4s, v29.4h, v9.H[5]
    smlal v7.4s, v30.4h, v9.H[6]
    smlsl v7.4s, v31.4h, v9.H[7]

    //O[14]
    smull v6.4s, v16.4h, v8.H[1]
    smlsl v6.4s, v17.4h, v8.H[4]
    smlal v6.4s, v18.4h, v8.H[7]
    smlsl v6.4s, v19.4h, v9.H[2]

    smlal v6.4s, v20.4h, v9.H[5]
    smlsl v6.4s, v21.4h, v9.H[7]
    smlal v6.4s, v22.4h, v9.H[4]
    smlsl v6.4s, v23.4h, v9.H[1]

    smlal v6.4s, v24.4h, v8.H[6]
    smlsl v6.4s, v25.4h, v8.H[3]
    smlal v6.4s, v26.4h, v8.H[0]
    smlal v6.4s, v27.4h, v8.H[2]

    smlsl v6.4s, v28.4h, v8.H[5]
    smlal v6.4s, v29.4h, v9.H[0]
    smlsl v6.4s, v30.4h, v9.H[3]
    smlal v6.4s, v31.4h, v9.H[7]

    //O[13]
    smull v5.4s, v16.4h, v8.H[2]
    smlsl v5.4s, v17.4h, v8.H[7]
    smlal v5.4s, v18.4h, v9.H[4]
    smlsl v5.4s, v19.4h, v9.H[7]

    smlal v5.4s, v20.4h, v9.H[1]
    smlsl v5.4s, v21.4h, v8.H[4]
    smlsl v5.4s, v22.4h, v8.H[0]
    smlal v5.4s, v23.4h, v8.H[5]

    smlsl v5.4s, v24.4h, v9.H[2]
    smlal v5.4s, v25.4h, v9.H[6]
    smlsl v5.4s, v26.4h, v9.H[3]
    smlal v5.4s, v27.4h, v8.H[6]

    smlsl v5.4s, v28.4h, v8.H[1]
    smlsl v5.4s, v29.4h, v8.H[3]
    smlal v5.4s, v30.4h, v9.H[0]
    smlsl v5.4s, v31.4h, v9.H[5]

    //O[12]
    smull v4.4s, v16.4h, v8.H[3]
    smlsl v4.4s, v17.4h, v9.H[2]
    smlal v4.4s, v18.4h, v9.H[7]
    smlsl v4.4s, v19.4h, v8.H[7]

    smlal v4.4s, v20.4h, v8.H[0]
    smlal v4.4s, v21.4h, v8.H[6]
    smlsl v4.4s, v22.4h, v9.H[5]
    smlal v4.4s, v23.4h, v9.H[3]

    smlsl v4.4s, v24.4h, v8.H[4]
    smlsl v4.4s, v25.4h, v8.H[2]
    smlal v4.4s, v26.4h, v9.H[1]
    smlsl v4.4s, v27.4h, v9.H[7]

    smlal v4.4s, v28.4h, v9.H[0]
    smlsl v4.4s, v29.4h, v8.H[1]
    smlsl v4.4s, v30.4h, v8.H[5]
    smlal v4.4s, v31.4h, v9.H[4]

    //O[11]
    smull v3.4s, v16.4h, v8.H[4]
    smlsl v3.4s, v17.4h, v9.H[5]
    smlal v3.4s, v18.4h, v9.H[1]
    smlsl v3.4s, v19.4h, v8.H[0]

    smlsl v3.4s, v20.4h, v9.H[0]
    smlal v3.4s, v21.4h, v9.H[7]
    smlsl v3.4s, v22.4h, v8.H[5]
    smlsl v3.4s, v23.4h, v8.H[3]

    smlal v3.4s, v24.4h, v9.H[4]
    smlsl v3.4s, v25.4h, v9.H[2]
    smlal v3.4s, v26.4h, v8.H[1]
    smlal v3.4s, v27.4h, v8.H[7]

    smlsl v3.4s, v28.4h, v9.H[7]
    smlal v3.4s, v29.4h, v8.H[6]
    smlal v3.4s, v30.4h, v8.H[2]
    smlsl v3.4s, v31.4h, v9.H[3]

    //O[10]
    smull v2.4s, v16.4h, v8.H[5]
    smlsl v2.4s, v17.4h, v9.H[7]
    smlal v2.4s, v18.4h, v8.H[4]
    smlal v2.4s, v19.4h, v8.H[6]

    smlsl v2.4s, v20.4h, v9.H[7]
    smlal v2.4s, v21.4h, v8.H[3]
    smlal v2.4s, v22.4h, v8.H[7]
    smlsl v2.4s, v23.4h, v9.H[5]

    smlal v2.4s, v24.4h, v8.H[2]
    smlal v2.4s, v25.4h, v9.H[0]
    smlsl v2.4s, v26.4h, v9.H[4]
    smlal v2.4s, v27.4h, v8.H[1]

    smlal v2.4s, v28.4h, v9.H[1]
    smlsl v2.4s, v29.4h, v9.H[3]
    smlal v2.4s, v30.4h, v8.H[0]
    smlal v2.4s, v31.4h, v9.H[2]

    //O[9]
    smull v1.4s, v16.4h, v8.H[6]
    smlsl v1.4s, v17.4h, v9.H[4]
    smlsl v1.4s, v18.4h, v8.H[0]
    smlal v1.4s, v19.4h, v9.H[5]

    smlsl v1.4s, v20.4h, v8.H[5]
    smlsl v1.4s, v21.4h, v8.H[7]
    smlal v1.4s, v22.4h, v9.H[3]
    smlal v1.4s, v23.4h, v8.H[1]

    smlsl v1.4s, v24.4h, v9.H[7]
    smlal v1.4s, v25.4h, v8.H[4]
    smlal v1.4s, v26.4h, v9.H[0]
    smlsl v1.4s, v27.4h, v9.H[2]

    smlsl v1.4s, v28.4h, v8.H[2]
    smlal v1.4s, v29.4h, v9.H[7]
    smlsl v1.4s, v30.4h, v8.H[3]
    smlsl v1.4s, v31.4h, v9.H[1]

    //O[8]
    smull v0.4s, v16.4h, v8.H[7]
    smlsl v0.4s, v17.4h, v9.H[1]
    smlsl v0.4s, v18.4h, v8.H[5]
    smlal v0.4s, v19.4h, v9.H[3]

    smlal v0.4s, v20.4h, v8.H[3]
    smlsl v0.4s, v21.4h, v9.H[5]
    smlsl v0.4s, v22.4h, v8.H[1]
    smlal v0.4s, v23.4h, v9.H[7]

    smlsl v0.4s, v24.4h, v8.H[0]
    smlsl v0.4s, v25.4h, v9.H[7]
    smlal v0.4s, v26.4h, v8.H[2]
    smlal v0.4s, v27.4h, v9.H[4]

    smlsl v0.4s, v28.4h, v8.H[4]
    smlsl v0.4s, v29.4h, v9.H[2]
    smlal v0.4s, v30.4h, v8.H[6]
    smlal v0.4s, v31.4h, v9.H[0]

    // STORE O[8] - O[15]
    mov x9, sp
    st1 {v0.4s, v1.4s, v2.4s, v3.4s}, [x9], #64 //STORE O[8] - O[11]
    st1 {v4.4s, v5.4s, v6.4s, v7.4s}, [x9], #64 //STORE O[12] - O[15]

    //O[7]
    smull v7.4s, v16.4h, v9.H[0]
    smlsl v7.4s, v17.4h, v8.H[6]
    smlsl v7.4s, v18.4h, v9.H[2]
    smlal v7.4s, v19.4h, v8.H[4]

    smlal v7.4s, v20.4h, v9.H[4]
    smlsl v7.4s, v21.4h, v8.H[2]
    smlsl v7.4s, v22.4h, v9.H[7]
    smlal v7.4s, v23.4h, v8.H[0]

    smlal v7.4s, v24.4h, v9.H[7]
    smlal v7.4s, v25.4h, v8.H[1]
    smlsl v7.4s, v26.4h, v9.H[5]
    smlsl v7.4s, v27.4h, v8.H[3]

    smlal v7.4s, v28.4h, v9.H[3]
    smlal v7.4s, v29.4h, v8.H[5]
    smlsl v7.4s, v30.4h, v9.H[1]
    smlsl v7.4s, v31.4h, v8.H[7]

    //O[6]
    smull v6.4s, v16.4h, v9.H[1]
    smlsl v6.4s, v17.4h, v8.H[3]
    smlsl v6.4s, v18.4h, v9.H[7]
    smlsl v6.4s, v19.4h, v8.H[2]

    smlal v6.4s, v20.4h, v9.H[2]
    smlal v6.4s, v21.4h, v9.H[0]
    smlsl v6.4s, v22.4h, v8.H[4]
    smlsl v6.4s, v23.4h, v9.H[7]

    smlsl v6.4s, v24.4h, v8.H[1]
    smlal v6.4s, v25.4h, v9.H[3]
    smlal v6.4s, v26.4h, v8.H[7]
    smlsl v6.4s, v27.4h, v8.H[5]

    smlsl v6.4s, v28.4h, v9.H[5]
    smlsl v6.4s, v29.4h, v8.H[0]
    smlal v6.4s, v30.4h, v9.H[4]
    smlal v6.4s, v31.4h, v8.H[6]

    //O[5]
    smull v5.4s, v16.4h, v9.H[2]
    smlsl v5.4s, v17.4h, v8.H[0]
    smlsl v5.4s, v18.4h, v9.H[3]
    smlsl v5.4s, v19.4h, v9.H[1]

    smlal v5.4s, v20.4h, v8.H[1]
    smlal v5.4s, v21.4h, v9.H[4]
    smlal v5.4s, v22.4h, v9.H[0]
    smlsl v5.4s, v23.4h, v8.H[2]

    smlsl v5.4s, v24.4h, v9.H[5]
    smlsl v5.4s, v25.4h, v8.H[7]
    smlal v5.4s, v26.4h, v8.H[3]
    smlal v5.4s, v27.4h, v9.H[7]

    smlal v5.4s, v28.4h, v8.H[6]
    smlsl v5.4s, v29.4h, v8.H[4]
    smlsl v5.4s, v30.4h, v9.H[7]
    smlsl v5.4s, v31.4h, v8.H[5]

    //O[4]
    smull v4.4s, v16.4h, v9.H[3]
    smlal v4.4s, v17.4h, v8.H[2]
    smlsl v4.4s, v18.4h, v8.H[6]
    smlsl v4.4s, v19.4h, v9.H[6]

    smlsl v4.4s, v20.4h, v8.H[7]
    smlal v4.4s, v21.4h, v8.H[1]
    smlal v4.4s, v22.4h, v9.H[2]
    smlal v4.4s, v23.4h, v9.H[4]

    smlal v4.4s, v24.4h, v8.H[3]
    smlsl v4.4s, v25.4h, v8.H[5]
    smlsl v4.4s, v26.4h, v9.H[7]
    smlsl v4.4s, v27.4h, v9.H[0]

    smlal v4.4s, v28.4h, v8.H[0]
    smlal v4.4s, v29.4h, v9.H[1]
    smlal v4.4s, v30.4h, v9.H[5]
    smlal v4.4s, v31.4h, v8.H[4]

    //O[3]
    smull v3.4s, v16.4h, v9.H[4]
    smlal v3.4s, v17.4h, v8.H[5]
    smlsl v3.4s, v18.4h, v8.H[1]
    smlsl v3.4s, v19.4h, v9.H[0]

    smlsl v3.4s, v20.4h, v9.H[7]
    smlsl v3.4s, v21.4h, v9.H[1]
    smlsl v3.4s, v22.4h, v8.H[2]
    smlal v3.4s, v23.4h, v8.H[4]

    smlal v3.4s, v24.4h, v9.H[3]
    smlal v3.4s, v25.4h, v9.H[5]
    smlal v3.4s, v26.4h, v8.H[6]
    smlsl v3.4s, v27.4h, v8.H[0]

    smlsl v3.4s, v28.4h, v8.H[7]
    smlsl v3.4s, v29.4h, v9.H[7]
    smlsl v3.4s, v30.4h, v9.H[2]
    smlsl v3.4s, v31.4h, v8.H[3]

    //O[2]
    smull v2.4s, v16.4h, v9.H[5]
    smlal v2.4s, v17.4h, v9.H[0]
    smlal v2.4s, v18.4h, v8.H[3]
    smlsl v2.4s, v19.4h, v8.H[1]

    smlsl v2.4s, v20.4h, v8.H[6]
    smlsl v2.4s, v21.4h, v9.H[3]
    smlsl v2.4s, v22.4h, v9.H[7]
    smlsl v2.4s, v23.4h, v9.H[2]

    smlsl v2.4s, v24.4h, v8.H[5]
    smlsl v2.4s, v25.4h, v8.H[0]
    smlal v2.4s, v26.4h, v8.H[4]
    smlal v2.4s, v27.4h, v9.H[1]

    smlal v2.4s, v28.4h, v9.H[7]
    smlal v2.4s, v29.4h, v9.H[4]
    smlal v2.4s, v30.4h, v8.H[7]
    smlal v2.4s, v31.4h, v8.H[2]

    //O[1]
    smull v1.4s, v16.4h, v9.H[7]
    smlal v1.4s, v17.4h, v9.H[3]
    smlal v1.4s, v18.4h, v9.H[0]
    smlal v1.4s, v19.4h, v8.H[5]

    smlal v1.4s, v20.4h, v8.H[2]
    smlsl v1.4s, v21.4h, v8.H[0]
    smlsl v1.4s, v22.4h, v8.H[3]
    smlsl v1.4s, v23.4h, v8.H[6]

    smlsl v1.4s, v24.4h, v9.H[1]
    smlsl v1.4s, v25.4h, v9.H[4]
    smlsl v1.4s, v26.4h, v9.H[7]
    smlsl v1.4s, v27.4h, v9.H[5]

    smlsl v1.4s, v28.4h, v9.H[2]
    smlsl v1.4s, v29.4h, v8.H[7]
    smlsl v1.4s, v30.4h, v8.H[4]
    smlsl v1.4s, v31.4h, v8.H[1]

    //O[0]
    smull v0.4s, v16.4h, v9.H[7]
    smlal v0.4s, v17.4h, v9.H[6]
    smlal v0.4s, v18.4h, v9.H[5]
    smlal v0.4s, v19.4h, v9.H[4]

    smlal v0.4s, v20.4h, v9.H[3]
    smlal v0.4s, v21.4h, v9.H[2]
    smlal v0.4s, v22.4h, v9.H[1]
    smlal v0.4s, v23.4h, v9.H[0]

    smlal v0.4s, v24.4h, v8.H[7]
    smlal v0.4s, v25.4h, v8.H[6]
    smlal v0.4s, v26.4h, v8.H[5]
    smlal v0.4s, v27.4h, v8.H[4]

    smlal v0.4s, v28.4h, v8.H[3]
    smlal v0.4s, v29.4h, v8.H[2]
    smlal v0.4s, v30.4h, v8.H[1]
    smlal v0.4s, v31.4h, v8.H[0]
.endm

//************************************************************************
//void partialButterflyInverse32x32_arm64(coef_t *src, int i_src, coef_t *dst, int i_dst, int shift, int bit_depth);
//x0: coeff blk, 16 bit
//x1: i_src
//x2: dst, 16 bit
//x3: i_dst
//x4: shift
//x5: bit_depth
//************************************************************************
function partialButterflyInverse32x32_arm64
    sub sp, sp, #128
    st1 {v8.4s, v9.4s, v10.4s, v11.4s}, [sp], #64
    st1 {v12.4s, v13.4s, v14.4s, v15.4s}, [sp]
    sub sp, sp, #64

    mov w12, #32
    mov w6, #17
    mov w7, #42
    mov w8, #9
    mov w9, #25
    mov w10, #38
    mov w11, #44
    ins v14.h[0], w12
    ins v14.h[1], w12
    ins v14.h[2], w6
    ins v14.h[3], w7
    ins v14.h[4], w8
    ins v14.h[5], w9
    ins v14.h[6], w10
    ins v14.h[7], w11

    mov w8 , #4
    mov w9 , #13
    mov w10, #21
    mov w11, #29
    mov w12, #35
    mov w13, #40
    mov w14, #43
    mov w15, #45
    ins v15.h[0], w8
    ins v15.h[1], w9
    ins v15.h[2], w10
    ins v15.h[3], w11
    ins v15.h[4], w12
    ins v15.h[5], w13
    ins v15.h[6], w14
    ins v15.h[7], w15

    mov w8 , #2
    mov w9 , #7
    mov w10, #11
    mov w11, #15
    mov w12, #19
    mov w13, #23
    mov w14, #27
    mov w15, #30
    mov v8.h[0], w8
    mov v8.h[1], w9
    mov v8.h[2], w10
    mov v8.h[3], w11
    mov v8.h[4], w12
    mov v8.h[5], w13
    mov v8.h[6], w14
    mov v8.h[7], w15

    mov w8 , #34
    mov w9 , #36
    mov w10, #39
    mov w11, #41
    mov w12, #43
    mov w13, #44
    mov w14, #45
    mov w15, #45
    mov v9.h[0], w8
    mov v9.h[1], w9
    mov v9.h[2], w10
    mov v9.h[3], w11
    mov v9.h[4], w12
    mov v9.h[5], w13
    mov v9.h[6], w14
    mov v9.h[7], w15

    mov x11, #64                    // i_dst = 64
    lsl x1, x1, #1                  // i_src *= sizeof(s16)
    lsl x3, x3, #1
    mov x8, #0                      // i = 0
    lsl x12, x1, #3                 // 8*i_src
    lsl x6, x1, #2                  // 4*i_src
    lsl x7, x1, #1                  // 2*i_src
    cmp w5, #15                     // second transform: bit_depth == 15
    bne dct2_h32_2nd_loopx

dct2_h32_1st_loopx:
    add x10, x0, x8
    sub sp, sp, #384
    dct2_h32_w4_calcu_E_O_arm64

    add x9, sp, #128
    ld1 {v16.4s, v17.4s, v18.4s, v19.4s}, [x9], #64 // E[0]-E[3]
    ld1 {v20.4s, v21.4s, v22.4s, v23.4s}, [x9], #64 // E[4]-E[7]

    add v24.4s, v16.4s, v0.4s       // DST[0]
    add v25.4s, v17.4s, v1.4s       // DST[1]
    add v26.4s, v18.4s, v2.4s       // DST[2]
    add v27.4s, v19.4s, v3.4s       // DST[3]
    add v28.4s, v20.4s, v4.4s       // DST[4]
    add v29.4s, v21.4s, v5.4s       // DST[5]
    add v30.4s, v22.4s, v6.4s       // DST[6]
    add v31.4s, v23.4s, v7.4s       // DST[7]

    sqrshrn v24.4h, v24.4s, #5
    sqrshrn v25.4h, v25.4s, #5
    sqrshrn v26.4h, v26.4s, #5
    sqrshrn v27.4h, v27.4s, #5
    sqrshrn v28.4h, v28.4s, #5
    sqrshrn v29.4h, v29.4s, #5
    sqrshrn v30.4h, v30.4s, #5
    sqrshrn v31.4h, v31.4s, #5

    trn1 v10.2s, v24.2s, v26.2s
    trn1 v11.2s, v25.2s, v27.2s
    trn2 v12.2s, v24.2s, v26.2s
    trn2 v13.2s, v25.2s, v27.2s
    trn1 v24.4h, v10.4h, v11.4h     // dst[0]
    trn2 v25.4h, v10.4h, v11.4h
    trn1 v26.4h, v12.4h, v13.4h
    trn2 v27.4h, v12.4h, v13.4h

    trn1 v10.2s, v28.2s, v30.2s
    trn1 v11.2s, v29.2s, v31.2s
    trn2 v12.2s, v28.2s, v30.2s
    trn2 v13.2s, v29.2s, v31.2s
    trn1 v28.4h, v10.4h, v11.4h     // dst[4]
    trn2 v29.4h, v10.4h, v11.4h
    trn1 v30.4h, v12.4h, v13.4h
    trn2 v31.4h, v12.4h, v13.4h

    mov x10, x2                     // dst

    trn1 v24.2d, v24.2d, v28.2d
    trn1 v25.2d, v25.2d, v29.2d
    trn1 v26.2d, v26.2d, v30.2d
    trn1 v27.2d, v27.2d, v31.2d

    // store 4 rows: dst[0-7]
    st1 {v24.8h}, [x10], x11        // dst += i_dst
    st1 {v25.8h}, [x10], x11
    st1 {v26.8h}, [x10], x11
    st1 {v27.8h}, [x10], x11

    sub v31.4s, v16.4s, v0.4s       // DST[31]
    sub v30.4s, v17.4s, v1.4s       // DST[30]
    sub v29.4s, v18.4s, v2.4s       // DST[29]
    sub v28.4s, v19.4s, v3.4s       // DST[28]
    sub v27.4s, v20.4s, v4.4s       // DST[27]
    sub v26.4s, v21.4s, v5.4s       // DST[26]
    sub v25.4s, v22.4s, v6.4s       // DST[25]
    sub v24.4s, v23.4s, v7.4s       // DST[24]

    sqrshrn v24.4h, v24.4s, #5
    sqrshrn v25.4h, v25.4s, #5
    sqrshrn v26.4h, v26.4s, #5
    sqrshrn v27.4h, v27.4s, #5
    sqrshrn v28.4h, v28.4s, #5
    sqrshrn v29.4h, v29.4s, #5
    sqrshrn v30.4h, v30.4s, #5
    sqrshrn v31.4h, v31.4s, #5

    trn1 v10.2s, v24.2s, v26.2s
    trn1 v11.2s, v25.2s, v27.2s
    trn2 v12.2s, v24.2s, v26.2s
    trn2 v13.2s, v25.2s, v27.2s
    trn1 v24.4h, v10.4h, v11.4h     // dst[24]
    trn2 v25.4h, v10.4h, v11.4h
    trn1 v26.4h, v12.4h, v13.4h
    trn2 v27.4h, v12.4h, v13.4h

    trn1 v10.2s, v28.2s, v30.2s
    trn1 v11.2s, v29.2s, v31.2s
    trn2 v12.2s, v28.2s, v30.2s
    trn2 v13.2s, v29.2s, v31.2s
    trn1 v28.4h, v10.4h, v11.4h     // dst[28]
    trn2 v29.4h, v10.4h, v11.4h
    trn1 v30.4h, v12.4h, v13.4h
    trn2 v31.4h, v12.4h, v13.4h

    add x10, x2, #48
    trn1 v24.2d, v24.2d, v28.2d
    trn1 v25.2d, v25.2d, v29.2d
    trn1 v26.2d, v26.2d, v30.2d
    trn1 v27.2d, v27.2d, v31.2d

    // store 4 rows: dst[24-31]
    st1 {v24.8h}, [x10], x11
    st1 {v25.8h}, [x10], x11
    st1 {v26.8h}, [x10], x11
    st1 {v27.8h}, [x10], x11

    ld1 {v0.4s, v1.4s, v2.4s, v3.4s}, [sp], #64     // O[8]-O[11]
    ld1 {v4.4s, v5.4s, v6.4s, v7.4s}, [sp], #64     // O[12]-O[15]
    ld1 {v16.4s, v17.4s, v18.4s, v19.4s}, [x9], #64 // E[8]-E[11]
    ld1 {v20.4s, v21.4s, v22.4s, v23.4s}, [x9], #64 // E[12]-E[15]

    add v24.4s, v16.4s, v0.4s       // DST[8]
    add v25.4s, v17.4s, v1.4s       // DST[9]
    add v26.4s, v18.4s, v2.4s       // DST[10]
    add v27.4s, v19.4s, v3.4s       // DST[11]
    add v28.4s, v20.4s, v4.4s       // DST[12]
    add v29.4s, v21.4s, v5.4s       // DST[13]
    add v30.4s, v22.4s, v6.4s       // DST[14]
    add v31.4s, v23.4s, v7.4s       // DST[15]

    sqrshrn v24.4h, v24.4s, #5
    sqrshrn v25.4h, v25.4s, #5
    sqrshrn v26.4h, v26.4s, #5
    sqrshrn v27.4h, v27.4s, #5
    sqrshrn v28.4h, v28.4s, #5
    sqrshrn v29.4h, v29.4s, #5
    sqrshrn v30.4h, v30.4s, #5
    sqrshrn v31.4h, v31.4s, #5

    trn1 v10.2s, v24.2s, v26.2s
    trn1 v11.2s, v25.2s, v27.2s
    trn2 v12.2s, v24.2s, v26.2s
    trn2 v13.2s, v25.2s, v27.2s
    trn1 v24.4h, v10.4h, v11.4h     // dst[8]
    trn2 v25.4h, v10.4h, v11.4h
    trn1 v26.4h, v12.4h, v13.4h
    trn2 v27.4h, v12.4h, v13.4h

    trn1 v10.2s, v28.2s, v30.2s
    trn1 v11.2s, v29.2s, v31.2s
    trn2 v12.2s, v28.2s, v30.2s
    trn2 v13.2s, v29.2s, v31.2s
    trn1 v28.4h, v10.4h, v11.4h     // dst[12]
    trn2 v29.4h, v10.4h, v11.4h
    trn1 v30.4h, v12.4h, v13.4h
    trn2 v31.4h, v12.4h, v13.4h

    add x10, x2, #16

    trn1 v24.2d, v24.2d, v28.2d
    trn1 v25.2d, v25.2d, v29.2d
    trn1 v26.2d, v26.2d, v30.2d
    trn1 v27.2d, v27.2d, v31.2d

    // store 4 rows: dst[8-15]
    st1 {v24.8h}, [x10], x11
    st1 {v25.8h}, [x10], x11
    st1 {v26.8h}, [x10], x11
    st1 {v27.8h}, [x10], x11

    sub v31.4s, v16.4s, v0.4s       // DST[23]
    sub v30.4s, v17.4s, v1.4s       // DST[22]
    sub v29.4s, v18.4s, v2.4s       // DST[21]
    sub v28.4s, v19.4s, v3.4s       // DST[20]
    sub v27.4s, v20.4s, v4.4s       // DST[19]
    sub v26.4s, v21.4s, v5.4s       // DST[18]
    sub v25.4s, v22.4s, v6.4s       // DST[17]
    sub v24.4s, v23.4s, v7.4s       // DST[16]

    sqrshrn v24.4h, v24.4s, #5
    sqrshrn v25.4h, v25.4s, #5
    sqrshrn v26.4h, v26.4s, #5
    sqrshrn v27.4h, v27.4s, #5
    sqrshrn v28.4h, v28.4s, #5
    sqrshrn v29.4h, v29.4s, #5
    sqrshrn v30.4h, v30.4s, #5
    sqrshrn v31.4h, v31.4s, #5

    trn1 v10.2s, v24.2s, v26.2s
    trn1 v11.2s, v25.2s, v27.2s
    trn2 v12.2s, v24.2s, v26.2s
    trn2 v13.2s, v25.2s, v27.2s
    trn1 v24.4h, v10.4h, v11.4h     // dst[16]
    trn2 v25.4h, v10.4h, v11.4h
    trn1 v26.4h, v12.4h, v13.4h
    trn2 v27.4h, v12.4h, v13.4h

    trn1 v10.2s, v28.2s, v30.2s
    trn1 v11.2s, v29.2s, v31.2s
    trn2 v12.2s, v28.2s, v30.2s
    trn2 v13.2s, v29.2s, v31.2s
    trn1 v28.4h, v10.4h, v11.4h     // dst[20]
    trn2 v29.4h, v10.4h, v11.4h
    trn1 v30.4h, v12.4h, v13.4h
    trn2 v31.4h, v12.4h, v13.4h

    add x10, x2, #32
    trn1 v24.2d, v24.2d, v28.2d
    trn1 v25.2d, v25.2d, v29.2d
    trn1 v26.2d, v26.2d, v30.2d
    trn1 v27.2d, v27.2d, v31.2d

    // store 4 rows: dst[16-23]
    st1 {v24.8h}, [x10], x11
    st1 {v25.8h}, [x10], x11
    st1 {v26.8h}, [x10], x11
    st1 {v27.8h}, [x10], x11

    add x8, x8, #8
    add sp, sp, #256
    add x2, x2, #256
    cmp x8, x3
    blt dct2_h32_1st_loopx
    b   dct2_h32_end

dct2_h32_2nd_loopx:
    add x10, x0, x8
    sub sp, sp, #384
    dct2_h32_w4_calcu_E_O_arm64

    add x9, sp, #128
    sub x10, sp, #16
    sub sp, sp, #48
    ld1 {v16.4s, v17.4s, v18.4s, v19.4s}, [x9], #64 // E[0]-E[3]
    ld1 {v20.4s, v21.4s, v22.4s, v23.4s}, [x9], #64 // E[4]-E[7]
    st1 {v14.2d, v15.2d}, [sp]      // save v14, v15 (dct coeffs)
    st1 {v8.2d}, [x10]

    mov w13, #1
    lsl w13, w13, w5
    sub w15, w5, #20                // -shift = bit_depth - 20
    sub w14, w13, #1                // max_pel = (1<<bit_depth) - 1
    neg w13, w13                    // min_pel = -(1<<bit_depth)
    dup v8.4s, w15                  // for left shift
    dup v14.8h, w13                 // minvaL vector
    dup v15.8h, w14                 // maxvaL vector

    add v24.4s, v16.4s, v0.4s       // DST[0] = E[0] + O[0]
    add v25.4s, v17.4s, v1.4s       // DST[1]
    add v26.4s, v18.4s, v2.4s       // DST[2]
    add v27.4s, v19.4s, v3.4s       // DST[3]
    add v28.4s, v20.4s, v4.4s       // DST[4]
    add v29.4s, v21.4s, v5.4s       // DST[5]
    add v30.4s, v22.4s, v6.4s       // DST[6]
    add v31.4s, v23.4s, v7.4s       // DST[7]

#if !COMPILE_10BIT
    sqrshrn v24.4h, v24.4s, #12
    sqrshrn v25.4h, v25.4s, #12
    sqrshrn v26.4h, v26.4s, #12
    sqrshrn v27.4h, v27.4s, #12
    sqrshrn v28.4h, v28.4s, #12
    sqrshrn v29.4h, v29.4s, #12
    sqrshrn v30.4h, v30.4s, #12
    sqrshrn v31.4h, v31.4s, #12
#else
    srshl v24.4s, v24.4s, v8.4s
    srshl v25.4s, v25.4s, v8.4s
    srshl v26.4s, v26.4s, v8.4s
    srshl v27.4s, v27.4s, v8.4s
    srshl v28.4s, v28.4s, v8.4s
    srshl v29.4s, v29.4s, v8.4s
    srshl v30.4s, v30.4s, v8.4s
    srshl v31.4s, v31.4s, v8.4s

    sqxtn v24.4h, v24.4s
    sqxtn v25.4h, v25.4s
    sqxtn v26.4h, v26.4s
    sqxtn v27.4h, v27.4s
    sqxtn v28.4h, v28.4s
    sqxtn v29.4h, v29.4s
    sqxtn v30.4h, v30.4s
    sqxtn v31.4h, v31.4s
#endif

    trn1 v10.2s, v24.2s, v26.2s
    trn1 v11.2s, v25.2s, v27.2s
    trn2 v12.2s, v24.2s, v26.2s
    trn2 v13.2s, v25.2s, v27.2s
    trn1 v24.4h, v10.4h, v11.4h     // dst[0]
    trn2 v25.4h, v10.4h, v11.4h
    trn1 v26.4h, v12.4h, v13.4h
    trn2 v27.4h, v12.4h, v13.4h

    trn1 v10.2s, v28.2s, v30.2s
    trn1 v11.2s, v29.2s, v31.2s
    trn2 v12.2s, v28.2s, v30.2s
    trn2 v13.2s, v29.2s, v31.2s
    trn1 v28.4h, v10.4h, v11.4h     // dst[4]
    trn2 v29.4h, v10.4h, v11.4h
    trn1 v30.4h, v12.4h, v13.4h
    trn2 v31.4h, v12.4h, v13.4h

    trn1 v24.2d, v24.2d, v28.2d
    trn1 v25.2d, v25.2d, v29.2d
    trn1 v26.2d, v26.2d, v30.2d
    trn1 v27.2d, v27.2d, v31.2d

    mov x10, x2

    smax v24.8h, v24.8h, v14.8h
    smax v25.8h, v25.8h, v14.8h
    smax v26.8h, v26.8h, v14.8h
    smax v27.8h, v27.8h, v14.8h
    smin v24.8h, v24.8h, v15.8h
    smin v25.8h, v25.8h, v15.8h
    smin v26.8h, v26.8h, v15.8h
    smin v27.8h, v27.8h, v15.8h

    // store 4 rows: dst[0-7]
    st1 {v24.8h}, [x10], x11
    st1 {v25.8h}, [x10], x11
    st1 {v26.8h}, [x10], x11
    st1 {v27.8h}, [x10], x11

    sub v31.4s, v16.4s, v0.4s       // DST[31] = E[0] - O[0]
    sub v30.4s, v17.4s, v1.4s       // DST[30]
    sub v29.4s, v18.4s, v2.4s       // DST[29]
    sub v28.4s, v19.4s, v3.4s       // DST[28]
    sub v27.4s, v20.4s, v4.4s       // DST[27]
    sub v26.4s, v21.4s, v5.4s       // DST[26]
    sub v25.4s, v22.4s, v6.4s       // DST[25]
    sub v24.4s, v23.4s, v7.4s       // DST[24]

#if !COMPILE_10BIT
    sqrshrn v24.4h, v24.4s, #12
    sqrshrn v25.4h, v25.4s, #12
    sqrshrn v26.4h, v26.4s, #12
    sqrshrn v27.4h, v27.4s, #12
    sqrshrn v28.4h, v28.4s, #12
    sqrshrn v29.4h, v29.4s, #12
    sqrshrn v30.4h, v30.4s, #12
    sqrshrn v31.4h, v31.4s, #12
#else
    srshl v24.4s, v24.4s, v8.4s
    srshl v25.4s, v25.4s, v8.4s
    srshl v26.4s, v26.4s, v8.4s
    srshl v27.4s, v27.4s, v8.4s
    srshl v28.4s, v28.4s, v8.4s
    srshl v29.4s, v29.4s, v8.4s
    srshl v30.4s, v30.4s, v8.4s
    srshl v31.4s, v31.4s, v8.4s

    sqxtn v24.4h, v24.4s
    sqxtn v25.4h, v25.4s
    sqxtn v26.4h, v26.4s
    sqxtn v27.4h, v27.4s
    sqxtn v28.4h, v28.4s
    sqxtn v29.4h, v29.4s
    sqxtn v30.4h, v30.4s
    sqxtn v31.4h, v31.4s
#endif

    trn1 v10.2s, v24.2s, v26.2s
    trn1 v11.2s, v25.2s, v27.2s
    trn2 v12.2s, v24.2s, v26.2s
    trn2 v13.2s, v25.2s, v27.2s
    trn1 v24.4h, v10.4h, v11.4h     // dst[24]
    trn2 v25.4h, v10.4h, v11.4h
    trn1 v26.4h, v12.4h, v13.4h
    trn2 v27.4h, v12.4h, v13.4h

    trn1 v10.2s, v28.2s, v30.2s
    trn1 v11.2s, v29.2s, v31.2s
    trn2 v12.2s, v28.2s, v30.2s
    trn2 v13.2s, v29.2s, v31.2s
    trn1 v28.4h, v10.4h, v11.4h     // dst[28]
    trn2 v29.4h, v10.4h, v11.4h
    trn1 v30.4h, v12.4h, v13.4h
    trn2 v31.4h, v12.4h, v13.4h

    trn1 v24.2d, v24.2d, v28.2d
    trn1 v25.2d, v25.2d, v29.2d
    trn1 v26.2d, v26.2d, v30.2d
    trn1 v27.2d, v27.2d, v31.2d

    add x10, x2, #48
    smax v24.8h, v24.8h, v14.8h
    smax v25.8h, v25.8h, v14.8h
    smax v26.8h, v26.8h, v14.8h
    smax v27.8h, v27.8h, v14.8h
    smin v24.8h, v24.8h, v15.8h
    smin v25.8h, v25.8h, v15.8h
    smin v26.8h, v26.8h, v15.8h
    smin v27.8h, v27.8h, v15.8h

    // store 4 rows: dst[24-31]
    st1 {v24.8h}, [x10], x11
    st1 {v25.8h}, [x10], x11
    st1 {v26.8h}, [x10], x11
    st1 {v27.8h}, [x10], x11

    ld1 {v16.4s, v17.4s, v18.4s, v19.4s}, [x9], #64 // E[8]-E[11]
    ld1 {v20.4s, v21.4s, v22.4s, v23.4s}, [x9], #64 // E[12]-E[15]
    sub x9, x9, #384
    ld1 {v0.4s, v1.4s, v2.4s, v3.4s}, [x9], #64     // O[8]-O[11]
    ld1 {v4.4s, v5.4s, v6.4s, v7.4s}, [x9], #64     // O[12]-O[15]

    add v24.4s, v16.4s, v0.4s       // DST[8]
    add v25.4s, v17.4s, v1.4s       // DST[9]
    add v26.4s, v18.4s, v2.4s       // DST[10]
    add v27.4s, v19.4s, v3.4s       // DST[11]
    add v28.4s, v20.4s, v4.4s       // DST[12]
    add v29.4s, v21.4s, v5.4s       // DST[13]
    add v30.4s, v22.4s, v6.4s       // DST[14]
    add v31.4s, v23.4s, v7.4s       // DST[15]

#if !COMPILE_10BIT
    sqrshrn v24.4h, v24.4s, #12
    sqrshrn v25.4h, v25.4s, #12
    sqrshrn v26.4h, v26.4s, #12
    sqrshrn v27.4h, v27.4s, #12
    sqrshrn v28.4h, v28.4s, #12
    sqrshrn v29.4h, v29.4s, #12
    sqrshrn v30.4h, v30.4s, #12
    sqrshrn v31.4h, v31.4s, #12
#else
    srshl v24.4s, v24.4s, v8.4s
    srshl v25.4s, v25.4s, v8.4s
    srshl v26.4s, v26.4s, v8.4s
    srshl v27.4s, v27.4s, v8.4s
    srshl v28.4s, v28.4s, v8.4s
    srshl v29.4s, v29.4s, v8.4s
    srshl v30.4s, v30.4s, v8.4s
    srshl v31.4s, v31.4s, v8.4s

    sqxtn v24.4h, v24.4s
    sqxtn v25.4h, v25.4s
    sqxtn v26.4h, v26.4s
    sqxtn v27.4h, v27.4s
    sqxtn v28.4h, v28.4s
    sqxtn v29.4h, v29.4s
    sqxtn v30.4h, v30.4s
    sqxtn v31.4h, v31.4s
#endif

    trn1 v10.2s, v24.2s, v26.2s
    trn1 v11.2s, v25.2s, v27.2s
    trn2 v12.2s, v24.2s, v26.2s
    trn2 v13.2s, v25.2s, v27.2s
    trn1 v24.4h, v10.4h, v11.4h     // dst[8]
    trn2 v25.4h, v10.4h, v11.4h
    trn1 v26.4h, v12.4h, v13.4h
    trn2 v27.4h, v12.4h, v13.4h

    trn1 v10.2s, v28.2s, v30.2s
    trn1 v11.2s, v29.2s, v31.2s
    trn2 v12.2s, v28.2s, v30.2s
    trn2 v13.2s, v29.2s, v31.2s
    trn1 v28.4h, v10.4h, v11.4h     // dst[12]
    trn2 v29.4h, v10.4h, v11.4h
    trn1 v30.4h, v12.4h, v13.4h
    trn2 v31.4h, v12.4h, v13.4h

    trn1 v24.2d, v24.2d, v28.2d
    trn1 v25.2d, v25.2d, v29.2d
    trn1 v26.2d, v26.2d, v30.2d
    trn1 v27.2d, v27.2d, v31.2d

    add x10, x2, #16

    smax v24.8h, v24.8h, v14.8h
    smax v25.8h, v25.8h, v14.8h
    smax v26.8h, v26.8h, v14.8h
    smax v27.8h, v27.8h, v14.8h
    smin v24.8h, v24.8h, v15.8h
    smin v25.8h, v25.8h, v15.8h
    smin v26.8h, v26.8h, v15.8h
    smin v27.8h, v27.8h, v15.8h

    // store 4 rows: dst[8-15]
    st1 {v24.8h}, [x10], x11
    st1 {v25.8h}, [x10], x11
    st1 {v26.8h}, [x10], x11
    st1 {v27.8h}, [x10], x11

    sub v31.4s, v16.4s, v0.4s       // DST[23]
    sub v30.4s, v17.4s, v1.4s       // DST[22]
    sub v29.4s, v18.4s, v2.4s       // DST[21]
    sub v28.4s, v19.4s, v3.4s       // DST[20]
    sub v27.4s, v20.4s, v4.4s       // DST[19]
    sub v26.4s, v21.4s, v5.4s       // DST[18]
    sub v25.4s, v22.4s, v6.4s       // DST[17]
    sub v24.4s, v23.4s, v7.4s       // DST[16]

#if !COMPILE_10BIT
    sqrshrn v24.4h, v24.4s, #12
    sqrshrn v25.4h, v25.4s, #12
    sqrshrn v26.4h, v26.4s, #12
    sqrshrn v27.4h, v27.4s, #12
    sqrshrn v28.4h, v28.4s, #12
    sqrshrn v29.4h, v29.4s, #12
    sqrshrn v30.4h, v30.4s, #12
    sqrshrn v31.4h, v31.4s, #12
#else
    srshl v24.4s, v24.4s, v8.4s
    srshl v25.4s, v25.4s, v8.4s
    srshl v26.4s, v26.4s, v8.4s
    srshl v27.4s, v27.4s, v8.4s
    srshl v28.4s, v28.4s, v8.4s
    srshl v29.4s, v29.4s, v8.4s
    srshl v30.4s, v30.4s, v8.4s
    srshl v31.4s, v31.4s, v8.4s

    sqxtn v24.4h, v24.4s
    sqxtn v25.4h, v25.4s
    sqxtn v26.4h, v26.4s
    sqxtn v27.4h, v27.4s
    sqxtn v28.4h, v28.4s
    sqxtn v29.4h, v29.4s
    sqxtn v30.4h, v30.4s
    sqxtn v31.4h, v31.4s
#endif

    trn1 v10.2s, v24.2s, v26.2s
    trn1 v11.2s, v25.2s, v27.2s
    trn2 v12.2s, v24.2s, v26.2s
    trn2 v13.2s, v25.2s, v27.2s
    trn1 v24.4h, v10.4h, v11.4h     // dst[16]
    trn2 v25.4h, v10.4h, v11.4h
    trn1 v26.4h, v12.4h, v13.4h
    trn2 v27.4h, v12.4h, v13.4h

    trn1 v10.2s, v28.2s, v30.2s
    trn1 v11.2s, v29.2s, v31.2s
    trn2 v12.2s, v28.2s, v30.2s
    trn2 v13.2s, v29.2s, v31.2s
    trn1 v28.4h, v10.4h, v11.4h     // dst[20]
    trn2 v29.4h, v10.4h, v11.4h
    trn1 v30.4h, v12.4h, v13.4h
    trn2 v31.4h, v12.4h, v13.4h

    trn1 v24.2d, v24.2d, v28.2d
    trn1 v25.2d, v25.2d, v29.2d
    trn1 v26.2d, v26.2d, v30.2d
    trn1 v27.2d, v27.2d, v31.2d

    add x10, x2, #32
    smax v24.8h, v24.8h, v14.8h
    smax v25.8h, v25.8h, v14.8h
    smax v26.8h, v26.8h, v14.8h
    smax v27.8h, v27.8h, v14.8h
    smin v24.8h, v24.8h, v15.8h
    smin v25.8h, v25.8h, v15.8h
    smin v26.8h, v26.8h, v15.8h
    smin v27.8h, v27.8h, v15.8h

    // store 4 rows: dst[16-23]
    st1 {v24.8h}, [x10], x11
    st1 {v25.8h}, [x10], x11
    st1 {v26.8h}, [x10], x11
    st1 {v27.8h}, [x10], x11

    ld1 {v14.2d, v15.2d}, [sp], #32
    ld1 {v8.2d}, [sp], #16

    add x8, x8, #8
    add x2, x2, #256                // dst += i_dst*4
    add sp, sp, #384
    cmp x8, x3
    blt dct2_h32_2nd_loopx

dct2_h32_end:
    ld1 {v8.4s, v9.4s, v10.4s, v11.4s}, [sp], #64
    ld1 {v12.4s, v13.4s, v14.4s, v15.4s}, [sp], #64

    ret

    #endif

