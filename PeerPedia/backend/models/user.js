const mongoose = require("mongoose");

UserSchema = new mongoose.Schema({
    username: {type:String, required:true},
    password: {type:String, required:true},
    dpLink: {type:String, required:true},
    firstName: {type:String, required:true},
    lastName: {type:String, required:true},
},{timestamps: true});

module.exports = mongoose.model('User', UserSchema);