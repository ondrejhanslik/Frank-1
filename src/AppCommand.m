//
//  AppCommand.m
//  Chase.Mobi
//
//  Created by Pete Hodgson on 10/6/10.
//  Copyright 2010 ThoughtWorks. See NOTICE file for details.
//

#import <Foundation/Foundation.h>
#import "AppCommand.h"

#import "Operation.h"
#import "ViewJSONSerializer.h"
#import "FranklyProtocolHelper.h"
#import "JSON.h"

@implementation AppCommand

- (NSString *)handleCommandWithRequestBody:(NSString *)requestBody {
	
	NSDictionary *requestCommand = FROM_JSON(requestBody);
	NSDictionary *operationDict = [requestCommand objectForKey:@"operation"];
	Operation *operation = [[[Operation alloc] initFromJsonRepresentation:operationDict] autorelease];
	
#if TARGET_OS_IPHONE
    UIApplication* application = [UIApplication sharedApplication];
#else
    NSApplication* application = [NSApplication sharedApplication];
#endif
	
	if( ![operation appliesToObject:application] )
	{
		return [FranklyProtocolHelper generateErrorResponseWithReason:@"operation doesn't apply" andDetails:@"operation does not appear to be implemented in application"];
	}
	
	id result;
	
	@try {
		result = [operation applyToObject:application];
	}
	@catch (NSException *e) {
		NSLog( @"Exception while applying operation to application:\n%@", e );
		return [FranklyProtocolHelper generateErrorResponseWithReason:@"exception while executing operation" andDetails:[e reason]];
	}
	
    NSMutableArray *results = [NSMutableArray new];
	[results addObject:[ViewJSONSerializer jsonify:result]];
	
	return [FranklyProtocolHelper generateSuccessResponseWithResults: results];
}

@end
