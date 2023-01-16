/*
 Copyright (c) 2022, Provenance EMU Team
 */

@import Foundation;
@import PVSupport;

PVCORE_DIRECT_MEMBERS
@interface OdysseyGameCore : PVEmulatorCore <PVOdyssey2SystemResponderClient> {
    NSDictionary *virtualPhysicalKeyMap;
}
@end
