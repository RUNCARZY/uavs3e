#include "def_arm64.S"

#if defined(__arm64__)

#if !COMPILE_10BIT

//void xGetSAD8_arm64(pel *p_org, int i_org, pel *pred, int i_pred, int height, int skip_lines)
//*p_org->x0, i_org->x1, p_pred->x2, i_pred->x3, height->x4, skip_lines->x5
function xGetSAD8_arm64
    mov x6, #1
    lsl x6, x6, x5      //1 << skip_lines
    mul x1, x1, x6
    mul x3, x3, x6
    lsr x4, x4, x5
    movi v16.16b, #0

get_sad_8_y:
    //load org
    ld1 {v0.8b}, [x0], x1
    //load pred
    ld1 {v1.8b}, [x2], x3

    uabd v0.8b, v0.8b, v1.8b
    uxtl v0.8h, v0.8b
    add v16.8h, v16.8h, v0.8h

    subs w4, w4, #1
    bgt get_sad_8_y

    uaddlp v16.4s, v16.8h
    addp v16.4s, v16.4s, v16.4s
    addp v16.4s, v16.4s, v16.4s

    mov x0, #0
    umov w0, v16.s[0]
    lsl w0, w0, w5
    ret

//void xGetSAD16_arm64(pel *p_org, int i_org, pel *pred, int i_pred, int height, int skip_lines)
//*p_org->x0, i_org->x1, p_pred->x2, i_pred->x3, height->x4, skip_lines->x5
function xGetSAD16_arm64
    mov x6, #1
    lsl x6, x6, x5      //1 << skip_lines
    mul x1, x1, x6
    mul x3, x3, x6
    lsr x4, x4, x5

    movi v16.16b, #0
    movi v17.16b, #0
    movi v18.16b, #0
    movi v19.16b, #0

get_sad_16_y:
    ld1 {v0.16b}, [x0], x1
    ld1 {v1.16b}, [x0], x1
    //load pred
    ld1 {v2.16b}, [x2], x3
    ld1 {v3.16b}, [x2], x3

    uabd v4.16b, v0.16b, v2.16b
    uabd v5.16b, v1.16b, v3.16b

    uxtl v0.8h, v4.8b
    uxtl2 v1.8h, v4.16b
    uxtl v2.8h, v5.8b
    uxtl2 v3.8h, v5.16b

    add v16.8h, v16.8h, v0.8h
    add v17.8h, v17.8h, v1.8h
    add v18.8h, v18.8h, v2.8h
    add v19.8h, v19.8h, v3.8h

    subs w4, w4, #2
    bgt get_sad_16_y

    add v16.8h, v16.8h, v17.8h
    add v18.8h, v18.8h, v19.8h
    uaddlp v16.4s, v16.8h
    uaddlp v18.4s, v18.8h
    add v16.4s, v16.4s, v18.4s
    addp v16.4s, v16.4s, v16.4s
    addp v16.4s, v16.4s, v16.4s

    mov x0, #0
    umov w0, v16.s[0]
    lsl w0, w0, w5

    ret

//void xGetSAD32_arm64(pel *p_org, int i_org, pel *pred, int i_pred, int height, int skip_lines)
//*p_org->x0, i_org->x1, p_pred->x2, i_pred->x3, height->x4, skip_lines->x5
function xGetSAD32_arm64
    mov x6, #1
    lsl x6, x6, x5      //1 << skip_lines
    mul x1, x1, x6
    mul x3, x3, x6
    lsr x4, x4, x5

    movi v24.16b, #0
    movi v25.16b, #0
    movi v26.16b, #0
    movi v27.16b, #0
    movi v28.16b, #0
    movi v29.16b, #0
    movi v30.16b, #0
    movi v31.16b, #0

get_sad_32_y:
    //load p_org
    ld1 {v0.16b, v1.16b}, [x0], x1
    ld1 {v2.16b, v3.16b}, [x0], x1
    //load pred
    ld1 {v4.16b, v5.16b}, [x2], x3
    ld1 {v6.16b, v7.16b}, [x2], x3

    uabd v16.16b, v0.16b, v4.16b
    uabd v17.16b, v1.16b, v5.16b
    uabd v18.16b, v2.16b, v6.16b
    uabd v19.16b, v3.16b, v7.16b

    uxtl v0.8h, v16.8b
    uxtl2 v1.8h, v16.16b
    uxtl v2.8h, v17.8b
    uxtl2 v3.8h, v17.16b
    uxtl v4.8h, v18.8b
    uxtl2 v5.8h, v18.16b
    uxtl v6.8h, v19.8b
    uxtl2 v7.8h, v19.16b

    add v24.8h, v24.8h, v0.8h
    add v25.8h, v25.8h, v1.8h
    add v26.8h, v26.8h, v2.8h
    add v27.8h, v27.8h, v3.8h
    add v28.8h, v28.8h, v4.8h
    add v29.8h, v29.8h, v5.8h
    add v30.8h, v30.8h, v6.8h
    add v31.8h, v31.8h, v7.8h

    subs w4, w4, #2
    bgt get_sad_32_y

    uaddlp v24.4s, v24.8h
    uaddlp v25.4s, v25.8h
    uaddlp v26.4s, v26.8h
    uaddlp v27.4s, v27.8h
    uaddlp v28.4s, v28.8h
    uaddlp v29.4s, v29.8h
    uaddlp v30.4s, v30.8h
    uaddlp v31.4s, v31.8h
    addp v24.4s, v24.4s, v25.4s
    addp v26.4s, v26.4s, v27.4s
    addp v28.4s, v28.4s, v29.4s
    addp v30.4s, v30.4s, v31.4s
    addp v24.4s, v24.4s, v26.4s
    addp v28.4s, v28.4s, v30.4s
    addp v24.4s, v24.4s, v28.4s
    addp v24.4s, v24.4s, v24.4s
    addp v24.4s, v24.4s, v24.4s

    mov x0, #0
    umov w0, v24.s[0]
    lsl x0, x0, x5

    ret

//i32u_t xGetSSE8_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height);
//*p_org->x0, i_org->x1, p_pred->x2, i_pred->x3, height->x4
function xGetSSE8_arm64
    movi v16.16b, #0

get_ssd_8_y:
    //load p_org
    ld1 {v0.8b}, [x0], x1
    ld1 {v1.8b}, [x0], x1
    ld1 {v2.8b}, [x0], x1
    ld1 {v3.8b}, [x0], x1
    //load pred
    ld1 {v4.8b}, [x2], x3
    ld1 {v5.8b}, [x2], x3
    ld1 {v6.8b}, [x2], x3
    ld1 {v7.8b}, [x2], x3

    uabd v0.8b, v0.8b, v4.8b
    uabd v1.8b, v1.8b, v5.8b
    uabd v2.8b, v2.8b, v6.8b
    uabd v3.8b, v3.8b, v7.8b
    
    uxtl v0.8h, v0.8b
    uxtl v1.8h, v1.8b
    uxtl v2.8h, v2.8b
    uxtl v3.8h, v3.8b

    umlal v16.4s, v0.4h, v0.4h
    umlal2 v16.4s, v0.8h, v0.8h
    umlal v16.4s, v1.4h, v1.4h
    umlal2 v16.4s, v1.8h, v1.8h
    umlal v16.4s, v2.4h, v2.4h
    umlal2 v16.4s, v2.8h, v2.8h
    umlal v16.4s, v3.4h, v3.4h
    umlal2 v16.4s, v3.8h, v3.8h

    subs w4, w4, #4
    bgt get_ssd_8_y

    uaddlp v16.2d, v16.4s
    addp v16.2d, v16.2d, v16.2d
    mov x0, v16.d[0]

ret

//i32u_t xGetSSE16_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height);
//*p_org->x0, i_org->x1, p_pred->x2, i_pred->x3, height->x4
function xGetSSE16_arm64
    movi v24.16b, #0

get_ssd_16_y:
    //load p_org
    ld1 {v0.16b}, [x0], x1
    ld1 {v1.16b}, [x0], x1
    ld1 {v2.16b}, [x0], x1
    ld1 {v3.16b}, [x0], x1
    //load pred
    ld1 {v4.16b}, [x2], x3
    ld1 {v5.16b}, [x2], x3
    ld1 {v6.16b}, [x2], x3
    ld1 {v7.16b}, [x2], x3

    uabd v16.16b, v0.16b, v4.16b
    uabd v17.16b, v1.16b, v5.16b
    uabd v18.16b, v2.16b, v6.16b
    uabd v19.16b, v3.16b, v7.16b

    uxtl v0.8h, v16.8b
    uxtl2 v1.8h, v16.16b
    uxtl v2.8h, v17.8b
    uxtl2 v3.8h, v17.16b
    uxtl v4.8h, v18.8b
    uxtl2 v5.8h, v18.16b
    uxtl v6.8h, v19.8b
    uxtl2 v7.8h, v19.16b
    
    umlal v24.4s, v0.4h, v0.4h
    umlal2 v24.4s, v0.8h, v0.8h
    umlal v24.4s, v1.4h, v1.4h
    umlal2 v24.4s, v1.8h, v1.8h
    umlal v24.4s, v2.4h, v2.4h
    umlal2 v24.4s, v2.8h, v2.8h
    umlal v24.4s, v3.4h, v3.4h
    umlal2 v24.4s, v3.8h, v3.8h
    umlal v24.4s, v4.4h, v4.4h
    umlal2 v24.4s, v4.8h, v4.8h
    umlal v24.4s, v5.4h, v5.4h
    umlal2 v24.4s, v5.8h, v5.8h
    umlal v24.4s, v6.4h, v6.4h
    umlal2 v24.4s, v6.8h, v6.8h
    umlal v24.4s, v7.4h, v7.4h
    umlal2 v24.4s, v7.8h, v7.8h

    subs w4, w4, #4
    bgt get_ssd_16_y

    uaddlp v24.2d, v24.4s
    addp v24.2d, v24.2d, v24.2d
    mov x0, v24.d[0]

