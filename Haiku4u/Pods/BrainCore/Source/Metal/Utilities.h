// Copyright © 2016 Venture Media Labs. All rights reserved.
//
// This file is part of BrainCore. The full BrainCore copyright notice,
// including terms governing use, modification, and redistribution, is
// contained in the file LICENSE at the root of the source code distribution
// tree.

#include <metal_stdlib>

namespace bc {

/// The metal standard library `tanh` function causes NaN errors on certain GPUs. This is likely due to a naïve implementation that uses the series expansion of tanh(x). This `tanh` implementation is based on "Accurate Hyperbolic Tangent Computation" by Nelson H. F. Beebe, http://www.math.utah.edu/~beebe/software/ieee/tanh.pdf
inline float tanh(const float x) {
    static constexpr auto xLarge = 8.66433975699931636772f;
    static constexpr auto xMedium = 5.4930614433405484570e-1f;
    static constexpr auto xSmall = 4.22863966691620432990e-4f;

    const auto sign = metal::sign(x);
    const auto absX = sign * x;

    if (absX >= xLarge) {
        return sign;
    }

    if (absX >= xMedium) {
        const auto temp = 0.5 - 1 / (1 + metal::exp(2 * absX));
        return sign * (temp + temp);
    }

    if (absX < xSmall) {
        return sign * absX;
    }

    const auto P0 = -8.237728127e-1f;
    const auto P1 = -3.831010665e-3f;
    const auto Q0 = 2.471319654f;

    const auto g = absX * absX;
    const auto R = g * (P1 * g + P0) / (g + Q0);
    return x + x * R;
}

inline float sigmoid(const float x) {
    return 1.0 / (1.0 + metal::exp(-x));
}

} // namespace
