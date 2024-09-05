const express = require('express');

const router = express.Router();
const Group = require("../models/group");

router.post("/add", async (req, res) => {
    const { name, admins, subjects, description } = req.body;
    console.log(req.body);
    if (await Group.findOne({ name })) {
        res.status(201)
            .json({
                success: false,
                groupExist: true,
            });
        return;
    }

    Group({
        name,
        description,
        admins,
        subjects,
    }).save();

    res.status(500)
        .json({
            success: true,
            groupExist: false,
        })

});

router.post("/delete", async (req, res) => {
    const { name, username } = req.body;
    const group = await Group.findOne({ name })
    if (!group) {
        console.log("group missing");
        res.status(201)
            .json({
                success: false,
                groupExist: false,
                message: "Group Not Found",

            });
        return;

    }
    if (group.admins.includes(username)) {
        if (await Group.findOneAndDelete({ name })) {
            res.status(500)
                .json({
                    success: true,
                    groupExist: true,
                    message: "Group Deleted",
                });
            return;
        }


    } else {
        console.log("not admin");
        res.status(201)
            .json({
                success: false,
                groupExist: true,
                message: "You are not the admin of group",

            })
    }

});
router.post("/update", async (req, res) => {
    const { name, newGroupName, newDescription, username } = req.body;

    try {
        const group = await Group.findOne({ name });
        if (!group) {
            console.log("group missing");
            return res.status(404).json({
                success: false,
                groupExist: false,
                message: "Group Not Found",
            });
        }

        if (!group.admins.includes(username)) {
            console.log("not admin");
            return res.status(403).json({
                success: false,
                groupExist: true,
                message: "You are not the admin of the group",
            });
        }

        const updatedGroup = await Group.findOneAndUpdate(
            { name },
            { name: newGroupName, description: newDescription },
            { new: true }
        );

        if (!updatedGroup) {
            console.log("failed to update group");
            return res.status(500).json({
                success: false,
                groupExist: true,
                message: "Failed to update group",
            });
        }

        res.status(200).json({
            success: true,
            groupExist: true,
            message: "Group updated successfully",
        });
    } catch (error) {
        console.error("Error updating group:", error);
        res.status(500).json({
            success: false,
            groupExist: true,
            message: "Internal server error",
        });
    }
});





router.post("/deleteSub", async (req, res) => {
    const { groupName, subName, username } = req.body;
    const group = await Group.findOne({ name: groupName })
    if (!group) {
        console.log("group missing");
        res.status(201)
            .json({
                success: false,
                groupExist: false,
                message: "Group Not Found",

            });
        return;

    }
    const sub = group.subjects.find(sub => { return sub.name == subName; });
    if (!sub) {
        res.status(201)
            .json({
                success: false,
                groupExist: false,
                message: "Subject Not Found",

            });
        return;
    }

    if (sub.admins.includes(username)) {
        const subIndex = group.subjects.findIndex(sub => sub.name === subName);
        if (group.subjects.splice(subIndex, 1).length > 0) {
            await group.save();
            res.status(500)
                .json({
                    success: true,
                    groupExist: true,
                    message: "Sub Deleted",
                });
            return;
        }



    } else {
        console.log("not admin");
        res.status(201)
            .json({
                success: false,
                groupExist: true,
                message: "You are not the admin of group",

            })
    }
});

router.post("/deleteNote", async (req, res) => {


    const { groupName, noteName, subName, username } = req.body;
    const group = await Group.findOne({ name: groupName })
    if (!group) {
        console.log("group missing");
        res.status(201)
            .json({
                success: false,
                groupExist: false,
                message: "Group Not Found",

            });
        return;

    }
    const sub = group.subjects.find(sub => { return sub.name == subName; });
    if (!sub) {
        res.status(201)
            .json({
                success: false,
                groupExist: false,
                message: "Subject Not Found",

            });
        return;
    }
    const note = sub.notes.find(note => { return note.name == noteName; });
    if (!note) {
        res.status(201)
            .json({
                success: false,
                groupExist: false,
                message: "Note Not Found",

            });
        return;
    }

    if (note.admins.includes(username)) {
        const noteIndex = sub.notes.findIndex(note => note.name === noteName);
        if (sub.notes.splice(noteIndex, 1).length > 0) {
            await group.save();
            res.status(500)
                .json({
                    success: true,
                    groupExist: true,
                    message: "Note Deleted",
                });
            return;
        }



    } else {
        console.log("not admin");
        res.status(201)
            .json({
                success: false,
                groupExist: true,
                message: "You are not the admin of Note",

            })
    }
});


