//
//  nxuPaginatedDocuments.m
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/31/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//

#import "nxuPaginatedDocuments.h"

#import "NUXDocuments.h"
#import "NUXSession.h"
#import "NUXRequest.h"
#import "NUXSession+requests.h"

@implementation nxuPaginatedDocumentsError

+ (nxuPaginatedDocumentsError *) errorWithRequestStatus: (NSInteger) status
										 requestMessage: (NSString *) message
											   andError: (NSError *) error
{
	nxuPaginatedDocumentsError *err = [nxuPaginatedDocumentsError new];
	err.requestStatusCode = status;
	err.requestMessage = message;
	err.error = error;
	
	return err;
}

@end

@interface nxuPaginatedDocuments () {
	NUXRequest*		_request;
	NUXDocuments*	_docs;
	
	id <nxuPaginatedDocuments> _delegate;
	
	NSLock*			_lock;
}
@end

@implementation nxuPaginatedDocuments

// ==================================================
#pragma mark - query
// ==================================================
- (void) performRequest
{
	if(_request) {
		NSString *s = _request.parameters[@"currentPageIndex"];
		NSLog(@"currentPageIndex: %@", s);
	}
	
	// ----------------------------------------
	if(![_lock tryLock]) {
	// ----------------------------------------
		NSError *error = [NSError errorWithDomain:kPaginatedDocumentsErrorDomain
											 code:kERR_isBusy
										 userInfo:@{NSLocalizedDescriptionKey: @"Cannot perform request",
													NSLocalizedFailureReasonErrorKey: @"A request is already running"}];
		
		[_delegate paginatedDocumentsFailed:
					 [nxuPaginatedDocumentsError errorWithRequestStatus: 0
														 requestMessage: @""
															   andError: error] ];
	// ----------------------------------------
	} else {
	// ----------------------------------------
		if(!_request || !_delegate) {
			NSString *reason;
			if(!_request) {
				reason = @"request";
			} else {
				reason = @"delegate";
			}
			
			[_lock unlock];
			@throw [NSException exceptionWithName: NSInvalidArgumentException
										   reason: [NSString stringWithFormat:@"'%@' is nil", reason]
										 userInfo: nil];
		}
				
		// ================================= handleCompletion
		void (^handleCompletion)(NUXRequest *) = ^(NUXRequest *inRequest) {
			NSError *error;
			
			_docs = [inRequest responseEntityWithError:&error];
			if(error) {
				[_delegate paginatedDocumentsFailed:
							 [nxuPaginatedDocumentsError errorWithRequestStatus: 0
																 requestMessage: @""
																	   andError: error] ];
			} else {
				[_delegate paginatedDocumentsSucceeded: _docs.entries];
			}
			
			[_lock unlock];
		};
		
		// ================================= handleFailure
		void (^handleFailure)(NUXRequest *) = ^(NUXRequest *inRequest) {
			[_delegate paginatedDocumentsFailed:
						 [nxuPaginatedDocumentsError errorWithRequestStatus: [inRequest responseStatusCode]
															 requestMessage: [inRequest responseString]
																   andError: nil] ];
			[_lock unlock];
		};
		
		[_request setCompletionBlock:handleCompletion];
		[_request setFailureBlock:handleFailure];
		[_request start];
	}
}

// ==================================================
#pragma mark - init/dealloc
// ==================================================
// init should not be called
- (id) init
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class nxuPaginatedDocuments"
                                 userInfo:nil];
	// Caller will crash. We expect that ;->
	return nil;
}

- (id) initWithRequest: (NUXRequest *) request
		   andDelegate: (id) theDelegate
{
	self = [super init];
	
	if(self) {
		_reloadOnSamePage = YES;
		_docs = nil;
		
		_request = request;
		_delegate = theDelegate;
		
		_lock = [NSLock new];
	}
	
	return self;
}

- (void) dealloc
{
	_docs = nil;
	_request = nil;
	_delegate = nil;
	_lock = nil;
}


// ==================================================
#pragma mark - getters/setters
// ==================================================
- (BOOL) hasMoreData
{
	return _docs && _docs.currentPageIndex < (_docs.numberOfPages - 1);
}

- (void) setDelegate: (id <nxuPaginatedDocuments>) newDelegate
{
	_delegate = newDelegate;
}

// ==================================================
#pragma mark - Navigation
// ==================================================
- (void) goToPage: (NSInteger) pageNum
{
	// _docs will be nil at the first call, we must check that
	if(_docs && !_reloadOnSamePage && pageNum == _docs.currentPageIndex) {
		// do nothing
	} else {
		[_request addParameterValue:[NSString stringWithFormat:@"%ld", (long)pageNum]
							 forKey:@"currentPageIndex"];
		[self performRequest];
	}
}

- (void) goToPreviousPage
{
	[self goToPage: _docs.currentPageIndex - 1];
}

- (void) goToNextPage
{
	[self goToPage: _docs.currentPageIndex + 1];
}

- (void) goToLastPage
{
	[self goToPage:_docs.numberOfPages - 1];
}

- (void) goToFirstPage
{
	[self goToPage: 0];
}

@end

// --EOF--