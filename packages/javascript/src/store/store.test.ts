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
                        dogs: {
                            rex: "husky"
                        }
                    },
                    delete: {}
                })
                expect(store.query({})).toEqual({ dogs: { rex: "husky" } })

                store.mutation({
                    delete: {
                        dogs: {
                            rex: 1
                        }
                    },
                    merge: {}
                })
                expect(store.query({})).toEqual({ dogs: {} })

                store.mutation({
                    delete: { dogs: {} },
                    merge: { dogs: { spike: "bulldog", rex: "husky" } }
                })
                expect(store.query({})).toEqual({ dogs: { spike: "bulldog", rex: "husky" } })
                expect(store.query({ dogs: { rex: {} } })).toEqual({ dogs: { rex: "husky" } })
                expect(store.query({ dogs: { milo: { breed: {} } } })).toEqual({ dogs: { milo: { breed: undefined } } })
            })

        })
    })
