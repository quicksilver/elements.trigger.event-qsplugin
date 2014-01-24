//
//  QSMouseTriggerManager.m
//  Quicksilver
//
//  Created by Nicholas Jitkoff on Sun Jun 13 2004.
//

#import "QSEventTriggerManager.h"
#define QSTriggerCenter NSClassFromString(@"QSTriggerCenter")
@implementation QSEventTriggerManager

@synthesize eventTriggerObject;

-(NSString *)name{
	return @"Event";
}
-(NSImage *)image{
	NSImage *image=[[[QSResourceManager imageNamed:@"General"]copy]autorelease];
	[image setSize:NSMakeSize(16,16)];
	return image;
}
- (void)initializeTrigger:(NSMutableDictionary *)trigger{
}

+ (id)sharedInstance{
    static QSEventTriggerManager *_sharedInstance = nil;
    if (!_sharedInstance){
        _sharedInstance = [[[self class] allocWithZone:[self zone]] init];
    }
    return _sharedInstance;
}

- (id) init{
    if (self=[super init]){
		triggersByEvent=[[NSMutableDictionary alloc]init];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventTriggered:) name:QSEventNotification object:nil];
		[self addObserver:self
			   forKeyPath:@"currentTrigger"
				  options:0
				  context:nil];
	}
    return self;
} 

- (NSMutableArray *)triggerObjects
{
    return [NSMutableArray array];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	[self populateInfoFields];
}
-(void)eventTriggered:(NSNotification *)notif{
	id object=[notif userInfo];
	if ([object isKindOfClass:[NSDictionary class]])object=[object objectForKey:@"object"];
	[self handleTriggerEvent:[notif object] withObject:object];	
}

-(NSMutableArray *)triggerArrayForEvent:(NSString *)event{
	if (!event)return nil;
	NSMutableArray *array=[triggersByEvent objectForKey:event];
	if (!array)
		[triggersByEvent setValue:(array=[NSMutableArray array]) forKey:event];
	return array;
}

-(BOOL)enableTrigger:(QSTrigger *)entry{
	NSString *event=[entry objectForKey:kQSEventTrigger];
	NSDictionary *eventInfo=[[QSReg tableNamed:kQSTriggerEvents]objectForKey:event];
	NSString *providerClass=[eventInfo objectForKey:@"provider"];
	id provider=[QSReg getClassInstance:providerClass];
	
	NSMutableArray *triggerArray=[self triggerArrayForEvent:event];
	if ([triggerArray count]==0){
		if ([provider respondsToSelector:@selector(enableEventObserving:)])
			[provider enableEventObserving:event];
	}
    if (![triggerArray containsObject:entry]) {
        [triggerArray addObject:entry];
        if ([provider respondsToSelector:@selector(addObserverForEvent:trigger:)]) {
            [provider addObserverForEvent:event trigger:entry];
        }
    }
    return YES;
}



-(BOOL)disableTrigger:(QSTrigger *)entry{
	NSString *event=[entry objectForKey:kQSEventTrigger];
	NSDictionary *eventInfo=[[QSReg tableNamed:kQSTriggerEvents]objectForKey:event];
	NSString *providerClass=[eventInfo objectForKey:@"provider"];
	id provider=[QSReg getClassInstance:providerClass];
	
	NSMutableArray *triggerArray=[self triggerArrayForEvent:event];
	
	if ([provider respondsToSelector:@selector(removeObserverForEvent:trigger:)])
		[provider removeObserverForEvent:event trigger:entry];
	
	[triggerArray removeObject:entry];
	
	if ([triggerArray count]==0){
		if ([provider respondsToSelector:@selector(disableEventObserving:)])
			[provider disableEventObserving:event];
	}
    return YES;
}


-(void)handleTriggerEvent:(NSString *)event withObject:(id)object{
	//if (VERBOSE)	NSLog(@"Event:%@\r%@",event, object);
	[self setEventTriggerObject:object];
    NSString *objectID = [object respondsToSelector:@selector(identifier)] ? [object identifier] : @"";
    NSArray *matchList, *ignoreList = nil;
	for (QSTrigger *trigger in [self triggerArrayForEvent:event]){
        // see if trigger should fire based on defined restrictions
        matchList = [trigger objectForKey:kQSEventTriggerMatch];
        ignoreList = [trigger objectForKey:kQSEventTriggerIgnore];
        if (([matchList count] && ![matchList containsObject:objectID])
            || [ignoreList containsObject:objectID]) {
            continue;
        }
        // execute trigger
        BOOL delay = [[trigger objectForKey:kQSEventTriggerDelay] boolValue];
		float duration=[[trigger objectForKey:kQSEventTriggerDelayDuration] floatValue];
		BOOL oneTime=[[trigger objectForKey:kQSEventTriggerOneTime] boolValue];
		
		if (delay && duration) {
            [trigger performSelector:@selector(execute) withObject:nil afterDelay:duration extend:oneTime];
		} else {
			[trigger execute];
		}
	}
}

