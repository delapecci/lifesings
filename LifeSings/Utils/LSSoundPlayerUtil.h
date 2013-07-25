//
//  LSSoundPlayerUtil.h
//  LifeSings
//
//  Created by lichong on 13-7-12.
//  Copyright (c) 2013年 Li Chong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundBankPlayer.h"

@interface LSSoundPlayerUtil : NSObject
+ (SoundBankPlayer *)sharedSouncBankPlayer;
@end
