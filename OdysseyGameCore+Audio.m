#import "OdysseyGameCore.h"

@implementation OdysseyGameCore (Audio)
#pragma mark - Audio

- (NSUInteger)channelCount { return 1; }

- (double) audioSampleRate { return 44100; }
- (NSUInteger)audioBitDepth { return 16; }
@end
