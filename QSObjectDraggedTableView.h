//
//  QSObjectDraggedTableView.h
//  QSEventTriggersElement
//
//  Created by Patrick Robertson on 30/01/2014.
//
//

@class QSEventTriggerManager;

@interface QSObjectDraggedTableView : NSTableView <NSDraggingDestination>

@property IBOutlet NSArrayController *arrayController;

@end
