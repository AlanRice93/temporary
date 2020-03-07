import Base from './base';
export default abstract class Memory extends Base {
    private state;
    init(): void;
    mutation(mut: Mutation): void;
}
