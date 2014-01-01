//
//  NUXDocuments+nxuNUXDocuments.h
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/30/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//
/*
	What is done here:
 
	* Direct access to [self entries], so we can handle the list of NUXDocument inside
	  NXDocuments without using the entries property
	* It's just to make it a little bit easier/faster to code
 
	* count
		Simple rapper to [[self entries] count]
 
	* description
		Overriding the method so we dump the values (for debug)
 
	* Add the NSFastEnumeration protocol
		So we can iterates directly:
		for(NXDocument *doc in docs) ...
		(see implementation: we just wrap countByEnumeratingWithState:etc. and
		 use the one from self.entries)
 */

#import "NUXDocuments.h"

@interface NUXDocuments (nxuNUXDocuments) <NSFastEnumeration>

- (NSUInteger) count;
- (NSString *) description;
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state
								   objects:(__unsafe_unretained id [])buffer
									 count:(NSUInteger)len;
@end
