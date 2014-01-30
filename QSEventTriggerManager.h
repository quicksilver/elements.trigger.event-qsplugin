//
//  QSMouseTriggerManager.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on Sun Jun 13 2004.
//

#import <QSCore/QSTriggerManager.h>

#define kQSTriggerEvents @"QSTriggerEvents"

#define QSEventNotification @"QSEventNotification"

// event type keys
#define kQSEventTrigger @"eventTrigger"
#define kQSEventTriggerName @"name"
#define kQSEventTriggerAllowMatching @"allowMatching"
// trigger keys
#define kQSEventTriggerDelay @"eventDelay"
#define kQSEventTriggerDelayDuration @"delayDuration"
#define kQSEventTriggerOneTime @"eventOneTime"
#define kQSEventTriggerMatch @"matchList"
#define kQSEventTriggerIgnore @"ignoreList"

@interface NSObject (QSEventTriggerProvider)

// Called when first trigger enabled for event
- (void)enableEventObserving:(NSString *)event;

// Called when last trigger disabled for event
- (void)disableEventObserving:(NSString *)event;

// Called when any matching triggers are enabled/disabled
- (void)addObserverForEvent:(NSString *)event trigger:(QSTrigger *)trigger;
- (void)removeObserverForEvent:(NSString *)event trigger:(QSTrigger *)trigger;


@end

@class QSEventTriggerRestrictionController;

@interface QSEventTriggerManager : QSTriggerManager <NSTableViewDelegate> {
	IBOutlet NSPopUpButton *eventPopUp;
    IBOutlet NSTextField *matchLabel;
    IBOutlet NSTextField *ignoreLabel;
	NSDictionary *triggersByEvent;
    IBOutlet QSEventTriggerRestrictionController *restrictionController;
}

@property (retain) id eventTriggerObject;

+ (id)sharedInstance;
- (IBAction)updateTrigger:(id)sender;
- (IBAction)setEventType:(id)sender;
- (IBAction)showRestrictionPicker:(id)sender;

-(void)handleTriggerEvent:(NSString *)event withObject:(id)object;
- (void)setEventTriggerObject:(id)newEventTriggerObject;
@end
