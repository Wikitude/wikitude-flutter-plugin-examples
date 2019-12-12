//
//  WikitudePluginResponse.h
//  wikitude_plugin
//
//  Created by Damian Bermejo on 18/04/2019.
//  Copyright (c) 2019 Wikitude. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WikitudePluginResponse : NSObject

+ (NSString*)createJSONStringFromDictionary:(NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END
