//
//  PahoClient.h
//  Paho
//
//  Created by Jo on 2023/6/27.
//

#import <Foundation/Foundation.h>
#import "PahoMessages.h"
#import "PahoTopic.h"
#import "PahoPublisher.h"
#import "PahoResponse.h"
#import "PahoProperties.h"
#import "PahoSSLOptions.h"

NS_ASSUME_NONNULL_BEGIN

@class PahoClient;

@protocol PahoClientDelegate <NSObject>

- (void)pahoClientDidConnected:(PahoClient *)client
                         cause:(nullable NSString *)cause;

- (void)pahoClientDidDisconnected:(PahoClient *)client
                            cause:(nullable NSString *)cause;

- (BOOL)pahoClient:(PahoClient *)client
 didReceiveMessage:(PahoMessage *)message
           onTopic:(NSString *)topic;

- (void)pahoClient:(PahoClient *)client
          onAction:(PahoAction)action
           success:(nullable PahoSuccessedMessage *)succesedMsg
            failed:(nullable PahoFailedMessage *)failedMsg;

@end

@interface PahoClient : NSObject

- (instancetype)initWithClientID:(NSString *)clientID;

@property (nonatomic, weak) id<PahoClientDelegate> delegate;
@property (nonatomic, copy, readonly) NSString *clientID;

@property (nonatomic, assign) int keepAliveInterval;
@property (nonatomic, assign) BOOL cleanSession;
@property (nonatomic, assign) int maxInflight;
@property (nonatomic, strong, nullable) id will; /// MQTTAsync_willOptions
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) int connectTimeout;
@property (nonatomic, assign) int retryInterval;
@property (nonatomic, strong) PahoSSLOptions *ssl;
@property (nonatomic, strong, nullable) NSArray <NSString *> *serverURIs;
@property (nonatomic, assign) BOOL automaticReconnect;
@property (nonatomic, assign) int minRetryInterval;
@property (nonatomic, assign) int maxRetryInterval;
@property (nonatomic, assign) int cleanstart;
@property (nonatomic, strong, nullable) PahoProperties *connectProperties;
@property (nonatomic, strong, nullable) PahoProperties *willProperties;
/// http headers
/// http proxy
/// https proxy

@property (nonatomic, copy) NSString *hostAndPort;

- (PahoReturnCode)connectWithUsername:(NSString *)username password:(NSString *)password;
- (PahoReturnCode)subscribe:(NSString *)topic qos:(PahoQOS)qos;
- (PahoReturnCode)subscribe:(NSArray <PahoTopic *> *)topics;
- (PahoReturnCode)unsubscribeTopic:(NSString *)topic;
- (PahoReturnCode)unsubscribeTopics:(NSArray <NSString *> *)topics;
- (PahoReturnCode)publish:(PahoPublishedMessage *)message properties:(PahoProperties *)properties token:(int *)token;
- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
