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
#define kQSOpticalActiveEvent @"QSOpticalActiveEvent"

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
        [self discoverAudioDeviceProperties];
        _listenerBlocks = [[NSMutableDictionary alloc] init];
        [self registerListenerBlockForEvent:kQSHeadphonesActiveEvent deviceID:'hdpn'];
        [self registerListenerBlockForEvent:kQSInternalSpeakersActiveEvent deviceID:'ispk'];
        [self registerListenerBlockForEvent:kQSOpticalActiveEvent deviceID:'spdf'];
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
        [self monitorAudioOutputDeviceForEvent:event];
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
        [self ignoreAudioOutputDeviceForEvent:event];
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

- (void)registerListenerBlockForEvent:(NSString *)audioDeviceEvent deviceID:(FourCharCode)targetSourceID
{
    AudioObjectPropertyListenerBlock listenerBlock = ^(UInt32 inNumberAddresses, const AudioObjectPropertyAddress *inAddresses) {
        FourCharCode bDataSourceId = 0;
        UInt32 bDataSourceIdSize = sizeof(FourCharCode);
        AudioObjectGetPropertyData(defaultDevice, inAddresses, 0, NULL, &bDataSourceIdSize, &bDataSourceId);
        if (bDataSourceId == targetSourceID) {
            [[QSEventTriggerManager sharedInstance] handleTriggerEvent:audioDeviceEvent withObject:nil];
        }
    };
    
    [self.listenerBlocks setObject:listenerBlock forKey:audioDeviceEvent];
}

- (void)monitorAudioOutputDeviceForEvent:(NSString *)audioDeviceEvent
{
    AudioObjectPropertyListenerBlock listenerBlock = [self.listenerBlocks objectForKey:audioDeviceEvent];
    
    AudioObjectAddPropertyListenerBlock(defaultDevice, &sourceAddr, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), listenerBlock);
}

- (void)ignoreAudioOutputDeviceForEvent:(NSString *)audioDeviceEvent
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
