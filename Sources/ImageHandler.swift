import Foundation

//Image Handler
extension Request {

  /* Creates HTTP Body for file uploads
    @param parameters: [String: String]? - Optional data to send
    @param fileKey: String - Key for the file
    @param paths: [String] - Array of URLS to get file data from
    @param boundary: String - UUID Boundary
  */
  func createBody(with parameters: [String: String]?, fileKey: String, paths: [String], boundary: String) throws -> Data {

    var body = Data()

    if parameters != nil {
      for (key, value) in parameters! {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
        body.append("\(value)\r\n")
      }
    }

    for path in paths {
      let url = URL(string: path)!
      let filename = url.lastPathComponent
      let data = try Data(contentsOf: url)
      let mimetype = mimeType(for: path)

      body.append("--\(boundary)\r\n")
      body.append("Content-Disposition: form-data; name=\"\(fileKey)\"; filename=\"\(filename)\"\r\n")
      body.append("Content-Type: \(mimetype)\r\n\r\n")
      body.append(data)
      body.append("\r\n")
    }

    body.append("--\(boundary)--\r\n")
    return body

  }

}

// UUID Boundary Generator
func generateBoundaryString() -> String {
  return "Boundary-\(NSUUID().uuidString)"
}

/* Gets mimeType for URL
  @param path: String - URL to get mimeType for
*/
func mimeType(for path: String) -> String {
  let url = NSURL(string: path)!
  let pathExtension = url.pathExtension

  if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
    if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
      return mimetype as String
    }
  }

  return "application/octet-stream"
}
