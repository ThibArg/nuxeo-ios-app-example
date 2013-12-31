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

@interface NBAMasterViewController () {
    NSMutableArray *_objects;
	__weak IBOutlet UISearchBar *searchBar;
}
@end

@implementation NBAMasterViewController

- (void) performQuery:(NSString*) queryStr
{
	//NSLog(@"ICI REFRESH");
	
	NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/nuxeo"];
	NUXSession *session = [[NUXSession alloc] initWithServerURL:url username:@"Administrator" password:@"Administrator"];
	
	[session addDefaultSchemas:@[@"dublincore"]];
	
	NUXRequest *request = [[NUXRequest alloc] initWithSession:session];
	
	request = [session requestQuery: queryStr];
	
	// ================================= handleResult
	void (^handleResult)(NUXRequest *) = ^(NUXRequest *inRequest) {
		NSError *error;
		
		NUXDocuments * docs = [inRequest responseEntityWithError:&error];
		if(error) {
			NSLog(@"Error in [inRequest responseEntityWithError:&error]: %@", error);
		} else {
			[self insertNewObjectsWithArray: [docs entries]
								andResetAll: YES];
			
		}
	};
	
	// ================================= handleFailure
	void (^handleFailure)(NUXRequest *) = ^(NUXRequest *inRequest) {
		
		NSLog(@"Request failed because of:\r        - Status code: %d\r        - Message: %@",
			  [inRequest responseStatusCode],
			  [inRequest responseString]);
		
		// With only the text included in the html of responseString:
		NSString *html = [inRequest responseString];
		NSAttributedString *s = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
																 options:@{	NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
																			NSCharacterEncodingDocumentAttribute:
																				[NSNumber numberWithInt:NSUTF8StringEncoding]
																			}
													  documentAttributes:nil
																   error:nil];
		
		NSLog(@"%@", [s string]);
		
	};
	
	[request setCompletionBlock:handleResult];
	[request setFailureBlock:handleFailure];
	[request start];
	
}

- (IBAction)refreshList:(id)sender {
	
	[self performQuery:@"SELECT * FROM Document WHERE ecm:path STARTSWITH '/default-domain' and ecm:mixinType != 'Folderish'"];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
	_objects = [[NSMutableArray alloc] init];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.navigationItem.leftBarButtonItem = self.editButtonItem;

	/* PAS DE ADD BUTTON
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	self.navigationItem.rightBarButtonItem = addButton;
	 */
	[searchBar setDelegate:self];
}

- (void) insertNewObjectsWithArray:(NSArray *)array andResetAll:(BOOL) needsReset
{
	if(needsReset) {
		NSLog(@"RESET");
		[_objects removeAllObjects];
		[self.tableView reloadData];
	}
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
	[_objects insertObject:[doc title] atIndex:0];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

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

	NSDate *object = _objects[indexPath.row];
	cell.textLabel.text = [object description];
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

        [ [segue destinationViewController] setCurrentDoc:_objects[indexPath.row] ];
    }
}


#pragma  mark - Search Bar
- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
	[theSearchBar resignFirstResponder];
	[self performQuery: [theSearchBar text]];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
	NSLog(@"oiuiouoi");
}

@end
