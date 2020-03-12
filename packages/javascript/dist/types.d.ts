declare namespace Riptide {
    interface Mutation {
        merge: {
            [key: string]: any | Mutation['merge'];
        };
        delete: {
            [key: string]: 1 | Mutation['delete'];
        };
    }
    type Query = {
        [key: string]: Query | {
            min?: string;
            max?: string;
            limit?: string;
        };
    };
}
