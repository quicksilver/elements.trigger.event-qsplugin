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


- (void)awakeFromNib {
        [self registerForDraggedTypes:@[QSPasteboardObjectIdentifier, QSPasteboardObjectAddress, NSFilenamesPboardType, QSFilePathType, QSTextType, NSStringPboardType, NSURLPboardType, (__bridge NSString *)kUTTypeURL]];
}

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender {
    return NSDragOperationGeneric;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender {
    return NSDragOperationGeneric;
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender {
    return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender {
    NSPasteboard *draggingPboard = [sender draggingPasteboard];
    QSObject *pasteboardObject = [QSObject objectWithPasteboard:draggingPboard];
    if ([[self.objects arrangedObjects] containsObject:pasteboardObject]) {
        // Don't add duplicate objects
        return NO;
    }
    
    [self.objects addObject:pasteboardObject];
    return YES;
}

@end
