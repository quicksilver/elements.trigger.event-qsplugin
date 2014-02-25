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
@end
