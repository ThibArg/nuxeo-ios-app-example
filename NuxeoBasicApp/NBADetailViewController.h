//
//  NBADetailViewController.h
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/29/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NUXDocument+nxuNUXDocument.h"

@interface NBADetailViewController : UIViewController

- (void) displayDetails:(NUXDocument *)newDoc
				forList: (NSArray *) list;

@end
