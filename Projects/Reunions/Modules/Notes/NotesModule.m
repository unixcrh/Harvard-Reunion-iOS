
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import "NotesModule.h"
#import "NotesTableViewController.h"

@implementation NotesModule

- (UIViewController *)modulePage:(NSString *)pageName params:(NSDictionary *)params {
    UIViewController *vc = nil;
    if ([pageName isEqualToString:LocalPathPageNameHome]) {
        
        NotesTableViewController *notesVC = [[[NotesTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        vc = notesVC;
    }
    return vc;
}

#pragma mark Data

- (NSArray *)objectModelNames {
    return [NSArray arrayWithObject:@"Notes"];
}

@end
