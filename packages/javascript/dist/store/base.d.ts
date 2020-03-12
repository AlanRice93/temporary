export default abstract class Base {
    abstract init(): Promise<void>;
    abstract mutation(mut: Riptide.Mutation): void;
    abstract query(q: Riptide.Query): any;
    query_path(...path: string[]): unknown;
    query_values(...path: string[]): unknown[];
    query_keys(...path: string[]): string[];
}
