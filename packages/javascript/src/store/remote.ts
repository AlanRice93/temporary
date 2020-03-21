import Dynamic from '@ironbay/dynamic'
import Dispatcher from '../dispatcher'
import * as Connection from '../connection'

export default class Remote<T extends Riptide.Transport, F extends Riptide.Format>  {
    public readonly onChange = new Dispatcher<Riptide.Mutation>()
    private conn: Connection.Client<T, F>

    constructor(client: Connection.Client<T, F>) {
        this.conn = client
        client.on_cast.add(msg => {
            if (msg.action !== 'riptide.mutation') return
            this.onChange.trigger(msg.body)
        })
    }

    public async mutation(mut: Riptide.Mutation) {
        await this.conn.call('riptide.mutation', mut)
    }

    public async query(q: Riptide.Query) {
        const result = await this.conn.call<Riptide.Mutation>('riptide.query', q)
        this.onChange.trigger(result)
        return result.merge
    }

    public async query_path(path: string[], opts: Riptide.Query.Opts = {}) {
        return Dynamic.get(await this.query(Dynamic.put({}, path, opts) as Riptide.Query), path)
    }

    public async query_values(path: string[], opts: Riptide.Query.Opts = {}) {
        return Object.values(await this.query_path(path, opts) || {})
    }

    public async query_keys(path: string[], opts: Riptide.Query.Opts = {}) {
        return Object.keys(await this.query_path(path, opts) || {})
    }

    public async merge(path: string[], value: any) {
        await this.mutation({
            merge: Dynamic.put({}, path, value),
            delete: {}
        })
    }

    public async delete(path: string[]) {
        await this.mutation({
            delete: Dynamic.put({}, path, 1) as Riptide.Mutation['delete'],
            merge: {}
        })
    }
}