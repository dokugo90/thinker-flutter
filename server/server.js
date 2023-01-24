const express = require("express");
const cors = require('cors');
var multer = require('multer');
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
var upload = multer();
//const userPAge = require('client/src/user.js');
const app = express();
const router = express.Router();
const http = require('http');
const WebSocket = require('ws');

app.use(bodyParser.json()); 

// for parsing application/xwww-
app.use(bodyParser.urlencoded({ extended: true })); 
//form-urlencoded

// for parsing multipart/form-data
app.use(upload.array()); 
app.use(express.static('public'));

app.use(cors());

mongoose.connect("mongodb://localhost:27017/thinker", {
    useNewUrlParser: true,

});

const messageSchema = new mongoose.Schema({
    text_message: {
        type: String,
        required: true,
        validator: {
            validate: v => v.length >= 100,
            message: props => `${props.value} exceeds the maximuim characters required to send a message`
        }
    },
    name: {
        type: String,
        //min,
        //max,
        required: true,
        
    },
    image: {
        type: String,
        required: true,

    },
    date: {
        type: String,
        required: true
    }
})

const messageModel = mongoose.model("messages", messageSchema)

const dateTime = new Date();

const dateString = `${dateTime.getMonth() + 1}/${dateTime.getDate()}/${dateTime.getFullYear()}`

app.get("/messages", (req, res) => {
    messageModel.find(function(err, data) {
        if (err) {
            res.json(["error"])
            console.log(err)
        } else {
            res.json(data)
            console.log("Succesfully sent data", "to", req.hostname);
        }
    })
})

app.post("/send", (req, res) => {
    messageModel.create(
        {
            name: "test",
         text_message: req.body.message,
         date: dateString,
         image: "https://picsum.photos/204"
        }, (err, data) => {
            if (err) {
                console.log(err)
            } else {
                console.log(data)
            }
        }
        )

})


const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

wss.on('connection', (ws) => {
    ws.on('message', (message) => {
      console.log(`Received message: ${message}`);
      ws.send(`Echo: ${message}`);
    });
  });
  

setInterval(() => {
  messageModel.find({}, (err, data) => {
    if (err) {
      console.log(err);
    } else {
        server.emit('newData', data);
      
    }
  });
}, 5000);

server.listen(5000, () => {
  console.log('Listening on port 5000...');
});

