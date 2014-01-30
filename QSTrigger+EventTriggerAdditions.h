//
//  QSTrigger+EventTriggerAdditions.h
//  QSEventTriggersElement
//
//  Created by Patrick Robertson on 30/01/2014.
//
//

#import <QSCore/QSCore.h>

@interface QSTrigger (EventTriggerAdditions)

-(NSMutableArray *)ignoreList;
-(NSMutableArray *)matchList;

@end
