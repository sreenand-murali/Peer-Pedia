const mongoose = require('mongoose');


const CommentSchema = new mongoose.Schema({
    username: { type: String, required: true },
    comment: { type: String, required: true }
}, { timestamps: true });

const InPageComment = new mongoose.Schema({
    pageNo: { type: Number, required: true },
    ak: { type: Number, required: true },
    inPageComment: { type: CommentSchema, required: true }
}, { timestamps: true });

const NoteSchema =  new mongoose.Schema({
    name: {type: String, required: true},
    admins: [{type: String, required: true}],
    link: {type: String, required: true},
    comments: [{type:CommentSchema, }],
    inPageComments: [{type:InPageComment, }],
    likedUserNames: [{type: String, }],
},{timestamps: true});

const QuestionPaperSchema =  new mongoose.Schema({
    name: {type: String, required: true},
    admins: [{type: String, required: true}],
    linkQp: {type: String, required: true},
    linkAk: {type: String, },
    comments: [{type:CommentSchema, }],
    inPageComments: [{type:InPageComment, }],
    likedUserNames: [{type: String, }],
},{timestamps: true});

const SubjectSchema =  new mongoose.Schema({
    name: {type: String, required: true},
    admins: [{type: String, required: true}],
    notes: [{type: NoteSchema, required: true}],
    questionPapers: [{type: QuestionPaperSchema, required: true}],
},{timestamps: true});
const GroupSchema =  new mongoose.Schema({
    name: {type: String, required: true},
    description: {type: String,},
    admins: [{type: String, required: true}],
    subjects : [{type: SubjectSchema, required: true}],
},{timestamps: true});

SubjectSchema.methods.sortNotesByLikes = function () {
    this.notes.sort((noteA, noteB) => {
        return noteB.likedUserNames.length - noteA.likedUserNames.length;
    });
};
SubjectSchema.methods.sortQpsByLikes = function () {
    this.questionPapers.sort((qpA, qpB) => {
        return qpB.likedUserNames.length - qpA.likedUserNames.length;
    });
};


SubjectSchema.pre('save', function (next) {
    this.sortNotesByLikes();
    this.sortQpsByLikes();

    next();
});


module.exports = mongoose.model('Group', GroupSchema);