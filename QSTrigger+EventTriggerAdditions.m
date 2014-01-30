//
//  QSTrigger+EventTriggerAdditions.m
//  QSEventTriggersElement
//
//  Created by Patrick Robertson on 30/01/2014.
//
//

#import "QSTrigger+EventTriggerAdditions.h"
#import "QSEventTriggerManager.h"

@implementation QSTrigger (EventTriggerAdditions)


- (NSMutableArray *)matchList {
    NSMutableArray *matchList = [self objectForKey:kQSEventTriggerMatch];
    if (!matchList) {
        matchList = [NSMutableArray array];
        [self setObject:matchList forKey:kQSEventTriggerMatch];
    }
    return matchList;
}

- (NSMutableArray *)ignoreList {
    NSMutableArray *ignoreList = [self objectForKey:kQSEventTriggerIgnore];
    if (!ignoreList) {
        ignoreList = [NSMutableArray array];
        [self setObject:ignoreList forKey:kQSEventTriggerIgnore];
    }
    return ignoreList;
}

@end