ret

//i32u_t xGetSSE32_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height);
//*p_org->x0, i_org->x1, p_pred->x2, i_pred->x3, height->x4
function xGetSSE32_arm64
    movi v24.16b, #0

get_ssd_32_y:
    //load p_org
    ld1 {v0.16b, v1.16b}, [x0], x1
    ld1 {v2.16b, v3.16b}, [x0], x1

    //load pred
    ld1 {v4.16b, v5.16b}, [x2], x3
    ld1 {v6.16b, v7.16b}, [x2], x3

    uabd v16.16b, v0.16b, v4.16b
    uabd v17.16b, v1.16b, v5.16b
    uabd v18.16b, v2.16b, v6.16b
    uabd v19.16b, v3.16b, v7.16b
    
    uxtl v0.8h, v16.8b
    uxtl2 v1.8h, v16.16b
    uxtl v2.8h, v17.8b
    uxtl2 v3.8h, v17.16b
    uxtl v4.8h, v18.8b
    uxtl2 v5.8h, v18.16b
    uxtl v6.8h, v19.8b
    uxtl2 v7.8h, v19.16b

    umlal v24.4s, v0.4h, v0.4h
    umlal2 v24.4s, v0.8h, v0.8h
    umlal v24.4s, v1.4h, v1.4h
    umlal2 v24.4s, v1.8h, v1.8h
    umlal v24.4s, v2.4h, v2.4h
    umlal2 v24.4s, v2.8h, v2.8h
    umlal v24.4s, v3.4h, v3.4h
    umlal2 v24.4s, v3.8h, v3.8h
    umlal v24.4s, v4.4h, v4.4h
    umlal2 v24.4s, v4.8h, v4.8h
    umlal v24.4s, v5.4h, v5.4h
    umlal2 v24.4s, v5.8h, v5.8h
    umlal v24.4s, v6.4h, v6.4h
    umlal2 v24.4s, v6.8h, v6.8h
    umlal v24.4s, v7.4h, v7.4h
    umlal2 v24.4s, v7.8h, v7.8h

    subs w4, w4, #2
    bgt get_ssd_32_y

    uaddlp v24.2d, v24.4s
    addp v24.2d, v24.2d, v24.2d
    mov x0, v24.d[0]

ret

//i32u_t xGetSAD8_x4_arm64(pel_t *p_org, int i_org, pel_t *pred0, pel_t *pred1, pel_t *pred2, pel_t *pred3, int i_pred, i32u_t sad[4], int height, int skip_lines);
//*p_org->x0, i_org->x1, *pred0->x2, *pred1->x3, *pred2->x4, *pred3->x5, i_pred->x6, sad[4]->x7, height->[x8], skip_lines->x9
function xGetSAD8_x4_arm64
    mov x8, #0
    mov x9, #0
    mov x10, sp
#if defined(__APPLE__)
    ldr w8, [x10], #4
    ldr w9, [x10]
#else
    ldr w8, [x10], #8
    ldr w9, [x10]
#endif
    
    mov x10, #1
    lsl x10, x10, x9       //1 << skip_lines
    mul x1, x1, x10
    mul x6, x6, x10
    lsr x8, x8, x9

    movi v16.16b, #0
    movi v17.16b, #0
    movi v18.16b, #0
    movi v19.16b, #0

get_sad_x4_8_y:
    //load p_org
    ld1 {v0.8b}, [x0], x1

    //load pred
    ld1 {v1.8b}, [x2], x6
    ld1 {v2.8b}, [x3], x6
    ld1 {v3.8b}, [x4], x6
    ld1 {v4.8b}, [x5], x6
    
    uxtl v0.8h, v0.8b
    uxtl v1.8h, v1.8b
    uxtl v2.8h, v2.8b
    uxtl v3.8h, v3.8b
    uxtl v4.8h, v4.8b

    //abs
    uabd v1.8h, v0.8h, v1.8h
    uabd v2.8h, v0.8h, v2.8h
    uabd v3.8h, v0.8h, v3.8h
    uabd v4.8h, v0.8h, v4.8h

    add v16.8h, v16.8h, v1.8h
    add v17.8h, v17.8h, v2.8h
    add v18.8h, v18.8h, v3.8h
    add v19.8h, v19.8h, v4.8h

    subs w8, w8, #1
    bgt get_sad_x4_8_y

    uaddlp v16.4s, v16.8h
    uaddlp v17.4s, v17.8h
    uaddlp v18.4s, v18.8h
    uaddlp v19.4s, v19.8h
    addp v16.4s, v16.4s, v17.4s
    addp v18.4s, v18.4s, v19.4s
    addp v16.4s, v16.4s, v18.4s

    dup v17.4s, w9
    uqrshl v16.4s, v16.4s, v17.4s
    st1 {v16.4s}, [x7]
ret

//i32u_t xGetSAD16_x4_arm64(pel_t *p_org, int i_org, pel_t *pred0, pel_t *pred1, pel_t *pred2, pel_t *pred3, int i_pred, i32u_t sad[4], int height, int skip_lines);
//*p_org->x0, i_org->x1, *pred0->x2, *pred1->x3, *pred2->x4, *pred3->x5, i_pred->x6, sad[4]->x7, height->[x8], skip_lines->x9
function xGetSAD16_x4_arm64
    mov x8, #0
    mov x9, #0
    mov x10, sp
#if defined(__APPLE__)
    ldr w8, [x10], #4
    ldr w9, [x10]
#else
    ldr w8, [x10], #8
    ldr w9, [x10]
#endif
    
    mov x10, #1
    lsl x10, x10, x9       //1 << skip_lines
    mul x1, x1, x10
    mul x6, x6, x10
    lsr x8, x8, x9
    movi v24.16b, #0
    movi v25.16b, #0
    movi v26.16b, #0
    movi v27.16b, #0
    movi v28.16b, #0
    movi v29.16b, #0
    movi v30.16b, #0
    movi v31.16b, #0

get_sad_x4_16_y:
    //load p_org
    ld1 {v0.16b}, [x0], x1

    //load pred0
    ld1 {v1.16b}, [x2], x6
    ld1 {v2.16b}, [x3], x6
    ld1 {v3.16b}, [x4], x6
    ld1 {v4.16b}, [x5], x6

    uabd v16.16b, v0.16b, v1.16b
    uabd v17.16b, v0.16b, v2.16b
    uabd v18.16b, v0.16b, v3.16b
    uabd v19.16b, v0.16b, v4.16b

    uxtl v0.8h, v16.8b
    uxtl2 v1.8h, v16.16b
    uxtl v2.8h, v17.8b
    uxtl2 v3.8h, v17.16b
    uxtl v4.8h, v18.8b
    uxtl2 v5.8h, v18.16b
    uxtl v6.8h, v19.8b
    uxtl2 v7.8h, v19.16b
    
    add v24.8h, v24.8h, v0.8h
    add v25.8h, v25.8h, v1.8h
    add v26.8h, v26.8h, v2.8h
    add v27.8h, v27.8h, v3.8h
    add v28.8h, v28.8h, v4.8h
    add v29.8h, v29.8h, v5.8h
    add v30.8h, v30.8h, v6.8h
    add v31.8h, v31.8h, v7.8h

    subs w8, w8, #1
    bgt get_sad_x4_16_y
    uaddl v16.4s, v24.4h, v25.4h
    uaddl2 v17.4s, v24.8h, v25.8h
    add v18.4s, v16.4s, v17.4s
    uaddl v16.4s, v26.4h, v27.4h
    uaddl2 v17.4s, v26.8h, v27.8h
    add v19.4s, v16.4s, v17.4s
    uaddl v16.4s, v28.4h, v29.4h
    uaddl2 v17.4s, v28.8h, v29.8h
    add v20.4s, v16.4s, v17.4s
    uaddl v16.4s, v30.4h, v31.4h
    uaddl2 v17.4s, v30.8h, v31.8h
    add v21.4s, v16.4s, v17.4s

    addp v18.4s, v18.4s, v19.4s
    addp v20.4s, v20.4s, v21.4s
    addp v18.4s, v18.4s, v20.4s

    dup v17.4s, w9
    uqrshl v18.4s, v18.4s, v17.4s
    st1 {v18.4s}, [x7]
    ret

//i32u_t xGetSAD32_x4_arm64(pel_t *p_org, int i_org, pel_t *pred0, pel_t *pred1, pel_t *pred2, pel_t *pred3, int i_pred, i32u_t sad[4], int height, int skip_lines);
//*p_org->x0, i_org->x1, *pred0->x2, *pred1->x3, *pred2->x4, *pred3->x5, i_pred->x6, sad[4]->x7, height->[x8], skip_lines->x9
function xGetSAD32_x4_arm64
    mov x8, #0
    mov x9, #0
    mov x10, sp
#if defined(__APPLE__)
    ldr w8, [x10], #4
    ldr w9, [x10]
#else
    ldr w8, [x10], #8
    ldr w9, [x10]
#endif

    sub sp, sp, #64
    st1 {v8.8h, v9.8h, v10.8h, v11.8h}, [sp]
    sub sp, sp, #64
    st1 {v12.8h, v13.8h, v14.8h, v15.8h}, [sp]

    mov x10, #1
    lsl x10, x10, x9       //1 << skip_lines
    mul x1, x1, x10
    mul x6, x6, x10
    lsr x8, x8, x9

    movi v16.16b, #0
    movi v17.16b, #0
    movi v18.16b, #0
    movi v19.16b, #0
    movi v20.16b, #0
    movi v21.16b, #0
    movi v22.16b, #0
    movi v23.16b, #0

