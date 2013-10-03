//
//  FrankCommandRoute.h
//  Frank
//
//  Created by phodgson on 5/30/10.
//  Copyright 2010 ThoughtWorks. See NOTICE file for details.
//

#import <Foundation/Foundation.h>

#import "RequestRouter.h"

@protocol FrankCommand <NSObject>

@required
- (NSString *)handleCommandWithRequestBody:(NSString *)requestBody;

@optional
- (NSString *)handleCommand:(NSArray*)command withRequestBody:(NSString *)requestBody;

@end


@interface FrankCommandRoute : NSObject<Route> {
	NSMutableDictionary *_commandDict;
}

+ (FrankCommandRoute *) singleton;

-(void) registerCommand: (id<FrankCommand>)command withName:(NSString *)commandName;

@end
