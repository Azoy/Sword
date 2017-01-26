import Foundation
import Dispatch

#if os(Linux)
public typealias Process = Task
#endif

public class Encoder {

  let defaultSize = 320

  public let process: Process

  public let reader: Pipe

  let readQueue = DispatchQueue(label: "gg.azoy.sword.encoder.read")

  public let writer: Pipe

  init() {

    self.process = Process()
    self.reader = Pipe()
    self.writer = Pipe()

    self.process.launchPath = "/usr/local/bin/ffmpeg"
    self.process.standardInput = self.writer.fileHandleForReading
    self.process.standardOutput = self.reader.fileHandleForWriting
    self.process.arguments = ["-hide_banner", "-loglevel", "quiet", "-i", "pipe:0", "-f", "data", "-map", "0:a", "-ar", "48k", "-ac", "2", "-acodec", "libopus", "-sample_fmt", "s16", "-vbr", "off", "-b:a", "128k", "pipe:1"]

    self.process.terminationHandler = { _ in
      self.writer.fileHandleForWriting.closeFile()
      self.writer.fileHandleForReading.closeFile()
      self.reader.fileHandleForWriting.closeFile()
    }

    self.process.launch()

  }

  public func finishEncoding() {
    self.writer.fileHandleForWriting.closeFile()
  }

  func readFromPipe(_ completion: @escaping (Bool, [UInt8]) -> ()) {
    self.readQueue.async {
      let fileDescriptor = self.reader.fileHandleForReading.fileDescriptor

      let buffer = UnsafeMutableRawPointer.allocate(bytes: self.defaultSize, alignedTo: MemoryLayout<UInt8>.alignment)
      defer {
        free(buffer)
      }

      let readBytes = Foundation.read(fileDescriptor, buffer, self.defaultSize)

      guard readBytes > 0 else {
        completion(true, [])

        return
      }

      let pointer = buffer.assumingMemoryBound(to: UInt8.self)
      let bytes = Array(UnsafeBufferPointer(start: pointer, count: self.defaultSize))

      completion(false, bytes)
    }
  }

}