get_sad_x4_32_y:
    //load p_org
    ld1 {v0.16b, v1.16b}, [x0], x1
    //load pred
    ld1 {v2.16b, v3.16b}, [x2], x6
    ld1 {v4.16b, v5.16b}, [x3], x6
    ld1 {v6.16b, v7.16b}, [x4], x6
    ld1 {v8.16b, v9.16b}, [x5], x6

    uabd v2.16b, v0.16b, v2.16b
    uabd v3.16b, v1.16b, v3.16b
    uabd v4.16b, v0.16b, v4.16b
    uabd v5.16b, v1.16b, v5.16b
    uabd v6.16b, v0.16b, v6.16b
    uabd v7.16b, v1.16b, v7.16b
    uabd v8.16b, v0.16b, v8.16b
    uabd v9.16b, v1.16b, v9.16b

    uaddl v0.8h, v2.8b, v3.8b
    uaddl2 v1.8h, v2.16b, v3.16b
    uaddl v2.8h, v4.8b, v5.8b
    uaddl2 v3.8h, v4.16b, v5.16b
    uaddl v4.8h, v6.8b, v7.8b
    uaddl2 v5.8h, v6.16b, v7.16b
    uaddl v6.8h, v8.8b, v9.8b
    uaddl2 v7.8h, v8.16b, v9.16b

    add v16.8h, v16.8h, v0.8h
    add v17.8h, v17.8h, v1.8h
    add v18.8h, v18.8h, v2.8h
    add v19.8h, v19.8h, v3.8h
    add v20.8h, v20.8h, v4.8h
    add v21.8h, v21.8h, v5.8h
    add v22.8h, v22.8h, v6.8h
    add v23.8h, v23.8h, v7.8h

    subs w8, w8, #1
    bgt get_sad_x4_32_y
    
    //sad[0]
    uaddl v0.4s, v16.4h, v17.4h
    uaddl2 v1.4s, v16.8h, v17.8h
    add v16.4s, v0.4s, v1.4s
    //sad[1]
    uaddl v0.4s, v18.4h, v19.4h
    uaddl2 v1.4s, v18.8h, v19.8h
    add v17.4s, v0.4s, v1.4s

    //sad[2]
    uaddl v0.4s, v20.4h, v21.4h
    uaddl2 v1.4s, v20.8h, v21.8h
    add v18.4s, v0.4s, v1.4s

    //sad[3]
    uaddl v0.4s, v22.4h, v23.4h
    uaddl2 v1.4s, v22.8h, v23.8h
    add v19.4s, v0.4s, v1.4s

    addp v16.4s, v16.4s, v17.4s
    addp v18.4s, v18.4s, v19.4s
    addp v16.4s, v16.4s, v18.4s

    dup v17.4s, w9
    uqrshl v16.4s, v16.4s, v17.4s
    st1 {v16.4s}, [x7]

    ld1 {v12.8h, v13.8h, v14.8h, v15.8h}, [sp], #64
    ld1 {v8.8h, v9.8h, v10.8h, v11.8h}, [sp], #64

    ret

//i32u_t xGetAVGSAD8_arm64(pel_t *p_org, int i_org, pel_t *pred1, int i_pred1, pel_t *p_pred2, int i_pred2, int height, int skip_lines);
//*p_org->x0, i_org->x1, pred1->x2, i_pred1->x3, p_pred2->x4, i_pred2->x5, height->x6, skip_lines->x7
function xGetAVGSAD8_arm64
    mov x8, #1
    lsl x8, x8, x7      //1 << skip_lines

    mul x1, x1, x8
    mul x3, x3, x8
    mul x5, x5, x8
    lsr x6, x6, x7
    movi v3.16b, #0

get_sad_avg_8_y:
    //load org
    ld1 {v0.8b}, [x0], x1
    //load pred
    ld1 {v1.8b}, [x2], x3
    ld1 {v2.8b}, [x4], x5
    
    uxtl v0.8h, v0.8b

    uaddl v1.8h, v1.8b, v2.8b
    urshr v1.8h, v1.8h, #1
    uabd v2.8h, v0.8h, v1.8h
    add v3.8h, v3.8h, v2.8h

    subs x6, x6, #1
    bgt get_sad_avg_8_y

    uaddlp v3.4s, v3.8h
    addp v3.4s, v3.4s, v3.4s
    addp v3.4s, v3.4s, v3.4s

    mov x0, #0
    umov w0, v3.s[0]
    lsl w0, w0, w7
    ret
    
//i32u_t xGetAVGSAD16_arm64(pel_t *p_org, int i_org, pel_t *pred1, int i_pred1, pel_t *p_pred2, int i_pred2, int height, int skip_lines);
//*p_org->x0, i_org->x1, pred1->x2, i_pred1->x3, p_pred2->x4, i_pred2->x5, height->x6, skip_lines->x7
function xGetAVGSAD16_arm64
    mov x8, #1
    lsl x8, x8, x7      //1 << skip_lines

    mul x1, x1, x8
    mul x3, x3, x8
    mul x5, x5, x8
    lsr x6, x6, x7
    movi v6.16b, #0
    movi v7.16b, #0

get_sad_avg_16_y:
    //load org
    ld1 {v0.8b, v1.8b}, [x0], x1
    //load pred
    ld1 {v2.8b, v3.8b}, [x2], x3
    ld1 {v4.8b, v5.8b}, [x4], x5
    
    uxtl v0.8h, v0.8b
    uxtl v1.8h, v1.8b

    uaddl v2.8h, v2.8b, v4.8b
    uaddl v3.8h, v3.8b, v5.8b
    urshr v2.8h, v2.8h, #1
    urshr v3.8h, v3.8h, #1
    uabd v2.8h, v0.8h, v2.8h
    uabd v3.8h, v1.8h, v3.8h
    add v6.8h, v2.8h, v6.8h
    add v7.8h, v3.8h, v7.8h
    subs w6, w6, #1
    bgt get_sad_avg_16_y

    uaddl v16.4s, v6.4h, v7.4h
    uaddl2 v17.4s, v6.8h, v7.8h
    add v16.4s, v16.4s, v17.4s
    addp v16.4s, v16.4s, v16.4s
    addp v16.4s, v16.4s, v16.4s
    
    mov x0, #0
    umov w0, v16.s[0]
    lsl w0, w0, w7
    ret

//i32u_t xGetAVGSAD32_arm64(pel_t *p_org, int i_org, pel_t *pred1, int i_pred1, pel_t *p_pred2, int i_pred2, int height, int skip_lines);
//*p_org->x0, i_org->x1, pred1->x2, i_pred1->x3, p_pred2->x4, i_pred2->x5, height->x6, skip_lines->x7
function xGetAVGSAD32_arm64
    mov x8, #1
    lsl x8, x8, x7      //1 << skip_lines

    mul x1, x1, x8
    mul x3, x3, x8
    mul x5, x5, x8
    lsr x6, x6, x7
    movi v20.16b, #0
    movi v21.16b, #0
    movi v22.16b, #0
    movi v23.16b, #0

get_sad_avg_32_y:
    //load org
    ld1 {v0.8b, v1.8b, v2.8b, v3.8b}, [x0], x1
    //load pred
    ld1 {v4.8b, v5.8b, v6.8b, v7.8b}, [x2], x3
    ld1 {v16.8b, v17.8b, v18.8b, v19.8b}, [x4], x5

    uxtl v0.8h, v0.8b
    uxtl v1.8h, v1.8b
    uxtl v2.8h, v2.8b
    uxtl v3.8h, v3.8b

    uaddl v4.8h, v4.8b, v16.8b
    uaddl v5.8h, v5.8b, v17.8b
    uaddl v6.8h, v6.8b, v18.8b
    uaddl v7.8h, v7.8b, v19.8b
    urshr v4.8h, v4.8h, #1
    urshr v5.8h, v5.8h, #1
    urshr v6.8h, v6.8h, #1
    urshr v7.8h, v7.8h, #1

    uabd v4.8h, v0.8h, v4.8h
    uabd v5.8h, v1.8h, v5.8h
    uabd v6.8h, v2.8h, v6.8h
    uabd v7.8h, v3.8h, v7.8h

    add v20.8h, v20.8h, v4.8h
    add v21.8h, v21.8h, v5.8h
    add v22.8h, v22.8h, v6.8h
    add v23.8h, v23.8h, v7.8h
    subs w6, w6, #1
    bgt get_sad_avg_32_y

    add v20.8h, v20.8h, v21.8h
    add v21.8h, v22.8h, v23.8h
    uaddl v16.4s, v20.4h, v21.4h
    uaddl2 v17.4s, v20.8h, v21.8h
    add v16.4s, v16.4s, v17.4s
    addp v16.4s, v16.4s, v16.4s
    addp v16.4s, v16.4s, v16.4s
    
    mov x0, #0
    umov w0, v16.s[0]
    lsl w0, w0, w7
    ret

