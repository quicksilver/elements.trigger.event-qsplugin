//
//  QSPowerSourceEvents.m
//  QSEventTriggersElement
//
//  Created by Rob McBroom on 2014/02/20.
//
//

#import "QSPowerSourceEvents.h"
#import <IOKit/ps/IOPowerSources.h>

void handlePowerSourceChange(void *context)
{
    NSDictionary *powerEvents = @{
      @"AC Power": @"QSPowerSourceACEvent",
      @"Battery Power": @"QSPowerSourceBatteryEvent",
      @"UPS Power": @"QSPowerSourceUPSEvent",
    };
    CFTypeRef powerInfo = IOPSCopyPowerSourcesInfo();
    NSString *powerSource = (__bridge NSString*)IOPSGetProvidingPowerSourceType(powerInfo);
    NSString *event = [powerEvents objectForKey:powerSource];
    [[QSEventTriggerManager sharedInstance] handleTriggerEvent:event withObject:nil];
}

@implementation QSPowerSourceEvents

- (void)enableEventProvider
{
    // at least one event needs power state information
    rls = IOPSNotificationCreateRunLoopSource(handlePowerSourceChange, NULL);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
}

- (void)disableEventProvider
{
    // test for NULL first, because Quicksilver tends to disable triggers over and over
    if (rls) {
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
        CFRelease(rls);
        rls = NULL;
    }
}

@end
