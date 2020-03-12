import Dynamic from '@ironbay/dynamic';

/*! *****************************************************************************
Copyright (c) Microsoft Corporation. All rights reserved.
Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at http://www.apache.org/licenses/LICENSE-2.0

THIS CODE IS PROVIDED ON AN *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
MERCHANTABLITY OR NON-INFRINGEMENT.

See the Apache Version 2.0 License for specific language governing permissions
and limitations under the License.
***************************************************************************** */

function __awaiter(thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
}

class Base {
    query_path(...path) {
        return Dynamic.get(this.query(Dynamic.put({}, path, {})), path);
    }
    query_values(...path) {
        return Object.values(Dynamic.get(this.query(Dynamic.put({}, path, {})), path) || {});
    }
    query_keys(...path) {
        return Object.keys(Dynamic.get(this.query(Dynamic.put({}, path, {})), path) || {});
    }
}

class Memory extends Base {
    constructor() {
        super();
    }
    init() {
        return __awaiter(this, void 0, void 0, function* () {
            this.state = {};
        });
    }
    mutation(mut) {
        Memory.delete(this.state, mut.delete);
        Memory.merge(this.state, mut.merge);
    }
    query(query) {
        return Memory.query(this.state, query);
    }
    static query(state, input) {
        const result = {};
        let found = false;
        for (let key of Object.keys(input)) {
            const value = input[key];
            if (value instanceof Object) {
                found = true;
                const existing = state && state[key];
                result[key] = Memory.query(existing, value);
            }
        }
        if (!found)
            return state;
        return result;
    }
    static delete(state, input) {
        for (let key of Object.keys(input)) {
            const value = input[key];
            if (value === 1) {
                delete state[key];
                continue;
            }
            const existing = state[key];
            if (!existing)
                continue;
            Memory.delete(existing, value);
        }
    }
    static merge(state, input) {
        for (let key of Object.keys(input)) {
            const value = input[key];
            if (!(value instanceof Object)) {
                state[key] = value;
                continue;
            }
            if (!state[key])
                state[key] = {};
            const existing = state[key];
            Memory.merge(existing, value);
            continue;
        }
    }
}



var index = /*#__PURE__*/Object.freeze({
    __proto__: null,
    Memory: Memory,
    Base: Base
});

export { index as Store };
