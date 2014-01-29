//
//  QSBasicEventTriggers.m
//  QSEventTriggersPlugIn
//
//  Created by Nicholas Jitkoff on 1/22/05.
//

#import "QSBasicEventTriggers.h"
#import "QSEventTriggerManager.h"

#define kQSHeadphonesActiveEvent @"QSHeadphonesActiveEvent"
#define kQSInternalSpeakersActiveEvent @"QSInternalSpeakersActiveEvent"
#define kQSAirplayActiveEvent @"QSAirplayActiveEvent"
#define kQSOpticalActiveEvent @"QSOpticalActiveEvent"

@implementation QSBasicEventTriggers
-(id)init{
	if (self=[super init]){
        wsmap = [NSDictionary dictionaryWithObjectsAndKeys:
                 NSWorkspaceWillSleepNotification, @"QSWorkspaceWillSleepEvent",
                 NSWorkspaceDidWakeNotification, @"QSWorkspaceDidWakeEvent",
                 NSWorkspaceWillPowerOffNotification, @"QSWorkspaceWillPowerOffEvent",
                 NSWorkspaceSessionDidResignActiveNotification, @"QSWorkspaceSessionDidResignActiveEvent",
                 NSWorkspaceSessionDidBecomeActiveNotification, @"QSWorkspaceSessionDidBecomeActiveEvent",
                 NSWorkspaceActiveSpaceDidChangeNotification, @"QSActiveSpaceChangedEvent",
                 NSWorkspaceDidMountNotification, @"QSWorkspaceDidMountEvent",
                 NSWorkspaceWillUnmountNotification, @"QSWorkspaceWillUnmountEvent",
                 NSWorkspaceDidUnmountNotification, @"QSWorkspaceDidUnmountEvent",
                 nil];
        distmap = [NSDictionary dictionaryWithObjectsAndKeys:
                   @"com.apple.internetconfignotification", @"QSEthernetConfigurationChanged",
                   @"com.apple.screensaver.didstart", @"QSScreensaverStartedEvent",
                   @"com.apple.screensaver.didstop", @"QSScreensaverStoppedEvent",
                   @"com.apple.BezelServices.BMDisplayHWReconfiguredEvent", @"QSExternalDisplayChanged",
                   nil];
        [self discoverAudioDeviceProperties];
        _listenerBlocks = [[NSMutableDictionary alloc] init];
        [self defineListenerBlockFor:kQSHeadphonesActiveEvent deviceID:'hdpn'];
        [self defineListenerBlockFor:kQSInternalSpeakersActiveEvent deviceID:'ispk'];
	}
	return self;
}

- (void)discoverAudioDeviceProperties
{
    defaultDevice = 0;
    UInt32 defaultSize = sizeof(AudioDeviceID);
    
    const AudioObjectPropertyAddress defaultAddr = {
        kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };
    AudioObjectGetPropertyData(kAudioObjectSystemObject, &defaultAddr, 0, NULL, &defaultSize, &defaultDevice);
    
    sourceAddr.mSelector = kAudioDevicePropertyDataSource;
    sourceAddr.mScope = kAudioDevicePropertyScopeOutput;
    sourceAddr.mElement = kAudioObjectPropertyElementMaster;
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
    if ([self.listenerBlocks objectForKey:event]) {
        [self monitorAudioOutputDeviceFor:event];
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
    if ([self.listenerBlocks objectForKey:event]) {
        [self ignoreAudioOutputDeviceFor:event];
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

- (void)defineListenerBlockFor:(NSString *)audioDeviceEvent deviceID:(UInt32)targetSourceID
{
    AudioObjectPropertyListenerBlock listenerBlock = ^(UInt32 inNumberAddresses, const AudioObjectPropertyAddress *inAddresses) {
        UInt32 bDataSourceId = 0;
        UInt32 bDataSourceIdSize = sizeof(UInt32);
        AudioObjectGetPropertyData(defaultDevice, inAddresses, 0, NULL, &bDataSourceIdSize, &bDataSourceId);
        if (bDataSourceId == targetSourceID) {
            [[QSEventTriggerManager sharedInstance] handleTriggerEvent:audioDeviceEvent withObject:nil];
        }
    };
    
    [self.listenerBlocks setObject:listenerBlock forKey:audioDeviceEvent];
}

- (void)monitorAudioOutputDeviceFor:(NSString *)audioDeviceEvent
{
    AudioObjectPropertyListenerBlock listenerBlock = [self.listenerBlocks objectForKey:audioDeviceEvent];
    
    AudioObjectAddPropertyListenerBlock(defaultDevice, &sourceAddr, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), listenerBlock);
}

- (void)ignoreAudioOutputDeviceFor:(NSString *)audioDeviceEvent
{
    AudioObjectPropertyListenerBlock listenerBlock = [self.listenerBlocks objectForKey:audioDeviceEvent];
    
    AudioObjectRemovePropertyListenerBlock(defaultDevice, &sourceAddr, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), listenerBlock);
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
