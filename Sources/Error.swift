import Foundation

public enum Error {
  case ok, created, noContent, notModified, badRequest, unauthorized, forbidden, notFound, methodNotAllowed, tooManyRequests, gatewayUnavailable, serverError, unknown
}

extension HTTPURLResponse {
  var status: Error {
    switch self.statusCode {
      case 200:
        return .ok
      case 201:
        return .created
      case 204:
        return .noContent
      case 304:
        return .notModified
      case 400:
        return .badRequest
      case 401:
        return .unauthorized
      case 403:
        return .forbidden
      case 404:
        return .notFound
      case 405:
        return .methodNotAllowed
      case 429:
        return .tooManyRequests
      case 502:
        return .gatewayUnavailable
      default:
        return .serverError
    }
  }
}
