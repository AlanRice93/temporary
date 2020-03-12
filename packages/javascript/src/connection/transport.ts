import * as WebSocket from 'universal-websocket-client'
import sleep from '../sleep'
import Dispatcher from '../dispatcher'

export abstract class Base implements Riptide.Transport {
    abstract write(data: string): void
    protected dispatcher_data = new Dispatcher<string>()
    protected dispatcher_status = new Dispatcher<string>()

    handle_data(cb: (data: string) => void) {
        this.dispatcher_data.add(cb)
    }

    handle_status(cb: (status: string) => void) {
        this.dispatcher_status.add(cb)
    }
}

export class WS extends Base {
    public attempts = -1
    private socket: WebSocket;

    write(data: string) {
        if (!this.socket || this.socket.readyState !== 1) throw 'Socket unready'
        this.socket.send(data)
    }

    async connect(url: string) {
        this.attempts++
        await sleep(Math.min(this.attempts * 1000, 5 * 1000))
        this.socket = new WebSocket(url)
        this.socket.onopen = () => {
            this.attempts = 0
            this.dispatcher_status.trigger('ready')
        }

        this.socket.onclose = () => {
            this.cleanup()
            this.connect(url)
        }

        this.socket.onerror = () => {
            // this._cleanup()
            // this._connect()
        }

        this.socket.onmessage = evt => {
            this.dispatcher_data.trigger(evt.data)
        }
    }

    disconnect() {
        if (!this.socket) return
        this.socket.onclose = () => { }
        this.socket.close()
        this.cleanup()
    }


    private cleanup() {
        this.dispatcher_status.trigger('disconnected')
        this.socket = undefined
    }
}