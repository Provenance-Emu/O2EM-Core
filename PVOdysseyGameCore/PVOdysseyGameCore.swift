//
//  PVJaguarGameCore.swift
//  PVVirtualJaguar
//
//  Created by Joseph Mattiello on 5/21/24.
//  Copyright © 2024 Provenance EMU. All rights reserved.
//

import Foundation
import PVCoreBridge
#if canImport(GameController)
import GameController
#endif
#if canImport(OpenGLES)
import OpenGLES
import OpenGLES.ES3
#endif
import PVLogging
import PVAudio
import PVEmulatorCore
import PVCoreObjCBridge

@objc
@objcMembers
open class PVOdysseyGameCore: PVEmulatorCore, @unchecked Sendable {
    
//    @MainActor
//    @objc public var jagVideoBuffer: UnsafeMutablePointer<JagBuffer>?
//    @MainActor
//    @objc public var videoWidth: UInt32 = UInt32(VIDEO_WIDTH)
//    @MainActor
//    @objc public var videoHeight: Int = Int(VIDEO_HEIGHT)
//    @MainActor
//    @objc public var frameTime: Float = 0.0
    @objc public var multithreaded: Bool { true }

    // MARK: Audio
//    @objc public override var sampleRate: Double {
//        get { Double(AUDIO_SAMPLERATE) }
//        set {}
//    }

//    @objc dynamic public override var audioBufferCount: UInt { 1 }

//    @MainActor
//    @objc public var audioBufferSize: Int16 = 0

    // MARK: Queues
//    @objc  public let audioQueue: DispatchQueue = .init(label: "com.provenance.o2em.audio", qos: .userInteractive, autoreleaseFrequency: .inherit)
//    @objc public let videoQueue: DispatchQueue = .init(label: "com.provenance.o2em.video", qos: .userInteractive, autoreleaseFrequency: .inherit)
//    @objc public let renderGroup: DispatchGroup = .init()
//
//    @objc  public let waitToBeginFrameSemaphore: DispatchSemaphore = .init(value: 0)

    // MARK: Video

//    @objc public override var isDoubleBuffered: Bool {
//        // TODO: Fix graphics tearing when this is on
//        // return self.virtualjaguar_double_buffer
//        return false
//    }
    
    @objc public override dynamic var rendersToOpenGL: Bool { bridge.rendersToOpenGL }


//    @MainActor
//    @objc public override var videoBufferSize: CGSize { .init(width: Int(videoWidth), height: videoHeight) }

//    @MainActor
//    @objc public override var aspectSize: CGSize { .init(width: Int(TOMGetVideoModeWidth()), height: Int(TOMGetVideoModeHeight())) }

    // MARK: Inputs
    
    public lazy var keyChangedHandler: GCKeyboardValueChangedHandler? = {(keyboard, button, key, pressed) -> Void in
        if pressed {
            (self._bridge as! KeyboardResponder).keyDown(key)
        } else {
            (self._bridge as! KeyboardResponder).keyUp(key)
        }
    }
    
    let _bridge: OdysseyGameCoreBridge = .init()
    
    // MARK: Lifecycle
    public required init() {
        super.init()
        self.bridge = (_bridge as! any ObjCBridgedCoreBridge)
    }
}

extension PVOdysseyGameCore: PVOdyssey2SystemResponderClient {
    public func didPush(_ button: PVCoreBridge.PVOdyssey2Button, forPlayer player: Int) {
        (_bridge as! PVOdyssey2SystemResponderClient).didPush(button, forPlayer: player)
    }
    
    public func didRelease(_ button: PVCoreBridge.PVOdyssey2Button, forPlayer player: Int) {
        (_bridge as! PVOdyssey2SystemResponderClient).didRelease(button, forPlayer: player)
    }
}

extension PVOdysseyGameCore: KeyboardResponder {
    public var gameSupportsKeyboard: Bool { true }
    
    public var requiresKeyboard: Bool { false }
    
    public func keyDown(_ key: GCKeyCode) {
        _bridge.keyDown(UInt16(key.rawValue))
    }
    
    public func keyUp(_ key: GCKeyCode) {
        _bridge.keyUp(UInt16(key.rawValue))
    }
}
