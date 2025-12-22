import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import * as djwt from "https://deno.land/x/djwt@v3.0.1/mod.ts"

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

Deno.serve(async (req) => {
  try {
    const body = await req.json();
    const { record, old_record } = body;

    // --- LOGIKA VALIDASI (PENTING) ---
    // Agar INSERT (order baru) memicu notif, kita cek jika old_record kosong
    const isInsert = !old_record;
    const isStatusChanged = old_record && record.status !== old_record.status;

    if (!isInsert && !isStatusChanged) {
      return new Response("No status change detected", { status: 200 });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Ambil data profile penerima
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('fcm_token, name')
      .eq('id', record.user_id)
      .single();

    if (profileError || !profile?.fcm_token) {
      return new Response("User has no FCM token or profile not found", { status: 200 });
    }

    // --- AMBIL KONTEN NOTIFIKASI LAUNDRY ---
    const { title, body: notificationBody } = getNotificationContent(record.status, profile.name);

    // 1. Simpan Log ke Database
    await supabase.from('notification_logs').insert({
      user_id: record.user_id,
      title: title,
      body: notificationBody,
      order_id: record.id,
      type: 'push'
    });

    // 2. Proses Kirim FCM
    const fcmResult = await sendFCMNotification(title, notificationBody, record, profile.fcm_token);

    return new Response(JSON.stringify({ success: true, result: fcmResult }), { 
      status: 200,
      headers: { "Content-Type": "application/json" }
    });

  } catch (err) {
    console.error("Error:", err.message);
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
});

/**
 * Pemetaan status ke pesan notifikasi Laundry
 */
function getNotificationContent(status, name) {
  const userName = name || 'Pelanggan';
  const messages = {
    'pending': {
      title: "Pesanan Diterima ✨",
      body: `Halo ${userName}, pesananmu sudah masuk. Tunggu konfirmasi kami ya!`
    },
    'processing': {
      title: "Sedang Diproses 🧼",
      body: "Laundry kamu sedang kami siapkan untuk masuk antrean."
    },
    'washing': {
      title: "Lagi Dicuci 🌊",
      body: "Baju-baju kamu sedang dibersihkan biar wangi merona!"
    },
    'completed': {
      title: "Sudah Kering Nih! ✨",
      body: "Laundry sudah bersih dan rapi. Siap diambil atau diantar!"
    },
    'picked_up': {
      title: "Sudah Selesai 🏠",
      body: "Terima kasih sudah menggunakan jasa laundry kami!"
    },
    'cancelled': {
      title: "Pesanan Dibatalkan ❌",
      body: "Pesananmu telah dibatalkan. Hubungi kami jika ada kendala."
    }
  };

  return messages[status] || {
    title: "Update Pesanan Laundry 🧺",
    body: `Status pesananmu saat ini: ${status}`
  };
}

/**
 * Logika Auth Google & Pengiriman FCM v1
 */
async function sendFCMNotification(title, body, record, fcmToken) {
  const clientEmail = Deno.env.get('FIREBASE_CLIENT_EMAIL')!;
  const privateKeyRaw = Deno.env.get('FIREBASE_PRIVATE_KEY')!.replace(/\\n/g, '\n');
  const projectId = Deno.env.get('FIREBASE_PROJECT_ID')!;

  const pemContents = privateKeyRaw.replace(/-----BEGIN PRIVATE KEY-----|-----END PRIVATE KEY-----|\s/g, "");
  const binary = atob(pemContents);
  const buffer = new Uint8Array(binary.length).map((_, i) => binary.charCodeAt(i)).buffer;

  const key = await crypto.subtle.importKey(
    "pkcs8", buffer, { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["sign"]
  );

  const now = Math.floor(Date.now() / 1000);
  const jwt = await djwt.create({ alg: "RS256", typ: "JWT" }, {
    iss: clientEmail,
    sub: clientEmail,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
    scope: "https://www.googleapis.com/auth/cloud-platform",
  }, key);

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  
  const { access_token } = await tokenRes.json();

  const fcmRes = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${access_token}`,
    },
    body: JSON.stringify({
      message: {
        token: fcmToken,
        notification: { title, body },
        data: {
          order_id: String(record.id),
          status: record.status,
          type: "ORDER_UPDATE"
        },
        android: {
          notification: {
            channel_id: "channel_notification",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            sound: "blink.mp3"
          }
        }
      },
    }),
  });

  return await fcmRes.json();
}