//
//  QSObjectDraggedTableView.h
//  QSEventTriggersElement
//
//  Created by Patrick Robertson on 30/01/2014.
//
//

#import <Cocoa/Cocoa.h>
@class QSEventTriggerManager;

@interface QSObjectDraggedTableView : NSTableView <NSDraggingDestination>

@property IBOutlet NSArrayController *objects;

@end