- (NSString *)descriptionForTrigger:(NSDictionary *)dict{
	NSString *event=[dict objectForKey:kQSEventTrigger];
	NSDictionary *eventInfo=[[QSReg tableNamed:kQSTriggerEvents]objectForKey:event];
	return [eventInfo objectForKey:kQSEventTriggerName];
}

- (NSView *) settingsView{
    if (!settingsView){
        [NSBundle loadNibNamed:@"QSEventTrigger" owner:self];
	}
    return [[settingsView retain] autorelease];
}

- (IBAction)updateTrigger:(id)sender{
	[[QSTriggerCenter sharedInstance] triggerChanged:[self currentTrigger]];
}

- (IBAction)setEventType:(id)sender{
    NSString *triggerEvent = [[sender selectedItem] representedObject];
    NSDictionary *events = [QSReg tableNamed:kQSTriggerEvents];
    NSDictionary *event = [events objectForKey:triggerEvent];
	[self disableTrigger:[self currentTrigger]];
	[[self currentTrigger] setObject:triggerEvent forKey:kQSEventTrigger];
	[[QSTriggerCenter sharedInstance] triggerChanged:[self currentTrigger]];
	[self enableTrigger:[self currentTrigger]];
    BOOL noMatching = ![[event objectForKey:kQSEventTriggerAllowMatching] boolValue];
    [matchLabel setHidden:noMatching];
    [ignoreLabel setHidden:noMatching];
}

- (void)populateInfoFields{
	//QSTrigger *thisTrigger=[self currentTrigger];
	//	NSLog(@"populate for %@",thisTrigger);
	[eventPopUp removeAllItems];
	
	NSDictionary *events=[QSReg tableNamed:kQSTriggerEvents];
	
	
	NSSortDescriptor *typeDesc=[NSSortDescriptor descriptorWithKey:@"type" ascending:YES];
	NSSortDescriptor *nameDesc=[NSSortDescriptor descriptorWithKey:@"name" ascending:YES];
	
	NSDictionary *event;
	NSString *type=nil;
	NSMenuItem *item=nil;
	for (NSString *key in [events keysSortedByValueUsingDescriptors:[NSArray arrayWithObjects:typeDesc,nameDesc,nil]]) {
		event=[events objectForKey:key];
		NSString *newType=[event objectForKey:@"type"];
		if (![type isEqualToString:newType]){
			type=newType;
			if (type){
				if ([[eventPopUp menu]numberOfItems])
					[[eventPopUp menu]addItem:[NSMenuItem separatorItem]];
				item=[[eventPopUp menu]addItemWithTitle:type action:nil keyEquivalent:@""];
				[item setTarget:self];
				[item setEnabled:NO];
			}
		}
		item=[[eventPopUp menu]addItemWithTitle:[event objectForKey:kQSEventTriggerName]
										 action:nil
								  keyEquivalent:@""];
		//	NSLog(@"Event %@",[event objectForKey:kQSEventTriggerName]);
		NSImage *image=[[QSResourceManager imageNamed:[event objectForKey:@"icon"]]duplicateOfSize:NSMakeSize(16,16)];
		[item setImage:image];
		[item setRepresentedObject:key];
	}
    NSString *triggerEvent = [[self currentTrigger] objectForKey:kQSEventTrigger];
	NSInteger index = [[eventPopUp menu]indexOfItemWithRepresentedObject:triggerEvent];
	[eventPopUp selectItemAtIndex:index];
    event = [events objectForKey:triggerEvent];
    BOOL matching = [[event objectForKey:kQSEventTriggerAllowMatching] boolValue];
    [matchLabel setHidden:!matching];
    [ignoreLabel setHidden:!matching];
}

- (IBAction) setMouseTriggerValueForSender:(id)sender{
	
	[self populateInfoFields];
}




-(id)resolveProxyObject:(id)proxy{
	return [self eventTriggerObject];
}

-(NSArray *)typesForProxyObject:(id)proxy{
	return [[self eventTriggerObject]types];
}

- (NSTimeInterval)cacheTimeForProxy:(id)proxy
{
    return 0.0;
}

@end
