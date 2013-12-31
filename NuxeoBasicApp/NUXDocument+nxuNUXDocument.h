//
//  NUXDocument+nxuNUXDocument.h
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/30/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//
/**	Adding/overriding features
 *		isEqual
 *			Utility for querying a NUXDocument in an NSArray for example
 *
 *
*/

#import "NUXDocument.h"

extern NSString* const kDCTitle;
extern NSString* const kDCCreated;
extern NSString* const kDCCreator;
extern NSString* const kDCModified;
extern NSString* const kDCLastContributor;


@interface NUXDocument (nxuNUXDocument)

// This implementaiton of isEqual only compares UUID and changeToken
// Very useful when querying an NUXDocument in an NSArray of NUXDocument
// like in:
//			NUXDocuments *docs = ...
//			. . .
//			NUXDocument *oneDoc = ...
//			. . .
//			NSUInteger pos = [docs.entries indexOfObject:oneDoc];
//			. . .
//
// *BUT*, this means the comparison is not strict. For example, you could
// have 2 NUXDocument of the same document, but the user modified some
// values (dc:title, ...) => isEqual would still return YES
- (BOOL) isEqual:(id)object;

@end
