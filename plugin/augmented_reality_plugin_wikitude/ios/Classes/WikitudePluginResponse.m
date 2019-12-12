//
//  WikitudePluginResponse.m
//  wikitude_plugin
//
//  Created by Damian Bermejo on 18/04/2019.
//  Copyright (c) 2019 Wikitude. All rights reserved.
//

#import "WikitudePluginResponse.h"

@implementation WikitudePluginResponse

+ (NSString*)createJSONStringFromDictionary:(NSDictionary*)dictionary
{
    NSError *serializationError;
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&serializationError];
    NSString* JSONString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

    return JSONString;
}

@end
