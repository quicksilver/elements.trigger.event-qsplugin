//
//  QSInternetReachabilityEvents.h
//  QSEventTriggersElement
//
//  Created by Rob McBroom on 2014/02/04.
//
//

#import "QSEventTriggerManager.h"

@class Reachability;

@interface QSInternetReachabilityEvents : NSObject

@property (readonly, retain) Reachability *reach;
@property (assign) BOOL lastKnownState;

@end
