//
//  NxUtilsTestBase.m
//  NuxeoBasicApp
//
//  Created by Thibaud on 1/5/14.
//  Copyright (c) 2014 ThibArg. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "nxuPaginatedDocuments.h"

NSString* const kTEST_SERVER_URL_LOCAL = @"http://localhost:8080/nuxeo";
NSString* const kTEST_SERVER_URL_DEMO = @"http://demo.nuxeo.com/nuxeo";
NSString* const kTEST_LOGIN = @"Administrator";
NSString* const kTEST_PASSWORD = @"Administrator";

NSString* const kKEY_pageSize = @"pageSize";

@interface NxUtilsTestBase : XCTestCase

@end

@implementation NxUtilsTestBase

- (void)setUp
{
    [super setUp];
	
	self.continueAfterFailure = NO;
	NSLog(@"Start of tests..............................");

}

- (void)tearDown
{
    [super tearDown];
	NSLog(@"..............................End of tests");
}

- (NUXSession *) createATestSession
{
	NSURL *url = [[NSURL alloc] initWithString: kTEST_SERVER_URL_LOCAL];
	NUXSession *session = [[NUXSession alloc] initWithServerURL:url
													   username:kTEST_LOGIN
													   password:kTEST_PASSWORD];
	[session addDefaultSchemas:@[@"dublincore"]];
	
	return session;
}

@end
