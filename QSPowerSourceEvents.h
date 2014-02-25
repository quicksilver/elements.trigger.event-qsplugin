//
//  QSPowerSourceEvents.h
//  QSEventTriggersElement
//
//  Created by Rob McBroom on 2014/02/20.
//
//

#import "QSEventTriggerManager.h"

@interface QSPowerSourceEvents : NSObject <QSEventTriggerProvider> {
    CFRunLoopSourceRef rls;
}

@end
