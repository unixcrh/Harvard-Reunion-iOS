#import <UIKit/UIKit.h>
#import "ScheduleHomeViewController.h"

@class ScheduleDetailTableView;

@interface ScheduleHomeViewController_iPad : ScheduleHomeViewController {
    
    NSIndexPath *_selectedIndexPath;
    NSMutableArray *_cellData;
    
    NSInteger _selectedRow;
    
    MKMapView *_mapViewForSelectedCell;
    MKMapView *_mapViewForLastCell;
    
    UIView *_mapContainerViewForSelectedCell;
    UIView *_mapContainerViewForLastCell;
    
    ScheduleDetailTableView *_tableViewForSelectedCell;
    ScheduleDetailTableView *_tableViewForLastCell;

}

- (void)mapViewTapped:(id)sender;

@end
