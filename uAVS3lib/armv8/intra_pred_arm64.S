#include "def_arm64.S"

#if defined(__arm64__)
#if !COMPILE_10BIT

//void xPredIntraVertAdi_arm64(pel_t *psrc, pel_t *dst, int i_dst, int iWidth, int iHeight)
//psrc->x0, dst->x1, i_dst->x2, width->x3, height->x4
function xPredIntraVertAdi_arm64
    
    add x0, x0, #1

    //branch
    cmp w3, #16
    beq intra_pred_ver_w16
    bgt intra_pred_ver_w32

    cmp w3, #8
    beq intra_pred_ver_w8

//intra_pred_ver_w4:

    ld1 {v0.s}[0], [x0]	        // load src[x]
intra_pred_ver_w4_y:
    st1 {v0.s}[0], [x1], x2     // store dst[x]
    st1 {v0.s}[0], [x1], x2
    subs w4, w4, #4
    st1 {v0.s}[0], [x1], x2
    st1 {v0.s}[0], [x1], x2
    bgt intra_pred_ver_w4_y

    b intra_pred_ver_end

intra_pred_ver_w8:

    ld1 {v0.8b}, [x0]		    // load src[x]
intra_pred_ver_w8_y:
    st1 {v0.8b}, [x1], x2       // store dst[x]
    st1 {v0.8b}, [x1], x2
    subs w4, w4, #4
    st1 {v0.8b}, [x1], x2
    st1 {v0.8b}, [x1], x2
    bgt intra_pred_ver_w8_y

    b intra_pred_ver_end

intra_pred_ver_w16:

	ld1 {v0.16b}, [x0]		    // load src[x]
intra_pred_ver_w16_y:
	st1 {v0.16b}, [x1], x2      // store dst[x]
    st1 {v0.16b}, [x1], x2
    subs w4, w4, #4
    st1 {v0.16b}, [x1], x2
    st1 {v0.16b}, [x1], x2
	bgt intra_pred_ver_w16_y

	b intra_pred_ver_end

intra_pred_ver_w32:

	ld1 {v0.16b, v1.16b}, [x0]		// load src[x]
intra_pred_ver_w32_y:
	st1 {v0.16b, v1.16b}, [x1], x2  // store dst[x]
    st1 {v0.16b, v1.16b}, [x1], x2
    subs w4, w4, #4
    st1 {v0.16b, v1.16b}, [x1], x2
    st1 {v0.16b, v1.16b}, [x1], x2
	bgt intra_pred_ver_w32_y

intra_pred_ver_end:

    ret


//void xPredIntraHorAdi_arm64(pel_t *pSrc, pel_t *dst, int i_dst, int iWidth, int iHeight)
//src->x0, dst->x1, i_dst->x2, width->x3, height->x4
function xPredIntraHorAdi_arm64

    sub x0, x0, #1
	//branch
    cmp w3, #16
    beq intra_pred_hor_w16
    bgt intra_pred_hor_w32

    cmp w3, #8
    beq intra_pred_hor_w8

//intra_pred_hor_w4:

    sub x0, x0, #3
intra_pred_hor_w4_y:
    ld1 {v4.s}[0], [x0]  		    // load src[-y]
	dup v0.8b, v4.b[3]
    dup v1.8b, v4.b[2]
    subs w4, w4, #4
    sub x0, x0, #4
    dup v2.8b, v4.b[1]
    dup v3.8b, v4.b[0]
	st1 {v0.s}[0], [x1], x2  		// store dst[x]
    st1 {v1.s}[0], [x1], x2
    st1 {v2.s}[0], [x1], x2
    st1 {v3.s}[0], [x1], x2
	bgt intra_pred_hor_w4_y

	b intra_pred_hor_end

intra_pred_hor_w8:
    sub x0, x0, #3
intra_pred_hor_w8_y:
    ld1 {v4.s}[0], [x0]             // load src[-y]
    dup v0.8b, v4.b[3]
    dup v1.8b, v4.b[2]
    sub x0, x0, #4
    subs w4, w4, #4
    dup v2.8b, v4.b[1]
    dup v3.8b, v4.b[0]
    st1 {v0.8b}, [x1], x2           // store dst[x]
    st1 {v1.8b}, [x1], x2
    st1 {v2.8b}, [x1], x2
    st1 {v3.8b}, [x1], x2
	bgt intra_pred_hor_w8_y

	b intra_pred_hor_end

intra_pred_hor_w16:
    sub x0, x0, #3
intra_pred_hor_w16_y:
    ld1 {v4.s}[0], [x0]             // load src[-y]
    dup v0.16b, v4.b[3]
    dup v1.16b, v4.b[2]
    subs w4, w4, #4
    sub x0, x0, #4
    dup v2.16b, v4.b[1]
    dup v3.16b, v4.b[0]
	st1 {v0.16b}, [x1], x2  	    // store dst[x]
    st1 {v1.16b}, [x1], x2
    st1 {v2.16b}, [x1], x2
    st1 {v3.16b}, [x1], x2
	bgt intra_pred_hor_w16_y

	b intra_pred_hor_end

intra_pred_hor_w32:
    sub x0, x0, #3
intra_pred_hor_w32_y:
	ld1 {v16.s}[0], [x0]  			// load rpSrc[-y]
    dup v0.16b, v16.b[3]
    dup v2.16b, v16.b[2]
    dup v4.16b, v16.b[1]
    dup v6.16b, v16.b[0]
    mov v1.16b, v0.16b
    mov v3.16b, v2.16b
    mov v5.16b, v4.16b
    mov v7.16b, v6.16b
	st1 {v0.16b, v1.16b}, [x1], x2 // store dst[x]
    st1 {v2.16b, v3.16b}, [x1], x2
    sub x0, x0, #4
    subs w4, w4, #4
    st1 {v4.16b, v5.16b}, [x1], x2
    st1 {v6.16b, v7.16b}, [x1], x2
	bgt intra_pred_hor_w32_y

intra_pred_hor_end:
    ret


//void xPredIntraDCAdi_arm64(pel_t *pSrc, pel_t *dst, int i_dst, int iWidth, int iHeight, int bAboveAvail, int bLeftAvail, bit_depth)
//src->x0, dst->x1, i_dst->x2, width->x3, height->x4, bAboveAvail->x5, bLeftAvail->x6, bit_depth->x7
function xPredIntraDCAdi_arm64
    and w9, w6, w5
    cmp w9, #0
    bne intra_pred_dc_above_left

    cmp w5, #0
    bne intra_pred_dc_above

    cmp w6, #0
    beq intra_pred_dc_none

intra_pred_dc_left:
    sub x10, x0, x4
    mov w7, w4
    b intra_pred_dc_single_line
intra_pred_dc_above:
    add x10, x0, #1
    mov w7, w3

intra_pred_dc_single_line:
    cmp w7, #16
    beq intra_pred_dc_1ref_w16
    bgt intra_pred_dc_1ref_w32

    cmp w7, #8
    beq intra_pred_dc_1ref_w8

//intra_pred_dc_1ref_w4:
    movi v0.8h, #0
    ld1 {v0.s}[0], [x10]

    uaddlp v0.4h, v0.8b
    addp v0.4h, v0.4h, v0.4h

    umov w8, v0.h[0]
    add w8, w8, #2
    lsr w8, w8, #2              // dc /= height;
    dup v0.16b, w8

    b intra_pred_dc_fillblock

intra_pred_dc_1ref_w8:
    movi v0.8h, #0
    ld1 {v0.8b}, [x10]
    uaddlp v0.4h, v0.8b
    addp v0.4h, v0.4h, v0.4h
    addp v0.4h, v0.4h, v0.4h

    umov w8, v0.h[0]
    add w8, w8, #4
    lsr w8, w8, #3              // dc /= height;
    dup v0.16b, w8

    b intra_pred_dc_fillblock

intra_pred_dc_1ref_w16:
    ld1 {v0.8b, v1.8b}, [x10]
    uaddl v0.8h, v0.8b, v1.8b
    addp v0.8h, v0.8h, v0.8h
    addp v0.4h, v0.4h, v0.4h
    addp v0.4h, v0.4h, v0.4h

    umov w8, v0.h[0]
    add w8, w8, #8
    lsr w8, w8, #4              // dc /= height;
    dup v0.16b, w8

    b intra_pred_dc_fillblock

intra_pred_dc_1ref_w32:

    ld1 {v0.16b, v1.16b}, [x10]
    uaddl  v2.8h, v0.8b, v1.8b
    uaddl2 v3.8h, v0.16b, v1.16b
    add  v0.8h, v2.8h, v3.8h
    addp v0.8h, v0.8h, v0.8h
    addp v0.4h, v0.4h, v0.4h
    addp v0.4h, v0.4h, v0.4h

    umov w8, v0.h[0]
    add w8, w8, #16
    lsr w8, w8, #5              // dc /= height;
    dup v0.16b, w8

    b intra_pred_dc_fillblock

intra_pred_dc_none:

    movi v0.16b, #512			// iDCValue = 1 << (sample_bit_depth - 1);
    b intra_pred_dc_fillblock

intra_pred_dc_above_left:

    add x10, x0, #1 			// rpSrc = pSrc + 1;

    //branch
    cmp w3, #16
    beq intra_pred_dc_above_left_w16
    bgt intra_pred_dc_above_left_w32

    cmp w3, #8
    beq intra_pred_dc_above_left_w8

//intra_pred_dc_above_left_w4:

    movi v0.8h, #0
    ld1 {v0.s}[0], [x10]
    uxtl v0.8h, v0.8b
    b intra_pred_dc_above_left_h

intra_pred_dc_above_left_w8:
    movi v0.8h, #0
    ld1 {v0.8b}, [x10]
    uxtl v0.8h, v0.8b
    b intra_pred_dc_above_left_h

intra_pred_dc_above_left_w16:
    ld1 {v0.8b, v1.8b}, [x10]
    uaddl v0.8h, v0.8b, v1.8b
    b intra_pred_dc_above_left_h

intra_pred_dc_above_left_w32:

    ld1 {v0.16b, v1.16b}, [x10]
    uaddl  v2.8h, v0.8b, v1.8b
    uaddl2 v3.8h, v0.16b, v1.16b
    add    v0.8h, v2.8h, v3.8h

intra_pred_dc_above_left_h:

    //branch
    cmp w4, #16
    beq intra_pred_dc_above_left_h16
    bgt intra_pred_dc_above_left_h32

    cmp w4, #8
    beq intra_pred_dc_above_left_h8

//intra_pred_dc_above_left_h4:
    movi v1.8h, #0
    sub  x10, x0, #4
    ld1 {v1.s}[0], [x10]
    uaddw v0.8h, v0.8h, v1.8b
    b intra_pred_dc_above_left_dcvalue

intra_pred_dc_above_left_h8:
    sub  x10, x0, #8
    ld1 {v1.8b}, [x10]
    uaddw v0.8h, v0.8h, v1.8b
    b intra_pred_dc_above_left_dcvalue

