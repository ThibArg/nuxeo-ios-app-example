//
//  nxuPaginatedDocuments.h
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/31/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//
/*
	* Setup the callback, conforming to the nxuPaginatedDocuments protocol
		- (void) paginatedDocumentsSucceeded: (NSArray *) entities
		{
			[self addNewObjectsWithArray: entities];
		}

		- (void) paginatedDocumentsFailed: (nxuPaginatedDocumentsError *) error
		{
			NSLog(@"Request failed because of:\r- Status code: %d\r- Message: %@\r- Error: %@",
				  error.requestStatusCode,
				  error.requestMessage,
				  error.error);
		}
 
	* Perform first query (_paginatedDocs is a variable of the class)
		- (void) performQuery:(NSString*) queryStr
		{
			//NSLog(@"ICI REFRESH");
			
			// Setup the session and the request
			NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/nuxeo"];
			NUXSession *session = [[NUXSession alloc] initWithServerURL:url username:@"Administrator" password:@"Administrator"];
			[session addDefaultSchemas:@[@"dublincore"]];

			NUXRequest *request = [session requestQuery: queryStr];
			[request addParameterValue:@"25" forKey:@"pageSize"];
			
			// Use nxuPaginatedDocuments
			_paginatedDocs = [[nxuPaginatedDocuments alloc] initWithRequest: request
																andDelegate: self ];
			_paginatedDocs.reloadOnSamePage = NO;
			[_paginatedDocs goToPage:0];
			
		}
 
	* Later, navigate:
		[_paginatedDocs goToNextPafe];
	  or
		[_paginatedDocs goToLastPage]

 */

#import <Foundation/Foundation.h>
#import "NUXSession.h"

// ==================================================
#pragma mark - nxuError
// ==================================================
#define kPaginatedDocumentsErrorDomain @"com.nuxeo.paginateddocuments"
enum {
	kERR_isBusy = 10000
};

/**	Would be easier to have a classic C struct, but
 *	"ARC forbids Objective-C objects in struct".
 *	Could workaround by declaring the pointers as _unsafe_unretained,
 *	but let's follow Apple recommendations ("create a class")
 *
 *	An error can occured in 2 different areas:
 *		-> The request itself returned an error
 *		-> Or the request was ok, but extracting the data failed
 *		   (failed tj create the NUXDocuments for example)
 *
 *	So. If requestStatusCode is 0 or 200, then the problem occured
 *	*after* a succesfull request, you can then explore the error object.
 */
@interface nxuPaginatedDocumentsError : NSObject

@property NSInteger	requestStatusCode;
@property NSString*	requestMessage;
@property NSError*	error;

+ (nxuPaginatedDocumentsError *) errorWithRequestStatus: (NSInteger) status
										 requestMessage: (NSString *) message
											   andError: (NSError *) error;
@end

// ==================================================
#pragma mark - nxuPaginatedDocuments
// ==================================================
/**	@protocol nxuPaginatedDocuments
 *
 *	When using a nxuPaginatedDocuments, caller is used as a delegate
 *	to handle success/failure. It must then conform to this protocol
 *	since these callback methods will be used.
 *
 */
@protocol nxuPaginatedDocuments

- (void) paginatedDocumentsSucceeded: (NSArray *) entities;
- (void) paginatedDocumentsFailed: (nxuPaginatedDocumentsError *) error;

@end
//extern const NSInteger
typedef void (^nxuPaginatedDocumentsSuccessBlock) (NSArray *entities);
typedef void (^nxuPaginatedDocumentsErrorBlock) (nxuPaginatedDocumentsError *error);

@interface nxuPaginatedDocuments : NSObject

// Default value is YES
@property BOOL reloadOnSamePage;

/**	initWithRequest:successBlock:andFailureBlock
 *
 *	The request should not be modified by the caller after creating
 *	this nxuPaginatedDocuments object and until you have finish working
 *	with it.
 *
 *	request
 *		All the parameters of the request must be set, including
 *		"pageSize" and "query" if needed, etc.
 *		IMPORTANT
 *		---------
 *			- The completionBlock and failureBlock of the request
 *			  will be overriden by the one of this object.
 *			- The request parameter is just retained. It should be
 *			  deep-copied, but it is not.
 *				=>	*************************************
 *					Do not modify the request while using
 *					the nxuPaginatedDocuments object
 *					*************************************
 */
- (id) initWithRequest: (NUXRequest *) request
		   andDelegate: (id <nxuPaginatedDocuments>) theDelegate;

/*	Setters for the callback blocks. Can be changed between 2 navigations (goTo...)
	IMPORTANT MISSING FEATURE: protect change of callback while executing a request
	=> be prepared for that by defining getters. We must also declare the getters
	(can't define a setter without defining the getter, it's both or none)
 */
- (void) setDelegate: (id <nxuPaginatedDocuments>) newDelegate;


// Accessors. Actually, just wrappers to the NUXDocuments members
// If no request has been run the
- (BOOL) hasMoreData; // means current page is not the last one

/**	Navigation
 *
 *	Each navigation method sends a new request (one exception: when the current
 *	page is re-requested. It then depends on the reloadOnSamePage property).
 *	This request is always asynchronous
 *		=> the only way to get its result is to use the block callbacks.
 *		=> The callback blocks *MUST* have been set prior to the call.
 *
 *	Only one request can be run at a time (using a NSLock object).
 *		- If a navigation method is called while another one is running, then
 *		  the failureBlock with the following infos in the nxuError parameter:
 *				requestStatusCode is 0 and requestMessage @""
 *				error will give informations in its localizedDescription and
 *				localizedFailureReason getters.
 *
 *		- Unlock is done in the callback blocks (successBlock and errorBlock)
 *		  *after* the blocks are executed.
 *			=> Make sure they terminate normally. If they throws an exception,
 *				the nxuPaginatedDocuments will remain locked.
 *
 *	Because Nuxeo realigns the "currentPageIndex" values, no specific check
 *	is done in all these accessors:
 *		- If the requested page is < 0
 *			=> page 0 is fetched by Nuxeo
 *		- If the requested page is > (number of pages - 1
 *			=> last page is fetched by Nuxeo
 */
- (void) goToPage: (NSInteger) pageNum;

/**	Usual navigation methods. They all call goToPage:
 */
- (void) goToPreviousPage;
- (void) goToNextPage;
- (void) goToLastPage;
- (void) goToFirstPage;

@end
