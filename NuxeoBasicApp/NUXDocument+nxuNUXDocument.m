//
//  NUXDocument+nxuNUXDocument.m
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/30/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//

#import "NUXDocument+nxuNUXDocument.h"

@implementation NUXDocument (nxuNUXDocument)

- (NSString *) description
{
	return [NSString stringWithFormat:@"hop: %@", [self title]];
}

@end
