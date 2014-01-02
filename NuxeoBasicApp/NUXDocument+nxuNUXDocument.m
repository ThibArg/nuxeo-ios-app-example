//
//  NUXDocument+nxuNUXDocument.m
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/30/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//

#import "NUXDocument+nxuNUXDocument.h"

NSString* const kDCTitle = @"dc:title";
NSString* const kDCCreated = @"dc:created";
NSString* const kDCCreator = @"dc:creator";
NSString* const kDCModified = @"dc:modified";
NSString* const kDCLastContributor = @"dc:lastContributor";

@implementation NUXDocument (nxuNUXDocument)

- (BOOL) isEqual:(id)object
{
	if(self == object){
		return YES;
	}
	
	if(object && [object isKindOfClass:[NUXDocument class]]) {
		return [self.uid isEqualToString:[(NUXDocument *)object uid]]
			&& [self.changeToken isEqualToString:[(NUXDocument *)object changeToken]];
	}
	
	return NO;
}

@end
