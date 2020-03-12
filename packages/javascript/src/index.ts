import * as Store from './store'
import * as Connection from './connection'

export { Store, Connection }

export function create() {
    const local = new Store.Memory()
    const session = new Store.Memory()

    const conn = Connection.create()
    conn.transport.connect('ws://localhost:12000')
    conn.transport.handle_status(status => session.merge(['conn', 'session'], status))

    const remote = new Store.Remote(conn)
    local.sync(remote)
}
