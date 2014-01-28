//
//  QSEventTriggerRestrictionController.m
//  QSEventTriggersElement
//
//  Created by Rob McBroom on 2014/01/27.
//
//

#import "QSEventTriggerRestrictionController.h"

@implementation QSEventTriggerRestrictionController

- (void)windowDidLoad
{
    [super windowDidLoad];
    // set up the results window position
    [dSelector setPreferredEdge:NSMaxXEdge];
    [dSelector setResultsPadding:NSMinX([dSelector frame])];
    [dSelector setPreferredEdge:NSMinY([dSelector frame])];
    [(QSWindow *)[dSelector->resultController window] setShowOffset:NSMakePoint(NSMaxX([dSelector frame]), 0)];
}

- (BOOL)windowShouldClose:(id)sender
{
    return YES;
}

- (void)willHideMainWindow:(id)sender
{
    [dSelector clearObjectValue];
    [super willHideMainWindow:sender];
}

- (IBAction)executeCommand:(id)sender {
    // save the restrictions
    //NSLog(@"adding restriction type %@: %@", self.restrictionType, [dSelector objectValue]);
    NSDictionary *typeMap = @{@"addMatch": @"matchList", @"addIgnore": @"ignoreList"};
    NSString *listKey = typeMap[self.restrictionType];
    NSArray *currentList = [self.trigger objectForKey:listKey];
    NSMutableSet *newList = [NSMutableSet setWithArray:currentList];
    for (QSObject *obj in [[dSelector objectValue] splitObjects]) {
        [newList addObject:[obj identifier]];
    }
    [self.trigger setObject:[newList allObjects] forKey:listKey];
    [[QSTriggerCenter sharedInstance] triggerChanged:self.trigger];
    [self hideMainWindow:self];
}

- (id)representedObject
{
    // unsed here, but gets called by [super windowDidLoad]
    return nil;
}

@end
