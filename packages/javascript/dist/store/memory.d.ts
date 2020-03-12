import Local from './local';
export default class Memory extends Local {
    private state;
    mutation_raw(mut: Riptide.Mutation): void;
    query_raw(query: Riptide.Query): {
        [key: string]: any;
    };
    private static query;
    private static delete;
    private static merge;
}
