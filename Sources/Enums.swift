import Foundation

enum OPCode: Int {
  case dispatch, heartbeat, identify, statusUpdate, voiceStateUpdate, voiceServerPing, resume, reconnect, requestGuildMember, invalidSession, hello, heartbeatACK
}