//
//  NBADetailViewController.m
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/29/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//

#import "NBADetailViewController.h"

@interface NBADetailViewController ()
- (void)configureView;

@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet UILabel *lb_created;
@property (weak, nonatomic) IBOutlet UILabel *lb_createdBy;
@property (weak, nonatomic) IBOutlet UILabel *lb_modified;
@property (weak, nonatomic) IBOutlet UILabel *lb_modifiedBy;

@end

@implementation NBADetailViewController

#pragma mark - Managing the detail item

- (void)setCurrentDoc:(NUXDocument *)newDoc
{
    if (_currentDoc != newDoc) {
        _currentDoc = newDoc;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
	//NSLog(@"%@", self.currentDoc);
	if (self.currentDoc) {
		self.lb_title.text = self.currentDoc.title;
		
		NSDictionary *props = self.currentDoc.properties;
		self.lb_created.text = props[kDCCreated];
		self.lb_createdBy.text = props[kDCCreator];
		self.lb_modified.text = props[kDCModified];
		self.lb_modifiedBy.text = props[kDCLastContributor];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