//i32u_t xCalcHAD8x8_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred);
//*p_org->x0, i_org->x1, *p_pred->x2, i_pred->x3
function xCalcHAD8x8_arm64

    ld1 {v0.8b}, [x0], x1
    ld1 {v1.8b}, [x0], x1
    ld1 {v2.8b}, [x0], x1
    ld1 {v3.8b}, [x0], x1
    ld1 {v4.8b}, [x0], x1
    ld1 {v5.8b}, [x0], x1
    ld1 {v6.8b}, [x0], x1
    ld1 {v7.8b}, [x0], x1

    ld1 {v16.8b}, [x2], x3
    ld1 {v17.8b}, [x2], x3
    ld1 {v18.8b}, [x2], x3
    ld1 {v19.8b}, [x2], x3
    ld1 {v20.8b}, [x2], x3
    ld1 {v21.8b}, [x2], x3
    ld1 {v22.8b}, [x2], x3
    ld1 {v23.8b}, [x2], x3

    usubl v0.8h, v0.8b, v16.8b
    usubl v1.8h, v1.8b, v17.8b
    usubl v2.8h, v2.8b, v18.8b
    usubl v3.8h, v3.8b, v19.8b
    usubl v4.8h, v4.8b, v20.8b
    usubl v5.8h, v5.8b, v21.8b
    usubl v6.8h, v6.8b, v22.8b
    usubl v7.8h, v7.8b, v23.8b

    uzp1 v16.8h, v0.8h, v1.8h       //d0, d2, d4, d6, d8, d10, d12, d14
    uzp2 v17.8h, v0.8h, v1.8h       //d1, d3, d5, d7,
    uzp1 v18.8h, v2.8h, v3.8h       //d16, d18, d20, d22,
    uzp2 v19.8h, v2.8h, v3.8h       //d17, d19, d21, d23,
    uzp1 v20.8h, v4.8h, v5.8h       //d32, d34, d36, d38,
    uzp2 v21.8h, v4.8h, v5.8h       //d33, d35, d37, d39,
    uzp1 v22.8h, v6.8h, v7.8h       //d48, d50, d52, d54,
    uzp2 v23.8h, v6.8h, v7.8h       //d49, d51, d53, d55,

    add v0.8h, v16.8h, v17.8h       //d0 + d1, d2 + d3,
    sub v1.8h, v16.8h, v17.8h       //d0 - d1, d2 - d3,
    add v2.8h, v18.8h, v19.8h       //d16 + d17, d18 + d19
    sub v3.8h, v18.8h, v19.8h       //d16 - d17, d18 - d19
    add v4.8h, v20.8h, v21.8h
    sub v5.8h, v20.8h, v21.8h
    add v6.8h, v22.8h, v23.8h
    sub v7.8h, v22.8h, v23.8h

    trn1 v16.8h, v0.8h, v1.8h       //d0 + d1, d0 - d1, d4 + d5, d4 - d5
    trn2 v17.8h, v0.8h, v1.8h       //d2 + d3, d2 - d3, d6 + d7, d5 - d7
    trn1 v18.8h, v2.8h, v3.8h
    trn2 v19.8h, v2.8h, v3.8h
    trn1 v20.8h, v4.8h, v5.8h
    trn2 v21.8h, v4.8h, v5.8h
    trn1 v22.8h, v6.8h, v7.8h
    trn2 v23.8h, v6.8h, v7.8h

    add v0.8h, v16.8h, v17.8h       //d0 + d1 + d2 + d3, d0 - d1 + d2 - d3
    sub v1.8h, v16.8h, v17.8h       //d0 + d1 - (d2 + d3), d0 - d1 - (d2 - d3)
    add v2.8h, v18.8h, v19.8h       //d16 + d17 + d18 + d19, d16 - d17 + (d18 - d19)
    sub v3.8h, v18.8h, v19.8h       //d16 + d17 - d18 + d19, d16 - d17 - (d18 - d19)
    add v4.8h, v20.8h, v21.8h
    sub v5.8h, v20.8h, v21.8h
    add v6.8h, v22.8h, v23.8h
    sub v7.8h, v22.8h, v23.8h

    trn1 v16.4s, v0.4s, v1.4s       //d0 + d1 + d2 + d3, d0 - d1 + d2 - d3, d0 + d1 - (d2 + d3), d0 - d1 - (d2 - d3)
    trn2 v17.4s, v0.4s, v1.4s       //d4 + d5 + d6 + d7, d4 - d5 + d6 - d7, d4 + d5 - (d6 + d7), d4 - d5 - (d6 - d7)
    trn1 v18.4s, v2.4s, v3.4s
    trn2 v19.4s, v2.4s, v3.4s
    trn1 v20.4s, v4.4s, v5.4s
    trn2 v21.4s, v4.4s, v5.4s
    trn1 v22.4s, v6.4s, v7.4s
    trn2 v23.4s, v6.4s, v7.4s

    add v0.8h, v16.8h, v17.8h       //d0 + d1 + d2 + d3 + d4 + d5 + d6 + d7, d0 - d1 + d2 - d3 + d4 - d5 + d6 - d7
    sub v1.8h, v16.8h, v17.8h       //d0 + d1 + d2 + d3 - (d4 + d5 + d6 + d7)
    add v2.8h, v18.8h, v19.8h       //d16 + d17 + d18 + d19 + d20 + d21 + d22 + d23
    sub v3.8h, v18.8h, v19.8h       //d16 + d17 + d18 + d19 - (d20 + d21 + d22 + d23)
    add v4.8h, v20.8h, v21.8h
    sub v5.8h, v20.8h, v21.8h
    add v6.8h, v22.8h, v23.8h
    sub v7.8h, v22.8h, v23.8h

    trn1 v16.2d, v0.2d, v1.2d
    trn2 v17.2d, v0.2d, v1.2d
    trn1 v18.2d, v2.2d, v3.2d
    trn2 v19.2d, v2.2d, v3.2d
    trn1 v20.2d, v4.2d, v5.2d
    trn2 v21.2d, v4.2d, v5.2d
    trn1 v22.2d, v6.2d, v7.2d
    trn2 v23.2d, v6.2d, v7.2d

    add v0.8h, v16.8h, v17.8h
    sub v1.8h, v16.8h, v17.8h
    add v2.8h, v18.8h, v19.8h
    sub v3.8h, v18.8h, v19.8h
    add v4.8h, v20.8h, v21.8h
    sub v5.8h, v20.8h, v21.8h
    add v6.8h, v22.8h, v23.8h
    sub v7.8h, v22.8h, v23.8h

    add v16.8h, v0.8h, v2.8h
    sub v17.8h, v0.8h, v2.8h
    add v18.8h, v1.8h, v3.8h
    sub v19.8h, v1.8h, v3.8h
    add v20.8h, v4.8h, v6.8h
    sub v21.8h, v4.8h, v6.8h
    add v22.8h, v5.8h, v7.8h
    sub v23.8h, v5.8h, v7.8h

    saddl v0.4s, v16.4h, v20.4h
    saddl2 v1.4s, v16.8h, v20.8h
    saddl v2.4s, v17.4h, v21.4h
    saddl2 v3.4s, v17.8h, v21.8h
    saddl v4.4s, v18.4h, v22.4h
    saddl2 v5.4s, v18.8h, v22.8h
    saddl v6.4s, v19.4h, v23.4h
    saddl2 v7.4s, v19.8h, v23.8h
    ssubl v24.4s, v16.4h, v20.4h
    ssubl2 v25.4s, v16.8h, v20.8h
    ssubl v26.4s, v17.4h, v21.4h
    ssubl2 v27.4s, v17.8h, v21.8h
    ssubl v28.4s, v18.4h, v22.4h
    ssubl2 v29.4s, v18.8h, v22.8h
    ssubl v30.4s, v19.4h, v23.4h
    ssubl2 v31.4s, v19.8h, v23.8h

    abs v0.4s, v0.4s
    abs v1.4s, v1.4s
    abs v2.4s, v2.4s
    abs v3.4s, v3.4s
    abs v4.4s, v4.4s
    abs v5.4s, v5.4s
    abs v6.4s, v6.4s
    abs v7.4s, v7.4s
    abs v24.4s, v24.4s
    abs v25.4s, v25.4s
    abs v26.4s, v26.4s
    abs v27.4s, v27.4s
    abs v28.4s, v28.4s
    abs v29.4s, v29.4s
    abs v30.4s, v30.4s
    abs v31.4s, v31.4s

    add v0.4s, v0.4s, v24.4s
    add v1.4s, v1.4s, v25.4s
    add v2.4s, v2.4s, v26.4s
    add v3.4s, v3.4s, v27.4s
    add v4.4s, v4.4s, v28.4s
    add v5.4s, v5.4s, v29.4s
    add v6.4s, v6.4s, v30.4s
    add v7.4s, v7.4s, v31.4s

    add v0.4s, v0.4s, v1.4s
    add v2.4s, v2.4s, v3.4s
    add v4.4s, v4.4s, v5.4s
    add v6.4s, v6.4s, v7.4s
    add v0.4s, v0.4s, v2.4s
    add v4.4s, v4.4s, v6.4s
    add v0.4s, v0.4s, v4.4s

    addp v0.4s, v0.4s, v0.4s
    addp v0.4s, v0.4s, v0.4s

    mov x0, #0
    umov w0, v0.s[0]
    add x0, x0, #2
    lsr x0, x0, #2

ret

#else

//void xGetSAD8_arm64(pel *p_org, int i_org, pel *pred, int i_pred, int height, int skip_lines)
//*p_org->x0, i_org->x1, p_pred->x2, i_pred->x3, height->x4, skip_lines->x5
function xGetSAD8_arm64
    mov x6, #1
    lsl x6, x6, x5      //1 << skip_lines
    lsl x1, x1, #1
    mul x1, x1, x6
    lsl x3, x3, #1
    mul x3, x3, x6
    lsr x4, x4, x5
    movi v16.16b, #0

get_sad_8_y:
    //load org
    ld1 {v0.8h}, [x0], x1
    //load pred
    ld1 {v1.8h}, [x2], x3

    uabd v0.8h, v0.8h, v1.8h
    add v16.8h, v16.8h, v0.8h

    subs w4, w4, #1
    bgt get_sad_8_y

    uaddlp v16.4s, v16.8h
    addp v16.4s, v16.4s, v16.4s
    addp v16.4s, v16.4s, v16.4s

    mov x0, #0
    umov w0, v16.s[0]
    lsl w0, w0, w5
    ret

//void xGetSAD16_arm64(pel *p_org, int i_org, pel *pred, int i_pred, int height, int skip_lines)
//*p_org->x0, i_org->x1, p_pred->x2, i_pred->x3, height->x4, skip_lines->x5
function xGetSAD16_arm64
    mov x6, #1
    lsl x6, x6, x5      //1 << skip_lines
    lsl x1, x1, #1
    mul x1, x1, x6
    lsl x3, x3, #1
    mul x3, x3, x6
    lsr x4, x4, x5

    movi v16.16b, #0
    movi v17.16b, #0
    movi v18.16b, #0
    movi v19.16b, #0