router.post("/deleteQp", async (req, res) => {
    ;
    const { groupName, qpName, subName, username } = req.body;
    const group = await Group.findOne({ name: groupName })
    if (!group) {
        console.log("group missing");
        res.status(201)
            .json({
                success: false,
                groupExist: false,
                message: "Group Not Found",

            });
        return;

    }
    const sub = group.subjects.find(sub => { return sub.name == subName; });
    if (!sub) {
        res.status(201)
            .json({
                success: false,
                groupExist: false,
                message: "Subject Not Found",

            });
        return;
    }
    const qp = sub.questionPapers.find(qp => { return qp.name == qpName; });
    if (!qp) {
        res.status(201)
            .json({
                success: false,
                groupExist: false,
                message: "Question Paper Not Found",

            });
        return;
    }

    if (qp.admins.includes(username)) {
        const qpIndex = sub.questionPapers.findIndex(qp => qp.name === qpName);
        if (sub.questionPapers.splice(qpIndex, 1).length > 0) {
            await group.save();
            res.status(500)
                .json({
                    success: true,
                    groupExist: true,
                    message: "Question Paper Deleted",
                });
            return;
        }



    } else {
        console.log("not admin");
        res.status(201)
            .json({
                success: false,
                groupExist: true,
                message: "You are not the admin of Note",

            })
    }
});


router.get("/get", async (req, res) => {
    const groups = await Group.find({}).limit(100);
    if (!groups) {
        res.status(201).json({
            "success": false
        });
        return;
    }
    res.status(500).json({
        "groups": groups.map((e) => {
            return {
                "name": e.name,
                "description": e.description,
                "admins": e.admins,
                "subjects": e.subjects,
            };
        })
    });
})


router.post("/searchGroup", async (req, res) => {
    const { groupName } = req.body;
    const groups = await Group.find({
        name: { $regex: new RegExp(groupName, 'i') },
    }).limit(100);
    if (!groups) {
        res.status(201).json({
            "success": false
        });
        return;
    }
    res.status(500).json({
        "groups": groups.map((e) => {
            return {
                "name": e.name,
                "admins": e.admins,
                "subjects": e.subjects,
            };
        })
    });
})

router.post("/addsub", async (req, res) => {
    const { groupName, subject, admin } = req.body;
    try {

        const group = await Group.findOne({ name: groupName });
        if (!group) {
            console.log("group not exist");
            return;
        }
        group.subjects.push({ name: subject.name, admins: [admin], notes: [], questionPapers: [] });
        await group.save();
        res.status(500).json({
            "success": true,
            "data": ""
        });
    } catch (e) {
        console.log("error occured while adding sub to gorup : " + e);
        res.status(500).json({
            "success": false,
            "data": "error occured while adding sub to gorup",
        });
    }
})


router.post("/addMat", async (req, res) => {
    const { groupName, subName, materialName, admin, materialType, link, link2 } = req.body;
    try {

        const group = await Group.findOne({ name: groupName });

        if (!group) {
            console.log("group not exist");
            return;
        }
        const sub = group.subjects.find(sub => { return sub.name == subName; });
        if (!sub) {
            console.log("sub not exist" + subName);
            return;
        }

        if (materialType == "note") {

            sub.notes.push({ name: materialName, admins: [admin], link: link, likedUserNames: [] });
            await group.save();
            res.status(500).json({
                "success": true,
                "data": ""
            });
        } else if (materialType == "qpak") {
            sub.questionPapers.push({ name: materialName, admins: [admin], linkQp: link, linkAk: link2, likedUserNames: [] });
            await group.save();
            res.status(500).json({
                "success": true,
                "data": ""
            });
        }
        else {
            console.log((materialType));
        }
    } catch (e) {
        console.log("error occured while adding sub to gorup : " + e);
        res.status(500).json({
            "success": false,
            "data": "error occured while adding sub to gorup",
        });
    }
})



router.post("/like", async (req, res) => {
    const { groupName, subName, materialName, username, matType } = req.body;
    try {

        const group = await Group.findOne({ name: groupName });
        if (!group) {
            console.log("group not exist");
            return;
        }
        const sub = group.subjects.find(sub => sub.name === subName);
        if (!sub) {
            console.log("sub not exist");
            return;
        }
        if (matType == "notes") {
            const note = sub.notes.find(mat => mat.name === materialName);
            if (!note) {
                console.log("note not exist");
                return;
            }

            const userIndex = note.likedUserNames.indexOf(username);
            if (userIndex === -1) {

                note.likedUserNames.push(username);
            } else {
                note.likedUserNames.splice(userIndex, 1);
            }
        } else {
            const qp = sub.questionPapers.find(mat => mat.name === materialName);
            if (!qp) {
                console.log("qp not exist");
                return;
            }

            const userIndex = qp.likedUserNames.indexOf(username);
            if (userIndex === -1) {

                qp.likedUserNames.push(username);
            } else {
                qp.likedUserNames.splice(userIndex, 1);
            }
        }


        await group.save();
        res.status(500).json({
            "success": true,
            "data": ""
        });

    } catch (e) {
        console.log("error occured while liking : " + e);
        res.status(500).json({
            "success": false,
            "data": "error occured while liking",
        });
    }
})

