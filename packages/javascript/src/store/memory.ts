import Base from './base'
import Dynamic from '@ironbay/dynamic'

export default abstract class Memory extends Base {
    private state: { [key: string]: any }
    init() {
        this.state = {}
    }

    mutation(mut: Mutation) {
        Memory.delete(this.state, mut.delete)
    }

    private static delete(state: { [key: string]: any }, input: Mutation['delete']) {
        for (let key of Object.keys(input)) {
            const value = input[key]
            if (value === 1) {
                delete state[key]
                continue
            }
            const existing = state[key]
            if (!existing) continue
            this.delete(existing, value)
        }
    }

    private static merge(state: { [key: string]: any }, input: Mutation['merge']) {
        for (let key of Object.keys(input)) {
            const value = input[key]
            if (value === 1) {
                delete input[key]
                continue
            }
            const existing = this.state[key]
            if (!existing) continue
            this.delete(value)
        }
    }
}