export default abstract class Base {
    abstract init(): void;
    abstract mutation(mut: Mutation): void;
    abstract query(q: Query): any;
}