intra_pred_dc_above_left_h16:
    sub  x10, x0, #16
    ld1 {v1.8b, v2.8b}, [x10]
    uaddl v1.8h, v1.8b, v2.8b
    add   v0.8h, v0.8h, v1.8h
    b intra_pred_dc_above_left_dcvalue

intra_pred_dc_above_left_h32:

    sub  x10, x0, #32
    ld1 {v1.16b, v2.16b}, [x10]
    uaddl  v3.8h, v1.8b, v2.8b
    uaddl2 v4.8h, v1.16b, v2.16b
    add    v3.8h, v3.8h, v4.8h
    add    v0.8h, v0.8h, v3.8h

intra_pred_dc_above_left_dcvalue:

    addp v0.8h, v0.8h, v0.8h
    addp v0.8h, v0.8h, v0.8h
    addp v0.8h, v0.8h, v0.8h

    // (dc + ((w + h) >> 1)) * (4096 / (w + h)) >> 12;
    add w10, w3, w4			    // dc += ((w + h) >> 1);
    lsr w8, w10, #1
    umov w9, v0.h[0]
    add w8, w8, w9

    mov w11, #4096				// dc = (dc * (4096 / (w + h))) >> 12;
    udiv w11, w11, w10
    mul w8, w8, w11
    lsr w8, w8, #12
    dup v0.16b, w8

intra_pred_dc_fillblock:

    //branch
    cmp w3, #16
    beq intra_pred_dc_fillblock_w16
    bgt intra_pred_dc_fillblock_w32

    cmp w3, #8
    beq intra_pred_dc_fillblock_w8

// intra_pred_dc_fillblock_w4:

intra_pred_dc_fillblock_w4_y:
    st1 {v0.s}[0], [x1], x2  // store dst[x]
    st1 {v0.s}[0], [x1], x2
    subs w4, w4, #4
    st1 {v0.s}[0], [x1], x2
    st1 {v0.s}[0], [x1], x2
    bne intra_pred_dc_fillblock_w4_y
    b   intra_pred_dc_end

intra_pred_dc_fillblock_w8:
    st1 {v0.8b}, [x1], x2       // store dst[x]
    st1 {v0.8b}, [x1], x2
    subs w4, w4, #4
    st1 {v0.8b}, [x1], x2
    st1 {v0.8b}, [x1], x2
    bgt intra_pred_dc_fillblock_w8
    b   intra_pred_dc_end

intra_pred_dc_fillblock_w16:
    st1 {v0.16b}, [x1], x2  // store dst[x]
    st1 {v0.16b}, [x1], x2
    subs w4, w4, #4
    st1 {v0.16b}, [x1], x2
    st1 {v0.16b}, [x1], x2
    bgt intra_pred_dc_fillblock_w16
    b   intra_pred_dc_end

intra_pred_dc_fillblock_w32:
    
    mov v1.16b, v0.16b
intra_pred_dc_fillblock_w32_y:
    st1 {v0.16b, v1.16b}, [x1], x2  // store dst[x]
    st1 {v0.16b, v1.16b}, [x1], x2
    subs w4, w4, #4
    st1 {v0.16b, v1.16b}, [x1], x2
    st1 {v0.16b, v1.16b}, [x1], x2
    bgt intra_pred_dc_fillblock_w32_y

intra_pred_dc_end:
    ret

intra_plane_mul_shift:
.byte 13, 7, 17, 10, 5, 11, 11, 15, 23, 19

intra_plane_coef:
.byte 8, 7, 6, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

//void xPredIntraPlaneAdi_arm64(pel_t *pSrc, pel_t *dst, int i_dst, int iWidth, int iHeight, int bit_depth)
//pSrc->x0, dst->x1, i_dst->x2, iWidth->x3, iHeight->x4, bit_depth->x5
function xPredIntraPlaneAdi_arm64

    sub sp, sp, #16
    stp x19, x20, [sp]

    mov x9, #61
    clz x7, x3
    clz x8, x4
    sub x15, x9, x7  					// tab_log2[width] - 2
    sub x14, x9, x8					    // tab_log2[height] - 2

    movi v6.2s, #0
    movi v7.2s, #0

    adr x19, intra_plane_mul_shift
    lsl w15, w15, #1
    add x15, x19, x15					// im_h, is_h
    ld2 {v6.b, v7.b}[0], [x15]

    lsl w14, w14, #1
    add x14, x19, x14					// im_v, is_v
    ld2 {v6.b, v7.b}[4], [x14]

    lsr x10, x3, #1						// iW2 = width >> 1;
    lsr x11, x4, #1						// iH2 = height >> 1;

    add x19, x0, x10					// rpSrc = pSrc + 1;  rpSrc += (iW2 - 1);

    cmp x10, #4
    beq intra_pred_plane_coef_h_loop4
    bgt intra_pred_plane_coef_h_loop8

