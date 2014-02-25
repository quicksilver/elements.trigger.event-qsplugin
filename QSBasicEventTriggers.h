//
//  QSBasicEventTriggers.h
//  QSEventTriggersPlugIn
//
//  Created by Nicholas Jitkoff on 1/22/05.
//

#import "QSEventTriggerManager.h"

@interface QSBasicEventTriggers : NSObject <QSEventTriggerProvider> {
    NSDictionary *wsmap;
    NSDictionary *distmap;
}

@end
