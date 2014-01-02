//
//  NBADetailViewController.m
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/29/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//

#import "NBADetailViewController.h"

@interface NBADetailViewController () {

	NUXDocument*			_currentDoc;
	NSArray*				_docList;
	NSUInteger				_indexCurrent;
	NSUInteger				_indexMax;
}

@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet UILabel *lb_created;
@property (weak, nonatomic) IBOutlet UILabel *lb_createdBy;
@property (weak, nonatomic) IBOutlet UILabel *lb_modified;
@property (weak, nonatomic) IBOutlet UILabel *lb_modifiedBy;
@property (weak, nonatomic) IBOutlet UIButton *bNext;
@property (weak, nonatomic) IBOutlet UIButton *bPrevious;


- (void) configureView;
- (void) goToNext;
- (void) goToPrevious;
- (void) updateInterface;

@end

@implementation NBADetailViewController

// This is the only public interface
- (void)displayDetails:(NUXDocument *)newDoc
			   forList: (NSArray *) list
{
    _currentDoc = newDoc;
	_docList = list;
	
	[self updateIndex];
	[self configureView];
}

- (void) dealloc
{
	_currentDoc = nil;
	_docList = nil;
}

- (void) updateIndex
{
	if(_currentDoc && _docList) {
		_indexCurrent = [_docList indexOfObject:_currentDoc];
		_indexMax = [_docList count] - 1;
	} else {
		_indexCurrent = NSNotFound;
		_indexMax = 0;
	}
}

- (IBAction)handleClick:(id)sender {
	if(sender == self.bNext) {
		[self goToNext];
	} else {
		[self goToPrevious];
	}
}

- (void) goToNext
{
	if(_indexCurrent < _indexMax) {
		_indexCurrent += 1;
	}
	[self displayDocument:[_docList objectAtIndex:_indexCurrent]];
	
}

- (void) goToPrevious
{
	if(_indexCurrent > 0) {
		_indexCurrent -= 1;
	}
	[self displayDocument:[_docList objectAtIndex:_indexCurrent]];
}

- (void) updateInterface
{
	self.bPrevious.enabled = YES;
	self.bNext.enabled = YES;
	
	if(!_currentDoc || _indexCurrent == NSNotFound) {
		self.bNext.enabled = NO;
		self.bPrevious.enabled = NO;
	} else if(_indexCurrent == 0) {
		self.bPrevious.enabled = NO;
	} else if(_indexCurrent == _indexMax) {
		self.bNext.enabled = NO;
	}
}

- (void) displayDocument: (NUXDocument *) doc
{
	_currentDoc = doc;
	[self configureView];
}

- (void)configureView
{
	if (_currentDoc) {
		self.lb_title.text = _currentDoc.title;
		
		NSDictionary *props = _currentDoc.properties;
		self.lb_created.text = props[kDCCreated];
		self.lb_createdBy.text = props[kDCCreator];
		self.lb_modified.text = props[kDCModified];
		self.lb_modifiedBy.text = props[kDCLastContributor];
	} else {
		self.lb_title.text = @"";
		self.lb_created.text = @"";
		self.lb_createdBy.text = @"";
		self.lb_modified.text = @"";
		self.lb_modifiedBy.text = @"";
	}
	[self updateInterface];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self updateIndex];
	[self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
