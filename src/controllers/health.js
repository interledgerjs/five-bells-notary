'use strict'

const model = require('../models/health')

/**
 * @api {get} /health Get server health status
 * @apiName GetHealth
 * @apiGroup Health
 * @apiVersion 1.0.0
 *
 * @apiDescription This endpoint will perform a quick self-check to ensure the
 *   server is still operating correctly.
 *
 * @returns {void}
 */
exports.getResource = function * health () {
  this.body = yield model.getDbHealth()
}
