/*!
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
