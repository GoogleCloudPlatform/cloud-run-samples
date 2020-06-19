const {google} = require('googleapis');
const metadata = require('gcp-metadata');
const {SecretManagerServiceClient} = require('@google-cloud/secret-manager');
const iam = google.iam('v1');
const pkg = require('./package.json');

const {SECRET_NAME, RUNNER_SERVICE_ACCOUNT} = process.env;
requireEnvVar('SECRET_NAME', SECRET_NAME);
requireEnvVar('RUNNER_SERVICE_ACCOUNT', SECRET_NAME);

exports.locksmith = async (req, res) => {
  let key;
  try {
    key = await createServiceAccountKeys();
    console.log(`Created service account key.`);
  } catch (e) {
    throw new Error(`failed creating service account keys: ${e}`);
  }

  try {
    const keyForGcloud = Buffer.from(key.privateKeyData, 'base64');
    const [version] = await addSecretVersion(keyForGcloud);
    console.log(`Added secret version ${version.name}`);
    res.status(202);
  } catch (e) {
    try {
      // Could not save key so invalidate it.
      await deleteServiceAccountKey(key.name);
    } catch (e2) {
      throw new Error(`could not update secret or delete the key: ${e2}`);
    }
    throw new Error(`could not update secret version: ${e}`);
  }
};

let authClient;
async function authorize() {
  if (!authClient) {
    const auth = new google.auth.GoogleAuth({
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
    });

    // Acquire an auth client, and bind it to all future calls
    const authClient = await auth.getClient();
    google.options({auth: authClient});
  }
}

async function createServiceAccountKeys() {
  await authorize();
  const project = await getProject();
  const serviceAccountEmail = `${RUNNER_SERVICE_ACCOUNT}@${project}.iam.gserviceaccount.com`;
  const res = await iam.projects.serviceAccounts.keys.create({
    name: `projects/${project}/serviceAccounts/${serviceAccountEmail}`,
  });

  return res.data;
}

async function deleteServiceAccountKey(name) {
  await authorize();
  const res = await iam.projects.serviceAccounts.keys.delete({name});
  return res.data;
}

let secretClient;
// Example: projects/PROJECT_ID/secrets/SECRET_NAME
let secretResourceName;

// Create a new version of the secret from the payload.
async function addSecretVersion(data) {
  if (!secretClient) secretClient = new SecretManagerServiceClient();
  if (!secretResourceName) {
    const project = await getProject();
    secretResourceName = `projects/${project}/secrets/${SECRET_NAME}`;
  }
  return secretClient.addSecretVersion({
    parent: secretResourceName,
    payload: {
      data: data,
    },
  });
}

async function getProject() {
  let project = process.env.GOOGLE_CLOUD_PROJECT;
  if (!project) project = await metadata.project('project-id');
  if (!project) {
    throw new Error(
      `Could not determine a Project ID. Try re-running with $GOOGLE_CLOUD_PROJECT.`
    );
  }
  return project;
}

function requireEnvVar(name, value) {
  if (!value)
    throw new Error(`${pkg.name}: Must set "${name}" environment variable`);
  else console.log(`${pkg.name}: using ${name} '${value}'`);
}

exports.tokenMinter = exports.locksmith;