// intra_pred_plane_coef_h_loop2

    ldrb w12, [x19, #1]
    ldrb w13, [x19, #-1]
    sub w14, w12, w13
    ldrb w12, [x19, #2]
    ldrb w13, [x19, #-2]
    sub w15, w12, w13
    lsl w15, w15, #1
    add w5, w14, w15
    movi v4.4s, #0
    mov v4.s[0], w5
    b intra_pred_plane_coef_h_end

intra_pred_plane_coef_h_loop4:

    adr x12, intra_plane_coef
    add x12, x12, #4
    ld1 {v2.8b}, [x12]			        // 4, 3, 2, 1
    uxtl v3.8h, v2.8b

    ld1 {v0.8b}, [x19]
    sub x19, x19, #4
    ld1 {v1.s}[0], [x19]
    tbl v0.8b, {v0.16b}, v2.8b

    usubl v0.8h, v0.8b, v1.8b
    smull v4.4s, v0.4h, v3.4h

    b intra_pred_plane_coef_h_end

intra_pred_plane_coef_h_loop8:

    mov w13, w10

    adr x12, intra_plane_coef
    ld1 {v2.8b}, [x12]			        // 8, 7, 6, 5, 4, 3, 2, 1
    uxtl v3.8h, v2.8b
    movi v4.4s, #0
    movi v16.8h, #8
    sub x20, x19, #8

intra_pred_plane_coef_h_loop8_x:

    ld1 {v0.16b}, [x19]
    ld1 {v1.8b}, [x20]
    tbl v0.16b, {v0.16b}, v2.16b

    usubl v0.8h, v0.8b, v1.8b
    smlal v4.4s, v0.4h, v3.4h
    smlal2 v4.4s, v0.8h, v3.8h

    add v3.8h, v3.8h, v16.8h
    subs w13, w13, #8
    add x19, x19, #8
    sub x20, x20, #8
    bgt intra_pred_plane_coef_h_loop8_x

//v4 -> coef_h
intra_pred_plane_coef_h_end:

    sub x19, x0, x11					// rpSrc = pSrc - 1;  rpSrc -= (iH2 - 1);

    cmp x11, #4
    beq intra_pred_plane_coef_v_loop4
    bgt intra_pred_plane_coef_v_loop8

// intra_pred_plane_coef_v_loop2

    ldrb w12, [x19, #1]
    ldrb w13, [x19, #-1]
    sub w14, w13, w12
    ldrb w12, [x19, #2]
    ldrb w13, [x19, #-2]
    sub w15, w13, w12
    lsl w15, w15, #1
    add w5, w14, w15
    movi v5.4s, #0
    mov v5.s[1], w5
    b intra_pred_plane_coef_v_end

intra_pred_plane_coef_v_loop4:

    adr x12, intra_plane_coef
    add x12, x12, #4
    ld1 {v2.8b}, [x12]			// 4, 3, 2, 1
    uxtl v3.8h, v2.8b

    ld1 {v0.8b}, [x19]
    sub x19, x19, #4
    ld1 {v1.s}[0], [x19]
    tbl v0.8b, {v0.16b}, v2.8b

    usubl v0.8h, v1.8b, v0.8b
    smull v5.4s, v0.4h, v3.4h

    b intra_pred_plane_coef_v_end

intra_pred_plane_coef_v_loop8:

    mov w13, w11

    adr x12, intra_plane_coef
    ld1 {v2.8b}, [x12]			// 8, 7, 6, 5, 4, 3, 2, 1
    uxtl v3.8h, v2.8b
    movi v5.4s, #0
    movi v16.8h, #8
    sub x20, x19, #8

intra_pred_plane_coef_v_loop8_x:

    ld1 {v0.16b}, [x19]
    ld1 {v1.8b}, [x20]
    tbl v0.16b, {v0.16b}, v2.16b

    usubl v0.8h, v1.8b, v0.8b
    smlal v5.4s, v0.4h, v3.4h
    smlal2 v5.4s, v0.8h, v3.8h

    add v3.8h, v3.8h, v16.8h
    subs w13, w13, #8
    add x19, x19, #8
    sub x20, x20, #8
    bgt intra_pred_plane_coef_v_loop8_x

//v5 -> coef_v
intra_pred_plane_coef_v_end:

    addp v4.4s, v4.4s, v5.4s
    addp v4.4s, v4.4s, v4.4s      // v4.4s[0]->coef_h; v4.4s[1]->coef_v;

    // iA = (pSrc[-1 - (height - 1)] + pSrc[1 + width - 1]) << 4
    sub x6, x0, x4
    ldrb w7, [x6]
    add x6, x0, x3
    ldrb w8, [x6]
    add w6, w7, w8
    lsl w6, w6, #4

    // iB = ((coef_h << 5) * im_h + (1 << (is_h - 1))) >> is_h;
    // iC = ((coef_v << 5) * im_v + (1 << (is_v - 1))) >> is_v;
    shl v4.2s, v4.2s, #5
    mul v4.2s, v4.2s, v6.2s
    neg v7.2s, v7.2s
    srshl v4.2s, v4.2s, v7.2s
    umov w12, v4.s[0]
    umov w13, v4.s[1]
    dup v30.8h, w12				//v30->iB
    dup v31.8h, w13				//v31->iC

    // iTmp = iA - (iH2 - 1) * iC - (iW2 - 1) * iB + 16
    sub w10, w10, #1
    sub w11, w11, #1
    mul w10, w10, w12
    mul w11, w11, w13
    sub w6, w6, w10
    sub w6, w6, w11
    add w6, w6, #16
    dup v0.8h, w6				// v0->iTmp

    adr x12, intra_plane_coef
    add x12, x12, #8
    ld1 {v2.8b}, [x12]			// 0, 1, 2, 3, 4, 5, 6, 7

    cmp x3, #4
    bne intra_pred_plane_fill_loop8

//intra_pred_plane_fill_loop4:

    sxtl v2.8h, v2.8b
    mul v30.4h, v30.4h, v2.4h

    movi v28.4h, #0			//max and min val
    movi v29.4h, #255

    add v0.4h, v0.4h, v30.4h
intra_pred_plane_fill_loop4_y:

// dst[x] = Clip3(0, vmax, iTmp2 >> 5);
    sshr v1.4h, v0.4h, #5
    smax v1.4h, v1.4h, v28.4h
    smin v1.4h, v1.4h, v29.4h
    xtn v1.8b, v1.8h
    st1 {v1.s}[0], [x1], x2

    subs w4, w4, #1
    add v0.4h, v0.4h, v31.4h   //iTmp += iC;
    bgt intra_pred_plane_fill_loop4_y

    b intra_pred_plane_fill_end

intra_pred_plane_fill_loop8:

    sxtl v2.8h, v2.8b
    mul v26.8h, v30.8h, v2.8h

    movi v28.8h, #0			//max and min val
    movi v29.8h, #255

    shl v27.8h, v30.8h, #3  // iB * 8

    add v0.8h, v0.8h, v26.8h
intra_pred_plane_fill_loop8_x:

    mov v1.16b, v0.16b
    mov x19, x1
    mov w8, w4
intra_pred_plane_fill_loop8_y:

    sshr v2.8h, v1.8h, #5
    smax v2.8h, v2.8h, v28.8h
    smin v2.8h, v2.8h, v29.8h

    xtn v2.8b, v2.8h
    st1 {v2.8b}, [x19], x2

    subs w8, w8, #1
    add v1.8h, v1.8h, v31.8h   //iTmp += iC;
    bgt intra_pred_plane_fill_loop8_y

    add x1, x1, #8
    subs w3, w3, #8
    add v0.8h, v0.8h, v27.8h
    bgt intra_pred_plane_fill_loop8_x

intra_pred_plane_fill_end:
    ldp x19, x20, [sp], #16
    ret

intra_bi_tbl_wc:
.byte -1, 21, 13, 7, 4, 2, 0, 0

//void xPredIntraBiAdi_arm64(pel_t *pSrc, pel_t *dst, int i_dst, int iWidth, int iHeight, int bit_depth)
//pSrc->x0, dst->x1, i_dst->x2, width->x3, height->x4, bit_depth->x5
function xPredIntraBiAdi_arm64
    sub sp, sp, #16
    stp x19, x20, [sp]

    mov x9, #63
    clz x7, x3
    clz x8, x4
    sub x6, x9, x7                  // ishift_x = tab_log2size[width];
    sub x7, x9, x8                  // ishift_y = tab_log2size[height];

    dup v4.8h, w6
    dup v5.8h, w7
    umin v6.8h, v4.8h, v5.8h

    add x19, x0, x3                 // a = ref_up[width - 1] = pSrc[width]
    ldrb w12, [x19]
    sub x19, x0, x4                 // b = ref_le[height - 1] = pSrc[-height]
    ldrb w13, [x19]

    dup v0.8h, w12
    dup v1.8h, w13

    cmp x3, x4
    bne intra_pred_bi_width_ne_height

//intra_pred_bi_width_eq_height:
    urhadd v2.8h, v0.8h, v1.8h      // c = (a + b + 1) >> 1
    shl v2.8h, v2.8h, #1            // w = (c << 1) - a - b;
    sub v2.8h, v2.8h, v0.8h
    sub v2.8h, v2.8h, v1.8h

    b intra_pred_bi_reflines

intra_pred_bi_width_ne_height:
    cmp x6, x7
    bgt intra_pred_bi_width_gt_height
    mov x8, x6                      // ishift
    sub x9, x7, x6                  // wc
    b   intra_pred_bi_abcw
intra_pred_bi_width_gt_height:
    mov w8, w7
    sub w9, w6, w7
intra_pred_bi_abcw:
    lsl w12, w12, w6                // a << ishift_x
    lsl w13, w13, w7                // b << ishift_y
    add w12, w12, w13
    adr x14, intra_bi_tbl_wc
    add x14, x14, x9
    ldrsb w15, [x14]
    mov w10, #1
    add w11, w8, #5                 // ishift + 5
    add w8, w8, #6
    mul w12, w12, w15
    lsl w10, w10, w11               // 1 << (ishift + 5)
    add w12, w12, w10
    lsr w12, w12, w8                // c = (((a << ishift_x) + (b << ishift_y)) * 13 + (1 << (ishift + 5))) >> (ishift + 6)

    dup v2.8h, w12

    shl v2.8h, v2.8h, #1            // w = (c << 1) - a - b;
    sub v2.8h, v2.8h, v0.8h
    sub v2.8h, v2.8h, v1.8h

intra_pred_bi_reflines:

    // align (x19)
    // x19-->tmp
    mov x19, sp
    sub sp, sp, #3072

    sub x20, x19, #1024             // ref_up
    sub x15, x19, #1536             // up
    sub x14, x19, #2048             // ref_le
    sub x13, x19, #2560             // le
    sub x12, x19, #3072             // wy

    // ref_up
    add x5, x0, #1

    cmp w3, #16
    beq intra_pred_bi_refup_w16
    bgt intra_pred_bi_refup_w32x
    cmp w3, #4
    beq intra_pred_bi_refup_w4

//intra_pred_bi_refup_w8:
    ld1 {v16.8b}, [x5]
    uxtl v16.8h, v16.8b
    sub v17.8h, v1.8h, v16.8h
    st1 {v17.8h}, [x15]
    sshl v17.8h, v16.8h, v5.8h
    st1 {v17.8h}, [x20]

    b intra_pred_bi_refup_end

intra_pred_bi_refup_w4:
    ld1 {v16.8b}, [x5]
    uxtl v16.8h, v16.8b
    sub v17.4h, v1.4h, v16.4h
    st1 {v17.4h}, [x15]
    sshl v17.4h, v16.4h, v5.4h
    st1 {v17.4h}, [x20]

    b intra_pred_bi_refup_end

intra_pred_bi_refup_w16:
    ld1 {v16.16b}, [x5]
    uxtl v17.8h, v16.8b
    uxtl2 v18.8h, v16.16b
    sub v19.8h, v1.8h, v17.8h
    sub v20.8h, v1.8h, v18.8h
    st1 {v19.8h, v20.8h}, [x15]     // up
    sshl v17.8h, v17.8h, v5.8h
    sshl v18.8h, v18.8h, v5.8h
    st1 {v17.8h, v18.8h}, [x20]     // ref_up

    b intra_pred_bi_refup_end

intra_pred_bi_refup_w32x:

    cmp w3, #64
    beq intra_pred_bi_refup_w64

//intra_pred_bi_refup_w32:
    ld1 {v16.16b, v17.16b}, [x5]
    uxtl v18.8h, v16.8b
    uxtl2 v19.8h, v16.16b
    uxtl v20.8h, v17.8b
    uxtl2 v21.8h, v17.16b
    sub v22.8h, v1.8h, v18.8h
    sub v23.8h, v1.8h, v19.8h
    sub v24.8h, v1.8h, v20.8h
    sub v25.8h, v1.8h, v21.8h
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x15]
    sshl v22.8h, v18.8h, v5.8h
    sshl v23.8h, v19.8h, v5.8h
    sshl v24.8h, v20.8h, v5.8h
    sshl v25.8h, v21.8h, v5.8h
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x20]

    b intra_pred_bi_refup_end

intra_pred_bi_refup_w64:
    ld1 {v16.16b, v17.16b}, [x5], #32
    uxtl v18.8h, v16.8b
    uxtl2 v19.8h, v16.16b
    uxtl v20.8h, v17.8b
    uxtl2 v21.8h, v17.16b
    sub v22.8h, v1.8h, v18.8h
    sub v23.8h, v1.8h, v19.8h
    sub v24.8h, v1.8h, v20.8h
    sub v25.8h, v1.8h, v21.8h
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x15], #64
    sshl v22.8h, v18.8h, v5.8h
    sshl v23.8h, v19.8h, v5.8h
    sshl v24.8h, v20.8h, v5.8h
    sshl v25.8h, v21.8h, v5.8h
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x20], #64

    ld1 {v16.16b, v17.16b}, [x5]
    uxtl v18.8h, v16.8b
    uxtl2 v19.8h, v16.16b
    uxtl v20.8h, v17.8b
    uxtl2 v21.8h, v17.16b
    sub v22.8h, v1.8h, v18.8h
    sub v23.8h, v1.8h, v19.8h
    sub v24.8h, v1.8h, v20.8h
    sub v25.8h, v1.8h, v21.8h
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x15]
    sshl v22.8h, v18.8h, v5.8h
    sshl v23.8h, v19.8h, v5.8h
    sshl v24.8h, v20.8h, v5.8h
    sshl v25.8h, v21.8h, v5.8h
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x20]

    sub x15, x15, #64
    sub x20, x20, #64

intra_pred_bi_refup_end:

    // ref_le and le and wy
    cmp w4, #16
    beq intra_pred_bi_refle_h16
    bgt intra_pred_bi_refle_h32x
    cmp w4, #8
    blt intra_pred_bi_refle_h4
//intra_pred_bi_refle_h8:

    adr x19, intra_plane_coef
    add x19, x19, #8
    ld1 {v6.8b}, [x19]              // 0, 1, 2, 3, 4, 5, 6, 7
    add x19, x19, #16
    ld1 {v3.8b}, [x19]              // 7, 6, 5, 4, 3, 2, 1, 0
    sxtl v6.8h, v6.8b

    sub x5, x0, #8
    ld1 {v16.8b}, [x5]
    tbl v16.8b, {v16.16b}, v3.8b
    uxtl v16.8h, v16.8b
    sub v17.8h, v0.8h, v16.8h
    st1 {v17.8h}, [x13]             // le
    sshl v17.8h, v16.8h, v4.8h
    st1 {v17.8h}, [x14]             // ref_le
    mul v17.8h, v2.8h, v6.8h
    st1 {v17.8h}, [x12]             // wy

    b intra_pred_bi_refle_end

intra_pred_bi_refle_h4:

    adr x19, intra_plane_coef
    add x19, x19, #8
    ld1 {v6.8b}, [x19]              // 0, 1, 2, 3, 4, 5, 6, 7
    add x19, x19, #20
    ld1 {v3.s}[0], [x19]            // 3, 2, 1, 0
    sxtl v6.8h, v6.8b

    sub x5, x0, #4
    ld1 {v16.s}[0], [x5]
    tbl v16.8b, {v16.16b}, v3.8b
    uxtl v16.8h, v16.8b
    sub v17.4h, v0.4h, v16.4h
    st1 {v17.4h}, [x13]
    sshl v17.4h, v16.4h, v4.4h
    st1 {v17.4h}, [x14]
    mul v17.4h, v2.4h, v6.4h
    st1 {v17.4h}, [x12]

    b intra_pred_bi_refle_end

intra_pred_bi_refle_h16:

    adr x19, intra_plane_coef
    add x19, x19, #8
    ld1 {v6.8b}, [x19]              // 0, 1, 2, 3, 4, 5, 6, 7
    sxtl v6.8h, v6.8b
    add x19, x19, #8
    ld1 {v3.16b}, [x19]             // 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

    sub x5, x0, #16
    ld1 {v16.16b}, [x5]
    tbl v16.16b, {v16.16b}, v3.16b
    uxtl v17.8h, v16.8b
    uxtl2 v18.8h, v16.16b
    sub v19.8h, v0.8h, v17.8h
    sub v20.8h, v0.8h, v18.8h
    st1 {v19.8h, v20.8h}, [x13]
    sshl v19.8h, v17.8h, v4.8h
    sshl v20.8h, v18.8h, v4.8h
    st1 {v19.8h, v20.8h}, [x14]
    movi v18.8h, #8
    mul v17.8h, v2.8h, v6.8h
    mul v18.8h, v18.8h, v2.8h
    add v18.8h, v18.8h, v17.8h
    st1 {v17.8h, v18.8h}, [x12]

    b intra_pred_bi_refle_end

intra_pred_bi_refle_h32x:

    cmp w4, #64
    beq intra_pred_bi_refle_h64

//intra_pred_bi_refle_h32:

    adr x19, intra_plane_coef
    add x19, x19, #8
    ld1 {v6.8b}, [x19]              // 0, 1, 2, 3, 4, 5, 6, 7
    sxtl v6.8h, v6.8b
    add x19, x19, #8
    ld1 {v3.16b}, [x19]             // 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

    sub x5, x0, #32
    ld1 {v16.16b, v17.16b}, [x5]
    tbl v16.16b, {v16.16b}, v3.16b
    tbl v17.16b, {v17.16b}, v3.16b
    uxtl v18.8h, v17.8b
    uxtl2 v19.8h, v17.16b
    uxtl v20.8h, v16.8b
    uxtl2 v21.8h, v16.16b
    sub v22.8h, v0.8h, v18.8h
    sub v23.8h, v0.8h, v19.8h
    sub v24.8h, v0.8h, v20.8h
    sub v25.8h, v0.8h, v21.8h
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x13]
    sshl v22.8h, v18.8h, v4.8h
    sshl v23.8h, v19.8h, v4.8h
    sshl v24.8h, v20.8h, v4.8h
    sshl v25.8h, v21.8h, v4.8h
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x14]
    movi v17.8h, #8
    mul v17.8h, v17.8h, v2.8h
    mul v18.8h, v2.8h, v6.8h
    add v19.8h, v18.8h, v17.8h
    add v20.8h, v19.8h, v17.8h
    add v21.8h, v20.8h, v17.8h
    st1 {v18.8h, v19.8h, v20.8h, v21.8h}, [x12]

    b intra_pred_bi_refle_end

