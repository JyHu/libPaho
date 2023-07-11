//
//  PahoSSLOptions.m
//  TestPahoC
//
//  Created by Jo on 2023/7/1.
//

#if PAHOC_ENABLE_SSL_CONNECTION

#import "PahoSSLOptions.h"
#import "PahoSSLOptions+Private.h"
#include "MQTTAsync.h"

@implementation PahoSSLOptions {
    MQTTAsync_SSLOptions sslOpts;
}

- (instancetype)init {
    if (self = [super init]) {
        MQTTAsync_SSLOptions opts = MQTTAsync_SSLOptions_initializer;
        self->sslOpts = opts;
    }
    return self;
}

#define SSL_STRING_OPTION(key)              \
    if (key == nil) {                       \
        self->sslOpts.key = NULL;           \
    } else {                                \
        self->sslOpts.key = key.UTF8String; \
    }                                       \
    _##key = key;

- (void)setStructVersion:(int)structVersion {
    self->sslOpts.struct_version = structVersion;
}

- (int)structVersion {
    return self->sslOpts.struct_version;
}

- (void)setTrustStore:(NSString *)trustStore {
    SSL_STRING_OPTION(trustStore)
}

- (void)setKeyStore:(NSString *)keyStore {
    SSL_STRING_OPTION(keyStore)
}

- (void)setPrivateKey:(NSString *)privateKey {
    SSL_STRING_OPTION(privateKey)
}

- (void)setPrivateKeyPassword:(NSString *)privateKeyPassword {
    SSL_STRING_OPTION(privateKeyPassword)
}

- (void)setEnabledCipherSuites:(NSString *)enabledCipherSuites {
    SSL_STRING_OPTION(enabledCipherSuites)
}

- (void)setEnableServerCertAuth:(BOOL)enableServerCertAuth {
    self->sslOpts.enableServerCertAuth = enableServerCertAuth ? 1 : 0;
}

- (BOOL)enableServerCertAuth {
    return self->sslOpts.enableServerCertAuth == 1;
}

- (void)setSslVersion:(PahoSSLVersion)sslVersion {
    self->sslOpts.sslVersion = sslVersion;
}

- (PahoSSLVersion)sslVersion {
    return self->sslOpts.sslVersion;
}

- (void)setVerify:(BOOL)verify {
    self->sslOpts.verify = verify ? 1 : 0;
}

- (BOOL)verify {
    return self->sslOpts.verify == 1;
}

- (void)setCApath:(NSString *)CApath {
    SSL_STRING_OPTION(CApath)
}

- (void)setDisableDefaultTrustStore:(BOOL)disableDefaultTrustStore {
    self->sslOpts.disableDefaultTrustStore = disableDefaultTrustStore ? 1 : 0;
}

- (BOOL)disableDefaultTrustStore {
    return self->sslOpts.disableDefaultTrustStore == 1;
}

- (void)setSslErrorCallback:(PahoSSLErrorCallback)sslErrorCallback {
    if (sslErrorCallback == nil) {
        self->sslOpts.ssl_error_cb = NULL;
        self->sslOpts.ssl_error_context = NULL;
    } else {
        self->sslOpts.ssl_error_cb = &sslErrorCb;
        self->sslOpts.ssl_error_context = (__bridge void *)(self);
        _sslErrorCallback = sslErrorCallback;
    }
}

- (void)setSslPSKCallback:(PahoSSLPSKCallback)sslPSKCallback {
    if (sslPSKCallback == nil) {
        self->sslOpts.ssl_psk_cb = NULL;
        self->sslOpts.ssl_psk_context = NULL;
    } else {
        self->sslOpts.ssl_psk_cb = &sslPSKCb;
        self->sslOpts.ssl_psk_context = (__bridge void *)(self);
        _sslPSKCallback = sslPSKCallback;
    }
}

- (MQTTAsync_SSLOptions)sslOptions {
    return self -> sslOpts;
}

#pragma mark - c mthods

int sslErrorCb(const char *str, size_t len, void *u) {
    PahoSSLOptions *options = (__bridge PahoSSLOptions *)u;
    if (options == nil || options.sslErrorCallback == nil ) { return 0; }
    if (str == NULL) {
        return options.sslErrorCallback(nil);
    }
    
    return options.sslErrorCallback([NSString stringWithUTF8String:str]);
}

unsigned int sslPSKCb(const char *hint, char *identity, unsigned int max_identity_len, unsigned char *psk, unsigned int max_psk_len, void *u) {
    PahoSSLOptions *options = (__bridge PahoSSLOptions *)u;
    if (options == nil || options.sslPSKCallback == nil ) { return 0; }
    return options.sslPSKCallback(hint, identity, max_psk_len, psk, max_psk_len);
}

@end

#undef SSL_STRING_OPTION

#endif
