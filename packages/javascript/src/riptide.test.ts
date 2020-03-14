import * as Riptide from './'
describe('riptide', () => {
    it('implementation', async () => {
        const local = new Riptide.Store.Memory()
        const session = new Riptide.Store.Memory()

        const conn = Riptide.Connection.create()
        conn.transport.onStatus.add(async status => {
            await session.merge(['conn', 'session'], status)
            expect(session.query_path(['conn', 'session'])).toEqual('ready')
        })
        await conn.transport.connect('ws://localhost:12000/socket')

        const remote = new Riptide.Store.Remote(conn)
        local.sync(remote)
        await local.merge(['animals', 'shark'], 'hammerhead')

        const result = await remote.query_path(['animals'])
        console.log(result)

    })
})