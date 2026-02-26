const fs = require("fs");
const path = require("path");
const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const admin = require("firebase-admin");

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json({ limit: "2mb" }));

const PORT = Number(process.env.PORT || 4000);
const ADMIN_API_KEY = process.env.ADMIN_API_KEY || "";
const TOKENS_FILE = path.join(__dirname, "device_tokens.json");

function loadTokens() {
  try {
    if (!fs.existsSync(TOKENS_FILE)) return [];
    const raw = fs.readFileSync(TOKENS_FILE, "utf8");
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : [];
  } catch (_) {
    return [];
  }
}

function saveTokens(tokens) {
  fs.writeFileSync(TOKENS_FILE, JSON.stringify(tokens, null, 2), "utf8");
}

function requireAdminKey(req, res, next) {
  if (!ADMIN_API_KEY) return next();
  const incoming = req.headers["x-admin-key"];
  if (incoming !== ADMIN_API_KEY) {
    return res.status(401).json({ ok: false, error: "Unauthorized." });
  }
  return next();
}

function initFirebaseAdmin() {
  if (admin.apps.length > 0) return;

  const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
  if (!serviceAccountPath) {
    throw new Error(
      "FIREBASE_SERVICE_ACCOUNT_PATH is missing in environment variables."
    );
  }
  const absolutePath = path.isAbsolute(serviceAccountPath)
    ? serviceAccountPath
    : path.join(process.cwd(), serviceAccountPath);
  const serviceAccount = require(absolutePath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

app.get("/health", (_, res) => {
  res.json({ ok: true, service: "university-notifications-api" });
});

app.post("/devices/register", (req, res) => {
  const token = (req.body?.token || "").toString().trim();
  const userRoll = (req.body?.userRoll || "").toString().trim();
  const platform = (req.body?.platform || "android").toString().trim();

  if (!token) {
    return res.status(400).json({ ok: false, error: "Token is required." });
  }

  const tokens = loadTokens();
  const existingIndex = tokens.findIndex((item) => item.token === token);
  const record = {
    token,
    userRoll,
    platform,
    updatedAt: new Date().toISOString(),
  };

  if (existingIndex >= 0) {
    tokens[existingIndex] = record;
  } else {
    tokens.push(record);
  }

  saveTokens(tokens);
  return res.json({ ok: true });
});

app.post("/admin/notifications/send", requireAdminKey, async (req, res) => {
  try {
    initFirebaseAdmin();

    const title = (req.body?.title || "").toString().trim();
    const body = (req.body?.body || "").toString().trim();
    const topic = (req.body?.topic || "all_students").toString().trim();
    const data = typeof req.body?.data === "object" && req.body?.data !== null
      ? req.body.data
      : {};
    const userRoll = (req.body?.userRoll || "").toString().trim();

    if (!title || !body) {
      return res
        .status(400)
        .json({ ok: false, error: "title and body are required." });
    }

    if (userRoll) {
      const tokens = loadTokens()
        .filter((t) => t.userRoll === userRoll)
        .map((t) => t.token);
      if (tokens.length === 0) {
        return res
          .status(404)
          .json({ ok: false, error: "No device tokens found for userRoll." });
      }
      const response = await admin.messaging().sendEachForMulticast({
        tokens,
        notification: { title, body },
        data: Object.fromEntries(
          Object.entries(data).map(([k, v]) => [k, String(v)])
        ),
      });
      return res.json({ ok: true, mode: "multicast", response });
    }

    const response = await admin.messaging().send({
      topic,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
    });
    return res.json({ ok: true, mode: "topic", messageId: response });
  } catch (error) {
    return res.status(500).json({
      ok: false,
      error: error instanceof Error ? error.message : "Unknown error.",
    });
  }
});

app.listen(PORT, () => {
  console.log(`University Notifications API running on port ${PORT}`);
});
