import Memory from './memory'

[
    Memory
]
    .map(mod => {
        describe(mod.name, () => {
            it('implementation', () => {
                const store = new mod()
                store.init()

                store.mutation({
                    merge: {
                        a: {
                            b: 1
                        }
                    },
                    delete: {}
                })
                expect(store.query({})).toEqual({ a: { b: 1 } })

                store.mutation({
                    delete: {
                        a: {
                            b: 1
                        }
                    },
                    merge: {}
                })
                expect(store.query({})).toEqual({ a: {} })

                store.mutation({
                    delete: { a: {} },
                    merge: { a: { c: 1, b: 2 } }
                })
                expect(store.query({})).toEqual({ a: { c: 1, b: 2 } })
                expect(store.query({ a: { b: {} } })).toEqual({ a: { b: 2 } })
                expect(store.query({ a: { e: { f: {} } } })).toEqual({ a: { e: { f: undefined } } })
            })

        })
    })
