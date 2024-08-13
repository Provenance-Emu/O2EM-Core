// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PVVirtualJaguar",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v9),
        .macOS(.v10_13),
        .macCatalyst(.v14)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PVVirtualJaguar",
            targets: ["PVVirtualJaguar", "PVVirtualJaguarSwift"]),
    ],
    dependencies: [
        .package(path: "../../PVCoreBridge"),
        .package(path: "../../PVEmulatorCore"),
        .package(path: "../../PVSupport"),
        .package(path: "../../PVAudio"),
        .package(path: "../../PVLogging"),
        .package(path: "../../PVObjCUtils")
    ],
    targets: [
        .target(
            name: "PVVirtualJaguar",
            dependencies: [
                "libjaguar",
                "PVEmulatorCore",
                "PVCoreBridge",
                "PVSupport",
                "PVObjCUtils"
            ],
            path: "VirtualJaguar",
            publicHeadersPath: "include",
            cSettings: [
                .define("INLINE", to: "inline"),
                .define("USE_STRUCTS", to: "1"),
                .define("__LIBRETRO__", to: "1"),
                .define("HAVE_COCOATOJUCH", to: "1"),
                .define("__GCCUNIX__", to: "1"),
                .headerSearchPath("../virtualjaguar-libretro/src"),
                .headerSearchPath("../virtualjaguar-libretro/src/m68000"),
                .headerSearchPath("../virtualjaguar-libretro/libretro-common"),
                .headerSearchPath("../virtualjaguar-libretro/libretro-common/include"),
            ]
        ),

        .target(
            name: "PVVirtualJaguarSwift",
            dependencies: [
                "PVEmulatorCore",
                "PVCoreBridge",
                "PVLogging",
                "PVAudio",
                "PVSupport",
                "libjaguar",
                "PVVirtualJaguar"
            ],
            path: "VirtualJaguarSwift",
            cSettings: [
                .define("INLINE", to: "inline"),
                .define("USE_STRUCTS", to: "1"),
                .define("__LIBRETRO__", to: "1"),
                .define("HAVE_COCOATOJUCH", to: "1"),
                .define("__GCCUNIX__", to: "1"),
                .headerSearchPath("../virtualjaguar-libretro/src"),
                .headerSearchPath("../virtualjaguar-libretro/src/m68000"),
                .headerSearchPath("../virtualjaguar-libretro/libretro-common"),
                .headerSearchPath("../virtualjaguar-libretro/libretro-common/include"),
            ]
        ),

        .target(
            name: "libjaguar",
            path: "virtualjaguar-libretro",
            exclude: [
            ],
            sources: [
                "src/blitter.c",
                "src/cdintf.c",
                "src/cdrom.c",
                "src/crc32.c",
                "src/dac.c",
                "src/dsp.c",
                "src/eeprom.c",
                "src/event.c",
                "src/file.c",
                "src/filedb.c",
                "src/gpu.c",
                "src/jagbios.c",
                "src/jagbios2.c",
                "src/jagcdbios.c",
                "src/jagdevcdbios.c",
                "src/jagstub1bios.c",
                "src/jagstub2bios.c",
                "src/jaguar.c",
                "src/jerry.c",
                "src/joystick.c",
                "src/m68000/cpudefs.c",
                "src/m68000/cpuemu.c",
                "src/m68000/cpuextra.c",
                "src/m68000/cpustbl.c",
                "src/m68000/m68kinterface.c",
                "src/m68000/readcpu.c",
                "src/memtrack.c",
                "src/mmu.c",
                "src/op.c",
                "src/settings.c",
                "src/tom.c",
                "src/universalhdr.c",
                "src/vjag_memory.c",
                "src/wavetable.c"
            ],
            publicHeadersPath: "src",
            packageAccess: true,
            cSettings: [
                .define("INLINE", to: "inline"),
                .define("USE_STRUCTS", to: "1"),
                .define("__LIBRETRO__", to: "1"),
                .define("HAVE_COCOATOJUCH", to: "1"),
                .define("__GCCUNIX__", to: "1"),
                .headerSearchPath("virtualjaguar-libretro/src"),
                .headerSearchPath("src"),
                .headerSearchPath("libretro-common/include")
            ]
        )
    ],
    swiftLanguageVersions: [.v5],
    cLanguageStandard: .gnu11,
    cxxLanguageStandard: .gnucxx14
)
