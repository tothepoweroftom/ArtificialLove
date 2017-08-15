// Copyright © 2016 Venture Media Labs. All rights reserved.
//
// This file is part of BrainCore. The full BrainCore copyright notice,
// including terms governing use, modification, and redistribution, is
// contained in the file LICENSE at the root of the source code distribution
// tree.

import Foundation
import Metal

public class SigmoidLayer: ForwardLayer, BackwardLayer {
    struct Parameters {
        let batchSize: UInt32
        let size: UInt32
    }
    
    public let id = UUID()
    public let name: String?

    /// The size of each batch element
    public let size: Int

    public var outputSize: Int {
        return size
    }

    public var inputSize: Int {
        return size
    }

    var forwardInvocation: Invocation?
    var backwardInvocation: Invocation?

    public var forwardInvocations: [Invocation] {
        guard let forwardInvocation = forwardInvocation else {
            fatalError("initializeForward needs to be called first")
        }
        return [forwardInvocation]
    }

    public var backwardInvocations: [Invocation] {
        guard let backwardInvocation = backwardInvocation else {
            fatalError("initializeBackward needs to be called first")
        }
        return [backwardInvocation]
    }


    public init(size: Int, name: String? = nil) {
        self.name = name
        self.size = size
    }

    public func initializeForward(builder: ForwardInvocationBuilder, batchSize: Int) throws {
        let buffers = [
            builder.inputBuffer,
            builder.outputBuffer
        ]

        let params = Parameters(batchSize: UInt32(batchSize), size: UInt32(size))
        forwardInvocation = try builder.createInvocation(
            functionName: "sigmoid_forward",
            buffers: buffers,
            values: [params],
            width: size * batchSize)
    }

    public func initializeBackward(builder: BackwardInvocationBuilder, batchSize: Int) throws {
        let params = Parameters(batchSize: UInt32(batchSize), size: UInt32(size))

        let buffers = [
            builder.outputDeltasBuffer,
            builder.inputBuffer,
            builder.inputDeltasBuffer
        ]
        backwardInvocation = try builder.createInvocation(
            functionName: "sigmoid_backward",
            buffers: buffers,
            values: [params],
            width: size * batchSize
        )
    }
}
