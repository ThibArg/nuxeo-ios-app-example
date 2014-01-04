//
//  NUXDocuments+nxuNUXDocuments.m
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/30/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//

#import <NUXJSONSerializer.h>
#import "NUXDocuments+nxuNUXDocuments.h"

@implementation NUXDocuments (nxuNUXDocuments)

- (NSUInteger)count
{
	return [[self entries] count];
}


- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state
								   objects:(__unsafe_unretained id [])buffer
									 count:(NSUInteger)len
{
	
	return [[self entries] countByEnumeratingWithState:state objects:buffer count:len];
}

- (NSString *) description
{
	// Using mutable just to make the code a bit more readable
	NSMutableString *s = [NSMutableString stringWithFormat:@"%@", [super description]];
	
	[s appendFormat:@"\r isPaginable: %hhd", [self isPaginable]];
	[s appendFormat:@"\r pageSize: %ld", (long)[self pageSize]];
	[s appendFormat:@"\r maxPageSize: %ld", (long)[self maxPageSize]];
	[s appendFormat:@"\r currentPageSize: %ld", (long)[self currentPageSize]];
	[s appendFormat:@"\r currentPageIndex: %ld", (long)[self currentPageIndex]];
	[s appendFormat:@"\r numberOfPages: %ld", (long)[self numberOfPages]];
	[s appendFormat:@"\r isPreviousPageAvailable: %hhd", [self isPreviousPageAvailable]];
	[s appendFormat:@"\r isNextPageAvailable: %hhd", [self isNextPageAvailable]];
	[s appendFormat:@"\r isLastPageAvailable: %hhd", [self isLastPageAvailable]];
	[s appendFormat:@"\r hasError: %hhd", [self hasError]];
	[s appendFormat:@"\r errorMessage: %@", [self errorMessage]];
	[s appendFormat:@"\r totalSize: %ld", (long)[self totalSize]];
	[s appendFormat:@"\r pageIndex: %ld", (long)[self pageIndex]];
	[s appendFormat:@"\r pageCount: %ld", (long)[self pageCount]];
	[s appendFormat:@"\r entries count: %lu", (unsigned long)[[self entries] count]];
	
	return s;

}
@end
