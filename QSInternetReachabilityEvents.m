//
//  QSInternetReachabilityEvents.m
//  QSEventTriggersElement
//
//  Created by Rob McBroom on 2014/02/04.
//
//

#import "QSInternetReachabilityEvents.h"
#import "Reachability.h"

@implementation QSInternetReachabilityEvents

- (void)enableEventProvider
{
    if (!_reach) {
        _reach = [Reachability reachabilityForInternetConnection];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetStatusChanged:) name:kReachabilityChangedNotification object:nil];
        _lastKnownState = _reach.isReachable;
        [_reach startNotifier];
    }
}

- (void)disableEventProvider
{
    [_reach stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    _reach = nil;
}

- (void)internetStatusChanged:(NSNotification *)notif
{
    // [notif object] == _reach, so we can use either one
    if (_reach.isReachable == _lastKnownState) {
        // nothing changed, or this event was triggered at launch
        // these notifications tend to come 4 at a time, with only one signifying a change
        return;
    }
    NSString *event = _reach.isReachable ? @"QSInternetReachableEvent" : @"QSInternetUnreachableEvent";
    _lastKnownState = _reach.isReachable;
    [[QSEventTriggerManager sharedInstance] handleTriggerEvent:event withObject:nil];
}

@end
