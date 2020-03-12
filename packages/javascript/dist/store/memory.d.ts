import Base from './base';
export default class Memory extends Base {
    private state;
    constructor();
    init(): Promise<void>;
    mutation(mut: Riptide.Mutation): void;
    query(query: Riptide.Query): {
        [key: string]: any;
    };
    private static query;
    private static delete;
    private static merge;
}
