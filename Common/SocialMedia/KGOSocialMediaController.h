#import <Foundation/Foundation.h>
#import "MGTwitterEngine.h"
#import "ConnectionWrapper.h"
#import "Facebook.h"

extern NSString * const KGOSocialMediaTypeFacebook;
extern NSString * const KGOSocialMediaTypeTwitter;
extern NSString * const KGOSocialMediaTypeEmail;
extern NSString * const KGOSocialMediaTypeBitly;

extern NSString * const TwitterDidLoginNotification;
extern NSString * const TwitterDidLogoutNotification;

extern NSString * const FacebookUsernameKey;

extern NSString * const FacebookDidLoginNotification;
extern NSString * const FacebookDidLogoutNotification;

@protocol TwitterWrapperDelegate <NSObject>

- (void)twitterDidLogin;
- (void)promptForTwitterLogin;
- (void)twitterFailedToLogin;
- (void)twitterDidLogout;

- (void)twitterRequestSucceeded:(NSString *)connectionIdentifier;

@optional

- (void)twitterRequestFailed:(NSString *)connectionIdentifier withError:(NSError *)error;

@end



@protocol BitlyWrapperDelegate <NSObject>

- (void)didGetBitlyURL:(NSString *)url;

@optional

- (void)failedToGetBitlyURL;

@end

@interface KGOSocialMediaController : NSObject <UIActionSheetDelegate,
MGTwitterEngineDelegate, ConnectionWrapperDelegate,
FBSessionDelegate, FBDialogDelegate, FBRequestDelegate> {
	
	NSDictionary *_appConfig; // from config plist
	
	MGTwitterEngine *_twitterEngine;
	NSString *_twitterUsername;
	
	ConnectionWrapper *_bitlyConnection;

	Facebook *_facebook;
    NSInteger _facebookStartupCount;
    
    // these objects are mutated by functions in the (FacebookAPI) category
    // of this class.  if (FacebookAPI) is not included, these will be empty
    // from start to finish.
    NSMutableArray *_fbRequestQueue;
    NSMutableArray *_fbRequestIdentifiers;
    NSMutableArray *_fbUploadQueue; // metadata of pending FacebookPost objects
    NSMutableArray *_fbUploadData;
    
    // settings for each social media object
    // internally we store this with the social media label (facebook, twitter, etc) as keys
    // and a dictionary as values
    // this dictionary has setting names as keys and an mutable array of strings as values
    NSMutableDictionary *_apiSettings;
}

@property (nonatomic, assign) id<TwitterWrapperDelegate> twitterDelegate;
@property (nonatomic, assign) id<BitlyWrapperDelegate> bitlyDelegate;
@property (nonatomic, retain) NSString *twitterUsername;

+ (KGOSocialMediaController *)sharedController;

- (void)addOptions:(NSArray *)options forSetting:(NSString *)setting forMediaType:(NSString *)mediaType;

#pragma mark Capabilities

- (NSArray *)allSupportedSharingTypes;

- (BOOL)supportsSharing;
- (BOOL)supportsFacebookSharing;
- (BOOL)supportsTwitterSharing;
- (BOOL)supportsEmailSharing;
- (BOOL)supportsBitlyURLShortening;

#pragma mark Twitter

- (BOOL)isTwitterLoggedIn;

- (void)startupTwitter;
- (void)shutdownTwitter;

- (void)loginTwitterWithDelegate:(id<TwitterWrapperDelegate>)delegate;
- (void)loginTwitterWithUsername:(NSString *)username password:(NSString *)password;
- (void)logoutTwitter;

- (void)postToTwitter:(NSString *)text;

#pragma mark bit.ly

- (void)getBitlyURLForLongURL:(NSString *)longURL delegate:(id<BitlyWrapperDelegate>)delegate;
- (void)shutdownBitly;

#pragma mark Facebook

- (BOOL)isFacebookLoggedIn;
- (void)parseCallbackURL:(NSURL *)url;

- (void)shareOnFacebook:(NSString *)attachment prompt:(NSString *)prompt;

- (void)startupFacebook;
- (void)shutdownFacebook;

- (void)loginFacebook;
- (void)logoutFacebook;

@property (nonatomic, readonly) Facebook *facebook;

@end


