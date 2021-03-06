
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import "Note.h"
#import <UIKit/UIPrintInteractionController.h>


@implementation Note

@dynamic title;
@dynamic date;
@dynamic details;
@dynamic eventIdentifier;


+ (NSString * ) dateToDisplay: (NSDate *) date {
    
    NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
    [format setDateFormat:@"MM/dd/yyyy"];
    
    NSString * dayMonthYearString = [format stringFromDate:date];
    
    [format setDateFormat:@"hh:mm a"];
    NSString * hoursMins = [format stringFromDate:date];
    
    return [NSString stringWithFormat:@"Created %@ at %@", dayMonthYearString, hoursMins];
    
}

+ (NSString *) noteTitleFromDetails: (NSString *) noteDetails {
    
    NSString * noteString = noteDetails;
    NSArray * splitArrayPeriod = [noteString componentsSeparatedByString:@"."];
    NSArray * splitArrayNewLine = [noteString componentsSeparatedByString:@"\n"];
    
    NSArray * splitArray;
    
    
    if ([[splitArrayPeriod objectAtIndex:0] length] < [[splitArrayNewLine objectAtIndex:0] length]) {
        splitArray = splitArrayPeriod;
    }
    else {
        splitArray = splitArrayNewLine;
    }
    
    return [splitArray objectAtIndex:0];
}

+ (void) printContent: (NSString *) textToPrint jobTitle:(NSString *) jobTitle 
           fromButton:(UIButton *) button parentView: (UIView *) parentView delegate:(id <UIPrintInteractionControllerDelegate>) delegate{
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    pic.delegate = delegate;
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = jobTitle;
    pic.printInfo = printInfo;
    
    UISimpleTextPrintFormatter *textFormatter = [[UISimpleTextPrintFormatter alloc]
                                                 initWithText:textToPrint];
    textFormatter.startPage = 0;
    textFormatter.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0); // 1 inch margins
    textFormatter.maximumContentWidth = 6 * 72.0;
    pic.printFormatter = textFormatter;
    [textFormatter release];
    pic.showsPageRange = YES;
    
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if (!completed && error) {
            NSLog(@"Printing could not complete because of error: %@", error);
        }
    };
    
    if (nil != button)
        [pic presentFromRect:button.frame inView:button animated:YES completionHandler:completionHandler];
    
    else
        [pic presentFromRect:parentView.frame inView:parentView animated:YES completionHandler:completionHandler];
}

@end
