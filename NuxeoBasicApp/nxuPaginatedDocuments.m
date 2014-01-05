//
//  nxuPaginatedDocuments.m
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/31/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//

#import "nxuPaginatedDocuments.h"

// ==================================================
#pragma mark - nxuPaginatedDocumentsError
// ==================================================
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


// ==================================================
#pragma mark - nxuPaginatedDocuments
// ==================================================
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
+ (nxuPaginatedDocuments *) paginatedDocumentsWithRequest: (NUXRequest *) request
											  andDelegate: (id <nxuPaginatedDocuments>) theDelegate
{
	nxuPaginatedDocuments *paginatedDocs;
	
	paginatedDocs = [nxuPaginatedDocuments alloc];
	
	if(paginatedDocs) {
		paginatedDocs = [paginatedDocs initWithRequest:request
										   andDelegate:theDelegate];
	}
	return paginatedDocs;
}

// init should not be called
- (id) init
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class nxuPaginatedDocuments"
                                 userInfo:nil];
	// Caller will crash. We expect that ;->
	return nil;
}

// Private init, not exposed in the header
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
	if(newDelegate != _delegate) {
		_delegate = newDelegate;
	}
}

- (BOOL) isFirstDocumentOfPage: (NUXDocument *) doc
{
	return	doc && _docs && _docs.entries
			&& [_docs.entries indexOfObject:doc] == 0;
}

- (BOOL) isLastDocumentOfPage: (NUXDocument *) doc
{
	return	doc && _docs && _docs.entries
			&& [_docs.entries indexOfObject:doc] == [_docs.entries count] - 1;
}

- (BOOL) isFirstDocument: (NUXDocument *) doc
{
	return	doc && _docs && _docs.entries
			&& _docs.currentPageIndex == 0
			&& [_docs.entries indexOfObject:doc] == 0;
}

- (BOOL) isLastDocument: (NUXDocument *) doc
{
	NSLog(@"%ld - %ld", (long) _docs.currentPageIndex, (long) _docs.numberOfPages );
	return	doc && _docs && _docs.entries
			&& _docs.currentPageIndex == _docs.numberOfPages - 1
			&& [_docs.entries indexOfObject:doc] == [_docs.entries count] - 1;;
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