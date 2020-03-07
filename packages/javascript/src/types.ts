interface Mutation {
    merge: { [key: string]: any | Mutation['delete'] }
    delete: { [key: string]: 1 | Mutation['delete'] }
}

type Query = Object