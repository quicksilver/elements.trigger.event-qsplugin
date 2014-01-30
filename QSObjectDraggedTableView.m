//
//  QSObjectDraggedTableView.m
//  QSEventTriggersElement
//
//  Created by Patrick Robertson on 30/01/2014.
//
//

#import "QSObjectDraggedTableView.h"
#import "QSEventTriggerManager.h"

@implementation QSObjectDraggedTableView

- (void)awakeFromNib
{
    [self registerForDraggedTypes:@[QSPasteboardObjectIdentifier, QSPasteboardObjectAddress, NSFilenamesPboardType, QSFilePathType, QSTextType, NSStringPboardType, NSURLPboardType, (__bridge NSString *)kUTTypeURL]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    return NSDragOperationGeneric;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    return NSDragOperationGeneric;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *draggingPboard = [sender draggingPasteboard];
    QSObject *pasteboardObject = [QSObject objectWithPasteboard:draggingPboard];
    for (QSObject *obj in [pasteboardObject splitObjects]) {
        NSString *ident = [obj identifier];
        if (![[self.arrayController arrangedObjects] containsObject:ident]) {
            [self.arrayController addObject:ident];
        }
    }
    return YES;
}
@end