intra_pred_bi_refle_h64:

    adr x19, intra_plane_coef
    add x19, x19, #8
    ld1 {v6.8b}, [x19]              // 0, 1, 2, 3, 4, 5, 6, 7
    sxtl v6.8h, v6.8b
    add x19, x19, #8
    ld1 {v3.16b}, [x19]             // 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

    sub x5, x0, #32
    ld1 {v16.16b, v17.16b}, [x5]
    tbl v16.16b, {v16.16b}, v3.16b
    tbl v17.16b, {v17.16b}, v3.16b
    uxtl v18.8h, v17.8b
    uxtl2 v19.8h, v17.16b
    uxtl v20.8h, v16.8b
    uxtl2 v21.8h, v16.16b
    sub v22.8h, v0.8h, v18.8h
    sub v23.8h, v0.8h, v19.8h
    sub v24.8h, v0.8h, v20.8h
    sub v25.8h, v0.8h, v21.8h
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x13], #64
    sshl v22.8h, v18.8h, v4.8h
    sshl v23.8h, v19.8h, v4.8h
    sshl v24.8h, v20.8h, v4.8h
    sshl v25.8h, v21.8h, v4.8h
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x14], #64

    sub x5, x5, #32
    ld1 {v16.16b, v17.16b}, [x5]
    tbl v16.16b, {v16.16b}, v3.16b
    tbl v17.16b, {v17.16b}, v3.16b
    uxtl v18.8h, v17.8b
    uxtl2 v19.8h, v17.16b
    uxtl v20.8h, v16.8b
    uxtl2 v21.8h, v16.16b
    sub v22.8h, v0.8h, v18.8h
    sub v23.8h, v0.8h, v19.8h
    sub v24.8h, v0.8h, v20.8h
    sub v25.8h, v0.8h, v21.8h
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x13]
    sshl v22.8h, v18.8h, v4.8h
    sshl v23.8h, v19.8h, v4.8h
    sshl v24.8h, v20.8h, v4.8h
    sshl v25.8h, v21.8h, v4.8h
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x14]

    movi v17.8h, #8
    mul v17.8h, v17.8h, v2.8h
    mul v18.8h, v2.8h, v6.8h
    add v19.8h, v18.8h, v17.8h
    add v20.8h, v19.8h, v17.8h
    add v21.8h, v20.8h, v17.8h
    add v22.8h, v21.8h, v17.8h
    add v23.8h, v22.8h, v17.8h
    add v24.8h, v23.8h, v17.8h
    add v25.8h, v24.8h, v17.8h
    st1 {v18.8h, v19.8h, v20.8h, v21.8h}, [x12], #64
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x12]

    sub x12, x12, #64
    sub x13, x13, #64
    sub x14, x14, #64
    
intra_pred_bi_refle_end:

    cmp w3, #16
    beq intra_pred_bi_fill_block_w16
    bgt intra_pred_bi_fill_block_w32x
    cmp w3, #8
    blt intra_pred_bi_fill_block_w4

//intra_pred_bi_fill_block_w8:

    ld1 {v18.8h}, [x20]                 // ref_up
    ld1 {v20.8h}, [x15]                 // up

    sxtl v6.4s, v6.4h                   // 0, 1, 2, 3

    uaddl v3.4s, v4.4h, v5.4h           // ishift_x + ishift_y;
    neg v3.4s, v3.4s

intra_pred_bi_fill_block_w8_y:

    add v18.8h, v18.8h, v20.8h          // ref_up[x] += up[x];

    sshll v23.4s, v18.4h, #3            // ref_up[x] << ishift_x (ishift_x = 3)
    sshll2 v24.4s, v18.8h, #3

    ldrsh w10, [x14], #2                // ref_le[y];
    ldrsh w11, [x13], #2                // le[y];

    lsl w10, w10, w7
    lsl w11, w11, w7
    add w10, w10, w11                   // (ref_le[y] << ishift_y) + (le[y] << ishift_y);
    dup v16.4s, w10

    ldrsh w10, [x12], #2
    add w11, w11, w10                   // add = (le[y] << ishift_y) + wy[y]
    dup v17.4s, w11

    mul v21.4s, v17.4s, v6.4s           // [0, 1, 2 ... 7] * add
    shl v22.4s, v17.4s, #2
    add v22.4s, v22.4s, v21.4s

    add v21.4s, v16.4s, v21.4s
    add v22.4s, v16.4s, v22.4s

    add v21.4s, v23.4s, v21.4s
    add v22.4s, v24.4s, v22.4s

    sshl v21.4s, v21.4s, v3.4s          // right shift ishift_x + ishift_y
    sshl v22.4s, v22.4s, v3.4s

    rshrn v21.4h, v21.4s, #1            // right shift 1
    rshrn2 v21.8h, v22.4s, #1

    uqxtn v21.8b, v21.8h

    st1 {v21.8b}, [x1], x2

    subs w4, w4, #1
    bgt intra_pred_bi_fill_block_w8_y

    b intra_pred_bi_end

intra_pred_bi_fill_block_w4:

    ld1 {v18.4h}, [x20]             // ref_up
    ld1 {v20.4h}, [x15]             // up

    sxtl v6.4s, v6.4h               // 0, 1, 2, 3

    uaddl v3.4s, v4.4h, v5.4h       // ishift_x + ishift_y;
    neg v3.4s, v3.4s

intra_pred_bi_fill_block_w4_y:

    add v18.8h, v18.8h, v20.8h      // ref_up[x] += up[x];

    sshll v23.4s, v18.4h, #2        // ref_up[x] << ishift_x (ishift_x = 2)

    ldrsh w10, [x14], #2            // ref_le[y];
    ldrsh w11, [x13], #2            // le[y];

    lsl w10, w10, w7
    lsl w11, w11, w7
    add w10, w10, w11               // (ref_le[y] << ishift_y) + (le[y] << ishift_y);
    dup v16.4s, w10

    ldrsh w10, [x12], #2
    add w11, w11, w10               // add = (pL[y] << ishift_y) + wy[y]
    dup v17.4s, w11

    mul v21.4s, v17.4s, v6.4s       // [0, 1, 2, 3] * add
    add v21.4s, v16.4s, v21.4s

    add v21.4s, v23.4s, v21.4s

    sshl v21.4s, v21.4s, v3.4s      // right shift ishift_x + ishift_y
    rshrn v21.4h, v21.4s, #1        // right shift 1

    uqxtn v21.8b, v21.8h

    subs w4, w4, #1
    st1 {v21.s}[0], [x1], x2
    bgt intra_pred_bi_fill_block_w4_y

    b intra_pred_bi_end

intra_pred_bi_fill_block_w16:

    ld1 {v18.8h, v19.8h}, [x20]     // ref_up
    ld1 {v20.8h, v21.8h}, [x15]     // up

    sxtl v6.4s, v6.4h               // 0, 1, 2, 3

    uaddl v3.4s, v4.4h, v5.4h       // ishift_x + ishift_y;
    neg v3.4s, v3.4s

intra_pred_bi_fill_block_w16_y:

    ldrsh w10, [x14], #2            // ref_le[y];
    ldrsh w11, [x13], #2            // le[y];

    lsl w10, w10, w7
    lsl w11, w11, w7
    add w10, w10, w11               // val = (ref_le[y] << ishift_y) + (le[y] << ishift_y);
    dup v16.4s, w10

    ldrsh w10, [x12], #2
    add w11, w11, w10               // add = (le[y] << ishift_y) + wy[y]
    dup v17.4s, w11

    add v18.8h, v18.8h, v20.8h      // ref_up[x] += up[x];
    add v19.8h, v19.8h, v21.8h

    mul v0.4s, v17.4s, v6.4s        // [0, 1, 2, 3] * add
    shl v1.4s, v17.4s, #2           // 4 * add
    add v2.4s, v1.4s, v0.4s

    sshll v22.4s, v18.4h, #4        // ref_up[x] << ishift_x (ishift_x = 4)
    sshll2 v23.4s, v18.8h, #4

    add v22.4s, v16.4s, v22.4s      // (ref_up[x] << ishift_x) + val
    add v23.4s, v16.4s, v23.4s

    add v22.4s, v0.4s, v22.4s       // (ref_up[x] << ishift_x) + val + add
    add v23.4s, v2.4s, v23.4s

    sshl v22.4s, v22.4s, v3.4s      // right shift ishift_x + ishift_y
    sshl v23.4s, v23.4s, v3.4s

    rshrn v22.4h, v22.4s, #1        // right shift 1
    rshrn2 v22.8h, v23.4s, #1

    uqxtn v24.8b, v22.8h

    add v0.4s, v2.4s, v1.4s
    add v2.4s, v0.4s, v1.4s

    sshll v22.4s, v19.4h, #4        // ref_up[x] << ishift_x (ishift_x = 4)
    sshll2 v23.4s, v19.8h, #4

    add v22.4s, v16.4s, v22.4s      // (ref_up[x] << ishift_x) + val
    add v23.4s, v16.4s, v23.4s

    add v22.4s, v0.4s, v22.4s       // (ref_up[x] << ishift_x) + val + add
    add v23.4s, v2.4s, v23.4s

    sshl v22.4s, v22.4s, v3.4s      // right shift ishift_x + ishift_y
    sshl v23.4s, v23.4s, v3.4s

    rshrn v22.4h, v22.4s, #1        // right shift 1
    rshrn2 v22.8h, v23.4s, #1

    uqxtn2 v24.16b, v22.8h

    subs w4, w4, #1
    st1 {v24.16b}, [x1], x2

    bgt intra_pred_bi_fill_block_w16_y

    b intra_pred_bi_end

