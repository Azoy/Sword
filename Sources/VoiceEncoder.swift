import Foundation

#if os(Linux)
public typealias Process = Task
#endif

public class Encoder {

  let defaultSize = 320

  public let process: Process

  public let reader: Pipe

  public let writer: Pipe

  init() {

    self.process = Process()
    self.reader = Pipe()
    self.writer = Pipe()

    self.process.launchPath = "/usr/local/bin/ffmpeg"
    self.process.standardInput = self.writer.fileHandleForWriting
    self.process.standardOutput = self.reader.fileHandleForReading
    self.process.arguments = ["-hide_banner", "-loglevel", "quiet", "-f", "data", "-i", "pipe:0", "-c", "libopus", "-ac", "2", "-ar", "48k", "-map", "0:1", "-b:a", "128k", "pipe:1"]

    self.process.terminationHandler = { _ in
      self.reader.fileHandleForReading.closeFile()
      self.writer.fileHandleForWriting.closeFile()
    }

    self.process.launch()

  }

}
