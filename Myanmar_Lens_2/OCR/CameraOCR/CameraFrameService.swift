
import AVFoundation

class CameraFrameService: NSObject, ObservableObject {
    
    @Published var current: CVPixelBuffer?
    private var lastTimestamp = CMTime()
    var fps = 10
    
    let queue = DispatchQueue(
        label: "com.jonahaung.FrameService",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
}

extension CameraFrameService: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let deltaTime = timestamp - self.lastTimestamp
        if  deltaTime >= CMTimeMake(value: 1, timescale: Int32(self.fps)) {
            lastTimestamp = timestamp
            self.current = sampleBuffer.imageBuffer
        }
    }
}
