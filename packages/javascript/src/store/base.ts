export default abstract class Base {
    protected abstract init(): void
    protected abstract mutation(mut: Mutation): void
    protected abstract query(q: Query): any
}