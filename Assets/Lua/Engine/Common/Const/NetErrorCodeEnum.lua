local NetErrorCodeEnum = 
{
	[-1] = "[SocketError] socket is error. errorcode = -1",
	[0] = "[Success] socket operation success. errorcode = 0",

	--500以下为自定义ErrorCode
	[201] = "[TCPConnectFail] connect remote computer failed. errorcode = 201",
	[202] = "[TCPDisconnect] disconnected, closed by client. errorcode = 202",
	[203] = "[TCPReceiveZeroBytes] disconnected, closed by server. errorcode = 203",

	--500以上为socket内置Errorcode
	[995]   = "[OperationAborted] The operation was aborted because the socket was closed. errorcode = 995",
	[10004] = "[Interrupted] blocking socket calls has been cancelled. errorcode = 10004",
	[10041] = "[ProtocolType] the protocol type of the socket is incorrect. errorcode = 10041",
	[10053] = "[ConnectionAborted] the link was terminated by the socket. errorcode = 10053",
	[10054] = "[ConnectionReset] this link was reset by the remote computer. errorcode = 10054",
	[10057] = "[NotConnect] the socket is not connected. errorcode = 10057",
	[10058] = "[ShutDown] the socket is closed. errorcode = 10058",
	[10064] = "[HostDown] the remote computer has been shut down. operation fail. errorcode = 10064",
	[11001] = "[HostNotFound] the host cannot be identified. errorcode = 11001",
}

return NetErrorCodeEnum