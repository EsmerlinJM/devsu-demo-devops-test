import sequelize from './shared/database/database.js'
import { usersRouter } from "./users/router.js"
import express from 'express'
import * as dotenv from 'dotenv'
dotenv.config()

const app = express()
const PORT = process.env.PORT || 8000

sequelize.sync({ force: true }).then(() => console.log('db is ready'))

app.use(express.json())
app.use('/api/users', usersRouter)
app.use('/ping', (req, res) => { res.status(200).json(`pong`)})

const server = app.listen(PORT, () => {
    console.log('Server running on port PORT', PORT)
})

export { app, server }