router.post("/comment", async (req, res) => {
    const { groupName, subName, materialName, materialType, username, comment, pageNo, } = req.body;
    try {

        const group = await Group.findOne({ name: groupName });
        if (!group) {
            console.log("group not exist");
            return;
        }
        const sub = group.subjects.find(sub => sub.name === subName);
        if (!sub) {
            console.log("sub not exist");
            return;
        }
        if (materialType == "notes") {
            const note = sub.notes.find(mat => mat.name === materialName);
            if (!note) {
                console.log("mat not exist");
                return;
            }
            if (pageNo >= 0) {
                note.inPageComments.push({ pageNo, inPageComment: { username, comment }, ak: 0 })
                await group.save();
                res.status(500).json({
                    "success": true,
                    "data": ""
                });
            } else {
                note.comments.push({ username, comment })
                await group.save();
                res.status(500).json({
                    "success": true,
                    "data": ""
                });
            }
        } else if(materialType == "qp") {
            const qp = sub.questionPapers.find(mat => mat.name === materialName);
            if (!qp) {
                console.log("qp not exist");
                return;
            }
            if (pageNo >= 0) {
                qp.inPageComments.push({ pageNo, inPageComment: { username, comment }, ak: 0 })
                await group.save();
                res.status(500).json({
                    "success": true,
                    "data": ""
                });
            } else {
                qp.comments.push({ username, comment })
                await group.save();
                res.status(500).json({
                    "success": true,
                    "data": ""
                });
            }
        }else if( materialType == "ak"){
            const qp = sub.questionPapers.find(mat => mat.name === materialName);
            if (!qp) {
                console.log("qp not exist");
                return;
            }
            if (pageNo >= 0) {
                qp.inPageComments.push({ pageNo, inPageComment: { username, comment }, ak: 1 })
                await group.save();
                res.status(500).json({
                    "success": true,
                    "data": ""
                });
            } else {
                qp.comments.push({ username, comment })
                await group.save();
                res.status(500).json({
                    "success": true,
                    "data": ""
                });
            }
        }



    } catch (e) {
        console.log("error occured while adding comment : " + e);
        res.status(500).json({
            "success": false,
            "data": "error occured while adding comment",
        });
    }
})

router.post("/getComment", async (req, res) => {
    const { groupName, subName, materialName, materialType, pageNo } = req.body;

    try {

        const group = await Group.findOne({ name: groupName });
        if (!group) {
            console.log("group not exist");
            return;
        }
        const sub = group.subjects.find(sub => sub.name === subName);
        if (!sub) {
            console.log("sub not exist");
            return;
        }
        if (materialType == "notes") {

            const note = sub.notes.find(mat => mat.name === materialName);
            if (!note) {
                console.log("sub not exist");
                return;
            }
            if (pageNo >= 0) {
                const inPageComments = note.inPageComments.filter(inPageComment => inPageComment.pageNo === pageNo);
                if (!inPageComments) {
                    console.log("inPageComment not exist");
                    return;
                }
                res.status(500).json({
                    "comments": inPageComments.map((e) => {
                        return {
                            "username": e.inPageComment.username,
                            "comment": e.inPageComment.comment,

                        };
                    })
                });
            }
            else {
                res.status(500).json({
                    "comments": note.comments.map((e) => {

                        return {
                            "username": e.username,
                            "comment": e.comment,

                        };
                    })
                });
            }
        } else if (materialType == "qp") {

            const qp = sub.questionPapers.find(mat => mat.name === materialName);
            if (!qp) {
                console.log("qp not exist");
                return;
            }
            if (pageNo >= 0) {
                var inPageComments = qp.inPageComments.filter(inPageComment => inPageComment.pageNo === pageNo);
                inPageComments = inPageComments.filter(inPageComment => inPageComment.ak != 1);
               
                if (!inPageComments) {
                    console.log("inPageComment not exist");
                    return;
                }
                res.status(500).json({
                    "comments": inPageComments.map((e) => {
                        return {
                            "username": e.inPageComment.username,
                            "comment": e.inPageComment.comment,

                        };
                    })
                });
            }
            else {
                res.status(500).json({
                    "comments": qp.comments.map((e) => {

                        return {
                            "username": e.username,
                            "comment": e.comment,

                        };
                    })
                });
            }
        }else if (materialType == "ak") {

            const qp = sub.questionPapers.find(mat => mat.name === materialName);
            if (!qp) {
                console.log("qp not exist");
                return;
            }
            if (pageNo >= 0) {
                const inPageComments = qp.inPageComments.filter(inPageComment => inPageComment.pageNo === pageNo);
                if (!inPageComments) {
                    console.log("inPageComment not exist");
                    return;
                }
                const inPageCommentsAk = inPageComments.filter(inPageComment => inPageComment.ak === 1);
                if (!inPageCommentsAk) {
                    console.log("inPageComment not exist");
                    return;
                }
                res.status(500).json({
                    "comments": inPageCommentsAk.map((e) => {
                        return {
                            "username": e.inPageComment.username,
                            "comment": e.inPageComment.comment,

                        };
                    })
                });
            }
            else {
                res.status(500).json({
                    "comments": qp.comments.map((e) => {

                        return {
                            "username": e.username,
                            "comment": e.comment,

                        };
                    })
                });
            }
        }

    } catch (e) {
        console.log("error occured while adding sub to gorup : " + e);
        res.status(500).json({
            "success": false,
            "data": "error occured while adding sub to gorup",
        });
    }
})



module.exports = router;