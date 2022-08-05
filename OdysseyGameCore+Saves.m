#import "OdysseyGameCore.h"
#include "vmachine.h"

@implementation OdysseyGameCore (Saves)
#pragma mark - Saves

- (void)saveStateToFileAtPath:(NSString *)fileName completionHandler:(void (^)(BOOL, NSError *))block {
    block(savestate(fileName.fileSystemRepresentation) ? YES : NO, nil);
}

- (void)loadStateFromFileAtPath:(NSString *)fileName completionHandler:(void (^)(BOOL, NSError *))block {
    block(loadstate(fileName.fileSystemRepresentation) ? YES : NO, nil);
}

@end
