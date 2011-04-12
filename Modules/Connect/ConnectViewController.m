//
//  ConnectViewController.m
//

#import "ConnectViewController.h"
#import "BumpAPI.h"
#import "AddressBookUtils.h"
#import "KGOTheme.h"

typedef enum
{
    kBumpStatusLabel = 0x324,
    kBumpMessageLabel,
    kBumpSpinnerView,
    kBumpUIGenericAlertTag,
    kBumpConnectRequestAlertTag
}
CustomBumpUITags;

#define kBumpStatusConnecting @"Preparing Bump session."
#define kBumpStatusConnectedToNetwork @"Connected to the Bump network. "\
"You may start Bumping other devices with the Reunion app!"
#define kBumpStatusDisconnected @"Not connected to the Bump network."
#define kBumpStatusConnectedToPerson @"Connected to another person."

static const CGFloat kConnectViewSubviewMargin = 20.0f;

#pragma mark Private methods

@interface ConnectViewController (Private)

- (void)setUpBump;
- (void)takeDownBump;

#pragma mark Address book
- (void)showPicker;
- (void)addAddressBookRecordForDict:(NSDictionary *)serializedRecord;
- (void)promptAboutAddingIncomingRecord;

#pragma mark Bump UI
- (void)showAlert:(NSString *)message;

// status: The current state of the Bump connection.
// message: The most recent notification about the Bump connection.
// Making either of them nil will leave them unchanged.
- (void)updateStatus:(NSString *)status andMessage:(NSString *)message;

@end

@implementation ConnectViewController (Private)

- (void)setUpBump {
    BumpAPI *bumpObject = [BumpAPI sharedInstance];        
    [bumpObject configUIDelegate:self];
    [bumpObject configDelegate:self];
    [bumpObject configAPIKey:@"57571df95089489d906d0d396ace290d"];
    [bumpObject configParentView:self.view];
    [bumpObject configActionMessage:
     @"Bump with another app user to get started."];
    [bumpObject requestSession];
}

- (void)takeDownBump {
    [[BumpAPI sharedInstance] endSession];
    [[BumpAPI sharedInstance] configUIDelegate:nil];
    [[BumpAPI sharedInstance] configDelegate:nil];
    [[BumpAPI sharedInstance] configParentView:nil];    
}    

#pragma mark Address book
- (void)showPicker {
    addressBookPickerShowing = YES;
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];    
    picker.peoplePickerDelegate = self;
    
    [self presentModalViewController:picker animated:YES];
    picker.navigationBar.topItem.prompt = @"Select a contact to share";
    [picker release];    
}

- (void)addAddressBookRecordForDict:(NSDictionary *)serializedRecord {
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    ABRecordRef newRecord = ABPersonCreate();    
    [AddressBookUtils setUpABRecord:newRecord withDict:serializedRecord];
    
    CFErrorRef error = NULL;
    if (!ABAddressBookAddRecord(addressBook, newRecord, &error)) {
        NSLog(@"Error adding record to address book.");
    }
    
    error = NULL;
    if (!ABAddressBookSave(addressBook, &error)) {
        NSLog(@"Error saving to address book.");
    }
    
    CFRelease(newRecord);
    CFRelease(addressBook);
}

