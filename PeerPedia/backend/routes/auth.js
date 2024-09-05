const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require("../models/user");

router.post('/signup', async (req, res) => {
    const { username, firstName, lastName, dpLink, password } = req.body;
    if (await User.findOne({ username })) {
        res.status(201)
            .json({
                success: false,
                userExist: true,
                data: {}
            });
        return;
    }

    try {
        let hashedPassword;
        try {
            const salt = await bcrypt.genSalt();
            hashedPassword = await bcrypt.hash(password, salt);
        } catch (error) {
            console.log("Error occured while encrypting password : " + error);
            res.sendStatus(500);
        }
        await User(
            {
                username,
                dpLink,
                firstName,
                lastName,
                password: hashedPassword,
            }).save();
    } catch (error) {
        console.log("Error occured while saving User : " + error);
        res.sendStatus(500);
    }
    let token;
    try {
        token = jwt.sign({ username, firstName, lastName, dpLink }, process.env.SECRET_KEY_JWT);
    } catch (error) {
        console.log("Error occured while creating token : " + error);
    }

    res.status(201)
        .json({
            success: true,
            userExist: false,
            data: {
                username,
                firstName,
                lastName,
                token,
            }
        });

});


router.post('/login', (req, res) => {
    const { username, password } = req.body;
    User.findOne({ username }).then((user) => {
        if (!user) {
            res.status(201)
                .json({
                    success: false,
                    data: {}
                });
            return;
        }
        bcrypt.compare(password, user.password).then((match) => {
            if (match) {
                try {
                    token = jwt.sign({ username, firstName: user.firstName, lastName: user.lastName,dpLink: user.dpLink }, process.env.SECRET_KEY_JWT);
                } catch (error) {
                    console.log("Error occured while creating token : " + error);
                }

                res.status(201)
                    .json({
                        success: true,
                        data: {
                            username,
                            firstName: user.firstName,
                            lastName: user.lastName,
                            dpLink: user.dpLink,
                            token: token,
                        }
                    });

            } else {
                res.status(201)
                    .json({
                        success: false,
                        data: {}
                    });
            }
        }).catch((error) => {
            console.log("Error occured while bcrypt compare : " + error);
            res.sendStatus(500);
        });

    });

});


router.get('/checklogin', (req, res) => {
    const token = req.headers.authorization.split(" ")[1];
    if (!token) {
        res.status(201)
            .json({
                success: false,
            });
    } else {
        const decodedToken = jwt.verify(token,
            process.env.SECRET_KEY_JWT);
        res.status(201)
            .json({
                success: true,
                data: {
                    username: decodedToken.username,
                    firstName: decodedToken.firstName,
                    lastName: decodedToken.lastName,
                    dpLink: decodedToken.dpLink,
                }
            });
    }

});

module.exports = router;