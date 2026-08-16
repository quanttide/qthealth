import { useState } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <h1>量潮健康</h1>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p>
          量潮健康官网（site 骨架——React + Vite）
        </p>
      </div>
    </>
  )
}

export default App