get_sad_16_y:
    ld1 {v0.8h, v1.8h}, [x0], x1
    ld1 {v2.8h, v3.8h}, [x0], x1
    //load pred
    ld1 {v4.8h, v5.8h}, [x2], x3
    ld1 {v6.8h, v7.8h}, [x2], x3

    uabd v0.8h, v0.8h, v4.8h
    uabd v1.8h, v1.8h, v5.8h
    uabd v2.8h, v2.8h, v6.8h
    uabd v3.8h, v3.8h, v7.8h

    add v0.8h, v0.8h, v1.8h
    add v2.8h, v2.8h, v3.8h
    add v0.8h, v0.8h, v2.8h
    add v16.8h, v16.8h, v0.8h

    subs w4, w4, #2
    bgt get_sad_16_y

    uaddlp v16.4s, v16.8h
    addp v16.4s, v16.4s, v16.4s
    addp v16.4s, v16.4s, v16.4s

    mov x0, #0
    umov w0, v16.s[0]
    lsl w0, w0, w5

    ret

//void xGetSAD32_arm64(pel *p_org, int i_org, pel *pred, int i_pred, int height, int skip_lines)
//*p_org->x0, i_org->x1, p_pred->x2, i_pred->x3, height->x4, skip_lines->x5
function xGetSAD32_arm64
    mov x6, #1
    lsl x6, x6, x5      //1 << skip_lines
    lsl x1, x1, #1
    mul x1, x1, x6
    lsl x3, x3, #1
    mul x3, x3, x6
    lsr x4, x4, x5

    movi v24.16b, #0
    movi v25.16b, #0
    movi v26.16b, #0
    movi v27.16b, #0

get_sad_32_y:
    //load p_org
    ld1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x0], x1
    ld1 {v4.8h, v5.8h, v6.8h, v7.8h}, [x0], x1
    //load pred
    ld1 {v16.8h, v17.8h, v18.8h, v19.8h}, [x2], x3
    ld1 {v20.8h, v21.8h, v22.8h, v23.8h}, [x2], x3

    uabd v0.8h, v0.8h, v16.8h
    uabd v1.8h, v1.8h, v17.8h
    uabd v2.8h, v2.8h, v18.8h
    uabd v3.8h, v3.8h, v19.8h
    uabd v4.8h, v4.8h, v20.8h
    uabd v5.8h, v5.8h, v21.8h
    uabd v6.8h, v6.8h, v22.8h
    uabd v7.8h, v7.8h, v23.8h

    add v0.8h, v0.8h, v1.8h
    add v1.8h, v2.8h, v3.8h
    add v2.8h, v4.8h, v5.8h
    add v3.8h, v6.8h, v7.8h

    add v24.8h, v24.8h, v0.8h
    add v25.8h, v25.8h, v1.8h
    add v26.8h, v26.8h, v2.8h
    add v27.8h, v27.8h, v3.8h

    subs w4, w4, #2
    bgt get_sad_32_y

    uaddlp v24.4s, v24.8h
    uaddlp v25.4s, v25.8h
    uaddlp v26.4s, v26.8h
    uaddlp v27.4s, v27.8h

    addp v24.4s, v24.4s, v25.4s
    addp v26.4s, v26.4s, v27.4s
    addp v24.4s, v24.4s, v26.4s
    addp v24.4s, v24.4s, v24.4s
    addp v24.4s, v24.4s, v24.4s

    mov x0, #0
    umov w0, v24.s[0]
    lsl x0, x0, x5

    ret


//i32u_t xGetSSE4_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height);
//*p_org->x0, i_org->x1, p_pred->x2, i_pred->x3, height->x4
function xGetSSE4_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    movi v16.16b, #0

get_ssd_4_y:
    //load p_org
    ld1 {v0.4h}, [x0], x1
    ld1 {v1.4h}, [x0], x1
    ld1 {v2.4h}, [x0], x1
    ld1 {v3.4h}, [x0], x1
    //load pred
    ld1 {v4.4h}, [x2], x3
    ld1 {v5.4h}, [x2], x3
    ld1 {v6.4h}, [x2], x3
    ld1 {v7.4h}, [x2], x3

    uabd v0.4h, v0.4h, v4.4h
    uabd v1.4h, v1.4h, v5.4h
    uabd v2.4h, v2.4h, v6.4h
    uabd v3.4h, v3.4h, v7.4h

    umlal v16.4s, v0.4h, v0.4h
    umlal v16.4s, v1.4h, v1.4h
    umlal v16.4s, v2.4h, v2.4h
    umlal v16.4s, v3.4h, v3.4h

    subs w4, w4, #4
    bgt get_ssd_4_y

    uaddlp v16.2d, v16.4s
    addp v16.2d, v16.2d, v16.2d
    mov x0, v16.d[0]

ret

//i32u_t xGetSSE8_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height);
//*p_org->x0, i_org->x1, p_pred->x2, i_pred->x3, height->x4
function xGetSSE8_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    movi v16.16b, #0

get_ssd_8_y:
    //load p_org
    ld1 {v0.8h}, [x0], x1
    ld1 {v1.8h}, [x0], x1
    ld1 {v2.8h}, [x0], x1
    ld1 {v3.8h}, [x0], x1
    //load pred
    ld1 {v4.8h}, [x2], x3
    ld1 {v5.8h}, [x2], x3
    ld1 {v6.8h}, [x2], x3
    ld1 {v7.8h}, [x2], x3

    uabd v0.8h, v0.8h, v4.8h
    uabd v1.8h, v1.8h, v5.8h
    uabd v2.8h, v2.8h, v6.8h
    uabd v3.8h, v3.8h, v7.8h

    umlal v16.4s, v0.4h, v0.4h
    umlal2 v16.4s, v0.8h, v0.8h
    umlal v16.4s, v1.4h, v1.4h
    umlal2 v16.4s, v1.8h, v1.8h
    umlal v16.4s, v2.4h, v2.4h
    umlal2 v16.4s, v2.8h, v2.8h
    umlal v16.4s, v3.4h, v3.4h
    umlal2 v16.4s, v3.8h, v3.8h

    subs w4, w4, #4
    bgt get_ssd_8_y

    uaddlp v16.2d, v16.4s
    addp v16.2d, v16.2d, v16.2d
    mov x0, v16.d[0]

ret

//i32u_t xGetSSE16_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height);
//*p_org->x0, i_org->x1, p_pred->x2, i_pred->x3, height->x4
function xGetSSE16_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    movi v24.16b, #0

get_ssd_16_y:
    //load p_org
    ld1 {v0.8h, v1.8h}, [x0], x1
    ld1 {v2.8h, v3.8h}, [x0], x1
    ld1 {v4.8h, v5.8h}, [x0], x1
    ld1 {v6.8h, v7.8h}, [x0], x1
    //load pred
    ld1 {v16.8h, v17.8h}, [x2], x3
    ld1 {v18.8h, v19.8h}, [x2], x3
    ld1 {v20.8h, v21.8h}, [x2], x3
    ld1 {v22.8h, v23.8h}, [x2], x3

    uabd v0.8h, v0.8h, v16.8h
    uabd v1.8h, v1.8h, v17.8h
    uabd v2.8h, v2.8h, v18.8h
    uabd v3.8h, v3.8h, v19.8h
    uabd v4.8h, v4.8h, v20.8h
    uabd v5.8h, v5.8h, v21.8h
    uabd v6.8h, v6.8h, v22.8h
    uabd v7.8h, v7.8h, v23.8h

    umlal v24.4s, v0.4h, v0.4h
    umlal2 v24.4s, v0.8h, v0.8h
    umlal v24.4s, v1.4h, v1.4h
    umlal2 v24.4s, v1.8h, v1.8h
    umlal v24.4s, v2.4h, v2.4h
    umlal2 v24.4s, v2.8h, v2.8h
    umlal v24.4s, v3.4h, v3.4h
    umlal2 v24.4s, v3.8h, v3.8h
    umlal v24.4s, v4.4h, v4.4h
    umlal2 v24.4s, v4.8h, v4.8h
    umlal v24.4s, v5.4h, v5.4h
    umlal2 v24.4s, v5.8h, v5.8h
    umlal v24.4s, v6.4h, v6.4h
    umlal2 v24.4s, v6.8h, v6.8h
    umlal v24.4s, v7.4h, v7.4h
    umlal2 v24.4s, v7.8h, v7.8h

    subs w4, w4, #4
    bgt get_ssd_16_y

    uaddlp v24.2d, v24.4s
    addp v24.2d, v24.2d, v24.2d
    mov x0, v24.d[0]

ret

//i32u_t xGetSSE32_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred, int height);
//*p_org->x0, i_org->x1, p_pred->x2, i_pred->x3, height->x4
function xGetSSE32_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1
    movi v24.16b, #0

