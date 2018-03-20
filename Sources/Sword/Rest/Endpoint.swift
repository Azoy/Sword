extension Sword {
  /// Organizes different http methods
  enum HTTPMethod: String {
    case get, post, patch, delete
  }
  
  /// Represents an API call
  struct Endpoint {
    /// The http method used for this endpoint
    let method: HTTPMethod
    
    /// The API URL
    let url: String
    
    /// Creates an Endpoint
    ///
    /// - parameter method: The HTTP method used for this endpoint
    /// - parameter url: The API URL for this endpoint
    init(_ method: HTTPMethod, _ url: String) {
      self.method = method
      self.url = "https://discordapp.com/api/v7\(url)"
    }
    
    /// Create Message
    ///
    /// - parameter channelId: The channel to create message in
    static func createMessage(in channelId: String) -> Endpoint {
      return Endpoint(.post, "/channels/\(channelId)/messages")
    }
    
    /// Gateway
    static func gateway() -> Endpoint {
      return Endpoint(.get, "/gateway/bot")
    }
  }
}
