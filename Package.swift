// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PVO2EM",
    platforms: [
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v9),
        .macOS(.v14),
        .macCatalyst(.v17)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PVO2EM",
            targets: ["PVO2EM", "PVO2EMSwift"]),
    ],
    dependencies: [
        .package(path: "../../PVCoreBridge"),
        .package(path: "../../PVCoreObjCBridge"),
        .package(path: "../../PVEmulatorCore"),
        .package(path: "../../PVSupport"),
        .package(path: "../../PVAudio"),
        .package(path: "../../PVLogging"),
        .package(path: "../../PVObjCUtils")
    ],
    targets: [
        .target(
            name: "PVO2EM",
            dependencies: [
                "libo2em",
                "PVEmulatorCore",
                "PVCoreBridge",
                "PVCoreObjCBridge",
                "PVAudio",
                .product(name: "RingBuffer", package: "PVAudio"),
                "PVSupport",
                "PVObjCUtils"
            ],
            path: "PVOdysseyGameCore",
            /* include/PVO2EM.h is the Xcode framework umbrella header; it does
             * `#import <PVO2EM/OdysseyGameCore.h>`, which has no meaning under SPM's
             * flat public-header layout and breaks the generated module. */
            exclude: Sources.swift + ["Resources", "include"],
            sources: Sources.bridge,
            /* "." rather than "include": OdysseyGameCore.h declares the bridge class
             * the Swift target subclasses, and it lives beside the .m files, not in
             * include/ (which holds only the framework umbrella header). */
            publicHeadersPath: ".",
            cSettings: [
                .define("INLINE", to: "inline"),
                .define("USE_STRUCTS", to: "1"),
                .define("__LIBRETRO__", to: "1"),
                .define("HAVE_COCOATOJUCH", to: "1"),
                .define("__GCCUNIX__", to: "1"),
                .headerSearchPath("../libo2em/src"),
                .headerSearchPath("../libo2em/allegrowrapper"),
            ]
        ),

        .target(
            name: "PVO2EMSwift",
            dependencies: [
                "PVEmulatorCore",
                "PVCoreBridge",
                "PVCoreObjCBridge",
                "PVLogging",
                "PVAudio",
                "PVSupport",
                "libo2em",
                "PVO2EM"
            ],
            path: "PVOdysseyGameCore",
            exclude: Sources.bridge + ["include", "Resources/Info.plist"],
            sources: Sources.swift,
            resources: [
                .process("Resources/Core.plist")
            ],
            cSettings: [
                .define("INLINE", to: "inline"),
                .define("USE_STRUCTS", to: "1"),
                .define("__LIBRETRO__", to: "1"),
                .define("HAVE_COCOATOJUCH", to: "1"),
                .define("__GCCUNIX__", to: "1"),
                .headerSearchPath("../libo2em/src"),
                .headerSearchPath("../libo2em/allegrowrapper"),
            ]
        ),

        .target(
            name: "libo2em",
            path: "libo2em",
            sources: Sources.libo2em,
            publicHeadersPath: "src",
            packageAccess: true,
            cSettings: [
                .define("INLINE", to: "inline"),
                .define("USE_STRUCTS", to: "1"),
                .define("__LIBRETRO__", to: "1"),
                .define("HAVE_COCOATOJUCH", to: "1"),
                .define("__GCCUNIX__", to: "1"),
                .headerSearchPath("src"),
                .headerSearchPath("allegrowrapper")
            ]
        )
    ],
    swiftLanguageVersions: [.v5],
    cLanguageStandard: .gnu11,
    cxxLanguageStandard: .gnucxx14
)

enum Sources {
    /* Mirrors the `O2EM` + `allegrowrapper` targets in PVO2EM.xcodeproj.
     * Deliberately omitted: `main.c` (defines `main()`), `system.c` (desktop
     * front end) and `dis48.c` (belongs to the standalone `dis48` tool
     * target). `clean/` is a second, unbuilt copy of the same upstream
     * sources -- listing sources explicitly keeps it out. */
    static let libo2em: [String] = [
        "src/audio.c",
        "src/cpu.c",
        "src/crc32.c",
        "src/cset.c",
        "src/debug.c",
        "src/keyboard.c",
        "src/score.c",
        "src/table.c",
        "src/timefunc.c",
        "src/vdc.c",
        "src/vmachine.c",
        "src/voice.c",
        "src/vpp.c",
        "src/vpp_cset.c",
        "allegrowrapper/wrapalleg.c"
    ]

    static let bridge: [String] = [
        "OdysseyGameCore.m",
        "OdysseyGameCore+Audio.m",
        "OdysseyGameCore+Controls.m",
        "OdysseyGameCore+Options.m",
        "OdysseyGameCore+Saves.m",
        "OdysseyGameCore+Video.m"
    ]

    static let swift: [String] = [
        "CoreOptions.swift",
        "CorePlist.swift",
        "CorePlist-Generated.swift",
        "PVOdysseyGameCore.swift"
    ]
}
