//
//  QSAudioOutputEvents.h
//  QSEventTriggersElement
//
//  Created by Rob McBroom on 2014/02/05.
//
//

#import "QSEventTriggerManager.h"
#import <CoreAudio/CoreAudio.h>

#define kQSHeadphonesActiveEvent @"QSHeadphonesActiveEvent"
#define kQSInternalSpeakersActiveEvent @"QSInternalSpeakersActiveEvent"
#define kQSOpticalActiveEvent @"QSOpticalActiveEvent"

@interface QSAudioOutputEvents : NSObject <QSEventTriggerProvider> {
    AudioDeviceID defaultDevice;
    AudioObjectPropertyAddress sourceAddr;
}

@property (retain) NSMutableDictionary *listenerBlocks;

@end
