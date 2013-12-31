//
//  NUXDocument+nxuNUXDocument.h
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/30/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//
/**	Adding/overriding features
 *		description
 *			Returns the title (easy to use in a TableView for example)
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

- (NSString *) description;

@end
