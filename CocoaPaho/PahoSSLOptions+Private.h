//
//  PahoSSLOptions+Private.h
//  TestPahoC
//
//  Created by Jo on 2023/7/1.
//

#import "PahoSSLOptions.h"
#include "MQTTAsync.h"

NS_ASSUME_NONNULL_BEGIN

@interface PahoSSLOptions ()

- (MQTTAsync_SSLOptions)sslOptions;

@end

NS_ASSUME_NONNULL_END
