//
//  PahoPublisher.m
//  Paho
//
//  Created by Jo on 2023/6/29.
//

#import "PahoPublisher.h"

@implementation PahoPublishedMessage

- (instancetype)init {
    if (self = [super init]) {
        self.qos = PahoQOS1;
    }
    
    return self;
}

- (instancetype)initWithTopic:(NSString *)topic {
    if (self = [self init]) {
        self.topic = topic;
    }
    
    return self;
}

- (instancetype)initWithTopic:(NSString *)topic qos:(PahoQOS)qos {
    if (self = [self initWithTopic:topic]) {
        self.qos = qos;
    }
    
    return self;
}

- (NSString *)description {
    NSString *payload = self.payload != nil && self.payload.count > 0 ? @"[Payload ...]" : @"";
    return [NSString stringWithFormat:@"topic: %@ [%d] %@", self.topic, self.qos, payload];
}

@end
