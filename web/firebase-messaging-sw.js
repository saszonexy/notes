importScripts(
  "https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js"
);

firebase.initializeApp({
  apiKey: "AIzaSyDpAqrMsKI9HHKiQP7GqoicOhDZs5gAy5M",
  authDomain: "notes-flutter-86dde.firebaseapp.com",
  projectId: "notes-flutter-86dde",
  storageBucket: "notes-flutter-86dde.appspot.com",
  messagingSenderId: "774560425656",
  appId: "1:774560425656:web:19264e329250565bcb764d",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  console.log("Received background message ", payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png",
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
