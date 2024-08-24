extends Node

var network = ENetMultiplayerPeer.new()
var port = 9999
var maxPlayers = 3000
var playerList = {}
var gamePortId = 8000

func _ready():
	#When scene enters tree, start lobby server
	start_server()
	
func start_server():
	#Creates server and connects server signals to various functions to hlep monitor
	network.create_server(port, maxPlayers)
	multiplayer.multiplayer_peer = network
	multiplayer.peer_connected.connect(onConnect)
	multiplayer.peer_disconnected.connect(func(id): print("Player dissconected. ID: ", id))
	print("Server Started!")

func uptickId():
	#Ticks up port used for game server so 2 servers are not lanuched on the same port, will be changed depending on how many servers
	#are run per instance of hosting
	gamePortId += 1
	if gamePortId == 9999:
		gamePortId = 8000

func onConnect(id):
	#prints id of a joined player and queries for their username
	print(id)
	rpc_id(id, "logUserInfo", id)

@rpc("any_peer", "call_remote", "reliable")
func updateLobby(list):
	#updates list of players in this lobby and all clients connected to it
	playerList = list.duplicate()
	rpc("updateLobby", playerList)
	pass
	
@rpc("any_peer", "call_remote", "reliable")
func updateClient():
	pass
	
@rpc("authority", "call_remote", "reliable")
func updateCard():
	pass
	
@rpc("any_peer", "call_remote", "reliable")
func logUserInfo(id, username):
	#stores info from the previous query
	playerList[username] = id
	print(playerList)
	rpc("updateLobby", playerList)
	
@rpc("any_peer", "call_remote", "reliable", 0)
func recieveClientData(data):
	#Prints messages from the client (for debug purpsoes mainly)
	print(data)
	pass
	
@rpc("any_peer", "call_remote", "reliable")
func getClientInfo():
	pass
	
@rpc("authority", "call_remote", "reliable", 0)
func joinGameServer():
	pass
	
@rpc("any_peer", "call_remote", "reliable", 0)
func createGameServer(player1, player2):
	#First stores player info of the two players game server is being made for
	var p1id = playerList[player1]
	var p2id = playerList[player2]
	#Removes the two players from the player list and updates all clients connected lists
	playerList.erase(player1)
	playerList.erase(player2)
	rpc("updateLobby", playerList)
	print("Creating game lobby for " + player1 + " and " + player2)
	#Find the next availble port and tick up for next server object
	var serverPort = gamePortId
	uptickId()
	#spawns game server process passing port as an argument
	OS.create_process("C:/Users/BW201/Documents/CHRONOCCG_Server/CHRONOCCG_Server.exe", [serverPort])
	#waits for game server to spawn
	await get_tree().create_timer(20).timeout
	#Tells the two players to connect to the game server
	rpc_id(p1id, "joinGameServer", serverPort)
	rpc_id(p2id, "joinGameServer", serverPort)
	pass
