// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpeechproSpeechKit",
    products: [
        .library(
            name: "SpeechproSpeechKit",
            targets: ["SpeechproSpeechKit"]),
    ],
    targets: [
        .target(
            name: "SpeechproSpeechKit",
            dependencies: [],
            path: "SpeechproSpeechKit",
            cSettings: [
                .headerSearchPath("SpeechproSpeechKit"),
                .headerSearchPath("SpeechproSpeechKit/AntiSpoofingKit"),
                .headerSearchPath("SpeechproSpeechKit/Common"),
                .headerSearchPath("SpeechproSpeechKit/Common/Category"),
                .headerSearchPath("SpeechproSpeechKit/Common/Error"),
                .headerSearchPath("SpeechproSpeechKit/Common/Networking"),
                .headerSearchPath("SpeechproSpeechKit/Common/Networking/Category"),
                .headerSearchPath("SpeechproSpeechKit/Common/Sockets"),
                .headerSearchPath("SpeechproSpeechKit/Common/VoiceCapture"),
                .headerSearchPath("SpeechproSpeechKit/DiarizationKit"),
                .headerSearchPath("SpeechproSpeechKit/DiarizationKit/Diarizator"),
                .headerSearchPath("SpeechproSpeechKit/DiarizationKit/Networking"),
                .headerSearchPath("SpeechproSpeechKit/RecognizeKit"),
                .headerSearchPath("SpeechproSpeechKit/RecognizeKit/Networking"),
                .headerSearchPath("SpeechproSpeechKit/RecognizeKit/Networking/Base"),
                .headerSearchPath("SpeechproSpeechKit/RecognizeKit/Networking/Packages"),
                .headerSearchPath("SpeechproSpeechKit/RecognizeKit/Networking/Recognize"),
                .headerSearchPath("SpeechproSpeechKit/RecognizeKit/Networking/StreamRecognize"),
                .headerSearchPath("SpeechproSpeechKit/RecognizeKit/Recognizing"),
                .headerSearchPath("SpeechproSpeechKit/RecognizeKit/Streamer"),
                .headerSearchPath("SpeechproSpeechKit/SynthesizeKit"),
                .headerSearchPath("SpeechproSpeechKit/SynthesizeKit/Networking"),
                .headerSearchPath("SpeechproSpeechKit/SynthesizeKit/Networking/Base"),
                .headerSearchPath("SpeechproSpeechKit/SynthesizeKit/Networking/Language"),
                .headerSearchPath("SpeechproSpeechKit/SynthesizeKit/Networking/Stream"),
                .headerSearchPath("SpeechproSpeechKit/SynthesizeKit/Networking/Synthesize"),
                .headerSearchPath("SpeechproSpeechKit/SynthesizeKit/Networking/Voice"),
                .headerSearchPath("SpeechproSpeechKit/SynthesizeKit/Streamer"),
                .headerSearchPath("SpeechproSpeechKit/SynthesizeKit/Synthesizing"),
            ]
        ),
    ]
)
