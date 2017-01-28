import Foundation
import Dispatch

#if os(Linux)
public typealias Process = Task
#endif

class Encoder {

  let defaultSize = 320

  let process: Process

  let reader: Pipe

  let readQueue = DispatchQueue(label: "gg.azoy.sword.encoder.read")

  let writer: Pipe

  init() {

    self.process = Process()
    self.reader = Pipe()
    self.writer = Pipe()

    self.process.launchPath = "/usr/local/bin/ffmpeg"
    self.process.standardInput = self.writer.fileHandleForReading
    self.process.standardOutput = self.reader.fileHandleForWriting
    self.process.arguments = ["-hide_banner", "-loglevel", "quiet", "-i", "pipe:0", "-f", "data", "-map", "0:a", "-ar", "48k", "-ac", "2", "-acodec", "libopus", "-sample_fmt", "s16", "-vbr", "off", "-b:a", "128k", "pipe:1"]

    self.process.terminationHandler = {[weak self] _ in
      self?.writer.fileHandleForWriting.closeFile()
      self?.writer.fileHandleForReading.closeFile()
      self?.reader.fileHandleForWriting.closeFile()
    }

    self.process.launch()

  }

  deinit {
    self.close()
  }

  func close() {
    #if !os(Linux)
    guard self.process.isRunning else { return }
    #else
    guard self.process.running else { return }
    #endif

    let waiter = DispatchSemaphore(value: 0)

    kill(self.process.processIdentifier, SIGKILL)

    self.process.waitUntilExit()

    self.reader.fileHandleForReading.closeFile()

    self.readQueue.async {
      waiter.signal()
    }

    waiter.wait()
  }

  func finishEncoding() {
    self.writer.fileHandleForWriting.closeFile()
  }

  func readFromPipe(_ completion: @escaping (Bool, [UInt8]) -> ()) {
    self.readQueue.async {[weak self] in
      guard let fileDescriptor = self?.reader.fileHandleForReading.fileDescriptor else { return }

      let buffer = UnsafeMutableRawPointer.allocate(bytes: 320, alignedTo: MemoryLayout<UInt8>.alignment)
      defer {
        free(buffer)
      }

      let readBytes = Foundation.read(fileDescriptor, buffer, 320)

      guard readBytes > 0 else {
        completion(true, [])

        return
      }

      let pointer = buffer.assumingMemoryBound(to: UInt8.self)
      let bytes = Array(UnsafeBufferPointer(start: pointer, count: 320))

      completion(false, bytes)
    }
  }

}