intra_pred_bi_fill_block_w32x:

    cmp w3, #64
    beq intra_pred_bi_fill_block_w64

// intra_pred_bi_fill_block_w32

    ld1 {v18.8h, v19.8h, v20.8h, v21.8h}, [x20]     // ref_up
    ld1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x15]     // up

    sxtl v6.4s, v6.4h               // 0, 1, 2, 3

    uaddl v3.4s, v4.4h, v5.4h       // ishift_x + ishift_y;
    neg v3.4s, v3.4s

intra_pred_bi_fill_block_w32_y:

    ldrsh w10, [x14], #2            // ref_le[y];
    ldrsh w11, [x13], #2            // le[y];

    lsl w10, w10, w7
    lsl w11, w11, w7
    add w10, w10, w11               // val = (ref_le[y] << ishift_y) + (le[y] << ishift_y);
    dup v16.4s, w10

    ldrsh w10, [x12], #2
    add w11, w11, w10               // add = (le[y] << ishift_y) + wy[y]
    dup v17.4s, w11

    add v18.8h, v18.8h, v22.8h      // ref_up[x] += up[x];
    add v19.8h, v19.8h, v23.8h
    add v20.8h, v20.8h, v24.8h
    add v21.8h, v21.8h, v25.8h

    mul v0.4s, v17.4s, v6.4s        // [0, 1, 2, 3] * add
    shl v1.4s, v17.4s, #2           // 4 * add
    add v2.4s, v1.4s, v0.4s

    sshll v26.4s, v18.4h, #5        // ref_up[x] << ishift_x (ishift_x = 5)
    sshll2 v27.4s, v18.8h, #5

    add v26.4s, v16.4s, v26.4s      // (ref_up[x] << ishift_x) + val
    add v27.4s, v16.4s, v27.4s

    add v26.4s, v0.4s, v26.4s       // (ref_up[x] << ishift_x) + val + add
    add v27.4s, v2.4s, v27.4s

    sshl v26.4s, v26.4s, v3.4s      // right shift ishift_x + ishift_y
    sshl v27.4s, v27.4s, v3.4s

    rshrn v26.4h, v26.4s, #1        // right shift 1
    rshrn2 v26.8h, v27.4s, #1

    uqxtn v28.8b, v26.8h

    add v0.4s, v2.4s, v1.4s
    add v2.4s, v0.4s, v1.4s

    sshll v26.4s, v19.4h, #5        // ref_up[x] << ishift_x (ishift_x = 5)
    sshll2 v27.4s, v19.8h, #5

    add v26.4s, v16.4s, v26.4s      // (ref_up[x] << ishift_x) + val
    add v27.4s, v16.4s, v27.4s

    add v26.4s, v0.4s, v26.4s       // (ref_up[x] << ishift_x) + val + add
    add v27.4s, v2.4s, v27.4s

    sshl v26.4s, v26.4s, v3.4s      // right shift ishift_x + ishift_y
    sshl v27.4s, v27.4s, v3.4s

    rshrn v26.4h, v26.4s, #1        // right shift 1
    rshrn2 v26.8h, v27.4s, #1

    uqxtn2 v28.16b, v26.8h

    add v0.4s, v2.4s, v1.4s
    add v2.4s, v0.4s, v1.4s

    sshll v26.4s, v20.4h, #5        // ref_up[x] << ishift_x (ishift_x = 5)
    sshll2 v27.4s, v20.8h, #5

    add v26.4s, v16.4s, v26.4s      // (ref_up[x] << ishift_x) + val
    add v27.4s, v16.4s, v27.4s

    add v26.4s, v0.4s, v26.4s       // (ref_up[x] << ishift_x) + val + add
    add v27.4s, v2.4s, v27.4s

    sshl v26.4s, v26.4s, v3.4s      // right shift ishift_x + ishift_y
    sshl v27.4s, v27.4s, v3.4s

    rshrn v26.4h, v26.4s, #1        // right shift 1
    rshrn2 v26.8h, v27.4s, #1

    uqxtn v29.8b, v26.8h

    add v0.4s, v2.4s, v1.4s
    add v2.4s, v0.4s, v1.4s

    sshll v26.4s, v21.4h, #5        // ref_up[x] << ishift_x (ishift_x = 5)
    sshll2 v27.4s, v21.8h, #5

    add v26.4s, v16.4s, v26.4s      // (ref_up[x] << ishift_x) + val
    add v27.4s, v16.4s, v27.4s

    add v26.4s, v0.4s, v26.4s       // (ref_up[x] << ishift_x) + val + add
    add v27.4s, v2.4s, v27.4s

    sshl v26.4s, v26.4s, v3.4s      // right shift ishift_x + ishift_y
    sshl v27.4s, v27.4s, v3.4s

    rshrn v26.4h, v26.4s, #1        // right shift 1
    rshrn2 v26.8h, v27.4s, #1

    uqxtn2 v29.16b, v26.8h

    subs w4, w4, #1
    st1 {v28.16b, v29.16b}, [x1], x2

    bgt intra_pred_bi_fill_block_w32_y

    b intra_pred_bi_end

intra_pred_bi_fill_block_w64:

    mov x9, x20

    ld1 {v16.8h, v17.8h, v18.8h, v19.8h}, [x20], #64    // ref_up
    ld1 {v20.8h, v21.8h, v22.8h, v23.8h}, [x20]
    ld1 {v24.8h, v25.8h, v26.8h, v27.8h}, [x15], #64    // up
    ld1 {v28.8h, v29.8h, v30.8h, v31.8h}, [x15]

    st1 {v8.16b, v9.16b, v10.16b, v11.16b}, [x9]        // protect registers

    sxtl v6.4s, v6.4h                   // 0, 1, 2, 3

    uaddl v4.4s, v4.4h, v5.4h           // ishift_x + ishift_y;
    neg v5.4s, v4.4s

intra_pred_bi_fill_block_w64_y:

    ldrsh w10, [x14], #2                // ref_le[y];
    ldrsh w11, [x13], #2                // le[y];

    lsl w10, w10, w7
    lsl w11, w11, w7
    add w10, w10, w11                   // val = (ref_le[y] << ishift_y) + (le[y] << ishift_y);
    dup v3.4s, w10

    ldrsh w10, [x12], #2
    add w11, w11, w10                   // add = (le[y] << ishift_y) + wy[y]
    dup v4.4s, w11

    add v16.8h, v16.8h, v24.8h          // ref_up[x] += up[x];
    add v17.8h, v17.8h, v25.8h
    add v18.8h, v18.8h, v26.8h
    add v19.8h, v19.8h, v27.8h
    add v20.8h, v20.8h, v28.8h
    add v21.8h, v21.8h, v29.8h
    add v22.8h, v22.8h, v30.8h
    add v23.8h, v23.8h, v31.8h

    mul v0.4s, v4.4s, v6.4s             // [0, 1, 2, 3] * add
    shl v1.4s, v4.4s, #2                // 4 * add
    add v2.4s, v1.4s, v0.4s

    sshll v4.4s, v16.4h, #6             // ref_up[x] << ishift_x (ishift_x = 6)
    sshll2 v7.4s, v16.8h, #6

    add v4.4s, v3.4s, v4.4s             // (ref_up[x] << ishift_x) + val
    add v7.4s, v3.4s, v7.4s

    add v4.4s, v0.4s, v4.4s             // (ref_up[x] << ishift_x) + val + add
    add v7.4s, v2.4s, v7.4s

    sshl v4.4s, v4.4s, v5.4s            // right shift ishift_x + ishift_y
    sshl v7.4s, v7.4s, v5.4s

    rshrn v4.4h, v4.4s, #1              // right shift 1
    rshrn2 v4.8h, v7.4s, #1

    uqxtn v8.8b, v4.8h

    add v0.4s, v2.4s, v1.4s
    add v2.4s, v0.4s, v1.4s

    sshll v4.4s, v17.4h, #6             // ref_up[x] << ishift_x (ishift_x = 6)
    sshll2 v7.4s, v17.8h, #6

    add v4.4s, v3.4s, v4.4s             // (ref_up[x] << ishift_x) + val
    add v7.4s, v3.4s, v7.4s

    add v4.4s, v0.4s, v4.4s             // (ref_up[x] << ishift_x) + val + add
    add v7.4s, v2.4s, v7.4s

    sshl v4.4s, v4.4s, v5.4s            // right shift ishift_x + ishift_y
    sshl v7.4s, v7.4s, v5.4s

    rshrn v4.4h, v4.4s, #1              // right shift 1
    rshrn2 v4.8h, v7.4s, #1

    uqxtn2 v8.16b, v4.8h

    add v0.4s, v2.4s, v1.4s
    add v2.4s, v0.4s, v1.4s

    sshll v4.4s, v18.4h, #6             // ref_up[x] << ishift_x (ishift_x = 6)
    sshll2 v7.4s, v18.8h, #6

    add v4.4s, v3.4s, v4.4s             // (ref_up[x] << ishift_x) + val
    add v7.4s, v3.4s, v7.4s             // (ref_up[x] << ishift_x) + val + add

    add v4.4s, v0.4s, v4.4s             // right shift ishift_x + ishift_y
    add v7.4s, v2.4s, v7.4s

    sshl v4.4s, v4.4s, v5.4s            // right shift 1
    sshl v7.4s, v7.4s, v5.4s

    rshrn v4.4h, v4.4s, #1              // ref_up[x] << ishift_x (ishift_x = 6)
    rshrn2 v4.8h, v7.4s, #1

    uqxtn v9.8b, v4.8h

    add v0.4s, v2.4s, v1.4s
    add v2.4s, v0.4s, v1.4s

    sshll v4.4s, v19.4h, #6             // ref_up[x] << ishift_x (ishift_x = 6)
    sshll2 v7.4s, v19.8h, #6

    add v4.4s, v3.4s, v4.4s             // (ref_up[x] << ishift_x) + val
    add v7.4s, v3.4s, v7.4s

    add v4.4s, v0.4s, v4.4s             // (ref_up[x] << ishift_x) + val + add
    add v7.4s, v2.4s, v7.4s

    sshl v4.4s, v4.4s, v5.4s            // right shift ishift_x + ishift_y
    sshl v7.4s, v7.4s, v5.4s

    rshrn v4.4h, v4.4s, #1              // right shift 1
    rshrn2 v4.8h, v7.4s, #1

    uqxtn2 v9.16b, v4.8h

    add v0.4s, v2.4s, v1.4s
    add v2.4s, v0.4s, v1.4s

    sshll v4.4s, v20.4h, #6             // ref_up[x] << ishift_x (ishift_x = 6)
    sshll2 v7.4s, v20.8h, #6

    add v4.4s, v3.4s, v4.4s             // (ref_up[x] << ishift_x) + val
    add v7.4s, v3.4s, v7.4s

    add v4.4s, v0.4s, v4.4s             // (ref_up[x] << ishift_x) + val + add
    add v7.4s, v2.4s, v7.4s

    sshl v4.4s, v4.4s, v5.4s            // right shift ishift_x + ishift_y
    sshl v7.4s, v7.4s, v5.4s

    rshrn v4.4h, v4.4s, #1              // right shift 1
    rshrn2 v4.8h, v7.4s, #1

    uqxtn v10.8b, v4.8h

    add v0.4s, v2.4s, v1.4s
    add v2.4s, v0.4s, v1.4s

    sshll v4.4s, v21.4h, #6             // ref_up[x] << ishift_x (ishift_x = 6)
    sshll2 v7.4s, v21.8h, #6

    add v4.4s, v3.4s, v4.4s             // (ref_up[x] << ishift_x) + val
    add v7.4s, v3.4s, v7.4s

    add v4.4s, v0.4s, v4.4s             // (ref_up[x] << ishift_x) + val + add
    add v7.4s, v2.4s, v7.4s

    sshl v4.4s, v4.4s, v5.4s            // right shift ishift_x + ishift_y
    sshl v7.4s, v7.4s, v5.4s

    rshrn v4.4h, v4.4s, #1              // right shift 1
    rshrn2 v4.8h, v7.4s, #1

    uqxtn2 v10.16b, v4.8h

    add v0.4s, v2.4s, v1.4s
    add v2.4s, v0.4s, v1.4s

    sshll v4.4s, v22.4h, #6             // ref_up[x] << ishift_x (ishift_x = 6)
    sshll2 v7.4s, v22.8h, #6

    add v4.4s, v3.4s, v4.4s             // (ref_up[x] << ishift_x) + val
    add v7.4s, v3.4s, v7.4s

    add v4.4s, v0.4s, v4.4s             // (ref_up[x] << ishift_x) + val + add
    add v7.4s, v2.4s, v7.4s

    sshl v4.4s, v4.4s, v5.4s            // right shift ishift_x + ishift_y
    sshl v7.4s, v7.4s, v5.4s

    rshrn v4.4h, v4.4s, #1              // right shift 1
    rshrn2 v4.8h, v7.4s, #1

    uqxtn v11.8b, v4.8h

    add v0.4s, v2.4s, v1.4s
    add v2.4s, v0.4s, v1.4s

    sshll v4.4s, v23.4h, #6             // ref_up[x] << ishift_x (ishift_x = 6)
    sshll2 v7.4s, v23.8h, #6

    add v4.4s, v3.4s, v4.4s             // (ref_up[x] << ishift_x) + val
    add v7.4s, v3.4s, v7.4s

    add v4.4s, v0.4s, v4.4s             // (ref_up[x] << ishift_x) + val + add
    add v7.4s, v2.4s, v7.4s

    sshl v4.4s, v4.4s, v5.4s            // right shift ishift_x + ishift_y
    sshl v7.4s, v7.4s, v5.4s

    rshrn v4.4h, v4.4s, #1              // right shift 1
    rshrn2 v4.8h, v7.4s, #1

    uqxtn2 v11.16b, v4.8h

    subs w4, w4, #1
    st1 {v8.16b, v9.16b, v10.16b, v11.16b}, [x1], x2

    bgt intra_pred_bi_fill_block_w64_y

    ld1 {v8.16b, v9.16b, v10.16b, v11.16b}, [x9]        // recovery registers

