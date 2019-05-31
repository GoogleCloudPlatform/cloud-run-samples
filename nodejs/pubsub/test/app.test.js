// Copyright 2019, Google LLC.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// NOTE:
// This app can only be fully tested when deployed, because
// Pub/Sub requires a live endpoint URL to hit. Nevertheless,
// these tests mock it and partially test it locally.

'use strict'

const test = require(`ava`)
const path = require(`path`)
const utils = require(`@google-cloud/nodejs-repo-tools`)
const uuid = require(`uuid`)
const sinon = require(`sinon`)

const cwd = path.join(__dirname, `../`)
const requestObj = utils.getRequest({cwd: cwd})
const consoleLog = sinon.stub(console, 'log')

test.serial.cb(`should fail on a Bad Request with an empty payload`, t => {
  requestObj
    .post('/')
    .type('json')
    .send('')
    .expect(400)
    .end(t.end);
})

test.serial.cb(`should fail on a Bad Request with an invalid payload`, t => {
  requestObj
    .post('/')
    .type('json')
    .send({nomessage: 'invalid'})
    .expect(400)
    .end(t.end);
})

test.serial.cb(`should fail on a Bad Request with an invalid mimetype`, t => {
  requestObj
    .post('/')
    .type('text')
    .send('{message: true}')
    .expect(400)
    .end(t.end);
})

test.serial.cb(`should succeed with a minimally valid Pub/Sub Message`, t => {
  requestObj
    .post('/')
    .type('json')
    .send({message: true})
    .expect(204)
    .expect(() => consoleLog.calledWith(`Hello World!`))
    .end(t.end);
})

test.serial.cb(`should succeed with a populated Pub/Sub Message`, t => {
  const name = uuid.v4()
  const data = Buffer.from(name).toString(`base64`)

  requestObj
    .post('/')
    .type('json')
    .send({message: { data } })
    .expect(204)
    .expect(() => consoleLog.calledWith(`Hello ${name}!`))
    .end(t.end);
})
