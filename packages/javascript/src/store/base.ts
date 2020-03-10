import Dynamic from '@ironbay/dynamic'

export default abstract class Base {
    public abstract async init(): Promise<void>
    public abstract mutation(mut: Riptide.Mutation): void
    public abstract query(q: Riptide.Query): any

    public query_path(...path: string[]) {
        return Dynamic.get(this.query(Dynamic.put({}, path, {}) as Riptide.Query), path)
    }

    public query_values(...path: string[]) {
        return Object.values(Dynamic.get(this.query(Dynamic.put({}, path, {}) as Riptide.Query), path) || {})
    }

    public query_keys(...path: string[]) {
        return Object.keys(Dynamic.get(this.query(Dynamic.put({}, path, {}) as Riptide.Query), path) || {})
    }
}