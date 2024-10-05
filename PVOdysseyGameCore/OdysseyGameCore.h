/*
 Copyright (c) 2022, Provenance EMU Team
 */

@import Foundation;
//@import PVEmulatorCore;
//@import PVCoreBridge;
@import PVCoreObjCBridge;

@protocol ObjCBridgedCoreBridge;
@protocol PVOdyssey2SystemResponderClient;
@protocol KeyboardResponder;
typedef enum PVOdyssey2Button: NSInteger PVOdyssey2Button;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything" // Silence "Cannot find protocol definition" warning due to forward declaration.
@interface OdysseyGameCoreBridge : PVCoreObjCBridge <ObjCBridgedCoreBridge> {
#pragma clang diagnostic pop
    NSDictionary *virtualPhysicalKeyMap;
}
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything" // Silence "Cannot find protocol definition" warning due to forward declaration.
@interface OdysseyGameCoreBridge (Controls) <PVOdyssey2SystemResponderClient, KeyboardResponder>
#pragma clang diagnostic pop
- (void)keyDown:(unsigned short)keyCode;
- (void)keyUp:(unsigned short)keyCode;
- (void)didPushOdyssey2Button:(PVOdyssey2Button)button forPlayer:(NSInteger)player;
- (void)didReleaseOdyssey2Button:(PVOdyssey2Button)button forPlayer:(NSInteger)player;
@end
NS_HEADER_AUDIT_END(nullability, sendability)
