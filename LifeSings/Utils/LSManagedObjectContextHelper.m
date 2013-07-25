//
//  LSManagedObjectContextHelper.m
//  LifeSings
//
//  Created by lichong on 13-7-11.
//  Copyright (c) 2013年 Li Chong. All rights reserved.
//

#import "LSManagedObjectContextHelper.h"
#import "LSAppDelegate.h"

@implementation LSManagedObjectContextHelper
+(NSManagedObjectContext *) getDefaultMOC {
    LSAppDelegate *delegate = (LSAppDelegate *) [[UIApplication sharedApplication] delegate];
    return [delegate managedObjectContext];
}
@end
