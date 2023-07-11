//
//  PahoTopic.h
//  Paho
//
//  Created by Jo on 2023/6/29.
//

#import <Foundation/Foundation.h>
#import "PahoConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface PahoTopic : NSObject

@property (nonatomic, copy) NSString *topic;
@property (nonatomic, assign) PahoQOS qos;

- (instancetype)initWithTopic:(NSString *)topic qos:(PahoQOS)qos;

@end

NS_ASSUME_NONNULL_END
