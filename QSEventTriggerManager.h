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

/**
 *  QSEventTriggerProvider Protocol
 *
 *  Optional methods to define behavior when Event Triggers are enabled and disabled.
 */
@protocol QSEventTriggerProvider
@optional;
/**
 *  If multiple events from this provider share common prerequisites, set them up here. This will be called before the first trigger using an event from this provider is enabled.
 */
- (void)enableEventProvider;
/**
 *  If multiple events from this provider share common prerequisites, tear them down here. This is called after the last trigger using an event from this provider is disabled.
 */
- (void)disableEventProvider;
/**
 *  Set up prerequisites for a specific event. This will be called *once* before the first trigger using the event is enabled.
 *
 *  @param event The identifier for an event, as defined under QSTriggerEvents in a plug-in's property list.
 */
- (void)enableEventObserving:(NSString *)event;
/**
 *  Tear down prerequisites for a specific event. This will be called *once* after the last trigger using the event is disabled.
 *
 *  @param event The identifier for an event, as defined under QSTriggerEvents in a plug-in's property list.
 */
- (void)disableEventObserving:(NSString *)event;
/**
 *  Set up observation for an event. This will be called for every trigger that uses the event when the trigger is enabled.
 *
 *  @param event   The identifier for an event, as defined under QSTriggerEvents in a plug-in's property list.
 *  @param trigger The trigger being enabled.
 */
- (void)addObserverForEvent:(NSString *)event trigger:(QSTrigger *)trigger;
/**
 *  Tear down observation for an event. This will be called for every trigger that uses the event when the trigger is disabled.
 *
 *  @param event   The identifier for an event, as defined under QSTriggerEvents in a plug-in's property list.
 *  @param trigger The trigger being disabled.
 */
- (void)removeObserverForEvent:(NSString *)event trigger:(QSTrigger *)trigger;
@end

@interface QSEventTriggerManager : QSTriggerManager <NSTableViewDelegate> {
	IBOutlet NSPopUpButton *eventPopUp;
    IBOutlet NSTextField *matchLabel;
    IBOutlet NSTextField *ignoreLabel;
	NSDictionary *triggersByEvent;
}

@property (retain) id eventTriggerObject;
@property (retain) NSMutableSet *activeProviders;

+ (id)sharedInstance;
- (IBAction)updateTrigger:(id)sender;
- (IBAction)setEventType:(id)sender;

-(void)handleTriggerEvent:(NSString *)event withObject:(id)object;
- (void)setEventTriggerObject:(id)newEventTriggerObject;
@property (strong) IBOutlet NSArrayController *matchObjects;
@property (strong) IBOutlet NSArrayController *ignoreObjects;
@end