get_ssd_32_y:
    //load p_org
    ld1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x0], x1
    ld1 {v4.8h, v5.8h, v6.8h, v7.8h}, [x0], x1
    //load pred
    ld1 {v16.8h, v17.8h, v18.8h, v19.8h}, [x2], x3
    ld1 {v20.8h, v21.8h, v22.8h, v23.8h}, [x2], x3

    uabd v0.8h, v0.8h, v16.8h
    uabd v1.8h, v1.8h, v17.8h
    uabd v2.8h, v2.8h, v18.8h
    uabd v3.8h, v3.8h, v19.8h
    uabd v4.8h, v4.8h, v20.8h
    uabd v5.8h, v5.8h, v21.8h
    uabd v6.8h, v6.8h, v22.8h
    uabd v7.8h, v7.8h, v23.8h

    umlal v24.4s, v0.4h, v0.4h
    umlal2 v24.4s, v0.8h, v0.8h
    umlal v24.4s, v1.4h, v1.4h
    umlal2 v24.4s, v1.8h, v1.8h
    umlal v24.4s, v2.4h, v2.4h
    umlal2 v24.4s, v2.8h, v2.8h
    umlal v24.4s, v3.4h, v3.4h
    umlal2 v24.4s, v3.8h, v3.8h
    umlal v24.4s, v4.4h, v4.4h
    umlal2 v24.4s, v4.8h, v4.8h
    umlal v24.4s, v5.4h, v5.4h
    umlal2 v24.4s, v5.8h, v5.8h
    umlal v24.4s, v6.4h, v6.4h
    umlal2 v24.4s, v6.8h, v6.8h
    umlal v24.4s, v7.4h, v7.4h
    umlal2 v24.4s, v7.8h, v7.8h

    subs w4, w4, #2
    bgt get_ssd_32_y

    uaddlp v24.2d, v24.4s
    addp v24.2d, v24.2d, v24.2d
    mov x0, v24.d[0]

ret

//i32u_t xGetSAD4_x4_arm64(pel_t *p_org, int i_org, pel_t *pred0, pel_t *pred1, pel_t *pred2, pel_t *pred3, int i_pred, i32u_t sad[4], int height, int skip_lines);
//*p_org->x0, i_org->x1, *pred0->x2, *pred1->x3, *pred2->x4, *pred3->x5, i_pred->x6, sad[4]->x7, height->[x8], skip_lines->x9
function xGetSAD4_x4_arm64
    mov x8, #0
    mov x9, #0
    mov x10, sp
#if defined(__APPLE__)
    ldr w8, [x10], #4
    ldr w9, [x10]
#else
    ldr w8, [x10], #8
    ldr w9, [x10]
#endif
    
    mov x10, #1
    lsl x10, x10, x9       //1 << skip_lines
    lsl x1, x1, #1
    mul x1, x1, x10
    lsl x6, x6, #1
    mul x6, x6, x10
    lsr x8, x8, x9

    movi v16.16b, #0
    movi v17.16b, #0
    movi v18.16b, #0
    movi v19.16b, #0

get_sad_x4_4_y:
    //load p_org
    ld1 {v0.d}[0], [x0], x1
    ld1 {v0.d}[1], [x0], x1

    //load pred
    ld1 {v1.d}[0], [x2], x6
    ld1 {v1.d}[1], [x2], x6
    ld1 {v2.d}[0], [x3], x6
    ld1 {v2.d}[1], [x3], x6
    ld1 {v3.d}[0], [x4], x6
    ld1 {v3.d}[1], [x4], x6
    ld1 {v4.d}[0], [x5], x6
    ld1 {v4.d}[1], [x5], x6

    //abs
    uabd v0.8h, v0.8h, v1.8h
    uabd v1.8h, v1.8h, v2.8h
    uabd v2.8h, v2.8h, v3.8h
    uabd v3.8h, v3.8h, v4.8h

    add v16.8h, v16.8h, v1.8h
    add v17.8h, v17.8h, v2.8h
    add v18.8h, v18.8h, v3.8h
    add v19.8h, v19.8h, v4.8h

    subs w8, w8, #2
    bgt get_sad_x4_4_y

    uaddlp v16.4s, v16.8h
    uaddlp v17.4s, v17.8h
    uaddlp v18.4s, v18.8h
    uaddlp v19.4s, v19.8h
    addp v16.4s, v16.4s, v17.4s
    addp v18.4s, v18.4s, v19.4s
    addp v16.4s, v16.4s, v18.4s

    dup v17.4s, w9
    uqrshl v16.4s, v16.4s, v17.4s
    st1 {v16.4s}, [x7]
    ret

//i32u_t xGetSAD8_x4_arm64(pel_t *p_org, int i_org, pel_t *pred0, pel_t *pred1, pel_t *pred2, pel_t *pred3, int i_pred, i32u_t sad[4], int height, int skip_lines);
//*p_org->x0, i_org->x1, *pred0->x2, *pred1->x3, *pred2->x4, *pred3->x5, i_pred->x6, sad[4]->x7, height->[x8], skip_lines->x9
function xGetSAD8_x4_arm64
    mov x8, #0
    mov x9, #0
    mov x10, sp
#if defined(__APPLE__)
    ldr w8, [x10], #4
    ldr w9, [x10]
#else
    ldr w8, [x10], #8
    ldr w9, [x10]
#endif
    
    mov x10, #1
    lsl x10, x10, x9       //1 << skip_lines
    lsl x1, x1, #1
    mul x1, x1, x10
    lsl x6, x6, #1
    mul x6, x6, x10
    lsr x8, x8, x9

    movi v16.16b, #0
    movi v17.16b, #0
    movi v18.16b, #0
    movi v19.16b, #0

get_sad_x4_8_y:
    //load p_org
    ld1 {v0.8h}, [x0], x1

    //load pred
    ld1 {v1.8h}, [x2], x6
    ld1 {v2.8h}, [x3], x6
    ld1 {v3.8h}, [x4], x6
    ld1 {v4.8h}, [x5], x6

    //abs
    uabd v1.8h, v0.8h, v1.8h
    uabd v2.8h, v0.8h, v2.8h
    uabd v3.8h, v0.8h, v3.8h
    uabd v4.8h, v0.8h, v4.8h

    add v16.8h, v16.8h, v1.8h
    add v17.8h, v17.8h, v2.8h
    add v18.8h, v18.8h, v3.8h
    add v19.8h, v19.8h, v4.8h

    subs w8, w8, #1
    bgt get_sad_x4_8_y

    uaddlp v16.4s, v16.8h
    uaddlp v17.4s, v17.8h
    uaddlp v18.4s, v18.8h
    uaddlp v19.4s, v19.8h
    addp v16.4s, v16.4s, v17.4s
    addp v18.4s, v18.4s, v19.4s
    addp v16.4s, v16.4s, v18.4s

    dup v17.4s, w9
    uqrshl v16.4s, v16.4s, v17.4s
    st1 {v16.4s}, [x7]
ret

//i32u_t xGetSAD16_x4_arm64(pel_t *p_org, int i_org, pel_t *pred0, pel_t *pred1, pel_t *pred2, pel_t *pred3, int i_pred, i32u_t sad[4], int height, int skip_lines);
//*p_org->x0, i_org->x1, *pred0->x2, *pred1->x3, *pred2->x4, *pred3->x5, i_pred->x6, sad[4]->x7, height->[x8], skip_lines->x9
function xGetSAD16_x4_arm64
    mov x8, #0
    mov x9, #0
    mov x10, sp
#if defined(__APPLE__)
    ldr w8, [x10], #4
    ldr w9, [x10]
#else
    ldr w8, [x10], #8
    ldr w9, [x10]
#endif
    
    mov x10, #1
    lsl x10, x10, x9       //1 << skip_lines
    lsl x1, x1, #1
    mul x1, x1, x10
    lsl x6, x6, #1
    mul x6, x6, x10
    lsr x8, x8, x9
    movi v18.16b, #0
    movi v19.16b, #0
    movi v20.16b, #0
    movi v21.16b, #0

get_sad_x4_16_y:
    //load p_org
    ld1 {v0.8h, v1.8h}, [x0], x1

    //load pred0
    ld1 {v2.8h, v3.8h}, [x2], x6
    ld1 {v4.8h, v5.8h}, [x3], x6
    ld1 {v6.8h, v7.8h}, [x4], x6
    ld1 {v16.8h, v17.8h}, [x5], x6

    uabd v2.8h, v0.8h, v2.8h
    uabd v3.8h, v1.8h, v3.8h
    uabd v4.8h, v0.8h, v4.8h
    uabd v5.8h, v1.8h, v5.8h
    uabd v6.8h, v0.8h, v6.8h
    uabd v7.8h, v1.8h, v7.8h
    uabd v16.8h, v0.8h, v16.8h
    uabd v17.8h, v1.8h, v17.8h

    add v2.8h, v2.8h, v3.8h
    add v3.8h, v4.8h, v5.8h
    add v4.8h, v6.8h, v7.8h
    add v5.8h, v16.8h, v17.8h
    add v18.8h, v18.8h, v2.8h
    add v19.8h, v19.8h, v3.8h
    add v20.8h, v20.8h, v4.8h
    add v21.8h, v21.8h, v5.8h

    subs w8, w8, #1
    bgt get_sad_x4_16_y
    uaddlp v18.4s, v18.8h
    uaddlp v19.4s, v19.8h
    uaddlp v20.4s, v20.8h
    uaddlp v21.4s, v21.8h

    addp v18.4s, v18.4s, v19.4s
    addp v20.4s, v20.4s, v21.4s
    addp v18.4s, v18.4s, v20.4s

    dup v17.4s, w9
    uqrshl v18.4s, v18.4s, v17.4s
    st1 {v18.4s}, [x7]
    ret

//i32u_t xGetSAD32_x4_arm64(pel_t *p_org, int i_org, pel_t *pred0, pel_t *pred1, pel_t *pred2, pel_t *pred3, int i_pred, i32u_t sad[4], int height, int skip_lines);
//*p_org->x0, i_org->x1, *pred0->x2, *pred1->x3, *pred2->x4, *pred3->x5, i_pred->x6, sad[4]->x7, height->[x8], skip_lines->x9
function xGetSAD32_x4_arm64
    mov x8, #0
    mov x9, #0
    mov x10, sp
#if defined(__APPLE__)
    ldr w8, [x10], #4
    ldr w9, [x10]
#else
    ldr w8, [x10], #8
    ldr w9, [x10]
