var config = {
  apiKey: "$AUTH_APIKEY",
  authDomain: "$AUTH_DOMAIN",
};
firebase.initializeApp(config);

var uiConfig = {
  credentialHelper: firebaseui.auth.CredentialHelper.NONE,
  signInOptions: [
    firebase.auth.EmailAuthProvider.PROVIDER_ID
  ]
};

var ui = new firebaseui.auth.AuthUI(firebase.auth());

function signedIn(user) {
  document.getElementById('signedOut').style.display = 'none';
  document.getElementById('userEmail').innerText = user.email;
  document.getElementById('signedIn').style.display = 'block';
  user.getIdToken().then(function(token) {
    fetch('/api/secure.json', {
      headers: {
        Authorization: 'Bearer ' +  token
      }
    }).then(function(response) {
      return response.json();
    }).then(function(responseJson) {
      document.getElementById('message').innerText = responseJson.message;
    }).catch(function(error) {
      console.error('Error: ', error);
    });
  });
}

function signedOut() {
  document.getElementById('signedIn').style.display = 'none';
  document.getElementById('message').innerText = '';
  document.getElementById('userEmail').innerText = '';
  document.getElementById('signedOut').style.display = 'block';
  ui.start('#firebaseui-auth-container', uiConfig);
}

window.addEventListener('load', function() {
  document.getElementById('signout').onclick = function() {
    firebase.auth().signOut();
  }
  firebase.auth().onAuthStateChanged(function(user) {
    if (user) {
      signedIn(user);
    } else {
      signedOut();
    }
  });
});
