/* vi: set ts=4 expandtab shiftwidth=4: */
/**
 * @file
 *
 * Copyright 2019 Digital Aggregates Corporation, Colorado, USA<BR>
 * Licensed under the terms in README.h<BR>
 * Chip Overclock (coverclock@diag.com)<BR>
 * https://github.com/coverclock/com-diag-hazer<BR>
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "com/diag/hazer/tumbleweed.h"
#include "../src/tumbleweed.h"

/******************************************************************************
 *
 ******************************************************************************/

static FILE * debug  = (FILE *)0;

/******************************************************************************
 *
 ******************************************************************************/

FILE * tumbleweed_debug(FILE * now)
{
    FILE * was;

    was = debug;
    debug = now;

    return was;
}

/******************************************************************************
 *
 ******************************************************************************/

int tumbleweed_initialize(void)
{
    return 0;
}

int tumbleweed_finalize(void)
{
    return 0;
}

/******************************************************************************
 *
 ******************************************************************************/

tumbleweed_state_t tumbleweed_machine(tumbleweed_state_t state, int ch, void * buffer, size_t size, char ** bp, size_t * sp, size_t * lp)
{
    int done = !0;
    tumbleweed_action_t action = TUMBLEWEED_ACTION_SKIP;

    /*
     * Short circuit state machine for some characters.
     */

    switch (ch) {

    case EOF:
        DEBUG("EOF %d!\n", ch);
        state = TUMBLEWEED_STATE_EOF;
        break;

    default:
        /* Do nothing. */
        break;

    }

    /*
     * Advance state machine based on stimulus.
     */

    switch (state) {

    case TUMBLEWEED_STATE_EOF:
        *bp = (char *)buffer;
        *sp = 0;
        break;

    case TUMBLEWEED_STATE_START:
        if (ch == TUMBLEWEED_STIMULUS_PREAMBLE) {
            DEBUG("RTCM 0x%02x.\n", ch);
            state = TUMBLEWEED_STATE_LENGTH_1;
            action = TUMBLEWEED_ACTION_SAVE;
            *bp = (char *)buffer;
            *sp = size;
            *lp = 0;
        }
        break;

    case TUMBLEWEED_STATE_LENGTH_1:
    	/*
    	 * Remarkably, I don't find any mention of byte order or endianess
    	 * in the RTCM specifications. But a dump of actual messages from a
    	 * U-blox UBX-ZED-F9P chip suggests big endianess.
    	 */
        *lp = ((unsigned)ch) << 8; /* MSB */
        DEBUG("LENGTH1 0x%02x %zu.\n", ch, *lp);
        state = TUMBLEWEED_STATE_LENGTH_2;
        action = TUMBLEWEED_ACTION_SAVE;
        break;

    case TUMBLEWEED_STATE_LENGTH_2:
    	/*
    	 * See above.
    	 */
        *lp |= (unsigned)ch; /* LSB */
        DEBUG("LENGTH2 0x%02x %zu.\n", ch, *lp);
        state = TUMBLEWEED_STATE_PAYLOAD;
        action = TUMBLEWEED_ACTION_SAVE;
        break;

    case TUMBLEWEED_STATE_PAYLOAD:
        if (((*lp)--) > 1) {
            state = TUMBLEWEED_STATE_PAYLOAD;
        } else {
            state = TUMBLEWEED_STATE_CRC_1;
        }
        action = TUMBLEWEED_ACTION_SAVE;
        break;

    case TUMBLEWEED_STATE_CRC_1:
        state = TUMBLEWEED_STATE_CRC_2;
        action = TUMBLEWEED_ACTION_SAVE;
        break;

    case TUMBLEWEED_STATE_CRC_2:
        state = TUMBLEWEED_STATE_CRC_3;
        action = TUMBLEWEED_ACTION_SAVE;
        break;

    case TUMBLEWEED_STATE_CRC_3:
        state = TUMBLEWEED_STATE_END;
        action = TUMBLEWEED_ACTION_TERMINATE;
        break;

    case TUMBLEWEED_STATE_END:
        DEBUG("END 0x%02x!\n", ch);
        break;

    /*
     * No default: must handle all cases.
     */

    }

    /*
     * Perform associated action.
     */

    switch (action) {

    case TUMBLEWEED_ACTION_SKIP:
        DEBUG("SKIP 0x%02x?\n", ch);
        break;

    case TUMBLEWEED_ACTION_SAVE:
        if ((*sp) > 0) {
            *((*bp)++) = ch;
            (*sp) -= 1;
            DEBUG("SAVE 0x%02x.\n", ch);
        } else {
            state = TUMBLEWEED_STATE_START;
            DEBUG("LONG!\n");
        }
        break;

    case TUMBLEWEED_ACTION_TERMINATE:
        /*
         * It seems like it's not really meaningful to NUL-terminate a binary
         * RTCM message, but it is. Doing so simplifies user code that doesn't
         * know yet the format of the data in the buffer, e.g. in the case of
         * IP datagrams.
         */
        if ((*sp) > 1) {
            *((*bp)++) = ch;
            (*sp) -= 1;
            DEBUG("SAVE 0x%02x.\n", ch);
            *((*bp)++) = '\0';
            (*sp) -= 1;
            DEBUG("SAVE 0x%02x.\n", '\0');
            (*sp) = size - (*sp);
        } else {
            state = TUMBLEWEED_STATE_START;
            DEBUG("LONG!\n");
        }
        break;

    /*
     * No default: must handle all cases.
     */

    }

    /*
     * Done.
     */

    return state;
}

