#import "KGOAttendeeWrapper.h"
#import <EventKit/EventKit.h>
#import "CalendarModel.h"
#import "Foundation+KGOAdditions.h"

@implementation KGOAttendeeWrapper

@synthesize identifier,
name = _name,
attendeeType = _attendeeType,
attendeeStatus = _attendeeStatus,
event = _event,
organizedEvent;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.name = [dictionary stringForKey:@"display_name" nilIfEmpty:YES];
        self.identifier = [dictionary stringForKey:@"id" nilIfEmpty:YES];
    }
    return self;
}

- (void)dealloc
{
    self.event = nil;
    self.organizedEvent = nil;
    self.identifier = nil;
    self.name = nil;
    self.contactInfo = nil;
    [_ekAttendee release];
    [_kgoAttendee release];
    [_relation release];
    [super dealloc];
}

#pragma mark EventKit

- (EKParticipant *)EKAttendee
{
    return _ekAttendee;
}

- (void)setEKAttendee:(EKParticipant *)attendee
{
    [_ekAttendee release];
    _ekAttendee = [attendee retain];
    
    self.name = _ekAttendee.name;
    self.attendeeType = _ekAttendee.participantType;
    self.attendeeStatus = _ekAttendee.participantStatus;
}

#pragma mark CoreData

- (id)initWithKGOAttendee:(KGOEventParticipant *)attendee
{
    self = [super init];
    if (self) {
        self.KGOAttendee = attendee;
    }
    return self;
}

- (void)convertToKGOAttendee
{
    if (!_kgoAttendee) {
        _kgoAttendee = [[[CoreDataManager sharedManager] insertNewObjectForEntityForName:KGOEntityNameEventAttendee] retain];
        _kgoAttendee.name = self.name;
        _kgoAttendee.identifier = self.identifier;
    }
}

- (NSSet *)contactInfo
{
    [self convertToKGOAttendee];
    return self.KGOAttendee.contactInfo;
}

- (void)setContactInfo:(NSSet *)contactInfo
{
    [self convertToKGOAttendee];
    self.KGOAttendee.contactInfo = contactInfo;
}

- (KGOEventParticipant *)KGOAttendee
{
    return _kgoAttendee;
}

- (void)setKGOAttendee:(KGOEventParticipant *)attendee
{
    [_kgoAttendee release];
    _kgoAttendee = [attendee retain];
    
    self.name = _kgoAttendee.name;
    self.identifier = _kgoAttendee.identifier;
}

@end
