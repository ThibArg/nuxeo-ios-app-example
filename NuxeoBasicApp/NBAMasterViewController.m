//
//  NBAMasterViewController.m
//  NuxeoBasicApp
//
//  Created by Thibaud on 12/29/13.
//  Copyright (c) 2013 ThibArg. All rights reserved.
//

#import "NBAMasterViewController.h"

#import "NBADetailViewController.h"

#import "NUXSession.h"
#import "NUXDocument.h"
#import "NUXDocuments.h"
#import "NUXRequest.h"
#import "NUXSession+requests.h"
#import "NUXDocuments+nxuNUXDocuments.h"
#import "nxuPaginatedDocuments.h"

NSString* const kDEFAULT_QUERY = @"SELECT * FROM Document WHERE ecm:path STARTSWITH '/default-domain/workspaces/ws/LotOfDocs' ORDER BY dc:title";

@interface NBAMasterViewController () {
    NSMutableArray*			_objects;
	
	nxuPaginatedDocuments*	_paginatedDocs;
	
	__weak IBOutlet UISearchBar *searchBar;
}
@end

@implementation NBAMasterViewController

// ==================================================
#pragma mark - nxuPaginatedDocuments protocol
// ==================================================
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

// ==================================================
#pragma mark - Query
// ==================================================
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

- (void) resetListAndPerformQuery: (NSString *) statement
{
	[_objects removeAllObjects];
	[self performQuery: statement];
}

// ==================================================
#pragma mark - actions
// ==================================================
- (IBAction)refreshList:(id)sender {
	
	[self resetListAndPerformQuery: kDEFAULT_QUERY];
}

// ==================================================
#pragma mark - Usual
// ==================================================
- (void)awakeFromNib
{
    [super awakeFromNib];
	_objects = [[NSMutableArray alloc] init];
	_paginatedDocs = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	[searchBar setDelegate:self];
	searchBar.text = kDEFAULT_QUERY;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
	_objects = nil;
	_paginatedDocs = nil;
}

// ==================================================
#pragma mark - Add object(s)
// ==================================================
- (void) addNewObjectsWithArray:(NSArray *)array
{
	/*
	if(needsReset) {
		[_objects removeAllObjects];
	}
	 */
	[_objects addObjectsFromArray:array];
	[self.tableView reloadData];
}

- (void) insertDebugString:(NSString *) aStr
{
	[_objects insertObject:aStr atIndex:0];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) insertNewObject:(NUXDocument *) doc
{
	//[_objects insertObject:[NSDate date] atIndex:0];
	[_objects insertObject:doc atIndex:0];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// ==================================================
#pragma mark - Table View
// ==================================================

// Later: better table view, not only the titles, but also icons, etc.
- (void) setupCell: (UITableViewCell *)cell forDoc: (NUXDocument *) doc
{
	cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", doc.type, doc.title];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	
	[self setupCell:cell forDoc:_objects[indexPath.row]];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

// We are moving to the detail viw => give the current doc
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        [ [segue destinationViewController] displayDetails:_objects[indexPath.row]
												   forList:_objects ];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	if (([scrollView contentOffset].y + scrollView.frame.size.height) >= [scrollView contentSize].height){
		
		if([_paginatedDocs hasMoreData]) {
			[_paginatedDocs goToNextPage];
		}
	}
}


// ==================================================
#pragma  mark - Search Bar
// ==================================================
- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
	[theSearchBar resignFirstResponder];
	[self resetListAndPerformQuery: [theSearchBar text]];
}

@end