/******************************************************************************
 *
 ******************************************************************************/

const uint32_t TUMBLEWEED_CRC24Q[256] = {
    0x00000000, 0x01864cfb, 0x028ad50d, 0x030c99f6,
    0x0493e6e1, 0x0515aa1a, 0x061933ec, 0x079f7f17,
    0x08a18139, 0x0927cdc2, 0x0a2b5434, 0x0bad18cf,
    0x0c3267d8, 0x0db42b23, 0x0eb8b2d5, 0x0f3efe2e,
    0x10c54e89, 0x11430272, 0x124f9b84, 0x13c9d77f,
    0x1456a868, 0x15d0e493, 0x16dc7d65, 0x175a319e,
    0x1864cfb0, 0x19e2834b, 0x1aee1abd, 0x1b685646,
    0x1cf72951, 0x1d7165aa, 0x1e7dfc5c, 0x1ffbb0a7,
    0x200cd1e9, 0x218a9d12, 0x228604e4, 0x2300481f,
    0x249f3708, 0x25197bf3, 0x2615e205, 0x2793aefe,
    0x28ad50d0, 0x292b1c2b, 0x2a2785dd, 0x2ba1c926,
    0x2c3eb631, 0x2db8faca, 0x2eb4633c, 0x2f322fc7,
    0x30c99f60, 0x314fd39b, 0x32434a6d, 0x33c50696,
    0x345a7981, 0x35dc357a, 0x36d0ac8c, 0x3756e077,
    0x38681e59, 0x39ee52a2, 0x3ae2cb54, 0x3b6487af,
    0x3cfbf8b8, 0x3d7db443, 0x3e712db5, 0x3ff7614e,
    0x4019a3d2, 0x419fef29, 0x429376df, 0x43153a24,
    0x448a4533, 0x450c09c8, 0x4600903e, 0x4786dcc5,
    0x48b822eb, 0x493e6e10, 0x4a32f7e6, 0x4bb4bb1d,
    0x4c2bc40a, 0x4dad88f1, 0x4ea11107, 0x4f275dfc,
    0x50dced5b, 0x515aa1a0, 0x52563856, 0x53d074ad,
    0x544f0bba, 0x55c94741, 0x56c5deb7, 0x5743924c,
    0x587d6c62, 0x59fb2099, 0x5af7b96f, 0x5b71f594,
    0x5cee8a83, 0x5d68c678, 0x5e645f8e, 0x5fe21375,
    0x6015723b, 0x61933ec0, 0x629fa736, 0x6319ebcd,
    0x648694da, 0x6500d821, 0x660c41d7, 0x678a0d2c,
    0x68b4f302, 0x6932bff9, 0x6a3e260f, 0x6bb86af4,
    0x6c2715e3, 0x6da15918, 0x6eadc0ee, 0x6f2b8c15,
    0x70d03cb2, 0x71567049, 0x725ae9bf, 0x73dca544,
    0x7443da53, 0x75c596a8, 0x76c90f5e, 0x774f43a5,
    0x7871bd8b, 0x79f7f170, 0x7afb6886, 0x7b7d247d,
    0x7ce25b6a, 0x7d641791, 0x7e688e67, 0x7feec29c,
    0x803347a4, 0x81b50b5f, 0x82b992a9, 0x833fde52,
    0x84a0a145, 0x8526edbe, 0x862a7448, 0x87ac38b3,
    0x8892c69d, 0x89148a66, 0x8a181390, 0x8b9e5f6b,
    0x8c01207c, 0x8d876c87, 0x8e8bf571, 0x8f0db98a,
    0x90f6092d, 0x917045d6, 0x927cdc20, 0x93fa90db,
    0x9465efcc, 0x95e3a337, 0x96ef3ac1, 0x9769763a,
    0x98578814, 0x99d1c4ef, 0x9add5d19, 0x9b5b11e2,
    0x9cc46ef5, 0x9d42220e, 0x9e4ebbf8, 0x9fc8f703,
    0xa03f964d, 0xa1b9dab6, 0xa2b54340, 0xa3330fbb,
    0xa4ac70ac, 0xa52a3c57, 0xa626a5a1, 0xa7a0e95a,
    0xa89e1774, 0xa9185b8f, 0xaa14c279, 0xab928e82,
    0xac0df195, 0xad8bbd6e, 0xae872498, 0xaf016863,
    0xb0fad8c4, 0xb17c943f, 0xb2700dc9, 0xb3f64132,
    0xb4693e25, 0xb5ef72de, 0xb6e3eb28, 0xb765a7d3,
    0xb85b59fd, 0xb9dd1506, 0xbad18cf0, 0xbb57c00b,
    0xbcc8bf1c, 0xbd4ef3e7, 0xbe426a11, 0xbfc426ea,
    0xc02ae476, 0xc1aca88d, 0xc2a0317b, 0xc3267d80,
    0xc4b90297, 0xc53f4e6c, 0xc633d79a, 0xc7b59b61,
    0xc88b654f, 0xc90d29b4, 0xca01b042, 0xcb87fcb9,
    0xcc1883ae, 0xcd9ecf55, 0xce9256a3, 0xcf141a58,
    0xd0efaaff, 0xd169e604, 0xd2657ff2, 0xd3e33309,
    0xd47c4c1e, 0xd5fa00e5, 0xd6f69913, 0xd770d5e8,
    0xd84e2bc6, 0xd9c8673d, 0xdac4fecb, 0xdb42b230,
    0xdcddcd27, 0xdd5b81dc, 0xde57182a, 0xdfd154d1,
    0xe026359f, 0xe1a07964, 0xe2ace092, 0xe32aac69,
    0xe4b5d37e, 0xe5339f85, 0xe63f0673, 0xe7b94a88,
    0xe887b4a6, 0xe901f85d, 0xea0d61ab, 0xeb8b2d50,
    0xec145247, 0xed921ebc, 0xee9e874a, 0xef18cbb1,
    0xf0e37b16, 0xf16537ed, 0xf269ae1b, 0xf3efe2e0,
    0xf4709df7, 0xf5f6d10c, 0xf6fa48fa, 0xf77c0401,
    0xf842fa2f, 0xf9c4b6d4, 0xfac82f22, 0xfb4e63d9,
    0xfcd11cce, 0xfd575035, 0xfe5bc9c3, 0xffdd8538,
};

