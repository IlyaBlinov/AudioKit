//
//  AKOperationEffect.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Operation-based efffect
public class AKOperationEffect: AKNode, AKToggleable {

    // MARK: - Properties
    
    /// Parameters for changing internal operations
    public var parameters: [Double] = [] {
        didSet {
            internalAU?.setParameters(parameters)
        }
    }
    
    private var internalAU: AKOperationEffectAudioUnit?
    
    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    public var connectionPoints = [AVAudioConnectionPoint]()
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }
    
    // MARK: - Initializers
    
    /// Initialize the effect with an input and an operation
    ///
    /// - parameter input: AKNode to use for processing
    /// - parameter operation: AKOperation stack to use
    ///
    public convenience init(_ input: AKNode, operation: AKOperation) {
        // add "dup" to copy the left channel output to the right channel output
        self.init(input, sporth:"\(operation) dup")
    }
    
    /// Initialize the effect with an input and a stereo operation
    ///
    /// - parameter input: AKNode to use for processing
    /// - parameter stereoOperation: AKStereoOperation stack to use
    ///
    public convenience init(_ input: AKNode, stereoOperation: AKStereoOperation) {
        self.init(input, sporth:"\(stereoOperation) swap")
    }
    
    /// Initialize the effect with an input and separate operations for each channel
    ///
    /// - parameter input: AKNode to use for processing
    /// - parameter left: AKOperation stack to use on the left
    /// - parameter right: AKOperation stack to use on the right
    ///  
    public convenience init(_ input: AKNode, left: AKOperation, right: AKOperation) {
        self.init(input, sporth:"\(left) swap \(right) swap")
    }
    
    /// Initialize the effect with an input and a valid Sporth string
    ///
    /// - parameter input: AKNode to use for processing
    /// - parameter sporth: String of valid Sporth code
    ///
    public init(var _ input: AKNode, sporth: String) {

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x6373746d /*'cstm'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKOperationEffectAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKOperationEffect",
            version: UInt32.max)

        self.avAudioNode = AVAudioNode()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKOperationEffectAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
            self.internalAU?.setSporth(sporth)
        }

    }
    
    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        internalAU!.start()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        internalAU!.stop()
    }
}
