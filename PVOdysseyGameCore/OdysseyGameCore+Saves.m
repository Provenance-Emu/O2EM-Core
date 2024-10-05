#import "OdysseyGameCore.h"
#import "vmachine.h"

@import PVCoreBridge;
@import PVEmulatorCore;

@implementation OdysseyGameCoreBridge (Saves)
#pragma mark - Saves

- (void)saveStateToFileAtPath:(NSString *)fileName completionHandler:(void (^)(NSError *))block {
    int saved = savestate(fileName.fileSystemRepresentation);
    if (saved == 0) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Failed to save state.",
            NSLocalizedFailureReasonErrorKey: @"O2EM failed to save state.",
            NSLocalizedRecoverySuggestionErrorKey: @"."
        };
        
        NSError *newError = [NSError errorWithDomain:CoreError.PVEmulatorCoreErrorDomain
                                                code:PVEmulatorCoreErrorCodeCouldNotSaveState
                                            userInfo:userInfo];
        block(newError);
    } else {
        block(nil);
    }
}

- (BOOL)loadStateToFileAtPath:(NSString * _Nonnull)path error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    int loaded = loadstate(path.fileSystemRepresentation);
    if (loaded == 0) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Failed to save state.",
            NSLocalizedFailureReasonErrorKey: @"O2EM failed to save state.",
            NSLocalizedRecoverySuggestionErrorKey: @"."
        };
        
        NSError *newError = [NSError errorWithDomain:CoreError.PVEmulatorCoreErrorDomain
                                                code:PVEmulatorCoreErrorCodeCouldNotLoadState
                                            userInfo:userInfo];
        *error = newError;
        return false;
    } else {
        return true;
    }
}

@end
