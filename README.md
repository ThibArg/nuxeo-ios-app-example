nuxeo-ios-app-example
=====================

Learning how to use nuxeo-ios-sdk, extending it, etc.

The SDK was imported following instruction found [here](http://doc.nuxeo.com/x/2Ir1) which means you have to open the workspace (not the project), because of the use of CocoaPods.

####The application does the following:

* Connects to localhost:8080/nuxeo, with the usual Administrator/Administrator credentials

* Displays a "refresh" button which gets all the documents in a specific (hard-coded) folder

* Displays a search bar, wher the user can enter a NXQL expression

* Pagination is set to 25. When the user scrolls down, a new page is fetched and its data added to the list

* When an item in the list is touched:
	* The app displays details: Just basic dublincore infos.
	* Previous/Next buttons allow navigation in the list

* (not yet a crazy flashy interface ;-))

 

####As of "today", what was added to the sdk:

* Category `nxuDocument` (NUXDocument+nxuNUXDocument.h and .m)
    * `isEqual` compares 2 documents. Mainly used in an `NSArray` of `NUXDocument`, to find one `NUXDocument` in the array

* Category `nxuDocuments` (NUXDocuments+nxuNUXDocuments.h and .m)
	* `count` returns the count of `NUXDocument` in the the `NUXDocuments` (basically, simple wrapper to `[[self entries] count]`)
	* `description` overrides the default description to output all informations (but only the count of entries, not each `NUXDocument`). Mainly used during debug, with `NSLog`.
	* `countByEnumeratingWithState:objects:count:` lets enumerate the `NUXDocuments`. Something like:

```objective-c
NUXDocuments docs;
. . . fill docs . . .
for(NUXDocument in docs) {
  . . .
}
```
 Note: It is not difficult to enumerate from the origina `NUXDocuments`: `for(NUXDocument in docs.entries)`. But found it even easier to directly use the object without its member.

* Class `nxuPaginatedDocuments`, with a `nxuPaginatedDocuments` (for callbacks) and a `nxuError` class.

 The goal is to be able to navigate in the pages. User of the class must conform to the `nxuPaginatedDocuments` protocol; wich declares two callbacks (one to handle success, on to handle error). A `nxuPaginatedDocuments` is initialized with a `NUXRequesy` and a delegate (`self` in this small app, see `NBAMasterViewController`). Then, user of the class can navigate in the pages to request a different one:
 
```objective-c
- (void) goToPage: (NSInteger) pageNum;
- (void) goToPreviousPage;
- (void) goToNextPage;
- (void) goToLastPage;
- (void) goToFirstPage;
```

 So, for example, at first call, initialize the object and go to first page:

 
```objective-c
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
```

 Later, go to a different page:

`[_paginatedDocs goToNextPage];`

