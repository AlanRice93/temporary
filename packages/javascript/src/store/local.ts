import Dynamic from '@ironbay/dynamic'
import Dispatcher from '../dispatcher'
import Interceptor from './interceptor'

interface Syncable {
    onChange: Dispatcher<Riptide.Mutation>
    mutation(mut: Riptide.Mutation): Promise<void>
}

export default abstract class Local {
    protected abstract mutation_raw(mut: Riptide.Mutation): void
    protected abstract query_raw(q: Riptide.Query): any

    public readonly onChange = new Dispatcher<Riptide.Mutation>()
    public readonly interceptor = new Interceptor()

    private syncs = new Array<Syncable>()

    public async mutation(mut: Riptide.Mutation) {
        await this.interceptor.trigger_before(mut)
        this.mutation_raw(mut)
        this.onChange.trigger(mut)
        await Promise.all(this.syncs.map(sync => sync.mutation(mut)))
    }

    public query(q: Riptide.Query) {
        return this.query_raw(q)
    }

    public sync(target: Syncable) {
        target.onChange.add(async mut => {
            await this.interceptor.trigger_before(mut)
            this.mutation_raw(mut)
            this.onChange.trigger(mut)
        })
        this.syncs.push(target)
    }

    public query_path(path: string[]) {
        return Dynamic.get(this.query(Dynamic.put({}, path, {}) as Riptide.Query), path)
    }

    public query_values(path: string[]) {
        return Object.values(this.query_path(path) || {})
    }

    public query_keys(path: string[]) {
        return Object.keys(this.query_path(path) || {})
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