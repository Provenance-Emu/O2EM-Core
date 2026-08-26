//
//  PVO2EM.h
//  PVO2EM
//
//  Created by Joseph Mattiello on 12/15/21.
//

#import <Foundation/Foundation.h>

//! Project version number for PVO2EM.
FOUNDATION_EXPORT double PVO2EMVersionNumber;

//! Project version string for PVO2EM.
FOUNDATION_EXPORT const unsigned char PVO2EMVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PVO2EM/PublicHeader.h>
// The framework form only resolves in the Xcode build; SwiftPM lays public headers
// out flat, so fall back to the sibling path there.
#if __has_include(<PVO2EM/OdysseyGameCore.h>)
#import <PVO2EM/OdysseyGameCore.h>
#else
#import "OdysseyGameCore.h"
#endif