intra_pred_bi_end:
    add sp, sp, #3072

    ldp x19, x20, [sp], #16
ret

#else

//void xPredIntraVertAdi_arm64(pel_t *pSrc, pel_t *dst, int i_dst, int iWidth, int iHeight);
//psrc->x0, dst->x1, i_dst->x2, width->x3, height->x4
function xPredIntraVertAdi_arm64
    add x0, x0, #2
    lsl w2, w2, #1
    //branch
    cmp w3, #16
    beq intra_pred_ver_w16
    
    cmp w3, #32
    beq intra_pred_ver_w32

    cmp w3, #8
    beq intra_pred_ver_w8

//intra_pred_ver_w4:
    ld1 {v0.4h}, [x0]           // load src[x]
intra_pred_ver_w4_y:
    st1 {v0.4h}, [x1], x2     // store dst[x]
    st1 {v0.4h}, [x1], x2
    st1 {v0.4h}, [x1], x2
    st1 {v0.4h}, [x1], x2
    subs w4, w4, #4
    bgt intra_pred_ver_w4_y

    b intra_pred_ver_end

intra_pred_ver_w8:

    ld1 {v0.8h}, [x0]           // load src[x]
intra_pred_ver_w8_y:
    st1 {v0.8h}, [x1], x2       // store dst[x]
    st1 {v0.8h}, [x1], x2
    st1 {v0.8h}, [x1], x2
    st1 {v0.8h}, [x1], x2
    subs w4, w4, #4
    bgt intra_pred_ver_w8_y

    b intra_pred_ver_end

intra_pred_ver_w16:

    ld1 {v0.8h, v1.8h}, [x0]          // load src[x]
intra_pred_ver_w16_y:
    st1 {v0.8h, v1.8h}, [x1], x2      // store dst[x]
    st1 {v0.8h, v1.8h}, [x1], x2
    st1 {v0.8h, v1.8h}, [x1], x2
    st1 {v0.8h, v1.8h}, [x1], x2
    subs w4, w4, #4
    bgt intra_pred_ver_w16_y

    b intra_pred_ver_end

intra_pred_ver_w32:
    ld1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x0]      // load src[x]
intra_pred_ver_w32_y:
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2  // store dst[x]
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    subs w4, w4, #4
    bgt intra_pred_ver_w32_y

intra_pred_ver_end:
    ret

//void xPredIntraHorAdi_arm64(pel *src, pel *dst, int i_dst, int width, int height)
//src->x0, dst->x1, i_dst->x2, width->x3, height->x4
function xPredIntraHorAdi_arm64
    sub x0, x0, #2
    //branch
    lsl x2, x2, #1
    cmp w3, #16
    beq intra_pred_hor_w16
    
    cmp w3, #32
    beq intra_pred_hor_w32

    cmp w3, #8
    beq intra_pred_hor_w8
//intra_pred_hor_w4:
    sub x0, x0, #6
intra_pred_hor_w4_y:
    ld1 {v4.d}[0], [x0]             // load src[-y]
    dup v0.8h, v4.h[3]
    dup v1.8h, v4.h[2]
    subs w4, w4, #4
    sub x0, x0, #8
    dup v2.8h, v4.h[1]
    dup v3.8h, v4.h[0]
    st1 {v0.d}[0], [x1], x2         // store dst[x]
    st1 {v1.d}[0], [x1], x2
    st1 {v2.d}[0], [x1], x2
    st1 {v3.d}[0], [x1], x2
    bgt intra_pred_hor_w4_y

    b intra_pred_hor_end

intra_pred_hor_w8:
    sub x0, x0, #6
intra_pred_hor_w8_y:
    ld1 {v4.d}[0], [x0]             // load src[-y]
    dup v0.8h, v4.h[3]
    dup v1.8h, v4.h[2]
    sub x0, x0, #8
    subs w4, w4, #4
    dup v2.8h, v4.h[1]
    dup v3.8h, v4.h[0]
    st1 {v0.8h}, [x1], x2           // store dst[x]
    st1 {v1.8h}, [x1], x2
    st1 {v2.8h}, [x1], x2
    st1 {v3.8h}, [x1], x2
    bgt intra_pred_hor_w8_y

    b intra_pred_hor_end

intra_pred_hor_w16:
    sub x0, x0, #6
intra_pred_hor_w16_y:
    ld1 {v16.d}[0], [x0]             // load src[-y]
    dup v0.8h, v16.h[3]
    dup v2.8h, v16.h[2]
    subs w4, w4, #4
    sub x0, x0, #8
    dup v4.8h, v16.h[1]
    dup v6.8h, v16.h[0]
    mov v1.16b, v0.16b
    mov v3.16b, v2.16b
    mov v5.16b, v4.16b
    mov v7.16b, v6.16b

    st1 {v0.8h, v1.8h}, [x1], x2         // store dst[x]
    st1 {v2.8h, v3.8h}, [x1], x2
    st1 {v4.8h, v5.8h}, [x1], x2
    st1 {v6.8h, v7.8h}, [x1], x2
    bgt intra_pred_hor_w16_y

    b intra_pred_hor_end

intra_pred_hor_w32:
    sub x0, x0, #6
    sub x2, x2, #32
intra_pred_hor_w32_y:
    ld1 {v16.d}[0], [x0]            // load rpSrc[-y]
    dup v0.8h, v16.h[3]
    dup v2.8h, v16.h[2]
    dup v4.8h, v16.h[1]
    dup v6.8h, v16.h[0]
    mov v1.16b, v0.16b
    mov v3.16b, v2.16b
    mov v5.16b, v4.16b
    mov v7.16b, v6.16b
    st1 {v0.8h, v1.8h}, [x1], #32 // store dst[x]
    st1 {v0.8h, v1.8h}, [x1], x2
    st1 {v2.8h, v3.8h}, [x1], #32
    st1 {v2.8h, v3.8h}, [x1], x2
    sub x0, x0, #8
    subs w4, w4, #4
    st1 {v4.8h, v5.8h}, [x1], #32
    st1 {v4.8h, v5.8h}, [x1], x2
    st1 {v6.8h, v7.8h}, [x1], #32
    st1 {v6.8h, v7.8h}, [x1], x2
    bgt intra_pred_hor_w32_y

intra_pred_hor_end:
    ret

//void xPredIntraDCAdi_arm64(pel_t *pSrc, pel_t *dst, int i_dst, int iWidth, int iHeight, int bAboveAvail, int bLeftAvail, int bit_depth);
//src->x0, dst->x1, i_dst->x2, w->x3, h->x4, bAoveAvail->x5, bLeftAvail->x6, bit_depth->x7
function xPredIntraDCAdi_arm64
    lsl x2, x2, #1
    lsl x12, x4, #1

    sub x14, x7, #1

    and w7, w6, #1          // left avail
    and w8, w5, #1          // up avail

    and w9, w7, w8          //left up
    cmp w9, #0
    bne intra_pred_dc_above_left

    cmp w8, #0
    bne intra_pred_dc_above //up

    cmp w7, #0
    beq intra_pred_dc_none  //else

//left
intra_pred_dc_left:
    sub x10, x0, x12
    mov w7, w4
    b intra_pred_dc_single_line
