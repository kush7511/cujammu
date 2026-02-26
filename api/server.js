require("dotenv").config();
const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");

const app = express();
app.use(cors());
app.use(express.json());

mongoose.connect(process.env.MONGO_URI);

const studentSchema = new mongoose.Schema({
  roll: { type: String, unique: true, required: true },
  name: String,
  fname: String,
  pnumber: Number,
  dob: Date,
  course: String,
  password: String, // hash in production
  profileImageBase64: { type: String, default: null },
  cgpa: Number,
  attendance: Number
}, { timestamps: true });

const Student = mongoose.model("Student", studentSchema);

app.post("/students", async (req, res) => {
  try {
    const created = await Student.create(req.body);
    res.status(201).json(created);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

app.get("/students/:roll", async (req, res) => {
  const student = await Student.findOne({ roll: req.params.roll });
  if (!student) return res.status(404).json({ error: "Not found" });
  res.json(student);
});

app.listen(3000, () => console.log("API running on :3000"));
