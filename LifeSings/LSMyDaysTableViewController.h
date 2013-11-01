//
//  BWDaysTableViewController.h
//  TaggedLocations
//
//  Created by lichong on 13-7-3.
//  Copyright (c) 2013年 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSNoteSequencePlayer.h"
#import "LSMyDayTableViewCell.h"

@interface LSMyDaysTableViewController : UITableViewController<SequencePlayerDelegate, SWTableViewCellDelegate, SmileSliderChangedDelegate>
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@end
