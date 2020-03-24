import Dispatcher from '../dispatcher';
import Interceptor from './interceptor';
interface Syncable {
    onChange: Dispatcher<Riptide.Mutation>;
    mutation(mut: Riptide.Mutation): Promise<void>;
}
export default abstract class Local {
    protected abstract mutation_raw(mut: Riptide.Mutation): void;
    protected abstract query_raw(q: Riptide.Query): any;
    readonly onChange: Dispatcher<Riptide.Mutation>;
    readonly interceptor: Interceptor;
    private syncs;
    mutation(mut: Riptide.Mutation): Promise<void>;
    query(q: Riptide.Query): any;
    sync(target: Syncable): void;
    query_path<T>(path: string[], opts?: Riptide.Query.Opts): T;
    query_values<T>(path: string[], opts?: Riptide.Query.Opts): T[];
    query_keys(path: string[], opts?: Riptide.Query.Opts): string[];
    merge(path: string[], value: any): Promise<void>;
    delete(path: string[]): Promise<void>;
}
export {};
