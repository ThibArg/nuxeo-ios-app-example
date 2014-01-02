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
	
	nxuPaginatedDocumentsSuccessBlock _successBlock;
	nxuPaginatedDocumentsErrorBlock _errorBlock;
	
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
		
		if(_errorBlock) {
			_errorBlock( [nxuPaginatedDocumentsError errorWithRequestStatus:0
															 requestMessage:@""
																   andError:error] );
		} else {
			// Just nothing will happen. We don't want to
			// raise an exception. Let just log the problem
			NSLog(@"%@", error);
		}
	// ----------------------------------------
	} else {
	// ----------------------------------------
		if(!_request || !_successBlock || !_errorBlock) {
			NSString *reason;
			if(!_request) {
				reason = @"request";
			} else if (!_successBlock) {
				reason = @"successBlock";
			} else {
				reason = @"errorBlock";
			}
			
			[_lock unlock];
			@throw [NSException exceptionWithName: NSInvalidArgumentException
										   reason: [NSString stringWithFormat:@"'%@' is nil", reason]
										 userInfo: nil];
		}
				
		// ================================= handleResult
		void (^handleResult)(NUXRequest *) = ^(NUXRequest *inRequest) {
			NSError *error;
			
			_docs = [inRequest responseEntityWithError:&error];
			if(error) {
				_errorBlock( [nxuPaginatedDocumentsError errorWithRequestStatus:0
																 requestMessage:@""
																	   andError:error] );
			} else {
				_successBlock(_docs.entries);
			}
			
			[_lock unlock];
		};
		
		// ================================= handleFailure
		void (^handleFailure)(NUXRequest *) = ^(NUXRequest *inRequest) {
			_errorBlock( [nxuPaginatedDocumentsError errorWithRequestStatus:[inRequest responseStatusCode]
															 requestMessage:[inRequest responseString]
																   andError:nil] );
			[_lock unlock];
		};
		
		[_request setCompletionBlock:handleResult];
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
		  successBlock: (nxuPaginatedDocumentsSuccessBlock) blockSuccess
	   andFailureBlock: (nxuPaginatedDocumentsErrorBlock) blockError
{
	self = [super init];
	
	if(self) {
		_reloadOnSamePage = YES;
		_docs = nil;
		
		_request = request;
		_successBlock = blockSuccess;
		_errorBlock = blockError;
		
		_lock = [NSLock new];
	}
	
	return self;
}

- (void) dealloc
{
	_docs = nil;
	_request = nil;
	_successBlock = nil;
	_errorBlock = nil;
	_lock = nil;
}


// ==================================================
#pragma mark - getters/setters
// ==================================================
- (NSInteger) pageSize
{
	return _docs.pageSize;
}
- (NSInteger) currentPageIndex
{
	return _docs.currentPageIndex;
}

- (void) setSuccessBlock:(nxuPaginatedDocumentsSuccessBlock) block
{
	_successBlock = block;
}

- (void) setErrorBlock:(nxuPaginatedDocumentsErrorBlock) block
{
	_errorBlock = block;
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