//
//  QSBasicEventTriggers.h
//  QSEventTriggersPlugIn
//
//  Created by Nicholas Jitkoff on 1/22/05.
//

#import <CoreAudio/CoreAudio.h>

@interface QSBasicEventTriggers : NSObject {
    NSDictionary *wsmap;
    NSDictionary *distmap;
    AudioDeviceID defaultDevice;
    AudioObjectPropertyAddress sourceAddr;
}

@property (retain) NSMutableDictionary *listenerBlocks;

@end
