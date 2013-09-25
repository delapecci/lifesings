//
// Created by lichong on 13-7-22.
// Copyright (c) 2013 Li Chong. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LSNoteSequencePlayer.h"
#import "LSNoteSequence.h"
#import "LSSoundPlayerUtil.h"


@implementation LSNoteSequencePlayer {
    LSNoteSequence *_sequence;
    CGFloat _speed;

    NSTimer *_playTimer;
    NSUInteger _playIndex;
}

- (void)dealloc {
    [self stopTimer];
}

- (id)initWithNoteSequence:(LSNoteSequence *)sequence andSpeed:(CGFloat)speed {
    if (self = [super init]) {
        _sequence = sequence;
        _speed = speed;
    }
    return self;
}

- (void)play {
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        [LSSoundPlayerUtil sharedSouncBankPlayer];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startTimer];
        });
    });
}

- (void) stop {
    [self stopTimer];
}

# pragma mark - Play days music timer
- (void)startTimer
{
    _playIndex = 0;
    [self.delegate willStarPlayAtIndex:0];
    _playTimer = [NSTimer scheduledTimerWithTimeInterval:_speed  // 500 ms
                                                  target:self
                                                selector:@selector(handleTimer:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopTimer
{
    if (_playTimer != nil && [_playTimer isValid])
    {
        [_playTimer invalidate];
        _playTimer = nil;
    }
    // 返回第一行
    [self.delegate didStopPlayAtIndex:_playIndex];
}

- (void)handleTimer:(NSTimer *)timer
{
    if (![_sequence hasNextNote]) {
        [self stopTimer];
    } else {
        int _note = [_sequence nextNote];
        switch (_note) {
            case -1: {
                // 延续当前音
                break;
            }
            case -2: {
                //TODO: 休止符
                _playIndex++;
                break;
            }
            default: {
                // TODO: delegate
                [self.delegate willPlayNoteAtIndex:_playIndex];
                _playIndex++;
                // 播放
                SoundBankPlayer *sbp = [LSSoundPlayerUtil sharedSouncBankPlayer];
                [sbp noteOn:_note gain:.6f];
                break;
            }
        }
    }
}
@end