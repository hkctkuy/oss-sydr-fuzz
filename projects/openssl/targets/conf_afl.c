/*
 * Copyright 2016 The OpenSSL Project Authors. All Rights Reserved.
 * Modifications copyright (C) 2022 ISP RAS
 *
 * Licensed under the Apache License 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * https://www.openssl.org/source/license.html
 * or in the file LICENSE in the source distribution.
 */

/*
 * Test configuration parsing.
 */

#include <openssl/conf.h>
#include <openssl/err.h>
#include <unistd.h>
#include <string.h>
#include <stdint.h>
#include "fuzzer.h"

__AFL_FUZZ_INIT();

int FuzzerInitialize(int *argc, char ***argv)
{
    OPENSSL_init_crypto(OPENSSL_INIT_LOAD_CRYPTO_STRINGS, NULL);
    ERR_clear_error();
    return 1;
}

int FuzzerTestOneInput(const uint8_t *buf, size_t len)
{
    CONF *conf;
    BIO *in;
    long eline;

    if (len == 0)
        return 0;

    conf = NCONF_new(NULL);
    in = BIO_new(BIO_s_mem());
    OPENSSL_assert((size_t)BIO_write(in, buf, len) == len);
    NCONF_load_bio(conf, in, &eline);
    NCONF_free(conf);
    BIO_free(in);
    ERR_clear_error();

    return 0;
}

void FuzzerCleanup(void)
{
}

int
main(int argc, char **argv)
{
    FuzzerInitialize(&argc, &argv);

#ifdef __AFL_HAVE_MANUAL_CONTROL
    __AFL_INIT();
#endif

    uint8_t *data = __AFL_FUZZ_TESTCASE_BUF;

    while (__AFL_LOOP(1000))
    {
        size_t size = __AFL_FUZZ_TESTCASE_LEN;

        FuzzerTestOneInput(data, size);
    }

    FuzzerCleanup();

    return 0;
}
