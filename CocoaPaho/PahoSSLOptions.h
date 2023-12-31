//
//  PahoSSLOptions.h
//  TestPahoC
//
//  Created by Jo on 2023/7/1.
//

#import <Foundation/Foundation.h>
#import "PahoConstants.h"

NS_ASSUME_NONNULL_BEGIN

typedef int (^PahoSSLErrorCallback)( NSString * _Nullable errorInfo);

typedef unsigned int (^PahoSSLPSKCallback)(
    const char *hint,
    char *identity,
    unsigned int max_identity_len,
    unsigned char *psk,
    unsigned int max_psk_len
);

@interface PahoSSLOptions : NSObject

@property (nonatomic, assign) int structVersion;
/// p12文件的本地路径
@property (nonatomic, copy, nullable) NSString *trustStore;
@property (nonatomic, copy, nullable) NSString *keyStore;
@property (nonatomic, copy, nullable) NSString *privateKey;
@property (nonatomic, copy, nullable) NSString *privateKeyPassword;
@property (nonatomic, copy, nullable) NSString *enabledCipherSuites;
/// 是否开启ssl验证
@property (nonatomic, assign) BOOL enableServerCertAuth;
@property (nonatomic, assign) PahoSSLVersion sslVersion;
@property (nonatomic, assign) BOOL verify;
@property (nonatomic, copy, nullable) NSString *CApath;

/// 是否禁止从默认路径查找证书
@property (nonatomic, assign) BOOL disableDefaultTrustStore;
@property (nonatomic, copy, nullable) PahoSSLErrorCallback sslErrorCallback;
@property (nonatomic, copy, nullable) PahoSSLPSKCallback sslPSKCallback;

@end

NS_ASSUME_NONNULL_END

