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

'use strict';

const test = require(`ava`);
const path = require(`path`);
const utils = require(`@google-cloud/nodejs-repo-tools`);

const cwd = path.join(__dirname, `../`);
const requestObj = utils.getRequest({cwd: cwd});

const errorType = 'text/html; charset=utf-8';

test.serial.cb(`should fail on a Bad Request with an empty payload`, (t) => {
  requestObj
      .get(`/diagram.png`)
      .type('text')
      .expect(400)
      .expect('Content-Type', errorType)
      .expect((res) => {
        if (res.headers['cache-control']) {
          throw new Error('Found cache header on uncached response');
        }
      })
      .end(t.end);
});

test.serial.cb(`should fail on a Bad Request with an invalid payload`, (t) => {
  requestObj
      .get(`/diagram.png`)
      .type('text')
      .query({dot: `digraph`})
      .expect(400)
      .expect('Content-Type', errorType)
      .expect((res) => {
        if (res.headers['cache-control']) {
          throw new Error('Found cache header on uncached response');
        }
      })
      .end(t.end);
});

test.serial.cb(`should succeed with a valid DOT description`, (t) => {
  requestObj
      .get(`/diagram.png`)
      .type(`text`)
      .query({dot: `digraph G { A -> {B, C, D} -> {F} }`})
      .expect(200)
      .expect('Content-Type', 'image/png')
      .expect('Cache-Control', 'public, max-age=86400')
      .end(t.end);
});
