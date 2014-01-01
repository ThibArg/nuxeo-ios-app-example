//
//  nxuPaginatedDocuments.h
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/31/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//
/*
	// Setup URL and session
	NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/nuxeo"];
	NUXSession *session = [[NUXSession alloc] initWithServerURL:url username:@"Administrator" password:@"Administrator"];
	[session addDefaultSchemas:@[@"dublincore"]];
 
	// Set up the callbacks (here, to make the call to initWithSession more readable)
	void (^handleSuccess) (nxuPaginatedDocuments*) = ^(nxuPaginatedDocuments *pagedDocs) {
		. . .
	};
	void (^handleError) (nxuPaginatedDocuments*) = ^(nxuPaginatedDocuments *pagedDocs) {
		. . .
	};

	// Create the object
	nxuPaginatedDocuments *paginatedDocs = [[nxuPaginatedDocuments alloc] initWithSession: session
																			 pageSize: 50
																	   queryStatement: queryStr
																	  queryParameters: nil
																	  completionBlock: handleSuccess
																	  andFailureBlock: handleError];
	 
	// Do first query. Callbacks will be run
	[paginatedDocs start];

 */

#import <Foundation/Foundation.h>
#import "NUXSession.h"

@class nxuPaginatedDocuments;
typedef void (^nxuPaginatedDocumentsResponseBlock)(nxuPaginatedDocuments *pagedDocs);

@interface nxuPaginatedDocuments : NSObject

/**	initWithSession
 *		session
 *			must be valid NUXSession object, already set-up with server URL and credentials
 *			Any schemas that must be retreived must also already be set
 *			(basically, caller is responsible for setting this object)
 *
 *		pageSize
 *			The size of one page (number of elements to retreive from the server)
 *			pageSize <= 0
 *				- If a "pageSize" key is found in queryParams:
 *					* If it's a positive value => use this value
 *					* Else, use default pagination value
 *				- Else, use default pagination value
 *			pageSize > 0 => use this value, ignore any "pageSize" key in pagination
 *
 *		queryStatement
 *			The full NXQL statement: SELECT * FROM . . .
 *
 *		queryParams
 *			A key-value dictionnary to add to the URL as query strings
 *			IMPORTANT: It is assumed all values are NSString*
 *			Can be nil
 *			If "queryStr" is in this dictionnary, it is ignored (statement is used intead)
 */
- (id) initWithSession: (NUXSession *) session
			  pageSize: (NSInteger) pageSize
		queryStatement: (NSString *) statement
	   queryParameters: (NSDictionary *) queryParams
	   completionBlock: (nxuPaginatedDocumentsResponseBlock) successBlock
	   andFailureBlock: (nxuPaginatedDocumentsResponseBlock) errorBlock;

/* callbacks can be changed between 2 navigations (goTo...)
	Missing featire: protcect change of callback while executing a request
 */
- (void) setCompletionBlock: (nxuPaginatedDocumentsResponseBlock) block;
- (void) setFailureBlock: (nxuPaginatedDocumentsResponseBlock) block;

/** start
 *	Does the first query. Calling it more than once is the same as calling goToFirstPage.
 *	The request is always done asynchronously, hence the need for callbacks.
 *
 *	IMPORTANT: The callback blocks *MUST* have been set prior to the call.
 *	If at least one callback is missing, an error is thrown
 */
- (void) start;


// Accessor for private variables
- (NSInteger) pageSize;
- (NSInteger) currentPage;
- (NSString *) queryStatement;

/*
 *	IMPORTANT: The callback blocks *MUST* have been set prior to the call.
 *	If at least one callback is missing, an error is thrown
 */
/*
// goToPage throws an error if pageNum < 0 or > max pages
// Does nothing if current page == pageNum (no reload)
- (void) goToPage: (NSInteger) pageNum;
// Quick accessors calling goToPage
- (void) goToPreviousPage;
- (void) goToNextPage;
- (void) goToLastPage;
- (void) goToFirstPage;
*/

@end
