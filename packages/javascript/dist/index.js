'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

function _interopDefault (ex) { return (ex && (typeof ex === 'object') && 'default' in ex) ? ex['default'] : ex; }

var Dynamic = _interopDefault(require('@ironbay/dynamic'));

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

exports.Store = index;
