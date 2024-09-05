const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');


require('dotenv').config();


const app = express();

app.use(express.json());
app.use(cors());

const authRoutes = require('./routes/auth');
const groupRoutes = require('./routes/group');

app.use('/auth' ,authRoutes);
app.use('/group' ,groupRoutes);
mongoose.connect(process.env.MONGO_KEY)
.then(()=>{
    console.log("Mongoose connected");
    app.listen(process.env.PORT || 3000,()=>{
        console.log("Server listening to port 3000");
    })
})
.catch((e)=>{
    console.log("Error occured while connecting mongoose: : "+e);
})
