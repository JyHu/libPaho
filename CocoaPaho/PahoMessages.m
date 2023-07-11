//
//  PahoMessages.m
//  Paho
//
//  Created by Jo on 2023/6/28.
//

#import "PahoMessages.h"
#import "PahoMessages+Private.h"
#import "PahoProperties+Private.h"
#import "PahoHelper.h"
#include "MQTTAsync.h"

#pragma mark -

@interface PahoMessage()

@property (nonatomic, strong, readwrite) NSData *payload;
@property (nonatomic, assign, readwrite) PahoQOS qos;
@property (nonatomic, assign, readwrite) BOOL retained;
@property (nonatomic, assign, readwrite) BOOL dup;
@property (nonatomic, assign, readwrite) NSInteger msgid;
@property (nonatomic, strong, readwrite, nullable) PahoProperties *properties;

@end

@implementation PahoMessage

- (instancetype)initWithMessage:(MQTTAsync_message *)msg {
    if (self = [super init]) {
        if (msg->payloadlen > 0) {        
            self.payload = [NSData dataWithBytes:msg->payload length:msg->payloadlen];
        }
        
        self.qos = msg->qos;
        self.retained = msg->retained == 1;
        self.dup = msg->retained == 1;
        self.msgid = msg->msgid;
        
        if (msg->properties.count > 0) {
            self.properties = [[PahoProperties alloc] initWithProperties:msg->properties];
        }
        
        NSLog(@"%@", self);
    }
    
    return self;
}

- (NSString *)description {
    NSMutableArray *logs = [[NSMutableArray alloc] init];
    [logs addObject:@"\n [PahoMessage]"];
    [logs addObject:[NSString stringWithFormat:@"\t|- QOS: %d", self.qos]];
    [logs addObject:[NSString stringWithFormat:@"\t|- Retained: %@", self.retained ? @"true" : @"false"]];
    [logs addObject:[NSString stringWithFormat:@"\t|- Dup: %@", self.dup ? @"true" : @"false"]];
    [logs addObject:[NSString stringWithFormat:@"\t|- Message ID: %ld", self.msgid]];
    
    if (self.payload && self.payload.length > 0) {
        [logs addObject:[NSString stringWithFormat:@"\t|- Payload: %@", self.payload]];
    }
    
    if (self.properties) {
        [logs addObject:@"\t|- Properties"];
        if (self.properties.responseTopic) {
            [logs addObject:[NSString stringWithFormat:@"\t|\t|- Response Topic: %@", self.properties.responseTopic]];
        }
        
        if (self.properties.correlation) {
            [logs addObject:[NSString stringWithFormat:@"\t|\t|- Correlation: %@", self.properties.correlation]];
        }
        
        if (self.properties.userProperties) {
            [logs addObject:@"\t|\t|- User Properties"];
            
            for (NSString *key in self.properties.userProperties) {
                NSString *value = [self.properties.userProperties objectForKey:key];
                [logs addObject:[NSString stringWithFormat:@"\t|\t|\t|- %@: %@", key, value]];
            }
        }
    }
    
    return [logs componentsJoinedByString:@"\n"];
}

@end
