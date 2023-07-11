//
//  PahoResponse.m
//  Paho
//
//  Created by Jo on 2023/6/29.
//

#import "PahoResponse.h"
#import "PahoResponse+Private.h"
#import "PahoProperties+Private.h"
#import "PahoHelper.h"

@interface PahoResponseMessage()

@property (nonatomic, assign, readwrite) PahoAction action;
@property (nonatomic, assign, readwrite) NSInteger token;
@property (nonatomic, assign, readwrite) PahoReasonCode reasonCode;
@property (nonatomic, strong, readwrite) PahoProperties *properties;

@end

@implementation PahoResponseMessage

@end

#pragma mark -

@implementation PahoSuccessedMessage

- (instancetype)initWithMessage5:(MQTTAsync_successData5 *)msg action:(PahoAction)action {
    if (self = [super init]) {
        self.action = action;
        self.token = msg->token;
        self.reasonCode = PahoReasonCodeFromMQTTResonCode(msg -> reasonCode);
        self.properties = [[PahoProperties alloc] initWithProperties:msg->properties];
    }
    
    return self;
}

@end

#pragma mark -

@interface PahoFailedMessage()

@property (nonatomic, assign, readwrite) NSInteger code;
@property (nonatomic, copy, readwrite, nullable) NSString *message;
@property (nonatomic, assign, readwrite) NSInteger packetType;

@end

@implementation PahoFailedMessage

- (instancetype)initWithMessage5:(MQTTAsync_failureData5 *)msg action:(PahoAction)action {
    if (self = [super init]) {
        self.action = action;
        self.token = msg->token;
        self.reasonCode = PahoReasonCodeFromMQTTResonCode(msg -> reasonCode);
        self.properties = [[PahoProperties alloc] initWithProperties:msg->properties];
        
        self.code = msg->code;
        self.packetType = msg->packet_type;
        
        if (msg->message != NULL) {
            self.message = [NSString stringWithUTF8String:msg->message];
        }
    }
    
    return self;
}

@end
