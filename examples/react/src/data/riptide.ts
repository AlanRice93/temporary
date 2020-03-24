import * as Riptide from '@ironbay/riptide'

// Create a connection to the remote server
const connection = Riptide.Connection.create()
connection.transport.connect('ws://localhost:12000/socket')

// Represents the remote store on the server
const remote = new Riptide.Store.Remote(connection)
// Represents local store that is synced with remote store
const local = new Riptide.Store.Memory()
// Setup local store to sync with remote
local.sync(remote)
// Session store for any data that shouldn't be synced to the remote
const session = new Riptide.Store.Memory()

export { connection, remote, local, session }