intra_pred_dc_above:
    add x10, x0, #2
    mov w7, w3

intra_pred_dc_single_line:
    cmp w7, #16
    beq intra_pred_dc_1ref_w16
    bgt intra_pred_dc_1ref_w32x

    cmp w7, #8
    beq intra_pred_dc_1ref_w8

//intra_pred_dc_1ref_w4:
    movi v0.8h, #0
    ld1 {v0.d}[0], [x10]

    addp v0.4h, v0.4h, v0.4h
    addp v0.4h, v0.4h, v0.4h

    umov w8, v0.h[0]
    add w8, w8, #2
    lsr w8, w8, #2              // dc /= height;
    dup v0.8h, w8

    b intra_pred_dc_fillblock

intra_pred_dc_1ref_w8:
    ld1 {v0.8h}, [x10]

    addp v0.8h, v0.8h, v0.8h
    addp v0.8h, v0.8h, v0.8h
    addp v0.8h, v0.8h, v0.8h

    umov w8, v0.h[0]
    add w8, w8, #4
    lsr w8, w8, #3              // dc /= height;
    dup v0.8h, w8

    b intra_pred_dc_fillblock

intra_pred_dc_1ref_w16:
    ld1 {v0.8h, v1.8h}, [x10]

    add v0.8h, v0.8h, v1.8h
    addp v0.8h, v0.8h, v0.8h
    addp v0.8h, v0.8h, v0.8h
    addp v0.8h, v0.8h, v0.8h

    umov w8, v0.h[0]
    add w8, w8, #8
    lsr w8, w8, #4              // dc /= height;
    dup v0.8h, w8

    b intra_pred_dc_fillblock

intra_pred_dc_1ref_w32x:
    cmp w7, #64
    beq intra_pred_dc_1ref_w64

    ld1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x10]
    uaddl v4.4s, v0.4h, v1.4h
    uaddl2 v5.4s, v0.8h, v1.8h
    uaddl v6.4s, v2.4h, v3.4h
    uaddl2 v7.4s, v2.8h, v3.8h
    add v4.4s, v4.4s, v5.4s
    add v6.4s, v6.4s, v7.4s
    add v0.4s, v4.4s, v6.4s
    addp v0.4s, v0.4s, v0.4s
    addp v0.4s, v0.4s, v0.4s

    umov w8, v0.s[0]
    add w8, w8, #16
    lsr w8, w8, #5              // dc /= height;
    dup v0.8h, w8

    b intra_pred_dc_fillblock

intra_pred_dc_1ref_w64:
    ld1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x10], #64
    ld1 {v4.8h, v5.8h, v6.8h, v7.8h}, [x10]
    add v0.8h, v0.8h, v4.8h
    add v1.8h, v1.8h, v5.8h
    add v2.8h, v2.8h, v6.8h
    add v3.8h, v3.8h, v7.8h

    uaddl v4.4s, v0.4h, v1.4h
    uaddl2 v5.4s, v0.8h, v1.8h
    uaddl v6.4s, v2.4h, v3.4h
    uaddl2 v7.4s, v2.8h, v3.8h

    add v4.4s, v4.4s, v5.4s
    add v6.4s, v6.4s, v7.4s
    add v0.4s, v4.4s, v6.4s
    addp v0.4s, v0.4s, v0.4s
    addp v0.4s, v0.4s, v0.4s

    umov w8, v0.s[0]
    add w8, w8, #32
    lsr w8, w8, #6              // dc /= height;
    dup v0.8h, w8

    b intra_pred_dc_fillblock

intra_pred_dc_none:
    mov x13, #1
    lsl x13, x13, x14
    dup v0.8h, w13			// iDCValue = 1 << (sample_bit_depth - 1);
    b intra_pred_dc_fillblock

intra_pred_dc_above_left:

    add x10, x0, #2 			// rpSrc = pSrc + 1;

    //branch
    cmp w3, #16
    beq intra_pred_dc_above_left_w16
    bgt intra_pred_dc_above_left_w32x

    cmp w3, #8
    beq intra_pred_dc_above_left_w8

//intra_pred_dc_above_left_w4:
    movi v0.8h, #0
    ld1 {v0.d}[0], [x10]
    b intra_pred_dc_above_left_h

intra_pred_dc_above_left_w8:
    ld1 {v0.8h}, [x10]
    b intra_pred_dc_above_left_h

intra_pred_dc_above_left_w16:
    ld1 {v0.8h, v1.8h}, [x10]
    add v0.8h, v0.8h, v1.8h
    b intra_pred_dc_above_left_h

intra_pred_dc_above_left_w32x:
    cmp w3, #64
    beq intra_pred_dc_above_left_w64

    ld1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x10]
    add v0.8h, v0.8h, v1.8h
    add v2.8h, v2.8h, v3.8h
    add v0.8h, v0.8h, v2.8h
    b intra_pred_dc_above_left_h

intra_pred_dc_above_left_w64:
    ld1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x10], #64
    ld1 {v4.8h, v5.8h, v6.8h, v7.8h}, [x10]
    add v0.8h, v0.8h, v1.8h
    add v2.8h, v2.8h, v3.8h
    add v0.8h, v0.8h, v2.8h
    add v4.8h, v4.8h, v5.8h
    add v6.8h, v6.8h, v7.8h
    add v4.8h, v4.8h, v6.8h
    add v0.8h, v0.8h, v4.8h

intra_pred_dc_above_left_h:
    //branch
    cmp w4, #16
    beq intra_pred_dc_above_left_h16
    bgt intra_pred_dc_above_left_h32x

    cmp w4, #8
    beq intra_pred_dc_above_left_h8

//intra_pred_dc_above_left_h4:
    movi v1.8h, #0
    sub  x10, x0, #8
    ld1 {v1.d}[0], [x10]
    add v0.8h, v0.8h, v1.8h
    b intra_pred_dc_above_left_dcvalue

intra_pred_dc_above_left_h8:
    sub  x10, x0, #16
    ld1 {v1.8h}, [x10]
    add v0.8h, v0.8h, v1.8h
    b intra_pred_dc_above_left_dcvalue

intra_pred_dc_above_left_h16:
    sub  x10, x0, #32
    ld1 {v1.8h, v2.8h}, [x10]
    add v1.8h, v1.8h, v2.8h
    add v0.8h, v0.8h, v1.8h
    b intra_pred_dc_above_left_dcvalue

intra_pred_dc_above_left_h32x:
    cmp w4, #64
    beq intra_pred_dc_above_left_h64

    sub  x10, x0, #64
    ld1 {v1.8h, v2.8h, v3.8h, v4.8h}, [x10]
    add v1.8h, v1.8h, v2.8h
    add v3.8h, v3.8h, v4.8h
    add v1.8h, v1.8h, v3.8h
    add v0.8h, v0.8h, v1.8h
    b intra_pred_dc_above_left_dcvalue

intra_pred_dc_above_left_h64:
    sub x10, x0, #128
    ld1 {v4.8h, v5.8h, v6.8h, v7.8h}, [x10], #64
    ld1 {v16.8h, v17.8h, v18.8h, v19.8h}, [x10]

    add v4.8h, v4.8h, v5.8h
    add v6.8h, v6.8h, v7.8h
    add v16.8h, v16.8h, v17.8h
    add v18.8h, v18.8h, v19.8h
    add v4.8h, v4.8h, v6.8h
    add v16.8h, v16.8h, v18.8h
    add v4.8h, v4.8h, v16.8h
    add v0.8h, v0.8h, v4.8h
    b intra_pred_dc_above_left_dcvalue

intra_pred_dc_above_left_dcvalue:

    uaddlp v0.4s, v0.8h
    addp v0.4s, v0.4s, v0.4s
    addp v0.4s, v0.4s, v0.4s

    // (dc + ((w + h) >> 1)) * (4096 / (w + h)) >> 9;
    add w10, w3, w4			    // dc += ((w + h) >> 1);
    lsr w8, w10, #1
    umov w9, v0.s[0]
    add w8, w8, w9

    mov w11, #512				// dc = (dc * (512 / (w + h))) >> 9;
    udiv w11, w11, w10
    mul w8, w8, w11
    lsr w8, w8, #9
    dup v0.8h, w8

intra_pred_dc_fillblock:

    //branch
    cmp w3, #16
    beq intra_pred_dc_fillblock_w16
    bgt intra_pred_dc_fillblock_w32x

    cmp w3, #8
    beq intra_pred_dc_fillblock_w8

// intra_pred_dc_fillblock_w4:

intra_pred_dc_fillblock_w4_y:
    st1 {v0.d}[0], [x1], x2  // store dst[x]
    st1 {v0.d}[0], [x1], x2
    subs w4, w4, #4
    st1 {v0.d}[0], [x1], x2
    st1 {v0.d}[0], [x1], x2
    bne intra_pred_dc_fillblock_w4_y
    b   intra_pred_dc_end

intra_pred_dc_fillblock_w8:
    st1 {v0.8h}, [x1], x2       // store dst[x]
    st1 {v0.8h}, [x1], x2
    subs w4, w4, #4
    st1 {v0.8h}, [x1], x2
    st1 {v0.8h}, [x1], x2
    bgt intra_pred_dc_fillblock_w8
    b   intra_pred_dc_end

intra_pred_dc_fillblock_w16:
    mov v1.16b, v0.16b
    st1 {v0.8h, v1.8h}, [x1], x2  // store dst[x]
    st1 {v0.8h, v1.8h}, [x1], x2
    subs w4, w4, #4
    st1 {v0.8h, v1.8h}, [x1], x2
    st1 {v0.8h, v1.8h}, [x1], x2
    bgt intra_pred_dc_fillblock_w16
    b   intra_pred_dc_end

intra_pred_dc_fillblock_w32x:

    cmp w3, #64
    beq intra_pred_dc_fillblock_w64

    mov v1.16b, v0.16b
    mov v2.16b, v0.16b
    mov v3.16b, v0.16b
intra_pred_dc_fillblock_w32_y:
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2  // store dst[x]
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    subs w4, w4, #4
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    bgt intra_pred_dc_fillblock_w32_y
    b   intra_pred_dc_end

intra_pred_dc_fillblock_w64:
    sub x2, x2, #64
    mov v1.16b, v0.16b
    mov v2.16b, v0.16b
    mov v3.16b, v0.16b
intra_pred_dc_fillblock_w64_y:
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64  // store dst[x]
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    subs w4, w4, #4
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    bgt intra_pred_dc_fillblock_w64_y

intra_pred_dc_end:
    ret


intra_plane_mul_shift:
.byte 13, 7, 17, 10, 5, 11, 11, 15, 23, 19

intra_plane_coef:
.byte 8, 7, 6, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, \
      16, 17, 14, 15, 12, 13, 10, 11, 8, 9, 6, 7, 4, 5, 2, 3, 0, 1

