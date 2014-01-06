//
//  nxuPaginatedDocumentsTests.m
//  NuxeoBasicApp
//
//  Created by Thibaud on 1/5/14.
//  Copyright (c) 2014 ThibArg. All rights reserved.
//
/*	About asynch testing

	XCTest is not ready for async. testing. But all our requests are
	done synchronously. So, we are (again) using a poor-man mechanism
	to handle that:
		-> A variable is set to YES when a request starts
		-> The cpde then wait until is reset to NO
		-> The callbacks rest is to NO
	(plus the misc. use of TEST_PSEUDO_FAILURE_POOR_WORKAROUND, see NxUtilsTestBase)
*/
/*	==================================================
	* * * * * * * * * * IMPORTANT * * * * * * * * * *
	==================================================
	Please change kDEFAULT_QUERY to feet your needs. It expects
	a specific path to search and will fail if this path can't be found.
	Also change the other (kFIRST_DOC... and kLAST_DOC...)
*/
NSString* const kDEFAULT_QUERY = @"SELECT * FROM Document WHERE ecm:path STARTSWITH '/default-domain/workspaces/ws/LotOfDocs' ORDER BY dc:title";
NSString* const kFIRST_DOC_TITLE = @"File-1";
NSString* const kLAST_DOC_TITLE = @"File-99";

#import <XCTest/XCTest.h>

#import "NUXDocument.h"
#import "NxUtilsTestBase.h"
#import "nxuPaginatedDocuments.h"

static const NSInteger kPAGE_SIZE = 25;
static NSString* const kPAGE_SIZE_STR = @"25";

@interface nxuPaginatedDocumentsTests : NxUtilsTestBase <nxuPaginatedDocuments> {
	BOOL	_waitingForAsync;
	
	nxuPaginatedDocuments* _paginatedDocs;
	
	BOOL		_shouldBeFirstPage;
	BOOL		_shouldBeLastPage;
}
@end

@implementation nxuPaginatedDocumentsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
	_waitingForAsync = NO;
	
	NSLog(@"__________<nxuPaginatedDocumentsTests>__________");
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
	NSLog(@"__________</nxuPaginatedDocumentsTests>__________");

    [super tearDown];
}

- (void) waitForCompletion
{
	while(_waitingForAsync) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
}

// ==================================================
#pragma mark - nxuPaginatedDocuments protocol
// ==================================================
- (void) paginatedDocumentsSucceeded: (NSArray *) entities
{
	XCTAssertNotNil(entities, @"After call to goToPage, received entities should not be nil");
	XCTAssert(entities.count > 0, @"Should have some documents found");
	XCTAssert([_paginatedDocs pageSize] == kPAGE_SIZE, @"Page size should be %d", kPAGE_SIZE);
	if(!_shouldBeLastPage) {
		XCTAssert( [_paginatedDocs hasMoreData], @"There should me more page(s) avilable" );
	} else {
		XCTAssert( ![_paginatedDocs hasMoreData], @"There should not be any more page(s) avilable" );
	}
	
	NUXDocument* aDoc;
	
	if(_shouldBeFirstPage) {
		aDoc = entities[0];
		XCTAssert( [_paginatedDocs isFirstDocument:aDoc], @"isFirstDocument failed");
		XCTAssert( [_paginatedDocs isFirstDocumentOfPage:aDoc], @"isFirstDocumentOfPage");
		
		XCTAssertEqualObjects(aDoc.title, kFIRST_DOC_TITLE, @"First doc title should be <%@>, but is <%@>", kFIRST_DOC_TITLE, aDoc.title ? kFIRST_DOC_TITLE : @"nil");
	}
	
	if(_shouldBeLastPage) {
		// Carefulis the last page contains only one doc
		if(entities.count > 0) {
			aDoc = entities[ entities.count - 1 ];
		} else {
			aDoc = entities[ 0 ];
		}
		XCTAssert( [_paginatedDocs isLastDocument:aDoc], @"isLastDocument failed");
		XCTAssert( [_paginatedDocs isLastDocumentOfPage:aDoc], @"isLastDocumentOfPage");
		XCTAssertEqualObjects(aDoc.title, kLAST_DOC_TITLE, @"Last doc title should be <%@>, but is <%@>", kFIRST_DOC_TITLE, aDoc.title ? kLAST_DOC_TITLE : @"nil");
	}
	
	_waitingForAsync = NO;
}

- (void) paginatedDocumentsFailed: (nxuPaginatedDocumentsError *) error
{
	XCTFail(@"Request failed because of:\r- Status code: %ld\r- Message: %@\r- Error: %@",
			(long)error.requestStatusCode,
			error.requestMessage,
			error.error);
	
	_waitingForAsync = NO;
}

// ==================================================
#pragma mark - Tests
// ==================================================
- (void) test_Navigate
{
	NUXSession *session = [self createATestSession];
	// Not really testing nxuPaginatedDocuments here, but NUXSession
	XCTAssertNotNil(session, @"_session should be instanciated during setup");
	
	NUXRequest *request = [session requestQuery: kDEFAULT_QUERY];
	// Not really testing nxuPaginatedDocuments here, but NUXRequest
	XCTAssertNotNil(request, @"NUXSession:requestQuery should not fail");
	
	[request addParameterValue:[NSString stringWithFormat:@"%d", kPAGE_SIZE] forKey:kKEY_pageSize];
	// Not really testing nxuPaginatedDocuments here, but NUXRequest
	XCTAssertEqualObjects(kPAGE_SIZE_STR, request.parameters[kKEY_pageSize], @"Page size should be %d", kPAGE_SIZE);
	
	_paginatedDocs = [nxuPaginatedDocuments paginatedDocumentsWithRequest:request
															  andDelegate:self];
	_paginatedDocs.reloadOnSamePage = YES;
	
	TEST_PSEUDO_FAILURE_POOR_WORKAROUND
	
	// Navigate
	[self goToFirstPage];
	[self goToNextPage];
	[self goToLastPage];
	
	TEST_PSEUDO_FAILURE_POOR_WORKAROUND
}

- (void) goToFirstPage
{
	_waitingForAsync = YES;
	_shouldBeFirstPage = YES;
	_shouldBeLastPage = NO;
	
	[_paginatedDocs goToPage:0];
	
	[self waitForCompletion];
	
	TEST_PSEUDO_FAILURE_POOR_WORKAROUND
}

- (void) goToNextPage
{
	_waitingForAsync = YES;
	_shouldBeFirstPage = NO;
	_shouldBeLastPage = NO;// It could, but we don't test
	
	[_paginatedDocs goToNextPage];
	
	[self waitForCompletion];
	TEST_PSEUDO_FAILURE_POOR_WORKAROUND
}

- (void) goToLastPage
{
	_waitingForAsync = YES;
	_shouldBeFirstPage = NO;
	_shouldBeLastPage = YES;
	
	[_paginatedDocs goToLastPage];
	
	[self waitForCompletion];
	TEST_PSEUDO_FAILURE_POOR_WORKAROUND
}



@end
