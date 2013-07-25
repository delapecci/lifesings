//
//  BWDaysTableViewController.h
//  TaggedLocations
//
//  Created by lichong on 13-7-3.
//  Copyright (c) 2013年 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSNoteSequencePlayer.h"

@interface LSMyDaysTableViewController : UITableViewController<SequencePlayerDelegate>
@property (nonatomic) NSManagedObjectContext *managedObjectContext;	   
@end
