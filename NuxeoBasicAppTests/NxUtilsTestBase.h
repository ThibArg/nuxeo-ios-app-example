//
//  NxUtilsTestBase.h
//  NuxeoBasicApp
//
//  Created by Thibaud on 1/5/14.
//  Copyright (c) 2014 ThibArg. All rights reserved.
//
/*	2014-01-05
	Either I misunderstood something completely, or there is a bug
	in the test framework. Basically, doing the test in other classes
	does not work as I want:
		-> the test is ran, for each test* method
		-> But, the final result is always a "Test Failed" message
			(notificaiton center, this is my Test behavior setting)
		-> While the tests are marked as succesfull
	Some googling on the internet seems to confirm other people have
	the same problem and blame XCode
		-> Maybe even worht, NSLog() does not work either

	One thing that seem to work, is to run the test from here. So maybe
	it must be run from a class which has the name of the project or
	whatever. or maybe I'm suppose to add some setting or declaration
	but I did not find where, and I want to test, so:
		-> Let's go with putting everything here (I don't have that
		   much after all)
		-> With this explanation
 */
#define TEST_PSEUDO_FAILURE_POOR_WORKAROUND [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];

#define TEST_PSEUDO_FAILURE_POOR_WORKAROUND_INTERVAL( _the_interval_)  [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:_the_interval_]];


#import <XCTest/XCTest.h>
#import "NUXSession+requests.h"

extern NSString* const kTEST_SERVER_URL_LOCAL;
extern NSString* const kTEST_SERVER_URL_DEMO;
extern NSString* const kTEST_LOGIN;
extern NSString* const kTEST_PASSWORD;

extern NSString* const kKEY_pageSize;

@interface NxUtilsTestBase : XCTestCase

- (NUXSession *) createATestSession;

@end