- (void)promptAboutAddingIncomingRecord
{
    // Ask about adding person sent to us to address book.
    if (self.incomingABRecordDict) {
        NSString *alertQuestion = 
        [NSString stringWithFormat:@"Do you want to add %@ %@ to your Contacts?",
         [self.incomingABRecordDict objectForKey:@"kABPersonFirstNameProperty"],
         [self.incomingABRecordDict objectForKey:@"kABPersonLastNameProperty"]];
        
        UIAlertView *alert = 
        [[UIAlertView alloc]
         initWithTitle:@"Add to Contacts" message:alertQuestion delegate:self 
         cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
        [alert show];
        [alert release];
        shouldPromptAboutAddingRecordAtNextChance = NO;
    }
    else {
        // Can't do it yet.
        shouldPromptAboutAddingRecordAtNextChance = YES;
    }
}

#pragma mark Bump UI
- (void)showAlert:(NSString *)message
{
    UIAlertView *alertView = 
    [[UIAlertView alloc]
     initWithTitle:nil 
     message:message 
     delegate:nil 
     cancelButtonTitle:nil 
     otherButtonTitles:@"OK", nil];
    alertView.tag = kBumpUIGenericAlertTag;
    [alertView show];
    [alertView release];
}

- (void)updateStatus:(NSString *)status andMessage:(NSString *)message {
    if (status) {
        self.statusLabel.text = status;
        
        if ([status isEqualToString:kBumpStatusConnecting]) {
            [self.spinner startAnimating];
        }
        else {
            [self.spinner stopAnimating];
        }

    }
    if (message) {
        self.messageLabel.text = message;
    }
}

@end


@implementation ConnectViewController

@synthesize incomingABRecordDict;
@synthesize statusLabel;
@synthesize messageLabel;
@synthesize spinner;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.navigationItem.title = @"Connect";
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    //self.view.backgroundColor = [UIColor greenColor];
    CGFloat viewWidth = self.view.frame.size.width;
            
    self.statusLabel = 
    [[[UILabel alloc] initWithFrame:
      CGRectMake(kConnectViewSubviewMargin, 
                 100, 
                 viewWidth - 2 * kConnectViewSubviewMargin, 
                 80)] 
     autorelease];
    self.statusLabel.tag = kBumpStatusLabel;
    self.statusLabel.backgroundColor = [UIColor clearColor];
    NSString *fontName = [[KGOTheme sharedTheme] defaultFontName];
    CGFloat fontSize = [[KGOTheme sharedTheme] defaultFontSize];
    UIFont *font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", fontName] size:fontSize];
    if (!font) {
        font = [UIFont fontWithName:fontName size:fontSize];
    }
    self.statusLabel.font = font;
    self.statusLabel.numberOfLines = 0;
    [self.view addSubview:self.statusLabel];

    self.spinner = 
    [[[UIActivityIndicatorView alloc] 
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]
     autorelease];
    CGRect spinnerFrame = self.spinner.frame;
    spinnerFrame.origin.x = viewWidth/2;
    spinnerFrame.origin.y = 210; 
    self.spinner.frame = spinnerFrame;
    [self.view addSubview:self.spinner];
    
    self.messageLabel = 
    [[[UILabel alloc] initWithFrame:
      CGRectMake(kConnectViewSubviewMargin, 
                 240, 
                 viewWidth - 2 * kConnectViewSubviewMargin, 
                 80)] autorelease];    
    self.messageLabel.tag = kBumpMessageLabel;
    self.messageLabel.backgroundColor = [UIColor clearColor];
    font = [UIFont fontWithName:fontName size:fontSize];
    self.messageLabel.font = font;
    self.messageLabel.numberOfLines = 0;
    [self.view addSubview:self.messageLabel];
        
    [self setUpBump];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    // Stop bump.
    [self takeDownBump];
    
    [spinner release];
    [messageLabel release];
    [statusLabel release];
    [incomingABRecordDict release];
    
    [super dealloc];
}

#pragma mark BumpAPIDelegate methods

- (void)bumpDataReceived:(NSData *)chunk {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// The chunk sent from the other user is a dictionary representing an ABRecord. 
    self.incomingABRecordDict = [NSKeyedUnarchiver unarchiveObjectWithData:chunk];
        
    if (addressBookPickerShowing) {
        shouldPromptAboutAddingRecordAtNextChance = YES;
    }
    else {
        [self promptAboutAddingIncomingRecord];
    }    
    
    [pool release];
}

- (void)bumpSessionStartedWith:(Bumper*)otherBumper{
    NSLog(@"Bump session started.");
//    [self showPicker];
}

- (void)bumpSessionEnded:(BumpSessionEndReason)reason {
	NSString *alertText;
	switch (reason) {
		case END_OTHER_USER_QUIT:
			alertText = @"Other user has quit the session.";            
			break;
		case END_LOST_NET:
			alertText = @"Connection to Bump network was lost.";
			break;
		case END_OTHER_USER_LOST:
			alertText = @"Connection to other user was lost.";
			break;
		case END_USER_QUIT:
			alertText = @"You have been disconnected.";
			break;
		default:
			alertText = @"You have been disconnected.";
			break;
	}
    
    [self updateStatus:kBumpStatusDisconnected andMessage:alertText];
	
	if (reason != END_USER_QUIT) { 
		UIAlertView *alert = 
        [[UIAlertView alloc] 
         initWithTitle:@"Disconnected" 
         message:alertText 
         delegate:nil 
         cancelButtonTitle:@"OK" 
         otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)bumpSessionFailedToStart:(BumpSessionStartFailedReason)reason {
	
	NSString *alertText;
	switch (reason) {
		case FAIL_NETWORK_UNAVAILABLE:
			alertText = @"Please check your network settings and try again.";
            [self updateStatus:kBumpStatusDisconnected andMessage:alertText];
			break;
		case FAIL_INVALID_AUTHORIZATION:
			//the user should never see this, since we'll pass in the correct API auth strings.
			//just for debug.
			alertText = @"Failed to connect to the Bump service. Auth error.";
			break;
		default:
			alertText = @"Failed to connect to the Bump service.";
			break;
	}

    [self updateStatus:kBumpStatusDisconnected andMessage:alertText];
	
	if (reason != FAIL_USER_CANCELED) {
		//if the user canceled they know it and they don't need a popup.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark UI Actions

#pragma mark ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
        
    [self dismissModalViewControllerAnimated:YES];
    addressBookPickerShowing = NO;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Send selected person.    
    NSDictionary *personDict = [AddressBookUtils dictionaryForRecord:person];
    NSData *chunk = [NSKeyedArchiver archivedDataWithRootObject:personDict];
    
    [[BumpAPI sharedInstance] sendData:chunk];
    
    if (shouldPromptAboutAddingRecordAtNextChance) {
        [self promptAboutAddingIncomingRecord];
    }

    [pool release];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}


#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kBumpConnectRequestAlertTag) {
        switch (buttonIndex) {
            case 0: 
                // Cancelled.
                [[BumpAPI sharedInstance] confirmMatch:NO];
                break;
            default:
                // Said yes to connect.
                [[BumpAPI sharedInstance] confirmMatch:YES];
                [self showPicker];
                break;
        }
    }
    else {
        if (buttonIndex == 0) {
            [self addAddressBookRecordForDict:self.incomingABRecordDict];
        }
        self.incomingABRecordDict = nil;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC), 
                   dispatch_get_current_queue(), 
                   ^{
                       // Start over.
                       [self takeDownBump];
                       [self setUpBump];
                   });
}


