//
//  QSObjectValueTransformerET.m
//  QSEventTriggersElement
//
//  Created by Rob McBroom on 2014/01/23.
//
//

#import "QSObjectValueTransformerET.h"

@implementation QSObjectValueTransformerET

- (Class)transformedValueClass
{
    return [NSMutableArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (NSMutableArray *)transformedValue:(NSArray *)objectIDs
{
    // turn an array of identifiers into an array of QSObjects
    if ([objectIDs count]) {
        NSMutableArray *objects = [[NSMutableArray alloc] init];
        QSObject *restriction = nil;
        for (NSString *ident in objectIDs) {
            restriction = [QSLib objectWithIdentifier:ident];
            if (!restriction) {
                restriction = [QSObject objectWithString:ident];
            }
            [objects addObject:restriction];
        }
        return objects;
    }
    return nil;
}

- (NSMutableArray *)reverseTransformedValue:(NSArray *)objects
{
    // turn an array of QSObjects into an array of identifiers
    return [objects arrayByPerformingSelector:@selector(identifier)];
}

@end