/*
 * This implementation of CRC-24Q (for "Qualcomm") was based on, but not copied
 * from, the program crc24q.c written by by Eric S. Raymond in the gpsd (GPS
 * Daemon) repository at https://github.com/ukyg9e5r6k7gubiekd6/gpsd. Since
 * I completely rewrote it for Tumbleweed, any bugs are strictly mine.
 */
const void * tumbleweed_crc24q(const void * buffer, size_t size, uint8_t * crc_1p, uint8_t * crc_2p, uint8_t * crc_3p)
{
    const void * result = (void *)0;
    const uint8_t * bp = (const uint8_t *)buffer;
    uint16_t length = 0;
    uint32_t crc = 0;
    int ii = 0;

    length = ((uint8_t)(bp[TUMBLEWEED_RTCM_LENGTH_MSB])) << 8;
    length |= ((uint8_t)(bp[TUMBLEWEED_RTCM_LENGTH_LSB]));
    length += TUMBLEWEED_RTCM_SUMMED;

#if 0
    fprintf(stderr, "TUMBLEWEED_CHECKSUM 0x%x 0x%x 0x%x 0x%x 0x%lx\n", bp[TUMBLEWEED_RTCM_LENGTH_MSB], bp[TUMBLEWEED_RTCM_LENGTH_LSB], TUMBLEWEED_RTCM_SUMMED, length, size);
#endif

    if ((length + TUMBLEWEED_RTCM_UNSUMMED) <= size) {

    	for (ii = 0; ii < length; ++ii) {
    		crc = (crc << 8) ^ TUMBLEWEED_CRC24Q[*(bp++) ^ (uint8_t)(crc >> 16)];
    	}

        *crc_1p = (uint8_t)((crc >> (8 * 2)) & 0xff);
        *crc_2p = (uint8_t)((crc >> (8 * 1)) & 0xff);
        *crc_3p = (uint8_t)((crc >> (8 * 0)) & 0xff);

        result = bp;

    }

    return result;
}