#pragma mark BumpAPICustomUI


/**
 * Result of requestSession on BumpAPI (user wants to connect to another device via Bump). UI should
 * now first appear saying something like "Warming up".
 */
- (void)bumpRequestSessionCalled
{
    [self updateStatus:kBumpStatusConnecting andMessage:@""];
}

/**
 * We were unable to establish a connection to the Bump network. Either show an error message or
 * hide the popup. The BumpAPIDelegate is about to be called with bumpSessionFailedToStart.
 */
- (void)bumpFailedToConnectToBumpNetwork
{
    [self updateStatus:kBumpStatusDisconnected 
            andMessage:@"Failed to connect to the Bump network."];
}

/**
 * We were able to establish a connection to the Bump network and you are now ready to bump. 
 * The UI should say something like "Ready to Bump".
 */
- (void)bumpConnectedToBumpNetwork
{
    [self updateStatus:kBumpStatusConnectedToNetwork andMessage:@""];
}

/**
 * Result of endSession call on BumpAPI. Will soon be followed by the call to bumpSessionEnded: on
 * API delegate. Highly unlikely to happen while the custom UI is up, but provided as a convenience
 * just in case.
 */
- (void)bumpEndSessionCalled
{
    [self updateStatus:kBumpStatusDisconnected andMessage:@""];
}

/**
 * Once the intial connection to the bump network has been made, there is a chance the connection
 * to the Bump Network is severed. In this case the bump network might come back, so it's
 * best to put the user back in the warming up state. If this happens too often then you can 
 * provide extra messaging and/or explicitly call endSession on the BumpAPI.
 */
- (void)bumpNetworkLost
{
    [self updateStatus:kBumpStatusDisconnected 
            andMessage:@"Lost connection to the Bump network."];
}

/**
 * Physical bump occurced. Update UI to tell user that a bump has occured and the Bump System is
 * trying to figure out who it matched with.
 */
- (void)bumpOccurred
{
    [self updateStatus:nil andMessage:@"Bumped!"];
}

/**
 * Let's you know that a match could not be made via a bump. It's best to prompt users to try again.
 * @param		reason			Why the match failed
 */
- (void)bumpMatchFailedReason:(BumpMatchFailedReason)reason
{
    [self updateStatus:nil andMessage:@"Could not make a Bump match."];
}

/**
 * The user should be presented with some data about who they matched, and whether they want to
 * accept this connection. (Pressing Yes/No should call confirmMatch:(BOOL) on the BumpAPI).
 * param		bumper			Information about the device the bump system mached with
 */
- (void)bumpMatched:(Bumper*)bumper
{
    UIAlertView *alertView = 
    [[UIAlertView alloc] 
     initWithTitle:@"Connection made"
     message:[NSString stringWithFormat:@"Do you want to connect with %@?", 
              [bumper userName]] 
     delegate:self 
     cancelButtonTitle:@"Cancel" 
     otherButtonTitles:@"Connect", nil];
    alertView.tag = kBumpConnectRequestAlertTag;
    [alertView show];
    
    [self updateStatus:kBumpStatusConnectedToPerson andMessage:nil];
}

/**
 * Called after both parties have pressed yes, and bumpSessionStartedWith:(Bumper) is about to be 
 * called on the API Delegate. You should now close the matching UI.
 */
- (void)bumpSessionStarted
{
    [self updateStatus:kBumpStatusConnectedToPerson andMessage:@"Connected!"];
}


@end