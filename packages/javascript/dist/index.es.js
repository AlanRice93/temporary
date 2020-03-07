import Dynamic from '@ironbay/dynamic';

class Base {
}

class Memory extends Base {
    constructor() {
        super(...arguments);
        this.state = {};
    }
    init() {
        this.state = {};
    }
    mutation(mut) {
        Dynamic.flatten(mut.merge);
    }
}



var index = /*#__PURE__*/Object.freeze({
    __proto__: null,
    Base: Base,
    Memory: Memory
});

export { index as Store };
