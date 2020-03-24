import React from 'react'
import * as ReactDOM from 'react-dom'
import * as Riptide from './data/riptide'

// Log entire state when local store or session store updates
Riptide.local.onChange.add(() => console.dir('Local', Riptide.local.query_path([])))
Riptide.session.onChange.add(() => console.dir('Session', Riptide.session.query_path([])))

// When the connection status changes, save the state in the session store
Riptide.connection.transport.onStatus.add(status => Riptide.session.merge(['connection', 'status'], status))

// Create interceptor to fetch creatures path whenever connection becomes ready
Riptide.session.interceptor.before_mutation(['connection'], async (mut) => {
    if (mut.merge.status !== 'ready') return

    // Refresh creatures path and subscribe to any future changes
    await Riptide.remote.query({
        'creatures': {
            subscribe: true
        }
    })
})

interface Creature {
    name?: string
    key?: string
}

function App() {
    const [_, render] = React.useState(0)
    React.useEffect(() => Riptide.local.onChange.add(() => render(val => val + 1)), [])
    return (
        <div >
            {
                Riptide.local
                    .query_values<Creature>(['creatures'])
                    .map(item => {
                        return <div key={item.key}>{item.name}</div>
                    })
            }
        </div>
    )
}

ReactDOM.render(<App />, document.querySelector('.root'))