//
//  LSSoundPlayerUtil.m
//  LifeSings
//
//  Created by lichong on 13-7-12.
//  Copyright (c) 2013年 Li Chong. All rights reserved.
//

#import "LSSoundPlayerUtil.h"
#import "SoundBankPlayer.h"

@implementation LSSoundPlayerUtil
+ (SoundBankPlayer *)sharedSouncBankPlayer
{
    static dispatch_once_t pred;
    static SoundBankPlayer *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[SoundBankPlayer alloc]init];
        [instance setSoundBank:@"Piano"];
    });
    return instance;
}
@end
