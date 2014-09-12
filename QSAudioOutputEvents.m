//
//  QSAudioOutputEvents.m
//  QSEventTriggersElement
//
//  Created by Rob McBroom on 2014/02/05.
//
//

#import "QSAudioOutputEvents.h"

@implementation QSAudioOutputEvents

- (id)init
{
    self = [super init];
    if (self) {
        // discover and cache audio device properties
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
        
        _listenerBlocks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (AudioObjectPropertyListenerBlock)registerListenerBlockForEvent:(NSString *)audioDeviceEvent deviceID:(FourCharCode)targetSourceID
{
    AudioObjectPropertyListenerBlock listenerBlock = ^(UInt32 inNumberAddresses, const AudioObjectPropertyAddress *inAddresses) {
        FourCharCode bDataSourceId = 0;
        UInt32 bDataSourceIdSize = sizeof(FourCharCode);
        AudioObjectGetPropertyData(defaultDevice, inAddresses, 0, NULL, &bDataSourceIdSize, &bDataSourceId);
        if (bDataSourceId == targetSourceID) {
            [[QSEventTriggerManager sharedInstance] handleTriggerEvent:audioDeviceEvent withObject:nil];
        }
    };
    // keep a reference to the block in a dictionary so it can be disabled
    [self.listenerBlocks setObject:listenerBlock forKey:audioDeviceEvent];
    
    return listenerBlock;
}

#pragma mark Event Management

- (void)addObserverForEvent:(NSString *)audioDeviceEvent trigger:(QSTrigger *)trigger
{
    AudioObjectPropertyListenerBlock listenerBlock;
    if ([audioDeviceEvent isEqualToString:kQSHeadphonesActiveEvent]) {
        listenerBlock = [self registerListenerBlockForEvent:kQSHeadphonesActiveEvent deviceID:'hdpn'];
    } else if ([audioDeviceEvent isEqualToString:kQSInternalSpeakersActiveEvent]) {
        listenerBlock = [self registerListenerBlockForEvent:kQSInternalSpeakersActiveEvent deviceID:'ispk'];
    } else if ([audioDeviceEvent isEqualToString:kQSOpticalActiveEvent]) {
        listenerBlock = [self registerListenerBlockForEvent:kQSOpticalActiveEvent deviceID:'spdf'];
    }
    
    if (listenerBlock) {
        AudioObjectAddPropertyListenerBlock(defaultDevice, &sourceAddr, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), listenerBlock);
    } else {
        NSLog(@"The event '%@' is not handled by the %@ class", audioDeviceEvent, NSStringFromClass([self class]));
    }
}

- (void)removeObserverForEvent:(NSString *)audioDeviceEvent trigger:(QSTrigger *)trigger
{
    AudioObjectPropertyListenerBlock listenerBlock = [self.listenerBlocks objectForKey:audioDeviceEvent];

    if (listenerBlock) {
        AudioObjectRemovePropertyListenerBlock(defaultDevice, &sourceAddr, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), listenerBlock);
    }
}

@end