//void xPredIntraPlaneAdi_arm64(pel *src, pel *dst, int i_dst, int width, int height, int bit_depth)
//src->x0, dst->x1, i_dst->x2, width->x3, height->x4, bit_depth->x5
function xPredIntraPlaneAdi_arm64

    sub sp, sp, #16
    stp x19, x20, [sp]

    mov x9, #61
    clz x7, x3
    clz x8, x4
    sub x15, x9, x7  					// idx_w = tab_log2[width] - 2
    sub x14, x9, x8					    // idx_h = tab_log2[height] - 2

    movi v6.2s, #0
    movi v7.2s, #0

    adr x19, intra_plane_mul_shift
    lsl w15, w15, #1
    add x15, x19, x15					// im_h, is_h
    ld2 {v6.b, v7.b}[0], [x15]

    lsl w14, w14, #1
    add x14, x19, x14					// im_v, is_v
    ld2 {v6.b, v7.b}[4], [x14]

    lsr x10, x3, #1						// iW2 = width >> 1;
    lsr x11, x4, #1						// iH2 = height >> 1;

    add x19, x0, x3					// rpSrc = pSrc + 1;  rpSrc += (iW2 - 1); 注意这里加了两倍的iW2

    mov x9, #1
    lsl x9, x9, x5
    sub x9, x9, #1                // max_val = 1 << bit_depth) - 1

    cmp x10, #4
    beq intra_pred_plane_coef_h_loop4
    bgt intra_pred_plane_coef_h_loop8

// intra_pred_plane_coef_h_loop2

    ldrh w12, [x19, #2]
    ldrh w13, [x19, #-2]
    sub w14, w12, w13
    ldrh w12, [x19, #4]
    ldrh w13, [x19, #-4]
    sub w15, w12, w13
    lsl w15, w15, #1
    add w5, w14, w15
    movi v4.4s, #0
    mov v4.s[0], w5                 // v4: coef_h
    b intra_pred_plane_coef_h_end

intra_pred_plane_coef_h_loop4:
//.byte 8, 7, 6, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
//.byte 16,17,14,15,12,13,10,11, 8,9,6,7,4,5,2,3, 0,1
    adr x12, intra_plane_coef
    add x12, x12, #4
    ld1 {v2.8b}, [x12]
    uxtl v3.8h, v2.8b               // 获得x：4, 3, 2, 1

    add x12, x12, #36               // 获得查表索引index
    ld1 {v2.8b}, [x12]			    // 89,67,45,23

    ld1 {v0.8h}, [x19]              // rsrc[0,1,2,3,4,5,6,7]
    sub x19, x19, #8
    ld1 {v1.4h}, [x19]              // rsrc[-4,-3,-2,-1]            v1.4h
    tbl v0.8b, {v0.16b}, v2.8b      // rsrc[ 4, 3, 2, 1, ...]       v0.4h
//    rev16 v0.8b, v0.8b              // 大小端问题：调整顺序

    sub v0.4h, v0.4h, v1.4h
    smull v4.4s, v0.4h, v3.4h

    b intra_pred_plane_coef_h_end

intra_pred_plane_coef_h_loop8:

    mov w13, w10

    adr x12, intra_plane_coef
    ld1 {v2.8b}, [x12]			        // 获得x：8, 7, 6, 5, 4, 3, 2, 1
    uxtl v3.8h, v2.8b

    add x12, x12, #34               // 获得查表索引14 15,12 13,10 11,89,67,45,23,01
    ld1 {v2.16b}, [x12]

    movi v4.4s, #0
    movi v16.8h, #8
    sub x20, x19, #16
    add x19, x19, #2

intra_pred_plane_coef_h_loop8_x:

    ld1 {v0.8h}, [x19]             // rsrc[1,2,3,4,5,6,7,8]
    ld1 {v1.8h}, [x20]              // rsrc[-8,-7,-6,-5,-4,-3,-2,-1]        v1.8h
    tbl v0.16b, {v0.16b}, v2.16b    // rsrc[ 8, 7, 6, 5, 4, 3, 2, 1]        v0.8h

    sub v0.8h, v0.8h, v1.8h
    smlal v4.4s, v0.4h, v3.4h
    smlal2 v4.4s, v0.8h, v3.8h      // sum of 8 values

    add v3.8h, v3.8h, v16.8h        // x = 16, 15, 14, ..., 9
    subs w13, w13, #8               // iw2 -= 8
    add x19, x19, #16               // rsrc += 8
    sub x20, x20, #16
    bgt intra_pred_plane_coef_h_loop8_x

//v4 -> coef_h
intra_pred_plane_coef_h_end:

    sub x19, x0, x4					// rpSrc = pSrc - 1;  rpSrc -= (iH2 - 1); 注意这里减了两倍的iH2

    cmp x11, #4
    beq intra_pred_plane_coef_v_loop4
    bgt intra_pred_plane_coef_v_loop8

// intra_pred_plane_coef_v_loop2

    ldrh w12, [x19, #2]
    ldrh w13, [x19, #-2]
    sub w14, w13, w12
    ldrh w12, [x19, #4]
    ldrh w13, [x19, #-4]
    sub w15, w13, w12
    lsl w15, w15, #1
    add w5, w14, w15
    movi v5.4s, #0
    mov v5.s[1], w5
    b intra_pred_plane_coef_v_end

intra_pred_plane_coef_v_loop4:

    adr x12, intra_plane_coef
    add x12, x12, #4
    ld1 {v2.8b}, [x12]			// 4, 3, 2, 1
    uxtl v3.8h, v2.8b

    add x12, x12, #36               // 获得查表索引index
    ld1 {v2.8b}, [x12]			    // 89,67,45,23

    ld1 {v0.8h}, [x19]
    sub x19, x19, #8
    ld1 {v1.4h}, [x19]
    tbl v0.8b, {v0.16b}, v2.8b

    sub v0.4h, v1.4h, v0.4h
    smull v5.4s, v0.4h, v3.4h

    b intra_pred_plane_coef_v_end

intra_pred_plane_coef_v_loop8:

    mov w13, w11

    adr x12, intra_plane_coef
    ld1 {v2.8b}, [x12]			// 8, 7, 6, 5, 4, 3, 2, 1
    uxtl v3.8h, v2.8b

    add x12, x12, #34               // 获得查表索引14 15,12 13,10 11,89,67,45,23,01
    ld1 {v2.16b}, [x12]

    movi v5.4s, #0
    movi v16.8h, #8
    sub x20, x19, #16
    add x19, x19, #2

intra_pred_plane_coef_v_loop8_x:

    ld1 {v0.8h}, [x19]
    ld1 {v1.8h}, [x20]
    tbl v0.16b, {v0.16b}, v2.16b

    sub v0.8h, v1.8h, v0.8h
    smlal v5.4s, v0.4h, v3.4h
    smlal2 v5.4s, v0.8h, v3.8h

    add v3.8h, v3.8h, v16.8h
    subs w13, w13, #8
    add x19, x19, #16
    sub x20, x20, #16
    bgt intra_pred_plane_coef_v_loop8_x

//v5 -> coef_v
intra_pred_plane_coef_v_end:

    addp v4.4s, v4.4s, v5.4s
    addp v4.4s, v4.4s, v4.4s      // v4.4s[0]->coef_h; v4.4s[1]->coef_v;

    // iA = (pSrc[-1 - (height - 1)] + pSrc[1 + width - 1]) << 4
    sub x6, x0, x4
    sub x6, x6, x4                  // todo：这里能不能一次减俩？
    ldrh w7, [x6]
    add x6, x0, x3
    add x6, x6, x3
    ldrh w8, [x6]
    add w6, w7, w8
    lsl w6, w6, #4

    // iB = ((coef_h << 5) * im_h + (1 << (is_h - 1))) >> is_h;
    // iC = ((coef_v << 5) * im_v + (1 << (is_v - 1))) >> is_v;
    shl v4.2s, v4.2s, #5
    mul v4.2s, v4.2s, v6.2s
    neg v7.2s, v7.2s
    srshl v4.2s, v4.2s, v7.2s
    umov w12, v4.s[0]
    umov w13, v4.s[1]
    dup v30.8h, w12				//v30->iB
    dup v31.8h, w13				//v31->iC

    // iTmp = iA - (iH2 - 1) * iC - (iW2 - 1) * iB + 16
    sub w10, w10, #1
    sub w11, w11, #1
    mul w10, w10, w12
    mul w11, w11, w13
    sub w6, w6, w10
    sub w6, w6, w11
    add w6, w6, #16
    dup v0.8h, w6				// v0->iTmp

//.byte 8, 7, 6, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
//.byte 16,17,14,15,12,13,10,11, 8,9,6,7,4,5,2,3, 0,1
    adr x12, intra_plane_coef
    add x12, x12, #8
    ld1 {v2.8b}, [x12]			// 0, 1, 2, 3, 4, 5, 6, 7
    lsl x2, x2, #1              // i_dst << 1

    cmp x3, #4
    bne intra_pred_plane_fill_loop8

//intra_pred_plane_fill_loop4:

    sxtl v2.8h, v2.8b
    mul v30.4h, v30.4h, v2.4h   // 0, b, 2b, 3b

    movi v28.4h, #0			//max and min val
    dup v29.4h, w9

    add v0.4h, v0.4h, v30.4h    // temp, temp + b, temp + 2b, temp + 3b
intra_pred_plane_fill_loop4_y:

// dst[x] = Clip3(0, vmax, iTmp2 >> 5);
    sshr v1.4h, v0.4h, #5
    smax v1.4h, v1.4h, v28.4h
    smin v1.4h, v1.4h, v29.4h
//    xtn v1.8b, v1.8h
    st1 {v1.4h}, [x1], x2

    subs w4, w4, #1
    add v0.4h, v0.4h, v31.4h   //iTmp += iC;
    bgt intra_pred_plane_fill_loop4_y

    b intra_pred_plane_fill_end

intra_pred_plane_fill_loop8:

    sxtl v2.8h, v2.8b
    mul v26.8h, v30.8h, v2.8h   // 0, b, 2b, 3b, 4b, 5b, 6b, 7b

    movi v28.8h, #0			    //max and min val
    dup v29.8h, w9

    shl v27.8h, v30.8h, #3      // iB * 8

    add v0.8h, v0.8h, v26.8h    // temp, temp + b, temp + 2b, temp + 3b, ..., temp + 7b
intra_pred_plane_fill_loop8_x:

    mov v1.16b, v0.16b
    mov x19, x1
    mov w8, w4
intra_pred_plane_fill_loop8_y:

    sshr v2.8h, v1.8h, #5
    smax v2.8h, v2.8h, v28.8h
    smin v2.8h, v2.8h, v29.8h

//    xtn v2.8b, v2.8h
    st1 {v2.8h}, [x19], x2

    subs w8, w8, #1
    add v1.8h, v1.8h, v31.8h   //iTmp += iC;
    bgt intra_pred_plane_fill_loop8_y

    add x1, x1, #16
    subs w3, w3, #8
    add v0.8h, v0.8h, v27.8h
    bgt intra_pred_plane_fill_loop8_x

intra_pred_plane_fill_end:
    ldp x19, x20, [sp], #16
    ret

#endif
#endif

