//
//  QSBasicEventTriggers.m
//  QSEventTriggersPlugIn
//
//  Created by Nicholas Jitkoff on 1/22/05.
//

#import "QSBasicEventTriggers.h"

@implementation QSBasicEventTriggers
-(id)init{
	if (self=[super init]){
        wsmap = @{
            @"QSWorkspaceWillSleepEvent": NSWorkspaceWillSleepNotification,
            @"QSWorkspaceDidWakeEvent": NSWorkspaceDidWakeNotification,
            @"QSWorkspaceWillPowerOffEvent": NSWorkspaceWillPowerOffNotification,
            @"QSWorkspaceSessionDidResignActiveEvent": NSWorkspaceSessionDidResignActiveNotification,
            @"QSWorkspaceSessionDidBecomeActiveEvent": NSWorkspaceSessionDidBecomeActiveNotification,
            @"QSActiveSpaceChangedEvent": NSWorkspaceActiveSpaceDidChangeNotification,
            @"QSWorkspaceDidMountEvent": NSWorkspaceDidMountNotification,
            @"QSWorkspaceWillUnmountEvent": NSWorkspaceWillUnmountNotification,
            @"QSWorkspaceDidUnmountEvent": NSWorkspaceDidUnmountNotification,
        };
        distmap = @{
            @"QSEthernetConfigurationChanged": @"com.apple.internetconfignotification",
            @"QSScreensaverStartedEvent": @"com.apple.screensaver.didstart",
            @"QSScreensaverStoppedEvent": @"com.apple.screensaver.didstop",
            @"QSExternalDisplayChanged": @"com.apple.BezelServices.BMDisplayHWReconfiguredEvent",
        };
	}
	return self;
}

- (void)addObserverForEvent:(NSString *)event trigger:(QSTrigger *)trigger
{
    if ([wsmap objectForKey:event]) {
		NSNotificationCenter *wc = [[NSWorkspace sharedWorkspace] notificationCenter];
        [wc addObserver:self selector:@selector(handleWorkspaceNotification:) name:[wsmap objectForKey:event] object:nil];
    }
    if ([distmap objectForKey:event]) {
        NSDistributedNotificationCenter *dc = [NSDistributedNotificationCenter defaultCenter];
        [dc addObserver:self selector:@selector(handleSystemNotification:) name:[distmap objectForKey:event] object:nil];
    }
}

- (void)removeObserverForEvent:(NSString *)event trigger:(QSTrigger *)trigger
{
    if ([wsmap objectForKey:event]) {
		NSNotificationCenter *wc = [[NSWorkspace sharedWorkspace] notificationCenter];
        [wc removeObserver:self name:[wsmap objectForKey:event] object:nil];
    }
    if ([distmap objectForKey:event]) {
        NSDistributedNotificationCenter *dc = [NSDistributedNotificationCenter defaultCenter];
        [dc removeObserver:self name:[distmap objectForKey:event] object:nil];
    }
}

-(void)handleWorkspaceNotification:(NSNotification *)notif{
    NSString *name = [self nameForEvent:[notif name]];
    if (!name) {
		return;
	}
    id argument = nil;
	NSString *path = [[notif userInfo] objectForKey:@"NSDevicePath"];
    if (path) {
        if ([path isEqualToString:@"/Network"]) {
            return;
        }
        argument = [QSObject fileObjectWithPath:path];
    }
	[[QSEventTriggerManager sharedInstance] handleTriggerEvent:name withObject:argument];
}

- (void)handleSystemNotification:(NSNotification *)notif
{
    NSString *name = [self nameForEvent:[notif name]];
    if (!name) {
		return;
	}
	[[QSEventTriggerManager sharedInstance] handleTriggerEvent:name withObject:nil];
}

- (NSString *)nameForEvent:(NSString *)inName
{
    NSArray *keyList = [[distmap allKeysForObject:inName] arrayByAddingObjectsFromArray:[wsmap allKeysForObject:inName]];
    if ([keyList count]) {
        // should only be one
        return [keyList objectAtIndex:0];
    }
    return nil;
}
@end
