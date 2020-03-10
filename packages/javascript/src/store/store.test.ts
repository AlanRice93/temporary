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
                        animals: {
                            shark: "hammerhead"
                        }
                    },
                    delete: {}
                })
                expect(store.query({})).toEqual({ animals: { shark: "hammerhead" } })

                store.mutation({
                    delete: {
                        animals: {
                            shark: 1
                        }
                    },
                    merge: {}
                })
                expect(store.query({})).toEqual({ animals: {} })

                store.mutation({
                    delete: { animals: {} },
                    merge: { animals: { fish: "barracuda", shark: "hammerhead" } }
                })
                expect(store.query({})).toEqual({ animals: { fish: "barracuda", shark: "hammerhead" } })
                expect(store.query({ animals: { shark: {} } })).toEqual({ animals: { shark: "hammerhead" } })
                expect(store.query({ animals: { stingray: { climate: {} } } })).toEqual({ animals: { stingray: { climate: undefined } } })

                expect(store.query_path(['animals', 'shark'])).toEqual('hammerhead')
                expect(store.query_keys(['animals'])).toEqual(['fish', 'shark'])
                store.merge(['animals', 'whale'], 'orca')
                expect(store.query_path(['animals', 'whale'])).toEqual('orca')
                store.delete(['animals', 'whale'])
                expect(store.query_path(['animals', 'whale'])).toEqual(undefined)
            })

        })

    })
