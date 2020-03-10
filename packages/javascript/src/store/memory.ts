import Base from './base'
export default class Memory extends Base {
    private state: { [key: string]: any }

    constructor() {
        super()
    }

    async init() {
        this.state = {}
    }

    mutation(mut: Riptide.Mutation) {
        Memory.delete(this.state, mut.delete)
        Memory.merge(this.state, mut.merge)
    }

    query(query: Riptide.Query) {
        return Memory.query(this.state, query)
    }

    private static query(state: { [key: string]: any }, input: Riptide.Query) {
        const result = {} as { [key: string]: any }
        let found = false
        for (let key of Object.keys(input)) {
            const value = input[key]
            if (value instanceof Object) {
                found = true
                const existing = state && state[key]
                result[key] = Memory.query(existing, value as Riptide.Query)
            }
        }
        if (!found) return state
        return result
    }

    private static delete(state: { [key: string]: any }, input: Riptide.Mutation['delete']) {
        for (let key of Object.keys(input)) {
            const value = input[key]

            if (value === 1) {
                delete state[key]
                continue
            }

            const existing = state[key]
            if (!existing) continue
            Memory.delete(existing, value)
        }
    }

    private static merge(state: { [key: string]: any }, input: Riptide.Mutation['merge']) {
        for (let key of Object.keys(input)) {
            const value = input[key]

            if (!(value instanceof Object)) {
                state[key] = value
                continue
            }

            if (!state[key]) state[key] = {}
            const existing = state[key]
            Memory.merge(existing, value)
            continue
        }
    }
}