/*
 Copyright (c) 2022, Provenance EMU Team
 */

@import Foundation;
@import PVSupport;

__attribute__((visibility("default")))
@interface OdysseyGameCore : PVEmulatorCore <PVOdyssey2SystemResponderClient> {
    NSDictionary *virtualPhysicalKeyMap;
}
@end
