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

@interface nxuPaginatedDocuments () {
    NSInteger		_pageSize;
	NSInteger		_currentPage;
	NSString*		_queryStatement;
	
	NUXSession*		_session;
	NUXRequest*		_request;
	
	nxuPaginatedDocumentsResponseBlock _completionBlock;
	nxuPaginatedDocumentsResponseBlock _failureBlock;
	
	NUXDocuments*	_docs;
}
@end

@implementation nxuPaginatedDocuments

// init should not be called
- (id) init
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class nxuPaginatedDocuments"
                                 userInfo:nil];
	// Caller will crash
	return nil;
}

- (id) initWithSession: (NUXSession *) session
			  pageSize: (NSInteger) pageSize
		queryStatement: (NSString *) statement
	andQueryParameters: (NSDictionary *) queryParams
{
	self = [super init];
	
	if(self) {
		_pageSize = pageSize;
		_currentPage = 0;
		_queryStatement = statement;
		
		_session = session;
				
		if(queryParams){
			for(NSString *key in queryParams) {
				if([key isEqualToString:@"pageSize"]) {
					NSInteger newPageSize = [ queryParams[key] integerValue ];
					if(newPageSize > 0 && _pageSize <= 0) {
						_pageSize = newPageSize;
					}
				} else {
					[_request addParameterValue:queryParams[key] forKey:key];
				}
			}
		}
		// Add parameters now, so we're sure to override any existing one that could
		// have been added while walking the queryParams dictionnary
		[_request addParameterValue:[NSString stringWithFormat:@"%@", _queryStatement] forKey:@"query"];
		[_request addParameterValue:[NSString stringWithFormat:@"%ld", (long)_pageSize] forKey:@"pageSize"];
		
	}
	
	return self;
}

- (void) setCompletionBlock: (nxuPaginatedDocumentsResponseBlock) block
{
	_completionBlock = block;
}
- (void) setFailureBlock: (nxuPaginatedDocumentsResponseBlock) block
{
	_failureBlock = block;
}

- (void) start
{
	// ================================= handleResult
	void (^handleResult)(NUXRequest *) = ^(NUXRequest *inRequest) {
		NSError *error;
		
		NUXDocuments *docs = [inRequest responseEntityWithError:&error];
		
		NSLog(@"%@", docs);
		[A FINIR: passer d'aurtes params']
		if(error) {
			_failureBlock(error);
		} else {
			_completionBlock(self);
		}
	};
	
	// ================================= handleFailure
	void (^handleFailure)(NUXRequest *) = ^(NUXRequest *inRequest) {
		
		NSLog(@"Request failed because of:\r        - Status code: %d\r        - Message: %@",
			  [inRequest responseStatusCode],
			  [inRequest responseString]);
		
		// With only the text included in the html of responseString:
		NSString *html = [inRequest responseString];
		NSAttributedString *s = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
																 options:@{	NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
																			NSCharacterEncodingDocumentAttribute:
																				[NSNumber numberWithInt:NSUTF8StringEncoding]
																			}
													  documentAttributes:nil
																   error:nil];
		
		NSLog(@"%@", [s string]);
		
	};
	
	[_request setCompletionBlock:handleResult];
	[_request setFailureBlock:handleFailure];
	[_request start];
}


- (NSInteger) pageSize
{
	return _pageSize;
}
- (NSInteger) currentPage
{
	return _currentPage;
}
- (NSString *) queryStatement
{
	return _queryStatement;
}

@end