#endif

    sub sp, sp, #64
    st1 {v8.8h, v9.8h, v10.8h, v11.8h}, [sp]
    sub sp, sp, #64
    st1 {v12.8h, v13.8h, v14.8h, v15.8h}, [sp]

    mov x10, #1
    lsl x10, x10, x9       //1 << skip_lines
    lsl x1, x1, #1
    mul x1, x1, x10
    lsl x6, x6, #1
    mul x6, x6, x10
    lsr x8, x8, x9

    sub x1, x1, #32
    sub x6, x6, #32

    movi v16.16b, #0
    movi v17.16b, #0
    movi v18.16b, #0
    movi v19.16b, #0
    movi v20.16b, #0
    movi v21.16b, #0
    movi v22.16b, #0
    movi v23.16b, #0

get_sad_x4_32_y:
    //load p_org
    ld1 {v0.8h, v1.8h}, [x0], #32
    //load pred
    ld1 {v2.8h, v3.8h}, [x2], #32
    ld1 {v4.8h, v5.8h}, [x3], #32
    ld1 {v6.8h, v7.8h}, [x4], #32
    ld1 {v8.8h, v9.8h}, [x5], #32

    uabd v2.8h, v0.8h, v2.8h
    uabd v3.8h, v1.8h, v3.8h
    uabd v4.8h, v0.8h, v4.8h
    uabd v5.8h, v1.8h, v5.8h
    uabd v6.8h, v0.8h, v6.8h
    uabd v7.8h, v1.8h, v7.8h
    uabd v8.8h, v0.8h, v8.8h
    uabd v9.8h, v1.8h, v9.8h

    add v16.8h, v16.8h, v2.8h
    add v17.8h, v17.8h, v3.8h
    add v18.8h, v18.8h, v4.8h
    add v19.8h, v19.8h, v5.8h
    add v20.8h, v20.8h, v6.8h
    add v21.8h, v21.8h, v7.8h
    add v22.8h, v22.8h, v8.8h
    add v23.8h, v23.8h, v9.8h

    //load p_org
    ld1 {v0.8h, v1.8h}, [x0], x1
    //load pred
    ld1 {v2.8h, v3.8h}, [x2], x6
    ld1 {v4.8h, v5.8h}, [x3], x6
    ld1 {v6.8h, v7.8h}, [x4], x6
    ld1 {v8.8h, v9.8h}, [x5], x6
    
    uabd v2.8h, v0.8h, v2.8h
    uabd v3.8h, v1.8h, v3.8h
    uabd v4.8h, v0.8h, v4.8h
    uabd v5.8h, v1.8h, v5.8h
    uabd v6.8h, v0.8h, v6.8h
    uabd v7.8h, v1.8h, v7.8h
    uabd v8.8h, v0.8h, v8.8h
    uabd v9.8h, v1.8h, v9.8h
    
    add v16.8h, v16.8h, v2.8h
    add v17.8h, v17.8h, v3.8h
    add v18.8h, v18.8h, v4.8h
    add v19.8h, v19.8h, v5.8h
    add v20.8h, v20.8h, v6.8h
    add v21.8h, v21.8h, v7.8h
    add v22.8h, v22.8h, v8.8h
    add v23.8h, v23.8h, v9.8h

    subs w8, w8, #1
    bgt get_sad_x4_32_y
    
    //sad[0]
    uaddl v0.4s, v16.4h, v17.4h
    uaddl2 v1.4s, v16.8h, v17.8h
    add v16.4s, v0.4s, v1.4s
    //sad[1]
    uaddl v0.4s, v18.4h, v19.4h
    uaddl2 v1.4s, v18.8h, v19.8h
    add v17.4s, v0.4s, v1.4s
    //sad[2]
    uaddl v0.4s, v20.4h, v21.4h
    uaddl2 v1.4s, v20.8h, v21.8h
    add v18.4s, v0.4s, v1.4s
    //sad[3]
    uaddl v0.4s, v22.4h, v23.4h
    uaddl2 v1.4s, v22.8h, v23.8h
    add v19.4s, v0.4s, v1.4s

    addp v16.4s, v16.4s, v17.4s
    addp v18.4s, v18.4s, v19.4s
    addp v16.4s, v16.4s, v18.4s

    dup v17.4s, w9
    uqrshl v16.4s, v16.4s, v17.4s
    st1 {v16.4s}, [x7]

    ld1 {v12.8h, v13.8h, v14.8h, v15.8h}, [sp], #64
    ld1 {v8.8h, v9.8h, v10.8h, v11.8h}, [sp], #64

    ret

//i32u_t xGetAVGSAD8_arm64(pel_t *p_org, int i_org, pel_t *pred1, int i_pred1, pel_t *p_pred2, int i_pred2, int height, int skip_lines);
//*p_org->x0, i_org->x1, pred1->x2, i_pred1->x3, p_pred2->x4, i_pred2->x5, height->x6, skip_lines->x7
function xGetAVGSAD8_arm64
    mov x8, #1
    lsl x8, x8, x7      //1 << skip_lines

    lsl x1, x1, #1
    mul x1, x1, x8
    lsl x3, x3, #1
    mul x3, x3, x8
    lsl x5, x5, #1
    mul x5, x5, x8
    lsr x6, x6, x7
    movi v3.16b, #0

get_sad_avg_8_y:
    //load org
    ld1 {v0.8h}, [x0], x1
    //load pred
    ld1 {v1.8h}, [x2], x3
    ld1 {v2.8h}, [x4], x5

    add v1.8h, v1.8h, v2.8h
    urshr v1.8h, v1.8h, #1
    uabd v2.8h, v0.8h, v1.8h
    add v3.8h, v3.8h, v2.8h

    subs x6, x6, #1
    bgt get_sad_avg_8_y

    uaddlp v3.4s, v3.8h
    addp v3.4s, v3.4s, v3.4s
    addp v3.4s, v3.4s, v3.4s

    mov x0, #0
    umov w0, v3.s[0]
    lsl w0, w0, w7
    ret
    
//i32u_t xGetAVGSAD16_arm64(pel_t *p_org, int i_org, pel_t *pred1, int i_pred1, pel_t *p_pred2, int i_pred2, int height, int skip_lines);
//*p_org->x0, i_org->x1, pred1->x2, i_pred1->x3, p_pred2->x4, i_pred2->x5, height->x6, skip_lines->x7
function xGetAVGSAD16_arm64
    mov x8, #1
    lsl x8, x8, x7      //1 << skip_lines

    lsl x1, x1, #1
    mul x1, x1, x8
    lsl x3, x3, #1
    mul x3, x3, x8
    lsl x5, x5, #1
    mul x5, x5, x8
    lsr x6, x6, x7
    movi v6.16b, #0
    movi v7.16b, #0

get_sad_avg_16_y:
    //load org
    ld1 {v0.8h, v1.8h}, [x0], x1
    //load pred
    ld1 {v2.8h, v3.8h}, [x2], x3
    ld1 {v4.8h, v5.8h}, [x4], x5

    add v2.8h, v2.8h, v4.8h
    add v3.8h, v3.8h, v5.8h
    urshr v2.8h, v2.8h, #1
    urshr v3.8h, v3.8h, #1
    uabd v2.8h, v0.8h, v2.8h
    uabd v3.8h, v1.8h, v3.8h
    add v6.8h, v2.8h, v6.8h
    add v7.8h, v3.8h, v7.8h
    subs w6, w6, #1
    bgt get_sad_avg_16_y

    uaddl v16.4s, v6.4h, v7.4h
    uaddl2 v17.4s, v6.8h, v7.8h
    add v16.4s, v16.4s, v17.4s
    addp v16.4s, v16.4s, v16.4s
    addp v16.4s, v16.4s, v16.4s
    
    mov x0, #0
    umov w0, v16.s[0]
    lsl w0, w0, w7
    ret

//i32u_t xGetAVGSAD32_arm64(pel_t *p_org, int i_org, pel_t *pred1, int i_pred1, pel_t *p_pred2, int i_pred2, int height, int skip_lines);
//*p_org->x0, i_org->x1, pred1->x2, i_pred1->x3, p_pred2->x4, i_pred2->x5, height->x6, skip_lines->x7
function xGetAVGSAD32_arm64
    mov x8, #1
    lsl x8, x8, x7      //1 << skip_lines

    lsl x1, x1, #1
    mul x1, x1, x8
    lsl x3, x3, #1
    mul x3, x3, x8
    lsl x5, x5, #1
    mul x5, x5, x8
    lsr x6, x6, x7
    movi v20.16b, #0
    movi v21.16b, #0
    movi v22.16b, #0
    movi v23.16b, #0

get_sad_avg_32_y:
    //load org
    ld1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x0], x1
    //load pred
    ld1 {v4.8h, v5.8h, v6.8h, v7.8h}, [x2], x3
    ld1 {v16.8h, v17.8h, v18.8h, v19.8h}, [x4], x5

    add v4.8h, v4.8h, v16.8h
    add v5.8h, v5.8h, v17.8h
    add v6.8h, v6.8h, v18.8h
    add v7.8h, v7.8h, v19.8h
    urshr v4.8h, v4.8h, #1
    urshr v5.8h, v5.8h, #1
    urshr v6.8h, v6.8h, #1
    urshr v7.8h, v7.8h, #1

    uabd v4.8h, v0.8h, v4.8h
    uabd v5.8h, v1.8h, v5.8h
    uabd v6.8h, v2.8h, v6.8h
    uabd v7.8h, v3.8h, v7.8h

    add v20.8h, v20.8h, v4.8h
    add v21.8h, v21.8h, v5.8h
    add v22.8h, v22.8h, v6.8h
    add v23.8h, v23.8h, v7.8h
    subs w6, w6, #1
    bgt get_sad_avg_32_y

    add v20.8h, v20.8h, v21.8h
    add v21.8h, v22.8h, v23.8h
    uaddl v16.4s, v20.4h, v21.4h
    uaddl2 v17.4s, v20.8h, v21.8h
    add v16.4s, v16.4s, v17.4s
    addp v16.4s, v16.4s, v16.4s
    addp v16.4s, v16.4s, v16.4s
    
    mov x0, #0
    umov w0, v16.s[0]
    lsl w0, w0, w7
    ret