ssize_t tumbleweed_length(const void * buffer, size_t size)
{
    ssize_t result = -1;
    uint16_t length = 0;
    const unsigned char * message = (const char *)0;

    message = (const char *)buffer;

    if (size < TUMBLEWEED_RTCM_SHORTEST) {
        /* Do nothing. */
    } else if (message[TUMBLEWEED_RTCM_PREAMBLE] != TUMBLEWEED_STIMULUS_PREAMBLE) {
        /* Do nothing. */
    } else {
        length = message[TUMBLEWEED_RTCM_LENGTH_MSB] << 8;
        length |= message[TUMBLEWEED_RTCM_LENGTH_LSB];
        if (((length & TUMBLEWEED_RTCM_MASK_RESERVED) >> TUMBLEWEED_RTCM_SHIFT_RESERVED) != TUMBLEWEED_STIMULUS_RESERVED) {
        	/* Do nothing. */
        } else if (length > (size - TUMBLEWEED_RTCM_SHORTEST)) {
            /* Do nothing. */
        } else {
            result = length;
            result += TUMBLEWEED_RTCM_SHORTEST;
        }
    }

    return result;
}

int tumbleweed_message(const void * buffer, size_t size)
{
    int result = -1;
    uint16_t number = 0;
    const unsigned char * message = (const char *)0;

    message = (const char *)buffer;

    if (size < (TUMBLEWEED_RTCM_SHORTEST + TUMBLEWEED_RTCM_NUMBER)) {
        /* Do nothing. */
    } else if (message[TUMBLEWEED_RTCM_PREAMBLE] != TUMBLEWEED_STIMULUS_PREAMBLE) {
        /* Do nothing. */
    } else {
        number = message[TUMBLEWEED_RTCM_NUMBER_MSB] << 8;
        number |= message[TUMBLEWEED_RTCM_NUMBER_LSB];
        number >>= TUMBLEWEED_RTCM_SHIFT_NUMBER;
		result = number;
    }

    return result;
}
