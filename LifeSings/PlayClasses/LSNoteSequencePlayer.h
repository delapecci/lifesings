//
// Created by lichong on 13-7-22.
// Copyright (c) 2013 Li Chong. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "LSNoteSequence.h"
@class LSNoteSequence;

#pragma mark - 音符序列播放器协议
@protocol SequencePlayer <NSObject>
@required
- (void)play;

@optional
- (void)pause;
- (void)resume;
- (void)stop;
@end

#pragma mark - 音符序列播放器回调协议
@protocol SequencePlayerDelegate <NSObject>
- (void)willPlayNoteAtIndex:(NSInteger)index;
- (void)willStarPlayAtIndex:(NSInteger)index;
- (void)didStopPlayAtIndex:(NSInteger)index;
@end

@interface LSNoteSequencePlayer : NSObject<SequencePlayer>
@property (nonatomic) id delegate;
- (id)initWithNoteSequence:(LSNoteSequence *)sequence andSpeed:(CGFloat)speed;
@end