//i32u_t xCalcHAD8x8_arm64(pel_t *p_org, int i_org, pel_t *p_pred, int i_pred);
//*p_org->x0, i_org->x1, *p_pred->x2, i_pred->x3
function xCalcHAD8x8_arm64
    lsl x1, x1, #1
    lsl x3, x3, #1

    ld1 {v0.8h}, [x0], x1
    ld1 {v1.8h}, [x0], x1
    ld1 {v2.8h}, [x0], x1
    ld1 {v3.8h}, [x0], x1
    ld1 {v4.8h}, [x0], x1
    ld1 {v5.8h}, [x0], x1
    ld1 {v6.8h}, [x0], x1
    ld1 {v7.8h}, [x0], x1

    ld1 {v16.8h}, [x2], x3
    ld1 {v17.8h}, [x2], x3
    ld1 {v18.8h}, [x2], x3
    ld1 {v19.8h}, [x2], x3
    ld1 {v20.8h}, [x2], x3
    ld1 {v21.8h}, [x2], x3
    ld1 {v22.8h}, [x2], x3
    ld1 {v23.8h}, [x2], x3

    sub v0.8h, v0.8h, v16.8h
    sub v1.8h, v1.8h, v17.8h
    sub v2.8h, v2.8h, v18.8h
    sub v3.8h, v3.8h, v19.8h
    sub v4.8h, v4.8h, v20.8h
    sub v5.8h, v5.8h, v21.8h
    sub v6.8h, v6.8h, v22.8h
    sub v7.8h, v7.8h, v23.8h

    uzp1 v16.8h, v0.8h, v1.8h       //d0, d2, d4, d6, d8, d10, d12, d14
    uzp2 v17.8h, v0.8h, v1.8h       //d1, d3, d5, d7,
    uzp1 v18.8h, v2.8h, v3.8h       //d16, d18, d20, d22,
    uzp2 v19.8h, v2.8h, v3.8h       //d17, d19, d21, d23,
    uzp1 v20.8h, v4.8h, v5.8h       //d32, d34, d36, d38,
    uzp2 v21.8h, v4.8h, v5.8h       //d33, d35, d37, d39,
    uzp1 v22.8h, v6.8h, v7.8h       //d48, d50, d52, d54,
    uzp2 v23.8h, v6.8h, v7.8h       //d49, d51, d53, d55,

    add v0.8h, v16.8h, v17.8h       //d0 + d1, d2 + d3,
    sub v1.8h, v16.8h, v17.8h       //d0 - d1, d2 - d3,
    add v2.8h, v18.8h, v19.8h       //d16 + d17, d18 + d19
    sub v3.8h, v18.8h, v19.8h       //d16 - d17, d18 - d19
    add v4.8h, v20.8h, v21.8h
    sub v5.8h, v20.8h, v21.8h
    add v6.8h, v22.8h, v23.8h
    sub v7.8h, v22.8h, v23.8h

    trn1 v16.8h, v0.8h, v1.8h       //d0 + d1, d0 - d1, d4 + d5, d4 - d5
    trn2 v17.8h, v0.8h, v1.8h       //d2 + d3, d2 - d3, d6 + d7, d5 - d7
    trn1 v18.8h, v2.8h, v3.8h
    trn2 v19.8h, v2.8h, v3.8h
    trn1 v20.8h, v4.8h, v5.8h
    trn2 v21.8h, v4.8h, v5.8h
    trn1 v22.8h, v6.8h, v7.8h
    trn2 v23.8h, v6.8h, v7.8h

    add v0.8h, v16.8h, v17.8h       //d0 + d1 + d2 + d3, d0 - d1 + d2 - d3
    sub v1.8h, v16.8h, v17.8h       //d0 + d1 - (d2 + d3), d0 - d1 - (d2 - d3)
    add v2.8h, v18.8h, v19.8h       //d16 + d17 + d18 + d19, d16 - d17 + (d18 - d19)
    sub v3.8h, v18.8h, v19.8h       //d16 + d17 - d18 + d19, d16 - d17 - (d18 - d19)
    add v4.8h, v20.8h, v21.8h
    sub v5.8h, v20.8h, v21.8h
    add v6.8h, v22.8h, v23.8h
    sub v7.8h, v22.8h, v23.8h

    trn1 v16.4s, v0.4s, v1.4s       //d0 + d1 + d2 + d3, d0 - d1 + d2 - d3, d0 + d1 - (d2 + d3), d0 - d1 - (d2 - d3)
    trn2 v17.4s, v0.4s, v1.4s       //d4 + d5 + d6 + d7, d4 - d5 + d6 - d7, d4 + d5 - (d6 + d7), d4 - d5 - (d6 - d7)
    trn1 v18.4s, v2.4s, v3.4s
    trn2 v19.4s, v2.4s, v3.4s
    trn1 v20.4s, v4.4s, v5.4s
    trn2 v21.4s, v4.4s, v5.4s
    trn1 v22.4s, v6.4s, v7.4s
    trn2 v23.4s, v6.4s, v7.4s

    add v0.8h, v16.8h, v17.8h       //d0 + d1 + d2 + d3 + d4 + d5 + d6 + d7, d0 - d1 + d2 - d3 + d4 - d5 + d6 - d7
    sub v1.8h, v16.8h, v17.8h       //d0 + d1 + d2 + d3 - (d4 + d5 + d6 + d7)
    add v2.8h, v18.8h, v19.8h       //d16 + d17 + d18 + d19 + d20 + d21 + d22 + d23
    sub v3.8h, v18.8h, v19.8h       //d16 + d17 + d18 + d19 - (d20 + d21 + d22 + d23)
    add v4.8h, v20.8h, v21.8h
    sub v5.8h, v20.8h, v21.8h
    add v6.8h, v22.8h, v23.8h
    sub v7.8h, v22.8h, v23.8h

    trn1 v16.2d, v0.2d, v1.2d
    trn2 v17.2d, v0.2d, v1.2d
    trn1 v18.2d, v2.2d, v3.2d
    trn2 v19.2d, v2.2d, v3.2d
    trn1 v20.2d, v4.2d, v5.2d
    trn2 v21.2d, v4.2d, v5.2d
    trn1 v22.2d, v6.2d, v7.2d
    trn2 v23.2d, v6.2d, v7.2d

    add v0.8h, v16.8h, v17.8h
    sub v1.8h, v16.8h, v17.8h
    add v2.8h, v18.8h, v19.8h
    sub v3.8h, v18.8h, v19.8h
    add v4.8h, v20.8h, v21.8h
    sub v5.8h, v20.8h, v21.8h
    add v6.8h, v22.8h, v23.8h
    sub v7.8h, v22.8h, v23.8h

    add v16.8h, v0.8h, v2.8h
    sub v17.8h, v0.8h, v2.8h
    add v18.8h, v1.8h, v3.8h
    sub v19.8h, v1.8h, v3.8h
    add v20.8h, v4.8h, v6.8h
    sub v21.8h, v4.8h, v6.8h
    add v22.8h, v5.8h, v7.8h
    sub v23.8h, v5.8h, v7.8h

    saddl v0.4s, v16.4h, v20.4h
    saddl2 v1.4s, v16.8h, v20.8h
    saddl v2.4s, v17.4h, v21.4h
    saddl2 v3.4s, v17.8h, v21.8h
    saddl v4.4s, v18.4h, v22.4h
    saddl2 v5.4s, v18.8h, v22.8h
    saddl v6.4s, v19.4h, v23.4h
    saddl2 v7.4s, v19.8h, v23.8h
    ssubl v24.4s, v16.4h, v20.4h
    ssubl2 v25.4s, v16.8h, v20.8h
    ssubl v26.4s, v17.4h, v21.4h
    ssubl2 v27.4s, v17.8h, v21.8h
    ssubl v28.4s, v18.4h, v22.4h
    ssubl2 v29.4s, v18.8h, v22.8h
    ssubl v30.4s, v19.4h, v23.4h
    ssubl2 v31.4s, v19.8h, v23.8h

    abs v0.4s, v0.4s
    abs v1.4s, v1.4s
    abs v2.4s, v2.4s
    abs v3.4s, v3.4s
    abs v4.4s, v4.4s
    abs v5.4s, v5.4s
    abs v6.4s, v6.4s
    abs v7.4s, v7.4s
    abs v24.4s, v24.4s
    abs v25.4s, v25.4s
    abs v26.4s, v26.4s
    abs v27.4s, v27.4s
    abs v28.4s, v28.4s
    abs v29.4s, v29.4s
    abs v30.4s, v30.4s
    abs v31.4s, v31.4s

    add v0.4s, v0.4s, v24.4s
    add v1.4s, v1.4s, v25.4s
    add v2.4s, v2.4s, v26.4s
    add v3.4s, v3.4s, v27.4s
    add v4.4s, v4.4s, v28.4s
    add v5.4s, v5.4s, v29.4s
    add v6.4s, v6.4s, v30.4s
    add v7.4s, v7.4s, v31.4s

    add v0.4s, v0.4s, v1.4s
    add v2.4s, v2.4s, v3.4s
    add v4.4s, v4.4s, v5.4s
    add v6.4s, v6.4s, v7.4s
    add v0.4s, v0.4s, v2.4s
    add v4.4s, v4.4s, v6.4s
    add v0.4s, v0.4s, v4.4s

    addp v0.4s, v0.4s, v0.4s
    addp v0.4s, v0.4s, v0.4s

    mov x0, #0
    umov w0, v0.s[0]
    add x0, x0, #2
    lsr x0, x0, #2

ret

#endif
#endif

