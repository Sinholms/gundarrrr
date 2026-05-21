import "dotenv/config";
import express from "express";
import cors from "cors";
import midtransClient from "midtrans-client";

const app = express();
const PORT = process.env.PORT || 3000;

// ---------------------------------------------------------------------------
// Middleware
// ---------------------------------------------------------------------------
app.use(cors());
app.use(express.json());

// ---------------------------------------------------------------------------
// Midtrans Snap client (Sandbox)
// ---------------------------------------------------------------------------
const snap = new midtransClient.Snap({
  isProduction: process.env.MIDTRANS_IS_PRODUCTION === "true",
  serverKey: process.env.MIDTRANS_SERVER_KEY,
  clientKey: process.env.MIDTRANS_CLIENT_KEY,
});

// ---------------------------------------------------------------------------
// Routes
// ---------------------------------------------------------------------------

// Health check
app.get("/", (_req, res) => {
  res.json({ status: "ok", service: "WessLess Payment API" });
});

// Create a Snap transaction
app.post("/api/payments/create", async (req, res) => {
  try {
    const { order_id, gross_amount, items, customer_name } = req.body;

    const parameter = {
      transaction_details: {
        order_id,
        gross_amount,
      },
      item_details: items,
      customer_details: {
        first_name: customer_name,
      },
    };

    const transaction = await snap.createTransaction(parameter);

    res.json({
      success: true,
      token: transaction.token,
      redirect_url: transaction.redirect_url,
    });
  } catch (error) {
    console.error("Payment creation error:", error.message);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Midtrans webhook / notification handler
app.post("/api/payments/notification", async (req, res) => {
  try {
    const notification = await snap.transaction.notification(req.body);

    const {
      transaction_status: transactionStatus,
      fraud_status: fraudStatus,
      order_id: orderId,
      payment_type: paymentType,
    } = notification;

    console.log(
      `[Notification] Order ${orderId} | Status: ${transactionStatus} | Fraud: ${fraudStatus} | Payment: ${paymentType}`
    );

    // In production you would update your database here based on the status.

    res.status(200).json({ message: "OK" });
  } catch (error) {
    console.error("Notification error:", error.message);
    res.status(500).json({ error: error.message });
  }
});

// Check transaction status
app.get("/api/payments/:orderId/status", async (req, res) => {
  try {
    const status = await snap.transaction.status(req.params.orderId);
    res.json(status);
  } catch (error) {
    console.error("Status check error:", error.message);
    res.status(500).json({ error: error.message });
  }
});

// ---------------------------------------------------------------------------
// Start server
// ---------------------------------------------------------------------------
app.listen(PORT, () => {
  console.log(`WessLess Payment API running on port ${PORT}`);
});
